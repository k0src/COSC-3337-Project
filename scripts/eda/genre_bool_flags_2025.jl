include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_bool_flags_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_N = 20
const MIN_PLAYS = 25

const FLAG_DEFS = [
  ("skip_count", "skip_rate", "Skip Rate", 2),
  ("shuffle_count", "shuffle_rate", "Shuffle Rate", 1),
  ("offline_count", "offline_rate", "Offline Rate", 3),
]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      lh.username,
      ag.genre,
      COUNT(*)::int                                            AS play_count,
      SUM(CASE WHEN lh.skipped  THEN 1 ELSE 0 END)::int      AS skip_count,
      SUM(CASE WHEN lh.shuffle  THEN 1 ELSE 0 END)::int      AS shuffle_count,
      SUM(CASE WHEN lh.offline  THEN 1 ELSE 0 END)::int      AS offline_count
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
      AND EXTRACT(YEAR FROM lh.timestamp) = 2025
    GROUP BY lh.username, ag.genre
    HAVING COUNT(*) >= $MIN_PLAYS
    ORDER BY lh.username, ag.genre
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function top_genres_by_rate(df, username, count_col)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return NamedTuple[]

  entries = [
    (
      genre=String(row.genre),
      rate=getproperty(row, Symbol(count_col)) / row.play_count,
      flag_count=getproperty(row, Symbol(count_col)),
      play_count=Int(row.play_count),
    )
    for row in eachrow(sub)
  ]

  sorted = sort(entries, by=r -> -r.rate)
  return sorted[1:min(TOP_N, length(sorted))]
end

function print_table(display_name, label, entries)
  println("$display_name - 2025 - $label  (top $(length(entries)))")
  @printf "  %-32s  %8s  %10s\n" "genre" "rate" "plays"
  for e in entries
    @printf "  %-32s  %7.1f%%  %10d\n" e.genre e.rate * 100 e.play_count
  end
  println()
end

function plot_individual(entries, display_name, label, color, fname)
  isempty(entries) && return

  genres = reverse([e.genre for e in entries])
  rates = reverse([e.rate for e in entries])
  n = length(entries)

  height = max(500, n * 28 + 120)
  fig = Figure(size=(850, height))
  ax = Axis(fig[1, 1],
    title="$label per Genre - $display_name - 2025",
    xlabel=label,
    ylabel="Genre",
    yticks=(1:n, genres),
    xtickformat=vs -> [@sprintf("%.0f%%", v * 100) for v in vs],
  )

  barplot!(ax, 1:n, rates,
    direction=:x,
    color=(color, 0.85),
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

  colors = Makie.wong_colors()
  json_out = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    json_out[display_name] = Dict{String,Any}()

    for (count_col, rate_key, label, ci) in FLAG_DEFS
      entries = top_genres_by_rate(df, username, count_col)
      isempty(entries) && continue

      print_table(display_name, label, entries)

      fname = joinpath(PLOTS_DIR, "genre_$(rate_key)_$(username)_2025.png")
      plot_individual(entries, display_name, label, colors[ci], fname)

      json_out[display_name][rate_key] = [
        Dict{String,Any}(
          "genre" => e.genre,
          "rate" => e.rate,
          "flag_count" => e.flag_count,
          "play_count" => e.play_count,
        )
        for e in entries
      ]
    end
  end

  save_json(joinpath(SCRIPT_DIR, "genre_bool_flags_2025.json"), json_out)
end

main()
