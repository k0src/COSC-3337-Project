include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_transition_matrix_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_N = 15

function get_data()
  conn = get_connection()
  query = """
    WITH sessions AS (
      SELECT
        username,
        timestamp,
        artist_name,
        CASE
          WHEN timestamp - LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp)
               > INTERVAL '30 minutes'
            OR LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp) IS NULL
          THEN 1 ELSE 0
        END AS is_new_session
      FROM listening_history
      WHERE EXTRACT(YEAR FROM timestamp) = 2025
        AND artist_name IS NOT NULL
    ),
    session_labeled AS (
      SELECT
        username,
        timestamp,
        artist_name,
        SUM(is_new_session) OVER (PARTITION BY username ORDER BY timestamp) AS session_id
      FROM sessions
    ),
    consecutive_pairs AS (
      SELECT
        username,
        LAG(artist_name) OVER (PARTITION BY username, session_id ORDER BY timestamp) AS prev_artist,
        artist_name AS curr_artist
      FROM session_labeled
    ),
    transitions AS (
      SELECT username, prev_artist, curr_artist
      FROM consecutive_pairs
      WHERE prev_artist IS NOT NULL
    )
    SELECT
      t.username,
      ag1.genre AS genre_from,
      ag2.genre AS genre_to,
      COUNT(*)::int AS n
    FROM  transitions   t
    JOIN  artist_genres ag1 ON t.prev_artist  = ag1.artist_name
    JOIN  artist_genres ag2 ON t.curr_artist  = ag2.artist_name
    GROUP BY t.username, ag1.genre, ag2.genre
    ORDER BY t.username, n DESC
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function top_genres(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return String[]

  totals = Dict{String,Int}()
  for row in eachrow(sub)
    g = String(row.genre_from)
    totals[g] = get(totals, g, 0) + Int(row.n)
  end

  ranked = sort(collect(totals), by=kv -> -kv[2])
  return [kv[1] for kv in ranked[1:min(TOP_N, length(ranked))]]
end

function build_matrix(df, username, genres)
  n = length(genres)
  g_idx = Dict(g => i for (i, g) in enumerate(genres))
  raw = zeros(Float64, n, n)

  sub = filter(r -> String(r.username) == username, df)
  for row in eachrow(sub)
    gf = String(row.genre_from)
    gt = String(row.genre_to)
    haskey(g_idx, gf) || continue
    haskey(g_idx, gt) || continue
    raw[g_idx[gf], g_idx[gt]] += Int(row.n)
  end

  normed = copy(raw)
  for i in 1:n
    rs = sum(raw[i, :])
    rs > 0 && (normed[i, :] ./= rs)
  end

  return raw, normed
end

function print_top_transitions(display_name, genres, normed)
  n = length(genres)
  println("$display_name  top transitions (genre_from → genre_to, row-normalised)")
  entries = vec([(genres[i], genres[j], normed[i, j]) for i in 1:n, j in 1:n])
  sort!(entries, by=e -> -e[3])
  @printf "  %-28s  %-28s  %8s\n" "from" "to" "prob"
  for (gf, gt, p) in entries[1:min(15, length(entries))]
    p > 0 || break
    @printf "  %-28s  %-28s  %8.3f\n" gf gt p
  end
  println()
end

function plot_heatmap(genres, normed, display_name, username, fname)
  n = length(genres)
  n == 0 && return

  fig = Figure(size=(980, 860))
  ax = Axis(fig[1, 1],
    title="Genre Transition Matrix (row-normalised) - $display_name - 2025",
    xlabel="Genre To",
    ylabel="Genre From",
    xticks=(1:n, genres),
    xticklabelrotation=pi / 3,
    yticks=(1:n, genres),
    yreversed=true,
  )

  hm = heatmap!(ax, 1:n, 1:n, normed',
    colormap=:YlOrRd,
    colorrange=(0.0, 1.0),
  )

  for i in 1:n, j in 1:n
    v = normed[i, j]
    v < 0.01 && continue
    text!(ax, j, i,
      text=@sprintf("%.2f", v),
      align=(:center, :center),
      fontsize=8,
      color=v > 0.5 ? :white : :black,
    )
  end

  Colorbar(fig[1, 2], hm, label="P(genre to | genre from)")

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  json_out = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    genres = top_genres(df, username)
    isempty(genres) && continue

    raw, normed = build_matrix(df, username, genres)
    print_top_transitions(display_name, genres, normed)

    fname = joinpath(PLOTS_DIR, "genre_transition_matrix_$(username).png")
    plot_heatmap(genres, normed, display_name, username, fname)

    json_out[display_name] = Dict{String,Any}(
      "genres" => genres,
      "raw_counts" => [[Int(raw[i, j]) for j in 1:length(genres)] for i in 1:length(genres)],
      "row_normalised" => [[normed[i, j] for j in 1:length(genres)] for i in 1:length(genres)],
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_transition_matrix_2025.json"), json_out)
end

main()
