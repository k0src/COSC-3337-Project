include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

function get_artist_data()
  conn = get_connection()

  query = """
    SELECT
      username,
      artist_name,
      COUNT(*)                                         AS play_count,
      AVG(ms_played)                                   AS avg_ms_played,
      AVG(CASE WHEN skipped THEN 1.0 ELSE 0.0 END)    AS skip_rate
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND ms_played   IS NOT NULL
      AND skipped     IS NOT NULL
      AND artist_name IS NOT NULL
    GROUP BY username, artist_name
    ORDER BY username, play_count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_track_data()
  conn = get_connection()

  query = """
    SELECT
      username,
      track_name,
      artist_name,
      COUNT(*)       AS play_count,
      AVG(ms_played) AS avg_ms_played
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND ms_played  IS NOT NULL
      AND track_name IS NOT NULL
    GROUP BY username, track_name, artist_name
    ORDER BY username, play_count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_album_data()
  conn = get_connection()

  query = """
    SELECT
      username,
      album_name,
      COUNT(*)                                         AS play_count,
      AVG(CASE WHEN skipped THEN 1.0 ELSE 0.0 END)    AS skip_rate
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND skipped    IS NOT NULL
      AND album_name IS NOT NULL
    GROUP BY username, album_name
    ORDER BY username, play_count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function safe_cor(x, y)
  length(x) < 3 && return NaN
  return cor(x, y)
end

function plot_artist_plays_vs_skip_rate(user_df, username, display_name)
  nrow(user_df) == 0 && return

  xs = Float64.(user_df.play_count)
  ys = Float64.(user_df.skip_rate)

  fig = Figure(size=(650, 500))
  ax = Axis(fig[1, 1],
    title="Artist Play Count vs. Skip Rate - $display_name - 2025",
    xlabel="Play Count (per artist)",
    ylabel="Skip Rate",
  )
  scatter!(ax, xs, ys, markersize=6, color=(Makie.wong_colors()[1], 0.6))

  fname = "artist_plays_vs_skip_rate_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_track_plays_vs_avg_duration(user_df, username, display_name)
  nrow(user_df) == 0 && return

  xs = Float64.(user_df.play_count)
  ys = Float64.(user_df.avg_ms_played) ./ 60000.0

  fig = Figure(size=(650, 500))
  ax = Axis(fig[1, 1],
    title="Track Play Count vs. Avg Play Duration - $display_name - 2025",
    xlabel="Play Count (per track)",
    ylabel="Avg Play Duration (minutes)",
  )
  scatter!(ax, xs, ys, markersize=6, color=(Makie.wong_colors()[2], 0.6))

  fname = "track_plays_vs_avg_duration_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_artist_plays_vs_avg_duration(user_df, username, display_name)
  nrow(user_df) == 0 && return

  xs = Float64.(user_df.play_count)
  ys = Float64.(user_df.avg_ms_played) ./ 60000.0

  fig = Figure(size=(650, 500))
  ax = Axis(fig[1, 1],
    title="Artist Play Count vs. Avg Play Duration - $display_name - 2025",
    xlabel="Play Count (per artist)",
    ylabel="Avg Play Duration (minutes)",
  )
  scatter!(ax, xs, ys, markersize=6, color=(Makie.wong_colors()[3], 0.6))

  fname = "artist_plays_vs_avg_duration_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_album_plays_vs_skip_rate(user_df, username, display_name)
  nrow(user_df) == 0 && return

  xs = Float64.(user_df.play_count)
  ys = Float64.(user_df.skip_rate)

  fig = Figure(size=(650, 500))
  ax = Axis(fig[1, 1],
    title="Album Play Count vs. Skip Rate - $display_name - 2025",
    xlabel="Play Count (per album)",
    ylabel="Skip Rate",
  )
  scatter!(ax, xs, ys, markersize=6, color=(Makie.wong_colors()[4], 0.6))

  fname = "album_plays_vs_skip_rate_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_artist_plays_vs_skip_rate_log(user_df, username, display_name)
  nrow(user_df) == 0 && return

  xs = Float64.(user_df.play_count)
  ys = Float64.(user_df.skip_rate)

  fig = Figure(size=(650, 500))
  ax = Axis(fig[1, 1],
    title="Artist Play Count vs. Skip Rate (Log Scale) - $display_name - 2025",
    xlabel="Play Count (per artist, log scale)",
    ylabel="Skip Rate",
    xscale=log10,
  )
  scatter!(ax, xs, ys, markersize=6, color=(Makie.wong_colors()[1], 0.6))

  fname = "artist_plays_vs_skip_rate_log_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_track_plays_vs_avg_duration_log(user_df, username, display_name)
  nrow(user_df) == 0 && return

  xs = Float64.(user_df.play_count)
  ys = Float64.(user_df.avg_ms_played) ./ 60000.0

  fig = Figure(size=(650, 500))
  ax = Axis(fig[1, 1],
    title="Track Play Count vs. Avg Play Duration (Log Scale) - $display_name - 2025",
    xlabel="Play Count (per track, log scale)",
    ylabel="Avg Play Duration (minutes)",
    xscale=log10,
  )
  scatter!(ax, xs, ys, markersize=6, color=(Makie.wong_colors()[2], 0.6))

  fname = "track_plays_vs_avg_duration_log_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_artist_plays_vs_avg_duration_log(user_df, username, display_name)
  nrow(user_df) == 0 && return

  xs = Float64.(user_df.play_count)
  ys = Float64.(user_df.avg_ms_played) ./ 60000.0

  fig = Figure(size=(650, 500))
  ax = Axis(fig[1, 1],
    title="Artist Play Count vs. Avg Play Duration (Log Scale) - $display_name - 2025",
    xlabel="Play Count (per artist, log scale)",
    ylabel="Avg Play Duration (minutes)",
    xscale=log10,
  )
  scatter!(ax, xs, ys, markersize=6, color=(Makie.wong_colors()[3], 0.6))

  fname = "artist_plays_vs_avg_duration_log_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_album_plays_vs_skip_rate_log(user_df, username, display_name)
  nrow(user_df) == 0 && return

  xs = Float64.(user_df.play_count)
  ys = Float64.(user_df.skip_rate)

  fig = Figure(size=(650, 500))
  ax = Axis(fig[1, 1],
    title="Album Play Count vs. Skip Rate (Log Scale) - $display_name - 2025",
    xlabel="Play Count (per album, log scale)",
    ylabel="Skip Rate",
    xscale=log10,
  )
  scatter!(ax, xs, ys, markersize=6, color=(Makie.wong_colors()[4], 0.6))

  fname = "album_plays_vs_skip_rate_log_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function main()
  artist_df = get_artist_data()
  track_df = get_track_data()
  album_df = get_album_data()

  j1 = Dict{String,Any}()
  j2 = Dict{String,Any}()
  j3 = Dict{String,Any}()
  j4 = Dict{String,Any}()

  for (username, display_name) in NAMES
    u_artist = filter(r -> String(r.username) == username, artist_df)
    u_track = filter(r -> String(r.username) == username, track_df)
    u_album = filter(r -> String(r.username) == username, album_df)

    println("$display_name:")

    if nrow(u_artist) > 0
      xs = Float64.(u_artist.play_count)
      ys = Float64.(u_artist.skip_rate)
      r = safe_cor(xs, ys)
      println("  artist plays vs skip rate    - n_artists=$(nrow(u_artist))  r=$(round(r, digits=4))")
      plot_artist_plays_vs_skip_rate(u_artist, username, display_name)
      plot_artist_plays_vs_skip_rate_log(u_artist, username, display_name)
      j1[display_name] = Dict{String,Any}(
        "n_artists" => nrow(u_artist),
        "correlation" => r,
        "points" => [
          Dict("artist" => String(row.artist_name),
            "play_count" => Int(row.play_count),
            "skip_rate" => Float64(row.skip_rate))
          for row in eachrow(u_artist)
        ],
      )
    end

    if nrow(u_track) > 0
      xs = Float64.(u_track.play_count)
      ys = Float64.(u_track.avg_ms_played) ./ 60000.0
      r = safe_cor(xs, ys)
      println("  track plays vs avg duration  - n_tracks=$(nrow(u_track))  r=$(round(r, digits=4))")
      plot_track_plays_vs_avg_duration(u_track, username, display_name)
      plot_track_plays_vs_avg_duration_log(u_track, username, display_name)
      j2[display_name] = Dict{String,Any}(
        "n_tracks" => nrow(u_track),
        "correlation" => r,
        "points" => [
          Dict("track" => String(row.track_name),
            "artist" => String(row.artist_name),
            "play_count" => Int(row.play_count),
            "avg_minutes" => Float64(row.avg_ms_played) / 60000.0)
          for row in eachrow(u_track)
        ],
      )
    end

    if nrow(u_artist) > 0
      xs = Float64.(u_artist.play_count)
      ys = Float64.(u_artist.avg_ms_played) ./ 60000.0
      r = safe_cor(xs, ys)
      println("  artist plays vs avg duration - n_artists=$(nrow(u_artist))  r=$(round(r, digits=4))")
      plot_artist_plays_vs_avg_duration(u_artist, username, display_name)
      plot_artist_plays_vs_avg_duration_log(u_artist, username, display_name)
      j3[display_name] = Dict{String,Any}(
        "n_artists" => nrow(u_artist),
        "correlation" => r,
        "points" => [
          Dict("artist" => String(row.artist_name),
            "play_count" => Int(row.play_count),
            "avg_minutes" => Float64(row.avg_ms_played) / 60000.0)
          for row in eachrow(u_artist)
        ],
      )
    end

    if nrow(u_album) > 0
      xs = Float64.(u_album.play_count)
      ys = Float64.(u_album.skip_rate)
      r = safe_cor(xs, ys)
      println("  album plays vs skip rate     - n_albums=$(nrow(u_album))  r=$(round(r, digits=4))")
      plot_album_plays_vs_skip_rate(u_album, username, display_name)
      plot_album_plays_vs_skip_rate_log(u_album, username, display_name)
      j4[display_name] = Dict{String,Any}(
        "n_albums" => nrow(u_album),
        "correlation" => r,
        "points" => [
          Dict("album" => String(row.album_name),
            "play_count" => Int(row.play_count),
            "skip_rate" => Float64(row.skip_rate))
          for row in eachrow(u_album)
        ],
      )
    end

    println()
  end

  save_json("artist_plays_vs_skip_rate_2025.json", j1)
  save_json("track_plays_vs_avg_duration_2025.json", j2)
  save_json("artist_plays_vs_avg_duration_2025.json", j3)
  save_json("album_plays_vs_skip_rate_2025.json", j4)
end

main()
