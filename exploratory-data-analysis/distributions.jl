using Statistics
using StatsBase
using CairoMakie

# Stats helpers

function compute_stats(values)
  vals = Float64.(collect(skipmissing(values)))
  if length(vals) < 2
    return Dict{String,Any}()
  end
  int_vals = round.(Int, vals)
  freq = countmap(int_vals)
  max_freq = maximum(Base.values(freq))
  mode_vals = sort([k for (k, v) in freq if v == max_freq])
  Dict{String,Any}(
    "min" => minimum(vals),
    "max" => maximum(vals),
    "q1" => quantile(vals, 0.25),
    "median" => median(vals),
    "q3" => quantile(vals, 0.75),
    "mean" => mean(vals),
    "modes" => mode_vals,
    "std" => std(vals),
    "variance" => var(vals),
    "skewness" => skewness(vals),
  )
end

function compute_entropy_gini(values)
  vals = Float64.(collect(skipmissing(values)))
  total = sum(vals)
  if total == 0 || isempty(vals)
    return Dict{String,Any}("entropy" => 0.0, "gini" => 0.0)
  end
  p = vals ./ total
  entropy = -sum(x -> x > 0 ? x * log2(x) : 0.0, p)
  n = length(vals)
  sorted = sort(vals)
  gini = (2 * sum(i * sorted[i] for i in 1:n) / (n * total)) - (n + 1) / n
  Dict{String,Any}("entropy" => entropy, "gini" => gini)
end

# Data

function dist_get_group_daily_play_counts(; year=nothing)
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

function dist_get_user_daily_play_counts(username; year=nothing)
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

function dist_get_group_plays_per_track(; year=nothing)
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

function dist_get_user_plays_per_track(username; year=nothing)
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

function dist_get_group_plays_per_artist(; year=nothing)
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

function dist_get_user_plays_per_artist(username; year=nothing)
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

function dist_get_group_plays_per_album(; year=nothing)
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

function dist_get_user_plays_per_album(username; year=nothing)
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

function dist_get_group_session_lengths(; year=nothing)
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

function dist_get_user_session_lengths(username; year=nothing)
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

# Plots

function plot_boxplot_group(vals, title_str, fname, suffix)
  isempty(vals) && return
  fig = Figure(size=(600, 600))
  ax = Axis(fig[1, 1],
    title="$title_str - Group - $(suffix == "alltime" ? "All-Time" : suffix)",
    ylabel=title_str
  )
  hidedecorations!(ax, label=false, ticklabels=false, ticks=false)
  ax.xticks = ([1], ["Group"])
  boxplot!(ax, ones(Int, length(vals)), vals)
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_boxplot_users(vals_dict, title_str, fname, suffix)
  if all(isempty(v) for v in values(vals_dict))
    return
  end
  title_label = suffix == "alltime" ? "All-Time" : suffix
  user_keys = collect(keys(vals_dict))
  fig = Figure(size=(800, 600))
  ax = Axis(fig[1, 1],
    title="$title_str - Per User - $title_label",
    ylabel=title_str
  )
  ax.xticks = (1:length(user_keys), user_keys)
  for (i, k) in enumerate(user_keys)
    v = vals_dict[k]
    isempty(v) && continue
    boxplot!(ax, fill(i, length(v)), v)
  end
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_histogram_daily_group(vals, suffix)
  isempty(vals) && return
  title_label = suffix == "alltime" ? "All-Time" : suffix
  fig = Figure(size=(900, 600))
  ax = Axis(fig[1, 1],
    title="Daily Play Count Distribution - Group - $title_label",
    xlabel="Daily Play Count",
    ylabel="Density"
  )
  hist!(ax, vals, bins=40, normalization=:pdf, color=(:steelblue, 0.5))
  density!(ax, vals, color=(:transparent), strokecolor=:red, strokewidth=2)
  fname = "daily_play_count_hist_group_$suffix.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_histogram_daily_user(username, display_name, vals, suffix)
  isempty(vals) && return
  title_label = suffix == "alltime" ? "All-Time" : suffix
  fig = Figure(size=(900, 600))
  ax = Axis(fig[1, 1],
    title="Daily Play Count Distribution - $display_name - $title_label",
    xlabel="Daily Play Count",
    ylabel="Density"
  )
  hist!(ax, vals, bins=40, normalization=:pdf, color=(:steelblue, 0.5))
  density!(ax, vals, color=(:transparent), strokecolor=:red, strokewidth=2)
  fname = "daily_play_count_hist_$(username)_$suffix.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_histogram_log_group(vals, title_str, fname, suffix)
  isempty(vals) && return
  title_label = suffix == "alltime" ? "All-Time" : suffix
  log_vals = log.(vals .+ 1)
  fig = Figure(size=(900, 600))
  ax = Axis(fig[1, 1],
    title="$title_str Distribution (Log) - Group - $title_label",
    xlabel="log(Play Count + 1)",
    ylabel="Count"
  )
  hist!(ax, log_vals, bins=40)
  fname_full = fname * "_group_$suffix.png"
  save(fname_full, fig)
  println("Plot saved to $fname_full")
