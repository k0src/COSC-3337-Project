include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie

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

# Data

function get_user_top_tracks(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      track_name,
      artist_name,
      album_name,
      COUNT(*) AS play_count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY track_name, artist_name, album_name
    ORDER BY play_count DESC
    LIMIT 20
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
      COUNT(*) AS play_count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY artist_name
    ORDER BY play_count DESC
    LIMIT 20
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
      COUNT(*) AS play_count
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY album_name, artist_name
    ORDER BY play_count DESC
    LIMIT 20
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Helpers

function truncate(s, maxlen=30)
  length(s) <= maxlen && return s
  return first(s, maxlen) * "..."
end

function two_line_label(name, artist)
  "$(truncate(name))\n$(truncate(artist))"
end

# Plots

function plot_top_tracks(df, username, display_name, year_label)
  nrow(df) == 0 && return
  n = min(10, nrow(df))

  counts = reverse(Int.(df.play_count[1:n]))
  labels = reverse([
    two_line_label(String(df.track_name[i]), String(df.artist_name[i]))
    for i in 1:n
  ])

  fig = Figure(size=(1000, 600))
  ax = Axis(fig[1, 1],
    title="Top 10 Tracks - $display_name - $(year_label == "alltime" ? "All-Time" : year_label)",
    xlabel="Play Count",
  )
  ax.yticks = (1:n, labels)
  barplot!(ax, 1:n, counts, direction=:x)

  fname = "top10_tracks_$(username)_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_top_artists(df, username, display_name, year_label)
  nrow(df) == 0 && return
  n = min(10, nrow(df))

  counts = reverse(Int.(df.play_count[1:n]))
  labels = reverse([truncate(String(df.artist_name[i])) for i in 1:n])

  fig = Figure(size=(1000, 600))
  ax = Axis(fig[1, 1],
    title="Top 10 Artists - $display_name - $(year_label == "alltime" ? "All-Time" : year_label)",
    xlabel="Play Count",
  )
  ax.yticks = (1:n, labels)
  barplot!(ax, 1:n, counts, direction=:x)

  fname = "top10_artists_$(username)_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_top_albums(df, username, display_name, year_label)
  nrow(df) == 0 && return
  n = min(10, nrow(df))

  counts = reverse(Int.(df.play_count[1:n]))
  labels = reverse([
    two_line_label(string(coalesce(df.album_name[i], "Unknown")), String(df.artist_name[i]))
    for i in 1:n
  ])

  fig = Figure(size=(1000, 600))
  ax = Axis(fig[1, 1],
    title="Top 10 Albums - $display_name - $(year_label == "alltime" ? "All-Time" : year_label)",
    xlabel="Play Count",
  )
  ax.yticks = (1:n, labels)
  barplot!(ax, 1:n, counts, direction=:x)

  fname = "top10_albums_$(username)_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

# Main

function main()
  all_data = Dict{String,Any}()

  for (year, year_label) in PERIODS
    period_data = Dict{String,Any}()

    for (username, display_name) in NAMES
      tracks_df = get_user_top_tracks(username, year=year)
      artists_df = get_user_top_artists(username, year=year)
      albums_df = get_user_top_albums(username, year=year)

      period_data[display_name] = Dict{String,Any}(
        "tracks" => [
          Dict{String,Any}(
            "track_name" => String(row.track_name),
            "artist_name" => String(row.artist_name),
            "album_name" => string(coalesce(row.album_name, "Unknown")),
            "play_count" => Int(row.play_count),
          )
          for row in eachrow(tracks_df)
        ],
        "artists" => [
          Dict{String,Any}(
            "artist_name" => String(row.artist_name),
            "play_count" => Int(row.play_count),
          )
          for row in eachrow(artists_df)
        ],
        "albums" => [
          Dict{String,Any}(
            "album_name" => string(coalesce(row.album_name, "Unknown")),
            "artist_name" => String(row.artist_name),
            "play_count" => Int(row.play_count),
          )
          for row in eachrow(albums_df)
        ],
      )

      plot_top_tracks(tracks_df, username, display_name, year_label)
      plot_top_artists(artists_df, username, display_name, year_label)
      plot_top_albums(albums_df, username, display_name, year_label)
    end

    all_data[year_label] = period_data
  end

  save_json("top_20.json", all_data)
end

main()
