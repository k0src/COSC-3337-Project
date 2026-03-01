names = Dict(
  "Koren" => "korenns",
  "Alexandra" => "alexxxxxrs",
  "Alan" => "alanjzamora",
  "Anthony" => "dasucc",
)

function summary_statistics()
  conn = get_connection()

  println("Group Statistics\n")

  rows = first(execute(conn, "SELECT COUNT(*) FROM listening_history"))[1]
  println("Total number of listening events: $rows")

  unique_tracks = first(execute(conn, "SELECT COUNT(DISTINCT track_id) FROM listening_history"))[1]
  println("Number of unique tracks: $unique_tracks")

  unique_artists = first(execute(conn, "SELECT COUNT(DISTINCT artist_name) FROM listening_history"))[1]
  println("Number of unique artists: $unique_artists")

  unique_albums = first(execute(conn, "SELECT COUNT(DISTINCT album_name) FROM listening_history"))[1]
  println("Number of unique albums: $unique_albums")

  platforms = first(execute(conn, "SELECT COUNT(DISTINCT platform) FROM listening_history"))[1]
  println("Number of unique platforms: $platforms")

  countries = first(execute(conn, "SELECT COUNT(DISTINCT conn_country) FROM listening_history"))[1]
  println("Number of unique countries: $countries")

  println("\nIndividual Statistics\n")

  println("Total Listening Events per User:")

  for (name, username) in names
    rows = first(execute(conn, "SELECT COUNT(*) FROM listening_history WHERE username = '$username'"))[1]
    println("$name: $rows total listening events")
  end

  println("\nUnique Tracks per User:")

  for (name, username) in names
    unique_tracks = first(execute(conn, "SELECT COUNT(DISTINCT track_id) FROM listening_history WHERE username = '$username'"))[1]
    println("$name: $unique_tracks unique tracks")
  end

  println("\nUnique Artists per User:")

  for (name, username) in names
    unique_artists = first(execute(conn, "SELECT COUNT(DISTINCT artist_name) FROM listening_history WHERE username = '$username'"))[1]
    println("$name: $unique_artists unique artists")
  end

  println("\nUnique Albums per User:")

  for (name, username) in names
    unique_albums = first(execute(conn, "SELECT COUNT(DISTINCT album_name) FROM listening_history WHERE username = '$username'"))[1]
    println("$name: $unique_albums unique albums")
  end

  println("\nUnique Platforms per User:")

  for (name, username) in names
    platforms = first(execute(conn, "SELECT COUNT(DISTINCT platform) FROM listening_history WHERE username = '$username'"))[1]
    println("$name: $platforms unique platforms")
  end

  println("\nUnique Countries per User:")

  for (name, username) in names
    countries = first(execute(conn, "SELECT COUNT(DISTINCT conn_country) FROM listening_history WHERE username = '$username'"))[1]
    println("$name: $countries unique countries")
  end

  close(conn)
end
