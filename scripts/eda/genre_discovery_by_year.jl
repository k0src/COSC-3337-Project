include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_discovery_by_year")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

function get_data()
  conn = get_connection()
  query = """
    WITH first_seen AS (
      SELECT
        lh.username,
        ag.genre,
        MIN(lh.timestamp) AS first_seen
      FROM  listening_history lh
      JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
      WHERE lh.artist_name IS NOT NULL
      GROUP BY lh.username, ag.genre
    )
    SELECT
      username,
      EXTRACT(YEAR FROM first_seen)::int AS year,
      COUNT(*)::int                      AS new_genres
    FROM  first_seen
    GROUP BY username, year
    ORDER BY username, year
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function user_series(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return Int[], Int[]
  years = Int.(sub.year)
  new_genres = Int.(sub.new_genres)
  return years, new_genres
end

function print_table(display_name, years, counts)
  total = sum(counts)
  println("$display_name  (total genres discovered: $total)")
  @printf "  %6s  %12s  %12s\n" "year" "new_genres" "cumulative"
  cuml = 0
  for (y, c) in zip(years, counts)
    cuml += c
    @printf "  %6d  %12d  %12d\n" y c cuml
  end
  println()
end

function plot_bars(years, counts, display_name, username, fname)
  isempty(years) && return

  xs = Float64.(years)

  fig = Figure(size=(750, 460))
  ax = Axis(fig[1, 1],
    title="New Genres Discovered by Year - $display_name - All Time",
    xlabel="Year",
    ylabel="New Genres",
    xticks=(xs, string.(years)),
  )

  barplot!(ax, xs, Float64.(counts),
    color=(Makie.wong_colors()[1], 0.85),
    strokecolor=:white,
    strokewidth=0.8,
  )

  for (x, c) in zip(xs, counts)
    c == 0 && continue
    text!(ax, x, Float64(c),
      text=string(c),
      align=(:center, :bottom),
      offset=(0, 4),
      fontsize=12,
    )
  end

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  json_out = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    years, counts = user_series(df, username)
    isempty(years) && continue

    print_table(display_name, years, counts)

    fname = joinpath(PLOTS_DIR, "genre_discovery_by_year_$(username).png")
    plot_bars(years, counts, display_name, username, fname)

    cuml = cumsum(counts)
    json_out[display_name] = Dict{String,Any}(
      "years" => years,
      "new_genres" => counts,
      "cumulative" => cuml,
      "total" => sum(counts),
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_discovery_by_year.json"), json_out)
end

main()
