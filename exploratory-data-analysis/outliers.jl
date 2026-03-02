using Statistics

# Data

function get_group_daily_play_counts(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      DATE_TRUNC('day', timestamp)::DATE::TEXT AS date,
      COUNT(*) AS play_count
    FROM listening_history
    $year_filter
    GROUP BY date
    ORDER BY date
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

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

function get_group_plays_per_track(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      track_name,
      artist_name,
      COUNT(*) AS play_count
    FROM listening_history
    $year_filter
    GROUP BY track_name, artist_name
    ORDER BY play_count DESC
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

function get_group_plays_per_artist(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      artist_name,
      COUNT(*) AS play_count
    FROM listening_history
    $year_filter
    GROUP BY artist_name
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

function get_group_plays_per_album(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      album_name,
      artist_name,
      COUNT(*) AS play_count
    FROM listening_history
    $year_filter
    GROUP BY album_name, artist_name
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

function get_group_session_lengths(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    WITH session_boundaries AS (
      SELECT
        username,
        timestamp,
        ms_played,
        CASE
          WHEN timestamp - LAG(timestamp)
            OVER (
              PARTITION BY username ORDER BY timestamp
            ) > INTERVAL '30 minutes'
          OR LAG(timestamp) OVER (
            PARTITION BY username ORDER BY timestamp
          ) IS NULL
          THEN 1 ELSE 0
        END AS is_new_session
      FROM listening_history
      $year_filter
    ),
    session_ids AS (
      SELECT
        username,
        timestamp,
        ms_played,
        SUM(is_new_session) OVER (
          PARTITION BY username ORDER BY timestamp
        ) AS session_id
      FROM session_boundaries
    ),
    session_lengths AS (
      SELECT
        username,
        session_id,
        EXTRACT(
          EPOCH FROM (MAX(timestamp) - MIN(timestamp))) / 60 + MAX(ms_played
        ) / 60000.0 AS session_length_minutes
      FROM session_ids
      GROUP BY username, session_id
    )
    SELECT session_length_minutes
    FROM session_lengths
    ORDER BY session_length_minutes
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

# IQR outlier detection

function iqr_outliers(values; log_scale=false)
  if length(values) < 4
    return falses(length(values))
  end
  v = log_scale ? log.(Float64.(values) .+ 1) : Float64.(values)
  q1 = quantile(v, 0.25)
  q3 = quantile(v, 0.75)
  iq = q3 - q1
  lower = q1 - 1.5 * iq
  upper = q3 + 1.5 * iq
  return v .< lower .|| v .> upper
end

# Helpers

function daily_to_dicts(df)
  [Dict(
    "date" => string(coalesce(r.date, "")),
    "play_count" => Int(coalesce(r.play_count, 0))
  ) for r in eachrow(df)]
end

function track_to_dicts(df)
  [Dict(
    "track_name" => string(coalesce(r.track_name, "Unknown")),
    "artist_name" => string(coalesce(r.artist_name, "Unknown")),
    "play_count" => Int(coalesce(r.play_count, 0))
  ) for r in eachrow(df)]
end

function artist_to_dicts(df)
  [Dict(
    "artist_name" => string(coalesce(r.artist_name, "Unknown")),
    "play_count" => Int(coalesce(r.play_count, 0))
  ) for r in eachrow(df)]
end

function album_to_dicts(df)
  [Dict(
    "album_name" => string(coalesce(r.album_name, "Unknown")),
    "artist_name" => string(coalesce(r.artist_name, "Unknown")),
    "play_count" => Int(coalesce(r.play_count, 0))
  ) for r in eachrow(df)]
end

function session_to_dicts(df)
  [Dict(
    "session_length_minutes" => Float64(coalesce(r.session_length_minutes, 0.0))
  ) for r in eachrow(df)]
end

# Main

function run_outliers(names; year=nothing)
  println("\nCalculating...")

  year_label = year === nothing ? "alltime" : string(year)
  title_label = year === nothing ? "All-Time" : string(year)
  no_data(name) = println("No data from $title_label for $name")

  g_daily = get_group_daily_play_counts(year=year)
  g_tracks = get_group_plays_per_track(year=year)
  g_artists = get_group_plays_per_artist(year=year)
  g_albums = get_group_plays_per_album(year=year)
  g_sessions = get_group_session_lengths(year=year)

  u_daily = Dict(u => get_user_daily_play_counts(u, year=year) for u in keys(names))
  u_tracks = Dict(u => get_user_plays_per_track(u, year=year) for u in keys(names))
  u_artists = Dict(u => get_user_plays_per_artist(u, year=year) for u in keys(names))
  u_albums = Dict(u => get_user_plays_per_album(u, year=year) for u in keys(names))
  u_sessions = Dict(u => get_user_session_lengths(u, year=year) for u in keys(names))

  if nrow(g_daily) == 0
    println("No group data for $title_label")
    return
  end

  # Group outliers

  g_daily_out = sort(
    g_daily[iqr_outliers(g_daily.play_count), :], :play_count, rev=true
  )
  g_tracks_out = sort(
    g_tracks[iqr_outliers(g_tracks.play_count, log_scale=true), :], :play_count, rev=true
  )
  g_artists_out = sort(
    g_artists[iqr_outliers(g_artists.play_count, log_scale=true), :], :play_count, rev=true
  )
  g_albums_out = sort(
    g_albums[iqr_outliers(g_albums.play_count, log_scale=true), :], :play_count, rev=true
  )
  g_sessions_out = sort(
    g_sessions[iqr_outliers(
      g_sessions.session_length_minutes, log_scale=true
    ), :], :session_length_minutes, rev=true
  )

  # User outliers

  u_daily_out = Dict(
    u => sort(
      d[iqr_outliers(d.play_count), :], :play_count, rev=true
    ) for (u, d) in u_daily
  )
  u_tracks_out = Dict(
    u => sort(
      d[iqr_outliers(d.play_count, log_scale=true), :], :play_count, rev=true
    ) for (u, d) in u_tracks
  )
  u_artists_out = Dict(
    u => sort(
      d[iqr_outliers(d.play_count, log_scale=true), :], :play_count, rev=true
    ) for (u, d) in u_artists
  )
  u_albums_out = Dict(
    u => sort(
      d[iqr_outliers(d.play_count, log_scale=true), :], :play_count, rev=true
    ) for (u, d) in u_albums
  )
  u_sessions_out = Dict(
    u => sort(
      d[iqr_outliers(
        d.session_length_minutes, log_scale=true
      ), :], :session_length_minutes, rev=true
    ) for (u, d) in u_sessions
  )

  println("\nGroup Outliers - $title_label\n")

  println("Daily Play Count:")
  for i in 1:min(10, nrow(g_daily_out))
    r = g_daily_out[i, :]
    println("  $(r.date): $(r.play_count) plays")
  end

  println("\nPlays per Track:")
  for i in 1:min(10, nrow(g_tracks_out))
    r = g_tracks_out[i, :]
    println("  $(r.track_name) by $(r.artist_name): $(r.play_count) plays")
  end

  println("\nPlays per Artist:")
  for i in 1:min(10, nrow(g_artists_out))
    r = g_artists_out[i, :]
    println("  $(r.artist_name): $(r.play_count) plays")
  end

  println("\nPlays per Album:")
  for i in 1:min(10, nrow(g_albums_out))
    r = g_albums_out[i, :]
    println("  $(r.album_name) by $(r.artist_name): $(r.play_count) plays")
  end

  println("\nSession Lengths:")
  for i in 1:min(10, nrow(g_sessions_out))
    r = g_sessions_out[i, :]
    println("  $(round(r.session_length_minutes; digits=2)) minutes")
  end

  println("\nUser Outliers - $title_label")

  for (username, display_name) in names
    println("\n$display_name:")

    if nrow(u_daily[username]) == 0
      no_data(display_name)
      continue
    end

    ud_out = u_daily_out[username]
    ut_out = u_tracks_out[username]
    ua_out = u_artists_out[username]
    ub_out = u_albums_out[username]
    us_out = u_sessions_out[username]

    println("\nDaily Play Count:")
    for i in 1:min(10, nrow(ud_out))
      r = ud_out[i, :]
      println("  $(r.date): $(r.play_count) plays")
    end

    println("\nPlays per Track:")
    for i in 1:min(10, nrow(ut_out))
      r = ut_out[i, :]
      println("  $(r.track_name) by $(r.artist_name): $(r.play_count) plays")
    end

    println("\nPlays per Artist:")
    for i in 1:min(10, nrow(ua_out))
      r = ua_out[i, :]
      println("  $(r.artist_name): $(r.play_count) plays")
    end

    println("\nPlays per Album :")
    for i in 1:min(10, nrow(ub_out))
      r = ub_out[i, :]
      println("  $(r.album_name) by $(r.artist_name): $(r.play_count) plays")
    end

    println("\nSession Lengths:")
    for i in 1:min(10, nrow(us_out))
      r = us_out[i, :]
      println("  $(round(r.session_length_minutes; digits=2)) minutes")
    end
  end

  # Save JSON

  println("\nSaving JSON...")

  data = Dict(
    "group" => Dict(
      "daily_play_count" => daily_to_dicts(g_daily_out),
      "plays_per_track" => track_to_dicts(g_tracks_out),
      "plays_per_artist" => artist_to_dicts(g_artists_out),
      "plays_per_album" => album_to_dicts(g_albums_out),
      "session_length" => session_to_dicts(g_sessions_out)
    ),
    "users" => Dict(
      display_name => Dict(
        "daily_play_count" => daily_to_dicts(u_daily_out[username]),
        "plays_per_track" => track_to_dicts(u_tracks_out[username]),
        "plays_per_artist" => artist_to_dicts(u_artists_out[username]),
        "plays_per_album" => album_to_dicts(u_albums_out[username]),
        "session_length" => session_to_dicts(u_sessions_out[username])
      )
      for (username, display_name) in names
    ),
  )

  save_json("outliers_$year_label.json", data)
end

function outliers(names)
  println("ALL-TIME OUTLIERS")
  run_outliers(names)

  println("\nPER-YEAR OUTLIERS")
  for year in 2015:2026
    println("\nYear: $year")
    run_outliers(names, year=year)
  end
end
