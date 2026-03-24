include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using StatsBase
using Colors

const DATA_DIR = joinpath(@__DIR__, "..", "..", "data", "distributions")
const PLOTS_DIR = joinpath(DATA_DIR, "plots")
mkpath(PLOTS_DIR)

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]

const USER_COLORS = Dict(
  "alanjzamora" => colorant"#4C72B0",
  "alexxxxxrs" => colorant"#DD8452",
  "dasucc" => colorant"#55A868",
  "korenns" => colorant"#C44E52",
)

const PERIODS = [
  (nothing, "alltime"),
  (2024, "2024"),
  (2025, "2025"),
]

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

function n_bins_fd(vals::Vector{Float64})
  n = length(vals)
  n < 4 && return 10
  iqr_val = quantile(vals, 0.75) - quantile(vals, 0.25)
  rng = maximum(vals) - minimum(vals)
  (iqr_val ≈ 0 || rng ≈ 0) && return 20
  bw = 2.0 * iqr_val / n^(1.0 / 3.0)
  clamp(round(Int, rng / bw), 10, 60)
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

function get_user_plays_per_track(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"
  query = """
    SELECT track_name, artist_name, COUNT(*) AS play_count
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
    SELECT artist_name, COUNT(*) AS play_count
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
    SELECT album_name, artist_name, COUNT(*) AS play_count
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

function get_user_plays_per_genre(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM lh.timestamp) = $year"
  query = """
    SELECT ag.genre, COUNT(*) AS play_count
    FROM listening_history lh
    JOIN artist_genres ag ON lh.artist_name = ag.artist_name
    WHERE lh.username = '$username'
    $year_filter
    GROUP BY ag.genre
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

function plot_boxplot(vals_dict, key, year_label)
  all(isempty(v) for v in values(vals_dict)) && return

  display_names = [NAMES[u] for u in USER_ORDER]
  n = length(USER_ORDER)

  fig = Figure(size=(800, 600))
  ax = Axis(fig[1, 1],
    ylabel="Value (log scale)",
    yscale=log10,
  )
  ax.xticks = (1:n, display_names)

  for (i, username) in enumerate(USER_ORDER)
    vals = filter(v -> v > 0, get(vals_dict, username, Float64[]))
    isempty(vals) && continue
    boxplot!(ax, fill(i, length(vals)), vals,
      show_outliers=true,
      color=(USER_COLORS[username], 0.75))
  end

  fname = joinpath(PLOTS_DIR, "boxplot_$(key)_$(year_label).png")
  save(fname, fig)
  println("Plot saved to $fname")
end

const LOG_TRANSFORM_KEYS = Set([
  "plays_per_track", "plays_per_artist", "plays_per_album",
  "plays_per_genre", "session_length",
])

function plot_histogram(vals_dict, key, year_label)
  use_log = key in LOG_TRANSFORM_KEYS

  for username in USER_ORDER
    raw_vals = get(vals_dict, username, Float64[])

    if use_log
      plot_vals = log10.(filter(v -> v > 0, raw_vals))
    else
      plot_vals = filter(v -> isfinite(v), raw_vals)
    end

    isempty(plot_vals) && continue

    fig = Figure(size=(800, 500))
    ax = Axis(fig[1, 1],
      xlabel=use_log ? "log₁₀(plays)" : key,
      ylabel="Density",
    )

    if use_log
      lo = floor(Int, minimum(plot_vals))
      hi = ceil(Int, maximum(plot_vals))
      tick_pos = Float64.(lo:hi)
      tick_labels = [v == 0 ? "1" : "10^$v" for v in lo:hi]
      ax.xticks = (tick_pos, tick_labels)
    end

    nbins = n_bins_fd(plot_vals)
    hist!(ax, plot_vals,
      bins=nbins,
      normalization=:pdf,
      color=(USER_COLORS[username], 0.55))

    density!(ax, plot_vals,
      color=(:black, 0.0),
      strokecolor=USER_COLORS[username],
      strokewidth=2.5)

    fname = joinpath(PLOTS_DIR, "histogram_$(key)_$(username)_$(year_label).png")
    save(fname, fig)
    println("Plot saved to $fname")
  end
end

function main()
  for (year, year_label) in PERIODS
    title_label = year_label == "alltime" ? "All-Time" : year_label
    println("\n$(title_label)\n")

    daily_dfs = Dict(u => get_user_daily_play_counts(u, year=year) for u in keys(NAMES))
    track_dfs = Dict(u => get_user_plays_per_track(u, year=year) for u in keys(NAMES))
    artist_dfs = Dict(u => get_user_plays_per_artist(u, year=year) for u in keys(NAMES))
    album_dfs = Dict(u => get_user_plays_per_album(u, year=year) for u in keys(NAMES))
    genre_dfs = Dict(u => get_user_plays_per_genre(u, year=year) for u in keys(NAMES))
    session_dfs = Dict(u => get_user_session_lengths(u, year=year) for u in keys(NAMES))

    daily_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in daily_dfs)
    track_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in track_dfs)
    artist_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in artist_dfs)
    album_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in album_dfs)
    genre_vals = Dict(u => Float64.(collect(skipmissing(df.play_count))) for (u, df) in genre_dfs)
    session_vals = Dict(u => Float64.(collect(skipmissing(df.session_length_minutes))) for (u, df) in session_dfs)

    attrs = [
      ("Daily Play Count", "daily_play_count", daily_vals, daily_dfs),
      ("Plays per Track", "plays_per_track", track_vals, track_dfs),
      ("Plays per Artist", "plays_per_artist", artist_vals, artist_dfs),
      ("Plays per Album", "plays_per_album", album_vals, album_dfs),
      ("Plays per Genre", "plays_per_genre", genre_vals, genre_dfs),
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
        elseif key == "plays_per_genre"
          [Dict{String,Any}("genre" => String(r.genre), "play_count" => Int(r.play_count))
           for r in eachrow(df)]
        else
          [Float64(r.session_length_minutes) for r in eachrow(df)]
        end

        attr_json[display_name] = Dict{String,Any}(
          "stats" => stats,
          "data" => data,
        )
      end

      plot_boxplot(vals_dict, key, year_label)
      plot_histogram(vals_dict, key, year_label)
      save_json(joinpath(DATA_DIR, "$(key)_$(year_label).json"), attr_json)
    end
  end
end

main()
