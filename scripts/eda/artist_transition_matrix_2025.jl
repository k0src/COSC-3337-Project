include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "artist_transition_matrix_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_N = 10

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
        LAG(artist_name) OVER (PARTITION BY username, session_id ORDER BY timestamp) AS artist_from,
        artist_name AS artist_to
      FROM session_labeled
    )
    SELECT
      username,
      artist_from,
      artist_to,
      COUNT(*)::int AS n
    FROM  consecutive_pairs
    WHERE artist_from IS NOT NULL
    GROUP BY username, artist_from, artist_to
    ORDER BY username, n DESC
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function top_artists(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return String[]

  totals = Dict{String,Int}()
  for row in eachrow(sub)
    a = String(row.artist_from)
    totals[a] = get(totals, a, 0) + Int(row.n)
  end

  ranked = sort(collect(totals), by=kv -> -kv[2])
  return [kv[1] for kv in ranked[1:min(TOP_N, length(ranked))]]
end

function build_matrix(df, username, artists)
  n = length(artists)
  a_idx = Dict(a => i for (i, a) in enumerate(artists))
  raw = zeros(Float64, n, n)

  sub = filter(r -> String(r.username) == username, df)
  for row in eachrow(sub)
    af = String(row.artist_from)
    at = String(row.artist_to)
    haskey(a_idx, af) || continue
    haskey(a_idx, at) || continue
    raw[a_idx[af], a_idx[at]] += Int(row.n)
  end

  normed = copy(raw)
  for i in 1:n
    rs = sum(raw[i, :])
    rs > 0 && (normed[i, :] ./= rs)
  end

  return raw, normed
end

function print_top_transitions(display_name, artists, normed)
  n = length(artists)
  println("$display_name  top transitions (artist_from → artist_to, row-normalised)")
  entries = vec([(artists[i], artists[j], normed[i, j]) for i in 1:n, j in 1:n])
  sort!(entries, by=e -> -e[3])
  @printf "  %-28s  %-28s  %8s\n" "from" "to" "prob"
  for (af, at, p) in entries[1:min(15, length(entries))]
    p > 0 || break
    @printf "  %-28s  %-28s  %8.3f\n" af at p
  end
  println()
end

function plot_heatmap(artists, normed, display_name, username, fname)
  n = length(artists)
  n == 0 && return

  fig = Figure(size=(1100, 980))
  ax = Axis(fig[1, 1],
    title="Artist Transition Matrix (row-normalised) - $display_name - 2025",
    xlabel="Artist To",
    ylabel="Artist From",
    xticks=(1:n, artists),
    xticklabelrotation=pi / 3,
    yticks=(1:n, artists),
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
      fontsize=10,
      color=v > 0.5 ? :white : :black,
    )
  end

  Colorbar(fig[1, 2], hm, label="P(artist to | artist from)")

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
    artists = top_artists(df, username)
    isempty(artists) && continue

    raw, normed = build_matrix(df, username, artists)
    print_top_transitions(display_name, artists, normed)

    fname = joinpath(PLOTS_DIR, "artist_transition_matrix_$(username).png")
    plot_heatmap(artists, normed, display_name, username, fname)

    n = length(artists)
    json_out[display_name] = Dict{String,Any}(
      "artists" => artists,
      "raw_counts" => [[Int(raw[i, j]) for j in 1:n] for i in 1:n],
      "row_normalised" => [[normed[i, j] for j in 1:n] for i in 1:n],
    )
  end

  save_json(joinpath(SCRIPT_DIR, "artist_transition_matrix_2025.json"), json_out)
end

main()
