include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using MultivariateStats
using LinearAlgebra
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_pca_2025")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const N_GENRES = 50
const N_ARROWS = 20

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
  genres = [kv[1] for kv in ranked[1:min(N_GENRES, length(ranked))]]
  g_idx = Dict(g => i for (i, g) in enumerate(genres))

  n_u = length(USER_ORDER)
  n_g = length(genres)
  raw = zeros(Float64, n_u, n_g)

  for row in eachrow(df)
    u = String(row.username)
    g = String(row.genre)
    ui = findfirst(==(u), USER_ORDER)
    (isnothing(ui) || !haskey(g_idx, g)) && continue
    raw[ui, g_idx[g]] += Int(row.plays)
  end

  for i in 1:n_u
    rs = sum(raw[i, :])
    rs > 0 && (raw[i, :] ./= rs)
  end

  return genres, raw
end

function run_pca(X)
  Xt = Matrix(X')
  M = fit(PCA, Xt; maxoutdim=2)

  scores = predict(M, Xt)'
  loadings = projection(M)

  var_exp = principalvars(M) ./ tvar(M)

  return scores, loadings, var_exp, M
end

function print_results(genres, scores, loadings, var_exp)
  @printf "Variance explained:  PC1 = %.1f%%   PC2 = %.1f%%\n" (var_exp[1] * 100) (var_exp[2] * 100)
  println()

  println("User scores:")
  @printf "  %-12s  %10s  %10s\n" "user" "PC1" "PC2"
  for (i, d) in enumerate(DISPLAY_ORDER)
    @printf "  %-12s  %10.4f  %10.4f\n" d scores[i, 1] scores[i, 2]
  end
  println()

  mags = [norm(loadings[i, :]) for i in 1:size(loadings, 1)]
  top_idx = sortperm(mags, rev=true)[1:min(N_ARROWS, length(mags))]
  println("Top genre loadings (by magnitude):")
  @printf "  %-30s  %10s  %10s  %10s\n" "genre" "PC1" "PC2" "|loading|"
  for i in top_idx
    @printf "  %-30s  %10.4f  %10.4f  %10.4f\n" genres[i] loadings[i, 1] loadings[i, 2] mags[i]
  end
  println()
end

function plot_biplot(genres, scores, loadings, var_exp, fname)
  n_g = size(loadings, 1)
  mags = [norm(loadings[i, :]) for i in 1:n_g]
  top_idx = sortperm(mags, rev=true)[1:min(N_ARROWS, n_g)]

  score_spread = maximum(abs.(scores))
  max_loading = maximum(mags[top_idx])
  arrow_scale = max_loading > 0 ? 0.80 * score_spread / max_loading : 1.0

  pc1_pct = round(var_exp[1] * 100, digits=1)
  pc2_pct = round(var_exp[2] * 100, digits=1)

  fig = Figure(size=(1000, 850))
  ax = Axis(fig[1, 1],
    title="Genre PCA Biplot - 2025\n(top $N_GENRES genres, top $N_ARROWS loading arrows shown)",
    xlabel="PC1 ($pc1_pct% var)",
    ylabel="PC2 ($pc2_pct% var)",
  )

  hlines!(ax, [0.0], color=:grey85, linewidth=0.8, linestyle=:dash)
  vlines!(ax, [0.0], color=:grey85, linewidth=0.8, linestyle=:dash)

  user_colors = Makie.wong_colors()
  for i in top_idx
    lx = loadings[i, 1] * arrow_scale
    ly = loadings[i, 2] * arrow_scale
    mag_frac = mags[i] / maximum(mags)
    col = (:grey55, 0.4 + 0.5 * mag_frac)
    arrows2d!(ax, [0.0], [0.0], [lx], [ly],
      color=col,
      shaftwidth=1.0,
      tipwidth=8,
      tiplength=8,
    )
    text!(ax, lx, ly,
      text=genres[i],
      align=(:center, lx >= 0 ? :bottom : :top),
      offset=(0, lx >= 0 ? 4 : -4),
      fontsize=9,
      color=:grey35,
    )
  end

  for (i, (d, u)) in enumerate(zip(DISPLAY_ORDER, USER_ORDER))
    scatter!(ax, [scores[i, 1]], [scores[i, 2]],
      color=user_colors[i],
      markersize=18,
      strokecolor=:white,
      strokewidth=1.5,
      label=d,
    )
    text!(ax, scores[i, 1], scores[i, 2],
      text=d,
      align=(:left, :bottom),
      offset=(7, 5),
      fontsize=13,
      color=user_colors[i],
      font=:bold,
    )
  end

  Legend(fig[1, 2], ax, "User", framevisible=false)

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)

  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  genres, X = build_matrix(df)
  scores, loadings, var_exp, _ = run_pca(X)

  print_results(genres, scores, loadings, var_exp)

  fname = joinpath(SCRIPT_DIR, "genre_pca_biplot_2025.png")
  plot_biplot(genres, scores, loadings, var_exp, fname)

  n_g = length(genres)
  save_json(joinpath(SCRIPT_DIR, "genre_pca_2025.json"), Dict{String,Any}(
    "genres" => genres,
    "variance_explained" => var_exp,
    "scores" => Dict(DISPLAY_ORDER[i] => scores[i, :] for i in 1:length(USER_ORDER)),
    "loadings" => Dict(genres[i] => loadings[i, :] for i in 1:n_g),
  ))
end

main()
