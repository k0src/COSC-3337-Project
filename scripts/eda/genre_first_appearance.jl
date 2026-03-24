include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Dates
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_first_appearance")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["dasucc", "alanjzamora", "alexxxxxrs", "korenns"]
const DISPLAY_ORDER = ["Anthony", "Alan", "Alexandra", "Koren"]

const PLOT_TOP_N = 60

function get_data()
  conn = get_connection()

  query = """
    SELECT
      lh.username,
      ag.genre,
      TO_CHAR(MIN(lh.timestamp), 'YYYY-MM-DD')  AS first_seen,
      COUNT(*)                                   AS play_count
    FROM listening_history   lh
    JOIN artist_genres        ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
    GROUP BY lh.username, ag.genre
    ORDER BY lh.username, first_seen
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function date_to_yearfrac(d::Date)
  y = year(d)
  return y + (dayofyear(d) - 1) / daysinyear(y)
end

function user_genre_data(df, username)
  sub = filter(r -> String(r.username) == username, df)
  nrow(sub) == 0 && return NamedTuple[]

  entries = [
    (
      genre=String(row.genre),
      first_seen=Date(String(row.first_seen)),
      play_count=Int(row.play_count),
    )
    for row in eachrow(sub)
  ]

  return sort(entries, by=r -> r.first_seen)
end

function plot_timeline(genres_data, display_name, fname)
  isempty(genres_data) && return

  n_plot = min(PLOT_TOP_N, length(genres_data))
  top_n = sort(genres_data, by=r -> -r.play_count)[1:n_plot]
  plotted = sort(top_n, by=r -> r.first_seen)

  year_fracs = [date_to_yearfrac(r.first_seen) for r in plotted]
  genre_names = [r.genre for r in plotted]
  play_counts = Float64.([r.play_count for r in plotted])

  min_year = floor(Int, minimum(year_fracs))
  tick_yrs = collect(min_year:2025)
  tick_pos = Float64.(tick_yrs)
  tick_lbls = string.(tick_yrs)

  height = max(520, n_plot * 19 + 140)
  fig = Figure(size=(1050, height))
  ax = Axis(fig[1, 1],
    title="Genre First Appearance - $display_name (top $n_plot by plays, all time)",
    xlabel="Year",
    ylabel="Genre",
    yticks=(1:n_plot, genre_names),
    xticks=(tick_pos, tick_lbls),
  )

  sc = scatter!(ax, year_fracs, Float64.(1:n_plot),
    color=play_counts,
    colormap=:plasma,
    markersize=10,
    strokecolor=:white,
    strokewidth=0.8,
  )

  Colorbar(fig[1, 2], sc, label="Total Play Count")

  save(fname, fig)
  println("  plot saved: $fname")
end

function print_timeline(display_name, genres_data)
  n_total = length(genres_data)
  n_shown = min(25, n_total)
  println("$display_name - all time  ($n_total genres total, earliest $n_shown shown)")
  @printf "  %-32s  %-12s  %10s\n" "genre" "first_seen" "play_count"
  for r in genres_data[1:n_shown]
    @printf "  %-32s  %-12s  %10d\n" r.genre string(r.first_seen) r.play_count
  end
  if n_total > n_shown
    println("  ... $(n_total - n_shown) more genres saved in JSON")
  end
  println()
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  all_data = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    genres_data = user_genre_data(df, username)
    isempty(genres_data) && continue

    print_timeline(display_name, genres_data)

    fname = joinpath(PLOTS_DIR, "genre_first_appearance_$(username).png")
    plot_timeline(genres_data, display_name, fname)

    all_data[display_name] = Dict{String,Any}(
      "n_genres" => length(genres_data),
      "genres" => [
        Dict{String,Any}(
          "genre" => r.genre,
          "first_seen" => string(r.first_seen),
          "year_frac" => date_to_yearfrac(r.first_seen),
          "play_count" => r.play_count,
        )
        for r in genres_data
      ],
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_first_appearance.json"), all_data)
end

main()
