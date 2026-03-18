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
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      COUNT(*) AS total_events,
      COUNT(DISTINCT track_id) AS unique_tracks,
      COUNT(DISTINCT artist_name) AS unique_artists,
      COUNT(DISTINCT album_name) AS unique_albums
    FROM listening_history
    $year_filter
    GROUP BY username
    ORDER BY username
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
    println("  Unique albums: $(row.unique_albums)\n")
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
