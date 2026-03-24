include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_avg_ms_played")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const PERIODS = [
  ("2024", 2024),
  ("2025", 2025),
  ("alltime", nothing),
]

const TOP_N = 20
const MIN_PLAYS = 25

function get_data()
  conn = get_connection()

  query = """
    SELECT
      lh.username,
      EXTRACT(YEAR FROM lh.timestamp)::INT  AS year,
      ag.genre,
      AVG(lh.ms_played)::FLOAT              AS avg_ms,
      COUNT(*)::INT                          AS play_count
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
    GROUP BY lh.username,
             EXTRACT(YEAR FROM lh.timestamp)::INT,
             ag.genre
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function filter_period(df, year_filter)
  year_filter === nothing && return df
  filter(r -> r.year == year_filter, df)
end

function top_genres_by_avg_ms(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return NamedTuple[]

  agg = Dict{String,Tuple{Float64,Int}}()
  for row in eachrow(sub)
    g = String(row.genre)
    ms = Float64(row.avg_ms) * Int(row.play_count)
    n = Int(row.play_count)
    if haskey(agg, g)
      prev_ms, prev_n = agg[g]
      agg[g] = (prev_ms + ms, prev_n + n)
    else
      agg[g] = (ms, n)
    end
  end

  entries = [
    (genre=g, avg_min=sum_ms / n / 60_000.0, play_count=n)
    for (g, (sum_ms, n)) in agg
    if n >= MIN_PLAYS
  ]
  return sort(entries, by=r -> -r.avg_min)[1:min(TOP_N, length(entries))]
end

function print_table(display_name, period_label, entries)
  println("$display_name - $period_label  (top $(length(entries)) genres by avg minutes played)")
  @printf "  %-32s  %10s  %10s\n" "genre" "avg_min" "plays"
  for e in entries
    @printf "  %-32s  %10.2f  %10d\n" e.genre e.avg_min e.play_count
  end
  println()
end

function plot_bar(entries, display_name, period_label, fname)
  isempty(entries) && return

  genres = [e.genre for e in entries]
  avg_mins = [e.avg_min for e in entries]
  n = length(entries)

  genres = reverse(genres)
  avg_mins = reverse(avg_mins)

  height = max(500, n * 28 + 120)
  fig = Figure(size=(850, height))
  ax = Axis(fig[1, 1],
    title="Avg Minutes Played per Genre - $display_name - $period_label (min $MIN_PLAYS plays)",
    xlabel="Avg Minutes per Play",
    ylabel="Genre",
    yticks=(1:n, genres),
  )

  barplot!(ax, 1:n, avg_mins,
    direction=:x,
    color=(Makie.wong_colors()[2], 0.85),
    strokecolor=:white,
    strokewidth=0.6,
  )

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
    json_out[display_name] = Dict{String,Any}()

    for (period_label, year_filter) in PERIODS
      period_df = filter_period(df, year_filter)
      entries = top_genres_by_avg_ms(period_df, username)
      isempty(entries) && continue

      print_table(display_name, period_label, entries)

      fname = joinpath(PLOTS_DIR, "genre_avg_ms_played_$(username)_$(period_label).png")
      plot_bar(entries, display_name, period_label, fname)

      json_out[display_name][period_label] = Dict{String,Any}(
        "top_n" => TOP_N,
        "genres" => [
          Dict{String,Any}(
            "genre" => e.genre,
            "avg_min" => e.avg_min,
            "play_count" => e.play_count,
          )
          for e in entries
        ],
      )
    end
  end

  save_json(joinpath(SCRIPT_DIR, "genre_avg_ms_played.json"), json_out)
end

main()
