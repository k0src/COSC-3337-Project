function get_group_averages(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      -- averages of various attributes
      AVG(ms_played) AS avg_ms_played,
      AVG(skip_rate) AS avg_skip_rate,
      AVG(shuffle_rate) AS avg_shuffle_rate,
      AVG(offline_rate) AS avg_offline_rate,
      AVG(daily_plays) AS avg_daily_plays,
      AVG(daily_unique_tracks) AS avg_daily_unique_tracks,
      AVG(daily_unique_artists) AS avg_daily_unique_artists,
      AVG(monthly_plays) AS avg_monthly_plays,
      AVG(yearly_plays) AS avg_yearly_plays
    FROM (
      SELECT
        ms_played,
        -- 1 if the bool is true, 0 if false
        -- this gives us a "rate" we can average
        CASE WHEN skipped THEN 1.0 ELSE 0.0 END AS skip_rate,
        CASE WHEN shuffle THEN 1.0 ELSE 0.0 END AS shuffle_rate,
        CASE WHEN offline THEN 1.0 ELSE 0.0 END AS offline_rate,

        COUNT(*) OVER w_day AS daily_plays,
        COUNT(*) OVER w_month AS monthly_plays,
        COUNT(*) OVER w_year AS yearly_plays,

        -- dense rank because pg doesnt support count distinct in window functions
        -- this gives the same result as count(distinct track_id) per day
        -- just gives a number that increments by 1 for each unique track_id in the day
        DENSE_RANK() OVER (
          PARTITION BY DATE_TRUNC('day', timestamp) 
          ORDER BY track_id
        )
        + DENSE_RANK() OVER (
            PARTITION BY DATE_TRUNC('day', timestamp) 
            ORDER BY track_id DESC
          )
        - 1
        AS daily_unique_tracks,

        DENSE_RANK() OVER (
          PARTITION BY DATE_TRUNC('day', timestamp) 
          ORDER BY artist_name
        )
        + DENSE_RANK() OVER (
            PARTITION BY DATE_TRUNC('day', timestamp) 
            ORDER BY artist_name DESC
          )
        - 1
        AS daily_unique_artists

      FROM listening_history
      $year_filter

      -- time frames
      WINDOW
        w_day AS (PARTITION BY DATE_TRUNC('day',   timestamp)),
        w_month AS (PARTITION BY DATE_TRUNC('month', timestamp)),
        w_year AS (PARTITION BY DATE_TRUNC('year',  timestamp))
    ) agg;
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_user_averages(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      AVG(ms_played) AS avg_ms_played,
      AVG(skip_rate) AS avg_skip_rate,
      AVG(shuffle_rate) AS avg_shuffle_rate,
      AVG(offline_rate) AS avg_offline_rate,
      AVG(daily_plays) AS avg_daily_plays,
      AVG(daily_unique_tracks) AS avg_daily_unique_tracks,
      AVG(daily_unique_artists) AS avg_daily_unique_artists,
      AVG(monthly_plays) AS avg_monthly_plays,
      AVG(yearly_plays) AS avg_yearly_plays
    FROM (
      SELECT
        username,
        ms_played,
        CASE WHEN skipped THEN 1.0 ELSE 0.0 END AS skip_rate,
        CASE WHEN shuffle THEN 1.0 ELSE 0.0 END AS shuffle_rate,
        CASE WHEN offline THEN 1.0 ELSE 0.0 END AS offline_rate,

        COUNT(*) OVER w_day AS daily_plays,
        COUNT(*) OVER w_month AS monthly_plays,
        COUNT(*) OVER w_year AS yearly_plays,

        DENSE_RANK() OVER (
          PARTITION BY username, DATE_TRUNC('day', timestamp) 
          ORDER BY track_id
        )
        + DENSE_RANK() OVER (
            PARTITION BY username, DATE_TRUNC('day', timestamp) 
            ORDER BY track_id DESC
          )
        - 1
        AS daily_unique_tracks,

        DENSE_RANK() OVER (
          PARTITION BY username, DATE_TRUNC('day', timestamp)
          ORDER BY artist_name
        )
        + DENSE_RANK() OVER (
            PARTITION BY username, DATE_TRUNC('day', timestamp)
            ORDER BY artist_name DESC
          )
        - 1
        AS daily_unique_artists

      FROM listening_history
      $year_filter

      WINDOW
        w_day   AS (PARTITION BY username, DATE_TRUNC('day',   timestamp)),
        w_month AS (PARTITION BY username, DATE_TRUNC('month', timestamp)),
        w_year  AS (PARTITION BY username, DATE_TRUNC('year',  timestamp))
    ) agg

    GROUP BY username
    ORDER BY username;
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_group_average_session_length(; year=nothing)
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
            OVER (PARTITION BY username ORDER BY timestamp) > INTERVAL '30 minutes'
          OR LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp) IS NULL
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
        SUM(is_new_session) 
        OVER (PARTITION BY username ORDER BY timestamp) AS session_id
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
    SELECT
      AVG(session_length_minutes) AS avg_session_length_minutes
    FROM session_lengths;
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_user_average_session_length(; year=nothing)
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
            OVER (PARTITION BY username ORDER BY timestamp) > INTERVAL '30 minutes'
          OR LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp) IS NULL
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
        SUM(is_new_session) OVER (PARTITION BY username ORDER BY timestamp) AS session_id
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
    SELECT
      username,
      AVG(session_length_minutes) AS avg_session_length_minutes
    FROM session_lengths

    GROUP BY username
    ORDER BY username;
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_group_top_tracks(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      track_name,
      artist_name,
      album_name,
      COUNT(*) AS play_count,
      SUM(ms_played) / 60000.0 AS total_minutes_played
    FROM listening_history
    $year_filter
    GROUP BY track_name, artist_name, album_name
    ORDER BY play_count DESC
    LIMIT 100;
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_group_top_artists(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      artist_name,
      COUNT(*) AS play_count,
      SUM(ms_played) / 60000.0 AS total_minutes_played
    FROM listening_history
    $year_filter
    GROUP BY artist_name
    ORDER BY play_count DESC
    LIMIT 100;
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_group_top_albums(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      album_name,
      artist_name,
      COUNT(*) AS play_count,
      SUM(ms_played) / 60000.0 AS total_minutes_played
    FROM listening_history
    $year_filter
    GROUP BY album_name, artist_name
    ORDER BY play_count DESC
    LIMIT 100;
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_user_top_tracks(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      track_name,
      artist_name,
      album_name,
      COUNT(*) AS play_count,
      SUM(ms_played) / 60000.0 AS total_minutes_played
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY track_name, artist_name, album_name
    ORDER BY play_count DESC
    LIMIT 100;
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_user_top_artists(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
        artist_name,
        COUNT(*) AS play_count,
        SUM(ms_played) / 60000.0 AS total_minutes_played
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY artist_name
    ORDER BY play_count DESC
    LIMIT 100;
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_user_top_albums(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
        album_name,
        artist_name,
        COUNT(*) AS play_count,
        SUM(ms_played) / 60000.0 AS total_minutes_played
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY album_name, artist_name
    ORDER BY play_count DESC
    LIMIT 100;
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function run_univariate_analysis(names; year=nothing)
  println("\nCalculating...")

  year_label = year === nothing ? "All-Time" : string(year)
  no_data(name) = println("\nNo data from $year_label for $name")

  # Averages
  group_averages = get_group_averages(year=year)
  user_averages = get_user_averages(year=year)

  # Session lengths
  group_avg_session_length = get_group_average_session_length(year=year)
  user_avg_session_length = get_user_average_session_length(year=year)

  # Group top stats
  group_top_tracks = get_group_top_tracks(year=year)
  group_top_artists = get_group_top_artists(year=year)
  group_top_albums = get_group_top_albums(year=year)

  # User top stats
  user_top_tracks = Dict(
    get(names, username, username) =>
      get_user_top_tracks(username, year=year) for username in keys(names)
  )
  user_top_artists = Dict(
    get(names, username, username) =>
      get_user_top_artists(username, year=year) for username in keys(names)
  )
  user_top_albums = Dict(
    get(names, username, username) =>
      get_user_top_albums(username, year=year) for username in keys(names)
  )

  if nrow(group_averages) == 0 || ismissing(first(group_averages).avg_ms_played)
    println("\nNo group data for $year_label")
    return
  end

  active_users = Set(String.(user_averages.username))

  println("\nAverages (Group)\n")

  println("Average ms_played: $(round(first(group_averages).avg_ms_played; digits=4))")
  println("Average skip rate: $(round(first(group_averages).avg_skip_rate; digits=4))")
  println("Average shuffle rate: $(round(first(group_averages).avg_shuffle_rate; digits=4))")
  println("Average offline rate: $(round(first(group_averages).avg_offline_rate; digits=4))")
  println("Average daily plays: $(round(first(group_averages).avg_daily_plays; digits=4))")
  println("Average daily unique tracks: $(round(first(group_averages).avg_daily_unique_tracks; digits=4))")
  println("Average daily unique artists: $(round(first(group_averages).avg_daily_unique_artists; digits=4))")
  println("Average monthly plays: $(round(first(group_averages).avg_monthly_plays; digits=4))")
  println("Average yearly plays: $(round(first(group_averages).avg_yearly_plays; digits=4))")

  println("\nAverages (per User)")

  for row in eachrow(user_averages)
    username = row.username
    name = get(names, username, username)
    println("\nUser: $name")
    println("  Average ms_played: $(round(row.avg_ms_played; digits=4))")
    println("  Average skip rate: $(round(row.avg_skip_rate; digits=4))")
    println("  Average shuffle rate: $(round(row.avg_shuffle_rate; digits=4))")
    println("  Average offline rate: $(round(row.avg_offline_rate; digits=4))")
    println("  Average daily plays: $(round(row.avg_daily_plays; digits=4))")
    println("  Average daily unique tracks: $(round(row.avg_daily_unique_tracks; digits=4))")
    println("  Average daily unique artists: $(round(row.avg_daily_unique_artists; digits=4))")
    println("  Average monthly plays: $(round(row.avg_monthly_plays; digits=4))")
    println("  Average yearly plays: $(round(row.avg_yearly_plays; digits=4))")
  end
  for (username, display_name) in names
    !(username in active_users) && no_data(display_name)
  end

  println("\nAverage Session Length (Group) (Minutes): ")
  println("$(round(first(group_avg_session_length).avg_session_length_minutes; digits=4))")

  println("\nAverage Session Length (per User) (Minutes)\n")

  active_session_users = Set(String.(user_avg_session_length.username))
  for row in eachrow(user_avg_session_length)
    username = row.username
    name = get(names, username, username)
    println("User: $name")
    println("  Average session length: $(round(row.avg_session_length_minutes; digits=4))")
  end
  for (username, display_name) in names
    !(username in active_session_users) && no_data(display_name)
  end

  println("\nTop Statistics (printing top 10)")

  println("\nTop Tracks (Group):\n")

  for i in 1:min(10, nrow(group_top_tracks))
    row = group_top_tracks[i, :]
    println("Track: $(row.track_name) by $(row.artist_name) from $(row.album_name)")
    println("  Play count: $(row.play_count)")
    println("  Total minutes played: $(round(row.total_minutes_played; digits=4))")
  end

  println("\nTop Artists (Group):\n")

  for i in 1:min(10, nrow(group_top_artists))
    row = group_top_artists[i, :]
    println("Artist: $(row.artist_name)")
    println("  Play count: $(row.play_count)")
    println("  Total minutes played: $(round(row.total_minutes_played; digits=4))")
  end

  println("\nTop Albums (Group):\n")

  for i in 1:min(10, nrow(group_top_albums))
    row = group_top_albums[i, :]
    println("Album: $(row.album_name) by $(row.artist_name)")
    println("  Play count: $(row.play_count)")
    println("  Total minutes played: $(round(row.total_minutes_played; digits=4))")
  end

  println("\nTop Tracks (per User):")

  for (name, df) in user_top_tracks
    println("\nUser: $name")
    if nrow(df) == 0
      no_data(name)
      continue
    end
    for i in 1:min(10, nrow(df))
      row = df[i, :]
      println("  Track: $(row.track_name) by $(row.artist_name) from $(row.album_name)")
      println("    Play count: $(row.play_count)")
      println("    Total minutes played: $(round(row.total_minutes_played; digits=4))")
    end
  end

  println("\nTop Artists (per User):")

  for (name, df) in user_top_artists
    println("\nUser: $name")
    if nrow(df) == 0
      no_data(name)
      continue
    end
    for i in 1:min(10, nrow(df))
      row = df[i, :]
      println("  Artist: $(row.artist_name)")
      println("    Play count: $(row.play_count)")
      println("    Total minutes played: $(round(row.total_minutes_played; digits=4))")
    end
  end

  println("\nTop Albums (per User):")

  for (name, df) in user_top_albums
    println("\nUser: $name")
    if nrow(df) == 0
      no_data(name)
      continue
    end
    for i in 1:min(10, nrow(df))
      row = df[i, :]
      println("  Album: $(row.album_name) by $(row.artist_name)")
      println("    Play count: $(row.play_count)")
      println("    Total minutes played: $(round(row.total_minutes_played; digits=4))")
    end
  end
end

function univariate_analysis(names)
  println("ALL-TIME STATISITCS")

  # run_univariate_analysis(names)

  println("\nPER-YEAR STATISITCS")

  for year in 2015:2026
    println("\nYear: $year")
    run_univariate_analysis(names, year=year)
  end
end