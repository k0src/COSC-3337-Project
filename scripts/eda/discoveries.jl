include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const YEAR = 2025
const MIN_PLAYS_D = 30 # minimum plays for discovered
const MIN_PLAYS_R = 20 # minimum plays for rediscovered
const REDISCOVERY_GAP_PCT = 0.50

# Data

function get_user_spans()
  conn = get_connection()
  query = """
    SELECT
      username,
      (EXTRACT(EPOCH FROM (
        MAX(CASE WHEN EXTRACT(YEAR FROM timestamp) < $YEAR THEN timestamp END) -
        MIN(timestamp)
      )) / 86400.0)::FLOAT8 AS span_days
    FROM listening_history
    GROUP BY username
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_track_status(username)
  conn = get_connection()
  query = """
    WITH plays_curr AS (
      SELECT
        track_name, artist_name,
        COUNT(*)         AS plays,
        MIN(timestamp)   AS first_play_curr
      FROM listening_history
      WHERE username = '$username'
        AND EXTRACT(YEAR FROM timestamp) = $YEAR
      GROUP BY track_name, artist_name
    ),
    prior_stats AS (
      SELECT track_name, artist_name, MAX(timestamp) AS last_play_before
      FROM listening_history
      WHERE username = '$username'
        AND EXTRACT(YEAR FROM timestamp) < $YEAR
      GROUP BY track_name, artist_name
    )
    SELECT
      p.track_name, p.artist_name, p.plays,
      (EXTRACT(EPOCH FROM (p.first_play_curr - ps.last_play_before)) / 86400.0)::FLOAT8 AS gap_days
    FROM plays_curr p
    LEFT JOIN prior_stats ps
      ON p.track_name = ps.track_name AND p.artist_name = ps.artist_name
    WHERE p.plays >= LEAST($MIN_PLAYS_D, $MIN_PLAYS_R)
    ORDER BY p.plays DESC
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_artist_status(username)
  conn = get_connection()
  query = """
    WITH plays_curr AS (
      SELECT
        artist_name,
        COUNT(*)         AS plays,
        MIN(timestamp)   AS first_play_curr
      FROM listening_history
      WHERE username = '$username'
        AND EXTRACT(YEAR FROM timestamp) = $YEAR
      GROUP BY artist_name
    ),
    prior_stats AS (
      SELECT artist_name, MAX(timestamp) AS last_play_before
      FROM listening_history
      WHERE username = '$username'
        AND EXTRACT(YEAR FROM timestamp) < $YEAR
      GROUP BY artist_name
    )
    SELECT
      p.artist_name, p.plays,
      (EXTRACT(EPOCH FROM (p.first_play_curr - ps.last_play_before)) / 86400.0)::FLOAT8 AS gap_days
    FROM plays_curr p
    LEFT JOIN prior_stats ps ON p.artist_name = ps.artist_name
    WHERE p.plays >= LEAST($MIN_PLAYS_D, $MIN_PLAYS_R)
    ORDER BY p.plays DESC
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_album_status(username)
  conn = get_connection()
  query = """
    WITH plays_curr AS (
      SELECT
        COALESCE(album_name, 'Unknown') AS album_name,
        artist_name,
        COUNT(*)         AS plays,
        MIN(timestamp)   AS first_play_curr
      FROM listening_history
      WHERE username = '$username'
        AND EXTRACT(YEAR FROM timestamp) = $YEAR
      GROUP BY COALESCE(album_name, 'Unknown'), artist_name
    ),
    prior_stats AS (
      SELECT
        COALESCE(album_name, 'Unknown') AS album_name,
        artist_name,
        MAX(timestamp) AS last_play_before
      FROM listening_history
      WHERE username = '$username'
        AND EXTRACT(YEAR FROM timestamp) < $YEAR
      GROUP BY COALESCE(album_name, 'Unknown'), artist_name
    )
    SELECT
      p.album_name, p.artist_name, p.plays,
      (EXTRACT(EPOCH FROM (p.first_play_curr - ps.last_play_before)) / 86400.0)::FLOAT8 AS gap_days
    FROM plays_curr p
    LEFT JOIN prior_stats ps
      ON p.album_name = ps.album_name AND p.artist_name = ps.artist_name
    WHERE p.plays >= LEAST($MIN_PLAYS_D, $MIN_PLAYS_R)
    ORDER BY p.plays DESC
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Helpers

function classify(df, threshold_days)
  discovered = filter(r -> ismissing(r.gap_days) && Int(r.plays) >= MIN_PLAYS_D, df)
  rediscovered = filter(
    r -> !ismissing(r.gap_days) && Float64(r.gap_days) >= threshold_days && Int(r.plays) >= MIN_PLAYS_R,
    df,
  )
  return discovered, rediscovered
end

function serialize_tracks(df, include_gap)
  [
    merge(
      Dict{String,Any}("track_name" => String(r.track_name), "artist_name" => String(r.artist_name), "plays" => Int(r.plays)),
      include_gap ? Dict{String,Any}("gap_days" => round(Int, Float64(r.gap_days))) : Dict{String,Any}()
    )
    for r in eachrow(df)
  ]
end

function serialize_artists(df, include_gap)
  [
    merge(
      Dict{String,Any}("artist_name" => String(r.artist_name), "plays" => Int(r.plays)),
      include_gap ? Dict{String,Any}("gap_days" => round(Int, Float64(r.gap_days))) : Dict{String,Any}()
    )
    for r in eachrow(df)
  ]
end

function serialize_albums(df, include_gap)
  [
    merge(
      Dict{String,Any}("album_name" => String(r.album_name), "artist_name" => String(r.artist_name), "plays" => Int(r.plays)),
      include_gap ? Dict{String,Any}("gap_days" => round(Int, Float64(r.gap_days))) : Dict{String,Any}()
    )
    for r in eachrow(df)
  ]
end

# Main

function main()
  spans_df = get_user_spans()
  json_data = Dict{String,Any}()

  for (username, display_name) in NAMES
    span_row = filter(r -> String(r.username) == username, spans_df)
    nrow(span_row) == 0 && continue

    span_days = coalesce(first(span_row).span_days, 0.0)
    threshold_days = Float64(span_days) * REDISCOVERY_GAP_PCT

    track_df = get_track_status(username)
    artist_df = get_artist_status(username)
    album_df = get_album_status(username)

    disc_tracks, redis_tracks = classify(track_df, threshold_days)
    disc_artists, redis_artists = classify(artist_df, threshold_days)
    disc_albums, redis_albums = classify(album_df, threshold_days)

    json_data[display_name] = Dict{String,Any}(
      "span_days" => round(Int, span_days),
      "threshold_days" => round(Int, threshold_days),
      "discovered_tracks" => serialize_tracks(disc_tracks, false),
      "rediscovered_tracks" => serialize_tracks(redis_tracks, true),
      "discovered_artists" => serialize_artists(disc_artists, false),
      "rediscovered_artists" => serialize_artists(redis_artists, true),
      "discovered_albums" => serialize_albums(disc_albums, false),
      "rediscovered_albums" => serialize_albums(redis_albums, true),
    )
  end

  save_json("discoveries_$(YEAR).json", json_data)
end

main()
