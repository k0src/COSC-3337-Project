include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using StatsBase

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const PERIODS = [
  (nothing, "alltime"),
  (2024, "2024"),
  (2025, "2025"),
]

# Stats

function compute_stats(values)
  vals = Float64.(collect(skipmissing(values)))
  length(vals) < 2 && return Dict{String,Any}()

  int_vals = round.(Int, vals)
  freq = countmap(int_vals)
  max_freq = maximum(Base.values(freq))
  mode_vals = sort([k for (k, v) in freq if v == max_freq])

  q1 = quantile(vals, 0.25)
  q3 = quantile(vals, 0.75)

  Dict{String,Any}(
    "mean" => mean(vals),
    "median" => median(vals),
    "modes" => mode_vals,
    "range" => maximum(vals) - minimum(vals),
    "std" => std(vals),
    "variance" => var(vals),
    "skewness" => skewness(vals),
    "q1" => q1,
    "q3" => q3,
    "iqr" => q3 - q1,
  )
end

# Data

function get_user_daily_play_counts(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      DATE_TRUNC('day', timestamp)::DATE::TEXT AS date,
      COUNT(*) AS play_count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY date
    ORDER BY date
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_user_plays_per_track(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      track_name,
      artist_name,
      COUNT(*) AS play_count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY track_name, artist_name
    ORDER BY play_count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_user_plays_per_artist(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      artist_name,
      COUNT(*) AS play_count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY artist_name
    ORDER BY play_count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_user_plays_per_album(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      album_name,
      artist_name,
      COUNT(*) AS play_count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY album_name, artist_name
    ORDER BY play_count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_user_session_lengths(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    WITH session_boundaries AS (
      SELECT
        timestamp,
        ms_played,
        CASE
          WHEN timestamp - LAG(timestamp)
            OVER (ORDER BY timestamp) > INTERVAL '30 minutes'
          OR LAG(timestamp) OVER (ORDER BY timestamp) IS NULL
          THEN 1 ELSE 0
        END AS is_new_session
      FROM listening_history
      WHERE username = '$username'
      $year_filter
    ),
    session_ids AS (
      SELECT
        timestamp,
        ms_played,
        SUM(is_new_session) OVER (ORDER BY timestamp) AS session_id
      FROM session_boundaries
    ),
    session_lengths AS (
      SELECT
        session_id,
        EXTRACT(
          EPOCH FROM (MAX(timestamp) - MIN(timestamp))) / 60 + MAX(ms_played
        ) / 60000.0 AS session_length_minutes
      FROM session_ids
      GROUP BY session_id
    )
    SELECT session_length_minutes
    FROM session_lengths
    ORDER BY session_length_minutes
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Print

function print_stats(stats)
  if isempty(stats)
    println("      (insufficient data)")
    return
  end
  println("    mean:     $(round(stats["mean"];     digits=4))")
  println("    median:   $(round(stats["median"];   digits=4))")
  println("    mode(s):  $(stats["modes"])")
  println("    range:    $(round(stats["range"];    digits=4))")
  println("    std:      $(round(stats["std"];      digits=4))")
  println("    variance: $(round(stats["variance"]; digits=4))")
  println("    skewness: $(round(stats["skewness"]; digits=4))")
  println("    q1:       $(round(stats["q1"];       digits=4))")
  println("    q3:       $(round(stats["q3"];       digits=4))")
  println("    iqr:      $(round(stats["iqr"];      digits=4))")
end

# Plots

function plot_boxplot(vals_dict, title_str, fname, year_label)
  all(isempty(v) for v in values(vals_dict)) && return

  title_label = year_label == "alltime" ? "All-Time" : year_label
  user_keys = collect(keys(NAMES))
  display_names = [NAMES[k] for k in user_keys]
  n = length(user_keys)

  fig = Figure(size=(800, 600))
  ax = Axis(fig[1, 1],
    title="$title_str - $title_label",
    ylabel="Value",
  )
  ax.xticks = (1:n, display_names)

  for (i, username) in enumerate(user_keys)
    vals = vals_dict[username]
    isempty(vals) && continue
    boxplot!(ax, fill(i, length(vals)), vals, show_outliers=true)
  end

  save(fname, fig)
  println("Plot saved to $fname")
end

# Main

function main()
  for (year, year_label) in PERIODS
    title_label = year_label == "alltime" ? "All-Time" : year_label
    println("\n$(title_label)\n")

    daily_dfs = Dict(u => get_user_daily_play_counts(u, year=year) for u in keys(NAMES))
    track_dfs = Dict(u => get_user_plays_per_track(u, year=year) for u in keys(NAMES))
    artist_dfs = Dict(u => get_user_plays_per_artist(u, year=year) for u in keys(NAMES))
    album_dfs = Dict(u => get_user_plays_per_album(u, year=year) for u in keys(NAMES))
    session_dfs = Dict(u => get_user_session_lengths(u, year=year) for u in keys(NAMES))

    daily_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in daily_dfs)
    track_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in track_dfs)
    artist_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in artist_dfs)
    album_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in album_dfs)
    session_vals = Dict(u => Float64.(collect(skipmissing(df.session_length_minutes))) for (u, df) in session_dfs)

    attrs = [
      ("Daily Play Count", "daily_play_count", daily_vals, daily_dfs),
      ("Plays per Track", "plays_per_track", track_vals, track_dfs),
      ("Plays per Artist", "plays_per_artist", artist_vals, artist_dfs),
      ("Plays per Album", "plays_per_album", album_vals, album_dfs),
      ("Session Length", "session_length", session_vals, session_dfs),
    ]

    for (title, key, vals_dict, dfs_dict) in attrs
      println("$title\n")

      attr_json = Dict{String,Any}()

      for (username, display_name) in NAMES
        vals = vals_dict[username]
        stats = compute_stats(vals)
        df = dfs_dict[username]

        println("  $display_name:")
        print_stats(stats)
        println()

        data = if key == "daily_play_count"
          [Dict{String,Any}("date" => String(r.date), "play_count" => Int(r.play_count))
           for r in eachrow(df)]
        elseif key == "plays_per_track"
          [Dict{String,Any}("track_name" => String(r.track_name), "artist_name" => String(r.artist_name), "play_count" => Int(r.play_count))
           for r in eachrow(df)]
        elseif key == "plays_per_artist"
          [Dict{String,Any}("artist_name" => String(r.artist_name), "play_count" => Int(r.play_count))
           for r in eachrow(df)]
        elseif key == "plays_per_album"
          [Dict{String,Any}("album_name" => string(coalesce(r.album_name, "Unknown")), "artist_name" => String(r.artist_name), "play_count" => Int(r.play_count))
           for r in eachrow(df)]
        else
          [Float64(r.session_length_minutes) for r in eachrow(df)]
        end

        attr_json[display_name] = Dict{String,Any}(
          "stats" => stats,
          "data" => data,
        )
      end

      plot_boxplot(vals_dict, title, "boxplot_$(key)_$(year_label).png", year_label)
      save_json("$(key)_$(year_label).json", attr_json)
    end
  end
end

main()
