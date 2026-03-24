include(joinpath(@__DIR__, "..", "database.jl"))

using DataFrames

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

function get_user_summary(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM lh.timestamp) = $year"

  query = """
    SELECT
      lh.username,
      COUNT(*) AS total_events,
      COUNT(DISTINCT lh.track_id) AS unique_tracks,
      COUNT(DISTINCT lh.artist_name) AS unique_artists,
      COUNT(DISTINCT lh.album_name) AS unique_albums,
      COUNT(DISTINCT ag.genre) AS unique_genres
    FROM listening_history lh
    LEFT JOIN artist_genres ag ON lh.artist_name = ag.artist_name
    $year_filter
    GROUP BY lh.username
    ORDER BY lh.username
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function print_summary(; year=nothing)
  year_label = year === nothing ? "alltime" : string(year)

  user_summary = get_user_summary(year=year)

  if nrow(user_summary) == 0
    println("No data for $year_label\n")
    return
  end

  active_users = Set(String.(user_summary.username))

  for row in eachrow(user_summary)
    name = get(NAMES, String(row.username), String(row.username))
    println("$name:")
    println("  Total events: $(row.total_events)")
    println("  Unique tracks: $(row.unique_tracks)")
    println("  Unique artists: $(row.unique_artists)")
    println("  Unique albums: $(row.unique_albums)")
    println("  Unique genres: $(row.unique_genres)\n")
  end

  for (username, display_name) in NAMES
    !(username in active_users) && println("No data from $year_label for $display_name")
  end
end

function main()
  println("ALL-TIME STATISTICS\n")
  print_summary()

  println("\n2024 STATISTICS\n")
  print_summary(year=2024)

  println("\n2025 STATISTICS\n")
  print_summary(year=2025)
end

main()
