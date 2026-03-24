include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using Printf

const DATA_DIR   = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_user_heatmap_2025")

const USER_ORDER    = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_N = 20  

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
    ORDER BY lh.username, ag.genre
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function build_matrix(df)
  genre_totals = Dict{String,Int}()
  for row in eachrow(df)
    g = String(row.genre)
    genre_totals[g] = get(genre_totals, g, 0) + Int(row.plays)
  end
  ranked = sort(collect(genre_totals), by=kv -> -kv[2])
  genres = [kv[1] for kv in ranked[1:min(TOP_N, length(ranked))]]

  user_totals = Dict{String,Int}()
  for row in eachrow(df)
    u = String(row.username)
    user_totals[u] = get(user_totals, u, 0) + Int(row.plays)
  end

  n_g = length(genres)
  n_u = length(USER_ORDER)
  genre_idx = Dict(g => i for (i, g) in enumerate(genres))
  user_idx  = Dict(u => i for (i, u) in enumerate(USER_ORDER))

  raw = zeros(Int, n_g, n_u)
  for row in eachrow(df)
    g = String(row.genre)
    u = String(row.username)
    haskey(genre_idx, g) || continue
    haskey(user_idx, u)  || continue
    raw[genre_idx[g], user_idx[u]] += Int(row.plays)
  end

  # normalize each column by that user's total plays
  norm = zeros(Float64, n_g, n_u)
  for (j, u) in enumerate(USER_ORDER)
    tot = user_totals[u]
    tot > 0 && (norm[:, j] .= raw[:, j] ./ tot)
  end

  return genres, raw, norm
end

function avg_dist(D, a_members, b_members)
  total, count = 0.0, 0
  for a in a_members, b in b_members
    total += D[a, b]
    count += 1
  end
  return total / count
end

function hclust_order(mat)
  n = size(mat, 1)
  n == 1 && return [1]

  D = [sqrt(sum((mat[i, k] - mat[j, k])^2 for k in 1:size(mat, 2)))
       for i in 1:n, j in 1:n]

  clusters = [[i] for i in 1:n]
  active   = collect(1:n)

  for _ in 1:(n - 1)
    na = length(active)
    best_d, best_ai, best_aj = Inf, 1, 2
    for ai in 1:na, aj in (ai + 1):na
      d = avg_dist(D, clusters[active[ai]], clusters[active[aj]])
      if d < best_d
        best_d, best_ai, best_aj = d, ai, aj
      end
    end
    append!(clusters[active[best_ai]], clusters[active[best_aj]])
    deleteat!(active, best_aj)
  end

  return clusters[active[1]]
end

function print_table(genres, raw, norm)
  hdr = @sprintf "  %-30s" "genre"
  for d in DISPLAY_ORDER
    hdr *= @sprintf "  %10s" d
  end
  println(hdr)

  for (i, g) in enumerate(genres)
    row_str = @sprintf "  %-30s" g
    for j in 1:length(USER_ORDER)
      row_str *= @sprintf "  %9.2f%%" norm[i, j] * 100
    end
    println(row_str)
  end
  println()
end

function plot_heatmap(genres, norm, cluster_order, fname)
  ordered_genres = genres[cluster_order]
  ordered_norm   = norm[cluster_order, :]     # n_g × n_u

  n_g = length(ordered_genres)
  n_u = length(DISPLAY_ORDER)

  fig_h = max(520, n_g * 32 + 160)
  fig   = Figure(size=(560, fig_h))

  ax = Axis(fig[1, 1],
    title="Genre Share by User - 2025 (top $TOP_N genres, rows clustered)",
    xlabel="User",
    ylabel="Genre",
    xticks=(1:n_u, DISPLAY_ORDER),
    yticks=(1:n_g, ordered_genres),
    yreversed=true,
  )

  hm = heatmap!(ax, 1:n_u, 1:n_g, ordered_norm',
    colormap=:YlOrRd,
    colorrange=(0.0, maximum(norm)),
  )

  Colorbar(fig[1, 2], hm,
    label="Share of User's Total Plays",
    tickformat=vs -> [@sprintf("%.1f%%", v * 100) for v in vs],
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)

  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  genres, raw, norm = build_matrix(df)
  println("Top $TOP_N genres × $(length(USER_ORDER)) users")
  print_table(genres, raw, norm)

  cluster_order = hclust_order(norm)

  fname = joinpath(SCRIPT_DIR, "genre_user_heatmap_2025.png")
  plot_heatmap(genres, norm, cluster_order, fname)

  json_out = Dict{String,Any}(
    "genres"        => genres,
    "cluster_order" => cluster_order,
    "users"         => DISPLAY_ORDER,
    "matrix_raw"    => Dict(
      DISPLAY_ORDER[j] => raw[:, j] for j in 1:length(USER_ORDER)
    ),
    "matrix_norm"   => Dict(
      DISPLAY_ORDER[j] => norm[:, j] for j in 1:length(USER_ORDER)
    ),
  )

  save_json(joinpath(SCRIPT_DIR, "genre_user_heatmap_2025.json"), json_out)
end

main()
