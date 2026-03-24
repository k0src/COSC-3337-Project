include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_session_opening_rate")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const PERIODS = [
  ("2024", 2024),
  ("2025", 2025),
  ("alltime", nothing),
]

const TOP_N = 20
const MIN_SESSIONS = 3

function get_data(year::Union{Int,Nothing})
  conn = get_connection()

  year_filter = isnothing(year) ? "" :
                "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    WITH sessions AS (
      SELECT
        username,
        timestamp,
        artist_name,
        CASE
          WHEN timestamp - LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp)
               > INTERVAL '30 minutes'
            OR LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp) IS NULL
          THEN 1 ELSE 0
        END AS is_new_session
      FROM listening_history
      WHERE artist_name IS NOT NULL
        $year_filter
    ),
    session_labeled AS (
      SELECT
        username,
        timestamp,
        artist_name,
        SUM(is_new_session) OVER (PARTITION BY username ORDER BY timestamp) AS session_id
      FROM sessions
    ),
    session_openers AS (
      SELECT DISTINCT ON (username, session_id)
        username,
        artist_name
      FROM session_labeled
      ORDER BY username, session_id, timestamp ASC
    )
    SELECT
      so.username,
      ag.genre,
      COUNT(*)::int AS n_sessions
    FROM  session_openers so
    JOIN  artist_genres    ag ON so.artist_name = ag.artist_name
    GROUP BY so.username, ag.genre
    HAVING COUNT(*) >= $MIN_SESSIONS
    ORDER BY so.username, n_sessions DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function user_rows(df, username)
  sub = filter(r -> String(r.username) == username, df)
  return sub[1:min(TOP_N, nrow(sub)), :]
end

function print_table(label, display_name, rows)
  total = nrow(rows)
  println("$display_name  [$label]  (top $total genres by session opens)")
  @printf "  %-32s  %10s\n" "genre" "n_sessions"
  for row in eachrow(rows)
    @printf "  %-32s  %10d\n" String(row.genre) Int(row.n_sessions)
  end
  println()
end

function plot_bar(rows, display_name, label, fname)
  nrow(rows) == 0 && return

  sorted = sort(rows, :n_sessions)
  genres = String.(sorted.genre)
  n_sessions = Int.(sorted.n_sessions)
  n_g = length(genres)

  fig_h = max(420, n_g * 34 + 180)
  fig = Figure(size=(820, fig_h))

  ax = Axis(fig[1, 1],
    title="Genre Session Opening Rate - $display_name - $label",
    xlabel="Number of Sessions Opened",
    ylabel="Genre",
    yticks=(1:n_g, genres),
  )

  barplot!(ax, 1:n_g, Float64.(n_sessions),
    direction=:x,
    color=(Makie.wong_colors()[4], 0.85),
    strokecolor=:white,
    strokewidth=0.5,
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  json_out = Dict{String,Any}()

  for (label, year) in PERIODS
    df = get_data(year)
    nrow(df) == 0 && (println("No data for $label"); continue)

    json_out[label] = Dict{String,Any}()

    for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
      rows = user_rows(df, username)
      nrow(rows) == 0 && continue

      print_table(label, display_name, rows)

      fname = joinpath(PLOTS_DIR, "genre_session_opening_$(username)_$(label).png")
      plot_bar(rows, display_name, label, fname)

      json_out[label][display_name] = [
        Dict{String,Any}(
          "genre" => String(row.genre),
          "n_sessions" => Int(row.n_sessions),
        )
        for row in eachrow(rows)
      ]
    end
  end

  save_json(joinpath(SCRIPT_DIR, "genre_session_opening_rate.json"), json_out)
end

main()
