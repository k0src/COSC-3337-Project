include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using Printf

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["dasucc", "alanjzamora", "alexxxxxrs", "korenns"]
const DISPLAY_ORDER = ["Anthony", "Alan", "Alexandra", "Koren"]

const PERIODS = [
  ("2024", 2024),
  ("2025", 2025),
  ("alltime", nothing),
]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      lh.username,
      EXTRACT(YEAR FROM lh.timestamp)::INT  AS year,
      ag.genre,
      COUNT(*)                              AS play_count,
      COUNT(DISTINCT lh.artist_name)        AS artist_count
    FROM listening_history   lh
    JOIN artist_genres        ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
    GROUP BY lh.username,
             EXTRACT(YEAR FROM lh.timestamp)::INT,
             ag.genre
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function filter_period(df, year_filter)
  year_filter === nothing && return df
  filter(r -> r.year == year_filter, df)
end

function aggregate_genres(df)
  plays = Dict{String,Int}()
  artists = Dict{String,Int}()

  for row in eachrow(df)
    g = String(row.genre)
    plays[g] = get(plays, g, 0) + Int(row.play_count)
    artists[g] = get(artists, g, 0) + Int(row.artist_count)
  end

  genres = collect(keys(plays))
  return [(g, plays[g], artists[g]) for g in genres]
end

function print_comparison(display_name, period_label, by_plays, by_artists)
  n = min(10, length(by_plays), length(by_artists))
  println("$display_name - $period_label")

  @printf "  %4s  %-28s  %7s  %7s    %-28s  %7s  %7s\n" "rank" "by play count" "plays" "artists" "by artist count" "artists" "plays"
  println("  ", "-"^90)

  for i in 1:n
    p = by_plays[i]
    a = by_artists[i]
    @printf "  %4d  %-28s  %7d  %7d    %-28s  %7d  %7d\n" i p[1] p[2] p[3] a[1] a[3] a[2]
  end

  top_play = by_plays[1][1]
  top_artist = by_artists[1][1]
  diverges = top_play != top_artist

  println()
  println("  Top by plays:   $(by_plays[1][1])  ($(by_plays[1][2]) plays, $(by_plays[1][3]) artists)")
  println("  Top by artists: $(by_artists[1][1])  ($(by_artists[1][3]) artists, $(by_artists[1][2]) plays)")
  println("  Diverges:       $(diverges ? "YES" : "NO")")
  println()
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  all_data = Dict{String,Any}()

  for (period_label, year_filter) in PERIODS
    period_df = filter_period(df, year_filter)
    nrow(period_df) == 0 && continue

    all_data[period_label] = Dict{String,Any}()

    for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
      user_df = filter(r -> String(r.username) == username, period_df)
      nrow(user_df) == 0 && continue

      rows = aggregate_genres(user_df)

      by_plays = sort(rows, by=r -> -r[2])
      by_artists = sort(rows, by=r -> -r[3])

      print_comparison(display_name, period_label, by_plays, by_artists)

      top_play_row = by_plays[1]
      top_artist_row = by_artists[1]

      all_data[period_label][display_name] = Dict{String,Any}(
        "by_plays" => [
          Dict{String,Any}(
            "rank" => i,
            "genre" => by_plays[i][1],
            "play_count" => by_plays[i][2],
            "artist_count" => by_plays[i][3],
          )
          for i in 1:length(by_plays)
        ],
        "by_artists" => [
          Dict{String,Any}(
            "rank" => i,
            "genre" => by_artists[i][1],
            "artist_count" => by_artists[i][3],
            "play_count" => by_artists[i][2],
          )
          for i in 1:length(by_artists)
        ],
        "summary" => Dict{String,Any}(
          "top_play_genre" => top_play_row[1],
          "top_play_count" => top_play_row[2],
          "top_play_artist_count" => top_play_row[3],
          "top_artist_genre" => top_artist_row[1],
          "top_artist_count" => top_artist_row[3],
          "top_artist_play_count" => top_artist_row[2],
          "diverges" => top_play_row[1] != top_artist_row[1],
        ),
      )
    end
  end

  save_json("genre_plays_vs_artists.json", all_data)
end

main()
