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

# Helpers

function serialize_row(key, row)
  if key == "daily_play_count"
    Dict{String,Any}("date" => String(row.date), "play_count" => Int(row.play_count))
  elseif key == "plays_per_track"
    Dict{String,Any}("track_name" => String(row.track_name), "artist_name" => String(row.artist_name), "play_count" => Int(row.play_count))
  elseif key == "plays_per_artist"
    Dict{String,Any}("artist_name" => String(row.artist_name), "play_count" => Int(row.play_count))
  elseif key == "plays_per_album"
    Dict{String,Any}("album_name" => string(coalesce(row.album_name, "Unknown")), "artist_name" => String(row.artist_name), "play_count" => Int(row.play_count))
  else
    Dict{String,Any}("session_length_minutes" => Float64(row.session_length_minutes))
  end
end

# Print

function print_stats(stats)
  if isempty(stats)
    println("    (insufficient data)")
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
      clean_vals_dict = Dict{String,Vector{Float64}}()

      for (username, display_name) in NAMES
        full_vals = vals_dict[username]
        full_df = dfs_dict[username]

        if length(full_vals) >= 4
          q1 = quantile(full_vals, 0.25)
          q3 = quantile(full_vals, 0.75)
          iqr_v = q3 - q1
          lower = q1 - 1.5 * iqr_v
          upper = q3 + 1.5 * iqr_v

          is_clean = [v >= lower && v <= upper for v in full_vals]
          clean_vals = full_vals[is_clean]
          clean_df = full_df[is_clean, :]
          outlier_vals = full_vals[.!is_clean]
          outlier_df = full_df[.!is_clean, :]
        else
          clean_vals = full_vals
          clean_df = full_df
          outlier_vals = Float64[]
          outlier_df = full_df[1:0, :]
        end

        mu = isempty(full_vals) ? 0.0 : mean(full_vals)
        sigma = length(full_vals) < 2 ? 1.0 : std(full_vals)
        sigma = sigma == 0.0 ? 1.0 : sigma

        clean_vals_dict[username] = clean_vals
        stats = compute_stats(clean_vals)

        println("  $display_name: ($(length(outlier_vals)) outliers removed)")
        print_stats(stats)
        println()

        clean_data = [serialize_row(key, r) for r in eachrow(clean_df)]

        outlier_data = [
          merge(serialize_row(key, r), Dict{String,Any}("z_score" => (v - mu) / sigma))
          for (r, v) in zip(eachrow(outlier_df), outlier_vals)
        ]

        attr_json[display_name] = Dict{String,Any}(
          "stats" => stats,
          "data" => clean_data,
          "outliers" => outlier_data,
        )
      end

      save_json("outliers_$(key)_$(year_label).json", attr_json)
    end
  end
end

main()
