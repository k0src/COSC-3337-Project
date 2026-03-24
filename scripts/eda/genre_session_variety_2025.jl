include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_session_variety_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

function get_session_genre_counts(username)
  conn = get_connection()

  query = """
    WITH session_boundaries AS (
      SELECT
        timestamp,
        artist_name,
        CASE
          WHEN timestamp - LAG(timestamp) OVER (ORDER BY timestamp) > INTERVAL '30 minutes'
            OR LAG(timestamp) OVER (ORDER BY timestamp) IS NULL
          THEN 1 ELSE 0
        END AS is_new_session
      FROM listening_history
      WHERE username = '$username'
        AND EXTRACT(YEAR FROM timestamp) = 2025
        AND artist_name IS NOT NULL
    ),
    session_ids AS (
      SELECT
        timestamp,
        artist_name,
        SUM(is_new_session) OVER (ORDER BY timestamp) AS session_id
      FROM session_boundaries
    ),
    session_genre_counts AS (
      SELECT
        si.session_id,
        COUNT(DISTINCT ag.genre) AS n_distinct_genres
      FROM session_ids            si
      JOIN artist_genres          ag ON si.artist_name = ag.artist_name
      GROUP BY si.session_id
    )
    SELECT n_distinct_genres
    FROM session_genre_counts
    ORDER BY n_distinct_genres
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return Int.(df.n_distinct_genres)
end

function summary_stats(counts)
  n = length(counts)
  Dict{String,Any}(
    "n_sessions" => n,
    "mean" => mean(counts),
    "median" => median(counts),
    "min" => minimum(counts),
    "max" => maximum(counts),
    "pct_single_genre" => round(count(==(1), counts) / n * 100.0, digits=2),
    "pct_5plus_genres" => round(count(>=(5), counts) / n * 100.0, digits=2),
    "pct_10plus_genres" => round(count(>=(10), counts) / n * 100.0, digits=2),
  )
end

function plot_histogram(counts, stats, display_name, fname)
  fig = Figure(size=(750, 500))
  ax = Axis(fig[1, 1],
    title="Distinct Genres per Session - $display_name - 2025",
    xlabel="Distinct Genre Count per Session",
    ylabel="Number of Sessions",
  )

  hist!(ax, Float64.(counts),
    bins=20,
    color=(Makie.wong_colors()[1], 0.8),
    strokecolor=:white,
    strokewidth=0.8,
  )

  text!(ax, 0.97, 0.95,
    text="single-genre: $(stats["pct_single_genre"])%\n5+ genres: $(stats["pct_5plus_genres"])%",
    align=(:right, :top),
    space=:relative,
    fontsize=11,
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

function print_stats(display_name, stats)
  println("$display_name - 2025")
  println("  n sessions:        $(stats["n_sessions"])")
  @printf "  mean genres/sess:  %.2f\n" stats["mean"]
  @printf "  median:            %.1f\n" stats["median"]
  @printf "  range:             %d - %d\n" stats["min"] stats["max"]
  println("  single-genre:      $(stats["pct_single_genre"])% of sessions")
  println("  5+ genres:         $(stats["pct_5plus_genres"])% of sessions")
  println("  10+ genres:        $(stats["pct_10plus_genres"])% of sessions")
  println()
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  all_data = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    counts = get_session_genre_counts(username)
    isempty(counts) && continue

    stats = summary_stats(counts)
    print_stats(display_name, stats)

    fname = joinpath(PLOTS_DIR, "genre_session_variety_$(username)_2025.png")
    plot_histogram(counts, stats, display_name, fname)

    all_data[display_name] = Dict{String,Any}(
      "session_genre_counts" => counts,
      "stats" => stats,
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_session_variety_2025.json"), all_data)
end

main()
