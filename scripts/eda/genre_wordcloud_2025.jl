include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using WordCloud
using Colors
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_wordcloud_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_N = 50

const PALETTE = [
  "#e63946", "#457b9d", "#2a9d8f",
  "#e9c46a", "#f4a261", "#a8dadc",
  "#6a4c93", "#52b788", "#f77f00",
  "#4cc9f0", "#c77dff", "#80b918",
  "#ff6b6b", "#48cae4", "#fb8500",
]

function get_data()
  conn = get_connection()
  query = """
    SELECT
      lh.username,
      ag.genre,
      COUNT(*)::int AS plays
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE EXTRACT(YEAR FROM lh.timestamp) = 2025
      AND lh.artist_name IS NOT NULL
    GROUP BY lh.username, ag.genre
    ORDER BY lh.username, plays DESC
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function user_top_genres(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return String[], Int[]
  n = min(TOP_N, nrow(sub))
  return String.(sub.genre[1:n]), Int.(sub.plays[1:n])
end

function print_summary(display_name, words, counts)
  println("$display_name  ($(length(words)) genres)")
  for (w, c) in zip(words[1:min(10, end)], counts[1:min(10, end)])
    @printf "  %-32s  %d\n" w c
  end
  length(words) > 10 && println("  ... $(length(words)-10) more")
  println()
end

function make_wordcloud(words, counts, display_name, username, fname)
  isempty(words) && return

  n = length(words)
  colors = [PALETTE[mod1(i, length(PALETTE))] for i in 1:n]

  wc = wordcloud(
    words, Float64.(counts);
    mask=shape(box, 2600, 1600, color=colorant"white"),
    colors=colors,
    fonts="Arial",
    angles=0,
    density=0.45,
    maxfontsize=55,
  )

  generate!(wc)
  paint(wc, fname)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  json_out = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    words, counts = user_top_genres(df, username)
    isempty(words) && continue

    print_summary(display_name, words, counts)

    fname = joinpath(PLOTS_DIR, "genre_wordcloud_$(username).png")
    make_wordcloud(words, counts, display_name, username, fname)

    json_out[display_name] = [
      Dict{String,Any}("genre" => w, "plays" => c)
      for (w, c) in zip(words, counts)
    ]
  end

  save_json(joinpath(SCRIPT_DIR, "genre_wordcloud_2025.json"), json_out)
end

main()
