include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using Printf

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["dasucc", "alanjzamora", "alexxxxxrs", "korenns"]
const DISPLAY_ORDER = ["Anthony", "Alan", "Alexandra", "Koren"]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      lh.username,
      ag.genre,
      COUNT(*)  AS play_count
    FROM listening_history   lh
    JOIN artist_genres        ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
      AND EXTRACT(YEAR FROM lh.timestamp)::INT = 2025
    GROUP BY lh.username, ag.genre
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function genre_play_counts(df, username)
  sub = filter(r -> String(r.username) == username, df)
  result = Dict{String,Int}()
  for row in eachrow(sub)
    g = String(row.genre)
    result[g] = get(result, g, 0) + Int(row.play_count)
  end
  return collect(values(result))
end

function lorenz_curve(counts)
  sorted = sort(Float64.(counts))
  n = length(sorted)
  total = sum(sorted)
  cuml_plays = [0.0; cumsum(sorted) ./ total]
  cuml_genres = collect(range(0.0, 1.0, length=n + 1))
  return cuml_genres, cuml_plays
end

function gini_from_lorenz(cuml_genres, cuml_plays)
  n = length(cuml_genres) - 1
  area = sum(
    (cuml_genres[i+1] - cuml_genres[i]) * (cuml_plays[i+1] + cuml_plays[i]) / 2.0
    for i in 1:n
  )
  return 1.0 - 2.0 * area
end

function bottom_pct_share(cuml_genres, cuml_plays, p)
  idx = findfirst(x -> x >= p / 100.0, cuml_genres)
  idx === nothing && return NaN
  return cuml_plays[idx] * 100.0
end

function plot_lorenz(cuml_genres, cuml_plays, gini_val, title, fname)
  fig = Figure(size=(650, 620))
  ax = Axis(fig[1, 1],
    title=title,
    xlabel="Cumulative Share of Genres",
    ylabel="Cumulative Share of Plays",
    aspect=DataAspect(),
    limits=(0.0, 1.0, 0.0, 1.0),
  )

  band!(ax, cuml_genres, cuml_plays, cuml_genres, color=(:steelblue, 0.18))

  lines!(ax, [0.0, 1.0], [0.0, 1.0],
    color=:black, linestyle=:dash, linewidth=1.5, label="Perfect Equality")

  lines!(ax, cuml_genres, cuml_plays,
    color=Makie.wong_colors()[1], linewidth=2.5, label="Lorenz Curve")

  text!(ax, 0.04, 0.91,
    text="Gini = $(@sprintf("%.4f", gini_val))",
    fontsize=13,
    color=:black,
  )

  Legend(fig[2, 1], ax, orientation=:horizontal, tellwidth=false)

  save(fname, fig)
  println("  plot saved: $fname")
end

function print_stats(display_name, n, gini_val, cuml_genres, cuml_plays)
  println("$display_name - 2025")
  println("  n genres: $n")
  @printf "  Gini:     %.4f\n" gini_val
  for p in [25, 50, 75]
    share = bottom_pct_share(cuml_genres, cuml_plays, p)
    @printf "  bottom %2d%% of genres -> %5.2f%% of plays\n" p share
  end
  println()
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data for 2025"); return)

  all_data = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    counts = genre_play_counts(df, username)
    length(counts) < 2 && continue

    cuml_genres, cuml_plays = lorenz_curve(counts)
    gini_val = gini_from_lorenz(cuml_genres, cuml_plays)

    print_stats(display_name, length(counts), gini_val, cuml_genres, cuml_plays)

    plot_lorenz(cuml_genres, cuml_plays, gini_val,
      "Genre Lorenz Curve - $display_name - 2025",
      "genre_lorenz_$(username)_2025.png")

    all_data[display_name] = Dict{String,Any}(
      "n_genres" => length(counts),
      "gini" => gini_val,
      "cuml_genres" => cuml_genres,
      "cuml_plays" => cuml_plays,
      "bottom_25pct_share" => bottom_pct_share(cuml_genres, cuml_plays, 25),
      "bottom_50pct_share" => bottom_pct_share(cuml_genres, cuml_plays, 50),
      "bottom_75pct_share" => bottom_pct_share(cuml_genres, cuml_plays, 75),
    )
  end

  save_json("genre_lorenz_2025.json", all_data)
end

main()
