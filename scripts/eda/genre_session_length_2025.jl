include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_session_length_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_N = 20
const MIN_SESSIONS = 3

function get_data()
  conn = get_connection()
  query = """
    WITH sessions AS (
      SELECT
        username,
        timestamp,
        ms_played,
        artist_name,
        CASE
          WHEN timestamp - LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp)
               > INTERVAL '30 minutes'
            OR LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp) IS NULL
          THEN 1 ELSE 0
        END AS is_new_session
      FROM listening_history
      WHERE EXTRACT(YEAR FROM timestamp) = 2025
        AND artist_name IS NOT NULL
    ),
    session_labeled AS (
      SELECT
        username,
        timestamp,
        ms_played,
        artist_name,
        SUM(is_new_session) OVER (PARTITION BY username ORDER BY timestamp) AS session_id
      FROM sessions
    ),
    session_totals AS (
      SELECT
        username,
        session_id,
        SUM(ms_played)::bigint AS session_ms
      FROM session_labeled
      GROUP BY username, session_id
    ),
    session_genre_plays AS (
      SELECT
        sl.username,
        sl.session_id,
        ag.genre,
        COUNT(*) AS genre_plays
      FROM session_labeled sl
      JOIN artist_genres ag ON sl.artist_name = ag.artist_name
      GROUP BY sl.username, sl.session_id, ag.genre
    ),
    session_genre_totals AS (
      SELECT
        username,
        session_id,
        SUM(genre_plays) AS total_genre_plays
      FROM session_genre_plays
      GROUP BY username, session_id
    ),
    dominant_sessions AS (
      SELECT
        sgp.username,
        sgp.genre,
        st.session_ms
      FROM session_genre_plays       sgp
      JOIN session_genre_totals sgt
        ON sgp.username = sgt.username AND sgp.session_id = sgt.session_id
      JOIN session_totals        st
        ON sgp.username = st.username  AND sgp.session_id = st.session_id
      WHERE sgp.genre_plays::float / NULLIF(sgt.total_genre_plays, 0) > 0.25
    )
    SELECT
      username,
      genre,
      COUNT(*)::int                          AS n_sessions,
      AVG(session_ms / 60000.0)             AS avg_session_min,
      STDDEV(session_ms / 60000.0)          AS std_session_min,
      SUM(session_ms / 60000.0)             AS total_session_min
    FROM dominant_sessions
    GROUP BY username, genre
    HAVING COUNT(*) >= $MIN_SESSIONS
    ORDER BY username, avg_session_min DESC
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function user_rows(df, username)
  sub = filter(r -> String(r.username) == username, df)
  sort!(sub, :avg_session_min, rev=true)
  return sub[1:min(TOP_N, nrow(sub)), :]
end

function print_table(display_name, rows)
  println("$display_name  (min $MIN_SESSIONS dominant sessions, top $TOP_N by avg length)")
  @printf "  %-30s  %10s  %10s  %10s\n" "genre" "avg_min" "std_min" "n_sessions"
  for row in eachrow(rows)
    std_str = ismissing(row.std_session_min) ? "    -" : @sprintf("%10.2f", row.std_session_min)
    @printf "  %-30s  %10.2f  %s  %10d\n" String(row.genre) Float64(row.avg_session_min) std_str Int(row.n_sessions)
  end
  println()
end

function plot_bar(rows, display_name, fname)
  nrow(rows) == 0 && return

  sorted = sort(rows, :avg_session_min)
  genres = String.(sorted.genre)
  avg_mins = Float64.(sorted.avg_session_min)
  n_sess = Int.(sorted.n_sessions)
  n_g = length(genres)

  fig_h = max(420, n_g * 36 + 180)
  fig = Figure(size=(860, fig_h))

  ax = Axis(fig[1, 1],
    title="Avg Session Length When Genre Dominates (>25%) - $display_name - 2025",
    xlabel="Avg Session Length (minutes)",
    ylabel="Genre",
    yticks=(1:n_g, genres),
  )

  barplot!(ax, 1:n_g, avg_mins,
    direction=:x,
    color=(Makie.wong_colors()[3], 0.85),
    strokecolor=:white,
    strokewidth=0.5,
  )

  for (i, (v, n)) in enumerate(zip(avg_mins, n_sess))
    text!(ax, v + 0.15, Float64(i),
      text="n=$n",
      align=(:left, :center),
      fontsize=11,
      color=:grey40,
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
    rows = user_rows(df, username)
    nrow(rows) == 0 && continue

    print_table(display_name, rows)

    fname = joinpath(PLOTS_DIR, "genre_session_length_$(username).png")
    plot_bar(rows, display_name, fname)

    json_out[display_name] = [
      Dict{String,Any}(
        "genre" => String(row.genre),
        "n_sessions" => Int(row.n_sessions),
        "avg_session_min" => Float64(row.avg_session_min),
        "std_session_min" => ismissing(row.std_session_min) ? nothing : Float64(row.std_session_min),
        "total_session_min" => Float64(row.total_session_min),
      )
      for row in eachrow(rows)
    ]
  end

  save_json(joinpath(SCRIPT_DIR, "genre_session_length_2025.json"), json_out)
end

main()
