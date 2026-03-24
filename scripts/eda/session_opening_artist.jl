include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "session_opening_artist")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_N = 20

const PERIODS = [
  ("2024", 2024),
  ("2025", 2025),
  ("alltime", nothing),
]

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
      FROM  session_labeled
      ORDER BY username, session_id, timestamp
    )
    SELECT
      username,
      artist_name,
      COUNT(*)::int AS times_opened
    FROM  session_openers
    WHERE artist_name IS NOT NULL
    GROUP BY username, artist_name
    ORDER BY username, times_opened DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function top_openers(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return String[], Int[]
  n = min(TOP_N, nrow(sub))
  return String.(sub.artist_name[1:n]), Int.(sub.times_opened[1:n])
end

function print_results(label, display_name, artists, counts)
  total = sum(counts)
  println("$display_name - $label  (total sessions opened: $total)")
  @printf "  %-32s  %8s  %8s\n" "artist" "opens" "share%"
  for (a, n) in zip(artists, counts)
    @printf "  %-32s  %8d  %8.1f%%\n" a n (n / total * 100)
  end
  println()
end

function plot_bar(artists, counts, display_name, label, fname)
  isempty(artists) && return
  n = length(artists)
  total = sum(counts)
  shares = counts ./ total .* 100

  ord = sortperm(shares)
  artists = artists[ord]
  shares = shares[ord]

  height = max(420, n * 34 + 160)
  fig = Figure(size=(800, height))
  ax = Axis(fig[1, 1],
    title="Session Opening Artist - $display_name - $label",
    xlabel="% of Sessions Opened",
    ylabel="Artist",
    yticks=(1:n, artists),
  )

  barplot!(ax, 1:n, shares,
    direction=:x,
    color=(Makie.wong_colors()[3], 0.85),
    strokecolor=:white,
    strokewidth=0.6,
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  json_out = Dict{String,Any}()

  for (label, year) in PERIODS
    println("=== $label ===")
    df = get_data(year)
    nrow(df) == 0 && (println("  no data"); continue)

    json_out[label] = Dict{String,Any}()

    for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
      artists, counts = top_openers(df, username)
      isempty(artists) && continue

      print_results(label, display_name, artists, counts)

      fname = joinpath(PLOTS_DIR, "session_opening_artist_$(username)_$(label).png")
      plot_bar(artists, counts, display_name, label, fname)

      total = sum(counts)
      json_out[label][display_name] = Dict{String,Any}(
        "total_sessions" => total,
        "artists" => [
          Dict{String,Any}(
            "artist" => artists[i],
            "opens" => counts[i],
            "share" => counts[i] / total,
          )
          for i in 1:length(artists)
        ],
      )
    end
  end

  save_json(joinpath(SCRIPT_DIR, "session_opening_artist.json"), json_out)
end

main()