end

function plot_histogram_log_user(username, display_name, vals, title_str, fname, suffix)
  isempty(vals) && return
  title_label = suffix == "alltime" ? "All-Time" : suffix
  log_vals = log.(vals .+ 1)
  fig = Figure(size=(900, 600))
  ax = Axis(fig[1, 1],
    title="$title_str Distribution (Log) - $display_name - $title_label",
    xlabel="log(Play Count + 1)",
    ylabel="Count"
  )
  hist!(ax, log_vals, bins=40)
  fname_full = fname * "_$(username)_$suffix.png"
  save(fname_full, fig)
  println("Plot saved to $fname_full")
end

# Main

function run_distributions(names; year=nothing)
  println("\nCalculating...")

  year_label = year === nothing ? "alltime" : string(year)
  title_label = year === nothing ? "All-Time" : string(year)
  no_data(name) = println("No data for $name - $title_label")

  g_daily = dist_get_group_daily_play_counts(year=year)
  g_tracks = dist_get_group_plays_per_track(year=year)
  g_artists = dist_get_group_plays_per_artist(year=year)
  g_albums = dist_get_group_plays_per_album(year=year)
  g_sessions = dist_get_group_session_lengths(year=year)

  u_daily = Dict(u => dist_get_user_daily_play_counts(u, year=year) for u in keys(names))
  u_tracks = Dict(u => dist_get_user_plays_per_track(u, year=year) for u in keys(names))
  u_artists = Dict(u => dist_get_user_plays_per_artist(u, year=year) for u in keys(names))
  u_albums = Dict(u => dist_get_user_plays_per_album(u, year=year) for u in keys(names))
  u_sessions = Dict(u => dist_get_user_session_lengths(u, year=year) for u in keys(names))

  if nrow(g_daily) == 0
    println("No group data for $title_label")
    return
  end

  # Compute stats

  g_daily_vals = Float64.(collect(skipmissing(g_daily.play_count)))
  g_tracks_vals = Float64.(collect(skipmissing(g_tracks.play_count)))
  g_artists_vals = Float64.(collect(skipmissing(g_artists.play_count)))
  g_albums_vals = Float64.(collect(skipmissing(g_albums.play_count)))
  g_sessions_vals = Float64.(collect(skipmissing(g_sessions.session_length_minutes)))

  g_daily_stats = compute_stats(g_daily_vals)
  g_tracks_stats = compute_stats(g_tracks_vals)
  g_artists_stats = compute_stats(g_artists_vals)
  g_albums_stats = compute_stats(g_albums_vals)
  g_sessions_stats = compute_stats(g_sessions_vals)

  g_tracks_info = compute_entropy_gini(g_tracks_vals)
  g_artists_info = compute_entropy_gini(g_artists_vals)
  g_albums_info = compute_entropy_gini(g_albums_vals)

  u_daily_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in u_daily)
  u_tracks_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in u_tracks)
  u_artists_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in u_artists)
  u_albums_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in u_albums)
  u_sessions_vals = Dict(u => Float64.(collect(skipmissing(df.session_length_minutes))) for (u, df) in u_sessions)

  # Print

  println("\nGroup - $title_label\n")

  println("Daily Play Count:")
  for (k, v) in g_daily_stats
    k == "modes" && continue
    println("  $k: $(round(v; digits=4))")
  end
  println("  modes: $(g_daily_stats["modes"])")

  println("\nPlays per Track:")
  for (k, v) in g_tracks_stats
    k == "modes" && continue
    println("  $k: $(round(v; digits=4))")
  end
  println("  modes: $(g_tracks_stats["modes"])")
  println("  entropy: $(round(g_tracks_info["entropy"]; digits=4))")
  println("  gini: $(round(g_tracks_info["gini"]; digits=4))")

  println("\nPlays per Artist:")
  for (k, v) in g_artists_stats
    k == "modes" && continue
    println("  $k: $(round(v; digits=4))")
  end
  println("  modes: $(g_artists_stats["modes"])")
  println("  entropy: $(round(g_artists_info["entropy"]; digits=4))")
  println("  gini: $(round(g_artists_info["gini"]; digits=4))")

  println("\nPlays per Album:")
  for (k, v) in g_albums_stats
    k == "modes" && continue
    println("  $k: $(round(v; digits=4))")
  end
  println("  modes: $(g_albums_stats["modes"])")
  println("  entropy: $(round(g_albums_info["entropy"]; digits=4))")
  println("  gini: $(round(g_albums_info["gini"]; digits=4))")

  println("\nSession Lengths:")
  for (k, v) in g_sessions_stats
    k == "modes" && continue
    println("  $k: $(round(v; digits=4))")
  end
  println("  modes: $(g_sessions_stats["modes"])")

  println("\nPer User - $title_label")

  for (username, display_name) in names
    println("\n$display_name:")

    if isempty(u_daily_vals[username])
      no_data(display_name)
      continue
    end

    dv = u_daily_vals[username]
    tv = u_tracks_vals[username]
    av = u_artists_vals[username]
    bv = u_albums_vals[username]
    sv = u_sessions_vals[username]

    ds = compute_stats(dv)
    ts = compute_stats(tv)
    as_ = compute_stats(av)
    bs = compute_stats(bv)
    ss = compute_stats(sv)

    ti = compute_entropy_gini(tv)
    ai = compute_entropy_gini(av)
    bi = compute_entropy_gini(bv)

    println("\nDaily Play Count:")
    for (k, v) in ds
      k == "modes" && continue
      println("    $k: $(round(v; digits=4))")
    end
    println("  modes: $(ds["modes"])")

    println("\n  Plays per Track:")
    for (k, v) in ts
      k == "modes" && continue
      println("  $k: $(round(v; digits=4))")
    end
    println("  modes: $(ts["modes"])")
    println("  entropy: $(round(ti["entropy"]; digits=4))")
    println("  gini: $(round(ti["gini"]; digits=4))")

    println("\nPlays per Artist:")
    for (k, v) in as_
      k == "modes" && continue
      println("  $k: $(round(v; digits=4))")
    end
    println("  modes: $(as_["modes"])")
    println("  entropy: $(round(ai["entropy"]; digits=4))")
    println("  gini: $(round(ai["gini"]; digits=4))")

    println("\nPlays per Album:")
    for (k, v) in bs
      k == "modes" && continue
      println("  $k: $(round(v; digits=4))")
    end
    println("  modes: $(bs["modes"])")
    println("  entropy: $(round(bi["entropy"]; digits=4))")
    println("  gini: $(round(bi["gini"]; digits=4))")

    println("\nSession Lengths:")
    for (k, v) in ss
      k == "modes" && continue
      println("  $k: $(round(v; digits=4))")
    end
    println("  modes: $(ss["modes"])")
  end

  # Plots

  println("\nGenerating plots...")

  # Box plots - group

  plot_boxplot_group(g_daily_vals,
    "Daily Play Count", "daily_play_count_boxplot_group_$year_label.png", year_label)
  plot_boxplot_group(log.(g_tracks_vals .+ 1),
    "log(Plays per Track + 1)", "plays_per_track_boxplot_group_$year_label.png", year_label)
  plot_boxplot_group(log.(g_artists_vals .+ 1),
    "log(Plays per Artist + 1)", "plays_per_artist_boxplot_group_$year_label.png", year_label)
  plot_boxplot_group(log.(g_albums_vals .+ 1),
    "log(Plays per Album + 1)", "plays_per_album_boxplot_group_$year_label.png", year_label)
  plot_boxplot_group(log.(g_sessions_vals .+ 1),
    "log(Session Length + 1)", "session_length_boxplot_group_$year_label.png", year_label)

  # Box plots - per user

  plot_boxplot_users(
    Dict(names[u] => u_daily_vals[u] for u in keys(names)),
    "Daily Play Count", "daily_play_count_boxplot_users_$year_label.png", year_label)
  plot_boxplot_users(
    Dict(names[u] => log.(u_tracks_vals[u] .+ 1) for u in keys(names)),
    "log(Plays per Track + 1)", "plays_per_track_boxplot_users_$year_label.png", year_label)
  plot_boxplot_users(
    Dict(names[u] => log.(u_artists_vals[u] .+ 1) for u in keys(names)),
    "log(Plays per Artist + 1)", "plays_per_artist_boxplot_users_$year_label.png", year_label)
  plot_boxplot_users(
    Dict(names[u] => log.(u_albums_vals[u] .+ 1) for u in keys(names)),
    "log(Plays per Album + 1)", "plays_per_album_boxplot_users_$year_label.png", year_label)
  plot_boxplot_users(
    Dict(names[u] => log.(u_sessions_vals[u] .+ 1) for u in keys(names)),
    "log(Session Length + 1)", "session_length_boxplot_users_$year_label.png", year_label)

  # Histograms - daily 

  plot_histogram_daily_group(g_daily_vals, year_label)
  for (username, display_name) in names
    plot_histogram_daily_user(username, display_name, u_daily_vals[username], year_label)
  end

  # Histograms - plays per track/artist/album (log transformed)

  plot_histogram_log_group(g_tracks_vals, "Plays per Track", "plays_per_track_hist", year_label)
  plot_histogram_log_group(g_artists_vals, "Plays per Artist", "plays_per_artist_hist", year_label)
  plot_histogram_log_group(g_albums_vals, "Plays per Album", "plays_per_album_hist", year_label)
  for (username, display_name) in names
    plot_histogram_log_user(
      username,
      display_name,
      u_tracks_vals[username],
      "Plays per Track", "plays_per_track_hist",
      year_label
    )
    plot_histogram_log_user(
      username,
      display_name,
      u_artists_vals[username],
      "Plays per Artist",
      "plays_per_artist_hist",
      year_label
    )
    plot_histogram_log_user(
      username,
      display_name,
      u_albums_vals[username],
      "Plays per Album",
      "plays_per_album_hist",
      year_label
    )
  end

  # Save JSON

  println("\nSaving JSON...")

  daily_to_labeled(df) = [
    Dict("date" => string(coalesce(r.date, "")), "play_count" => Int(coalesce(r.play_count, 0)))
    for r in eachrow(df)
  ]

  tracks_to_labeled(df) = [
    Dict(
      "track_name" => string(coalesce(r.track_name, "Unknown")),
      "artist_name" => string(coalesce(r.artist_name, "Unknown")),
      "play_count" => Int(coalesce(r.play_count, 0))
    )
    for r in eachrow(df)
  ]

  artists_to_labeled(df) = [
    Dict(
      "artist_name" => string(coalesce(r.artist_name, "Unknown")),
      "play_count" => Int(coalesce(r.play_count, 0))
    )
    for r in eachrow(df)
  ]

  albums_to_labeled(df) = [
    Dict(
      "album_name" => string(coalesce(r.album_name, "Unknown")),
      "artist_name" => string(coalesce(r.artist_name, "Unknown")),
      "play_count" => Int(coalesce(r.play_count, 0))
    )
    for r in eachrow(df)
  ]

  sessions_to_labeled(df) = [
    Float64(coalesce(r.session_length_minutes, 0.0))
    for r in eachrow(df)
  ]

  data = Dict{String,Any}(
    "group" => Dict{String,Any}(
      "daily_play_count" => Dict{String,Any}(
        "stats" => g_daily_stats,
        "data" => daily_to_labeled(g_daily),
      ),
      "plays_per_track" => Dict{String,Any}(
        "stats" => merge(g_tracks_stats, g_tracks_info),
        "data" => tracks_to_labeled(g_tracks),
      ),
      "plays_per_artist" => Dict{String,Any}(
        "stats" => merge(g_artists_stats, g_artists_info),
        "data" => artists_to_labeled(g_artists),
      ),
      "plays_per_album" => Dict{String,Any}(
        "stats" => merge(g_albums_stats, g_albums_info),
        "data" => albums_to_labeled(g_albums),
      ),
      "session_length" => Dict{String,Any}(
        "stats" => g_sessions_stats,
        "data" => sessions_to_labeled(g_sessions),
      ),
    ),
    "users" => Dict{String,Any}(
      display_name => begin
        dv = u_daily_vals[username]
        tv = u_tracks_vals[username]
        av = u_artists_vals[username]
        bv = u_albums_vals[username]
        sv = u_sessions_vals[username]
        Dict{String,Any}(
          "daily_play_count" => Dict{String,Any}(
            "stats" => compute_stats(dv),
            "data" => daily_to_labeled(u_daily[username]),
          ),
          "plays_per_track" => Dict{String,Any}(
            "stats" => merge(compute_stats(tv), compute_entropy_gini(tv)),
            "data" => tracks_to_labeled(u_tracks[username]),
          ),
          "plays_per_artist" => Dict{String,Any}(
            "stats" => merge(compute_stats(av), compute_entropy_gini(av)),
            "data" => artists_to_labeled(u_artists[username]),
          ),
          "plays_per_album" => Dict{String,Any}(
            "stats" => merge(compute_stats(bv), compute_entropy_gini(bv)),
            "data" => albums_to_labeled(u_albums[username]),
          ),
          "session_length" => Dict{String,Any}(
            "stats" => compute_stats(sv),
            "data" => sessions_to_labeled(u_sessions[username]),
          ),
        )
      end
      for (username, display_name) in names
    ),
  )

  save_json("distributions_$year_label.json", data)
end

function distributions(names)
  println("ALL-TIME DISTRIBUTIONS")
  run_distributions(names)

  println("\nPER-YEAR DISTRIBUTIONS")
  for year in 2015:2026
    println("\nYear: $year")
    run_distributions(names, year=year)
  end
end
