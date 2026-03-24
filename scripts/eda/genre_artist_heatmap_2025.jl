include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Clustering
using Distances
using LinearAlgebra
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_artist_heatmap_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_GENRES = 20
const TOP_ARTISTS = 20
const MIN_PLAYS_GENRE = 25

function get_data()
  conn = get_connection()
  query = """
    SELECT
      lh.username,
      ag.genre,
      lh.artist_name,
      COUNT(*)::int AS plays
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE EXTRACT(YEAR FROM lh.timestamp) = 2025
      AND lh.artist_name IS NOT NULL
    GROUP BY lh.username, ag.genre, lh.artist_name
    ORDER BY lh.username, plays DESC
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function user_matrix(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return String[], String[], Matrix{Float64}(undef, 0, 0)

  genre_totals = Dict{String,Int}()
  for row in eachrow(sub)
    g = String(row.genre)
    genre_totals[g] = get(genre_totals, g, 0) + Int(row.plays)
  end
  top_genres = [kv[1] for kv in
                sort([(g, n) for (g, n) in genre_totals if n >= MIN_PLAYS_GENRE], by=kv -> -kv[2])
  ][1:min(TOP_GENRES, end)]

  artist_totals = Dict{String,Int}()
  for row in eachrow(sub)
    a = String(row.artist_name)
    artist_totals[a] = get(artist_totals, a, 0) + Int(row.plays)
  end
  top_artists = [kv[1] for kv in
                 sort(collect(artist_totals), by=kv -> -kv[2])
  ][1:min(TOP_ARTISTS, length(artist_totals))]

  n_g = length(top_genres)
  n_a = length(top_artists)
  (n_g == 0 || n_a == 0) && return String[], String[], Matrix{Float64}(undef, 0, 0)

  g_idx = Dict(g => i for (i, g) in enumerate(top_genres))
  a_idx = Dict(a => j for (j, a) in enumerate(top_artists))

  mat = zeros(Float64, n_g, n_a)
  for row in eachrow(sub)
    g = String(row.genre)
    a = String(row.artist_name)
    haskey(g_idx, g) || continue
    haskey(a_idx, a) || continue
    mat[g_idx[g], a_idx[a]] += Int(row.plays)
  end

  return top_genres, top_artists, mat
end

function cluster_order(mat, dims)
  n = size(mat, dims)
  n <= 2 && return collect(1:n)

  if dims == 1
    norms = [norm(mat[i, :]) for i in 1:n]
    normed = hcat([norms[i] > 0 ? mat[i, :] ./ norms[i] : mat[i, :] for i in 1:n]...)'
  else
    norms = [norm(mat[:, j]) for j in 1:n]
    normed = hcat([norms[j] > 0 ? mat[:, j] ./ norms[j] : mat[:, j] for j in 1:n]...)
    normed = normed'
  end

  D = pairwise(CosineDist(), normed, dims=1)
  D[isnan.(D)] .= 1.0
  result = hclust(D, linkage=:average)
  return result.order
end

function print_summary(display_name, genres, artists, mat)
  println("$display_name  ($(length(genres)) genres x $(length(artists)) artists)")
  @printf "  %-30s  %8s\n" "genre" "top_artist"
  for (i, g) in enumerate(genres)
    best_j = argmax(mat[i, :])
    best_a = artists[best_j]
    best_n = Int(mat[i, best_j])
    best_n == 0 && continue
    @printf "  %-30s  %s (%d plays)\n" g best_a best_n
  end
  println()
end

function plot_heatmap(genres, artists, mat, display_name, username, fname)
  n_g, n_a = size(mat)
  (n_g == 0 || n_a == 0) && return

  g_ord = cluster_order(mat, 1)
  a_ord = cluster_order(mat, 2)

  genres_r = genres[g_ord]
  artists_r = artists[a_ord]
  mat_r = mat[g_ord, a_ord]

  display_mat = log1p.(mat_r)

  fig_w = max(800, n_a * 48 + 280)
  fig_h = max(600, n_g * 36 + 220)

  fig = Figure(size=(fig_w, fig_h))
  ax = Axis(fig[1, 1],
    title="Genre-Artist Play Heatmap (log scale) - $display_name - 2025",
    xlabel="Artist",
    ylabel="Genre",
    xticks=(1:n_a, artists_r),
    xticklabelrotation=pi / 3,
    yticks=(1:n_g, genres_r),
    yreversed=true,
  )

  hm = heatmap!(ax, 1:n_a, 1:n_g, display_mat',
    colormap=:YlOrRd,
  )

  Colorbar(fig[1, 2], hm, label="log(1 + plays)")

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
    genres, artists, mat = user_matrix(df, username)
    isempty(genres) && continue

    print_summary(display_name, genres, artists, mat)

    fname = joinpath(PLOTS_DIR, "genre_artist_heatmap_$(username).png")
    plot_heatmap(genres, artists, mat, display_name, username, fname)

    json_out[display_name] = Dict{String,Any}(
      "genres" => genres,
      "artists" => artists,
      "matrix" => [[Int(mat[i, j]) for j in 1:length(artists)] for i in 1:length(genres)],
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_artist_heatmap_2025.json"), json_out)
end

main()
