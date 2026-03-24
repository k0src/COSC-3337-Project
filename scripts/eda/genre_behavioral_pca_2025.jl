include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using MultivariateStats
using LinearAlgebra
using Statistics
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_behavioral_pca_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const MONTH_ABBR = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

const FEATURE_NAMES = ["plays", "skip_rate", "shuffle_rate",
  "artist_entropy", "genre_entropy",
  "genre_gini", "top1_genre_share"]

function get_monthly_totals()
  conn = get_connection()
  query = """
    SELECT
      username,
      TO_CHAR(DATE_TRUNC('month', timestamp), 'YYYY-MM') AS month,
      COUNT(*)::int                                        AS plays,
      AVG(CASE WHEN skipped      THEN 1.0 ELSE 0.0 END)  AS skip_rate,
      AVG(CASE WHEN shuffle THEN 1.0 ELSE 0.0 END)       AS shuffle_rate
    FROM  listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND artist_name IS NOT NULL
    GROUP BY username, month
    ORDER BY username, month
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_artist_plays()
  conn = get_connection()
  query = """
    SELECT
      username,
      TO_CHAR(DATE_TRUNC('month', timestamp), 'YYYY-MM') AS month,
      artist_name,
      COUNT(*)::int AS plays
    FROM  listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND artist_name IS NOT NULL
    GROUP BY username, month, artist_name
    ORDER BY username, month
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_genre_plays()
  conn = get_connection()
  query = """
    SELECT
      lh.username,
      TO_CHAR(DATE_TRUNC('month', lh.timestamp), 'YYYY-MM') AS month,
      ag.genre,
      COUNT(*)::int AS plays
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE EXTRACT(YEAR FROM lh.timestamp) = 2025
      AND lh.artist_name IS NOT NULL
    GROUP BY lh.username, month, ag.genre
    ORDER BY lh.username, month
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function shannon_entropy(counts::Vector{Int})
  total = sum(counts)
  total == 0 && return 0.0
  h = 0.0
  for c in counts
    c == 0 && continue
    p = c / total
    h -= p * log2(p)
  end
  return h
end

function gini_coeff(counts::Vector{Int})
  n = length(counts)
  (n == 0 || sum(counts) == 0) && return 0.0
  s = sort(counts)
  total = sum(s)
  cum = cumsum(s)
  return 1.0 - 2.0 * sum(cum) / (n * total) + 1.0 / n
end

function build_features(totals_df, artist_df, genre_df)
  artist_entropy = Dict{Tuple{String,String},Float64}()
  for sub_key in unique(zip(String.(artist_df.username), String.(artist_df.month)))
    u, m = sub_key
    counts = [Int(row.plays)
              for row in eachrow(artist_df)
              if String(row.username) == u && String(row.month) == m]
    artist_entropy[(u, m)] = shannon_entropy(counts)
  end

  genre_entropy_map = Dict{Tuple{String,String},Float64}()
  genre_gini_map = Dict{Tuple{String,String},Float64}()
  top1_share_map = Dict{Tuple{String,String},Float64}()

  for sub_key in unique(zip(String.(genre_df.username), String.(genre_df.month)))
    u, m = sub_key
    counts = [Int(row.plays)
              for row in eachrow(genre_df)
              if String(row.username) == u && String(row.month) == m]
    total = sum(counts)
    genre_entropy_map[(u, m)] = shannon_entropy(counts)
    genre_gini_map[(u, m)] = gini_coeff(counts)
    top1_share_map[(u, m)] = total > 0 ? maximum(counts) / total : 0.0
  end

  rows = NamedTuple[]
  for row in eachrow(totals_df)
    u = String(row.username)
    m = String(row.month)
    key = (u, m)
    haskey(artist_entropy, key) || continue
    haskey(genre_entropy_map, key) || continue

    push!(rows, (
      username=u,
      month=m,
      month_int=parse(Int, m[6:7]),
      plays=Int(row.plays),
      skip_rate=Float64(row.skip_rate),
      shuffle_rate=Float64(row.shuffle_rate),
      artist_entropy=artist_entropy[key],
      genre_entropy=genre_entropy_map[key],
      genre_gini=genre_gini_map[key],
      top1_share=top1_share_map[key],
    ))
  end

  return rows
end

function run_pca(all_rows)
  n = length(all_rows)
  n_f = length(FEATURE_NAMES)

  X = zeros(Float64, n, n_f)
  for (i, r) in enumerate(all_rows)
    X[i, :] = [r.plays, r.skip_rate, r.shuffle_rate,
      r.artist_entropy, r.genre_entropy,
      r.genre_gini, r.top1_share]
  end

  μ = mean(X, dims=1)
  σ = std(X, dims=1)
  σ[σ.==0] .= 1.0
  Xz = (X .- μ) ./ σ

  M = fit(PCA, Matrix(Xz'); maxoutdim=2)
  scores = predict(M, Matrix(Xz'))'
  loadings = projection(M)
  var_exp = principalvars(M) ./ tvar(M)

  scores_dict = Dict{String,Vector{NamedTuple}}()
  for (i, r) in enumerate(all_rows)
    u = r.username
    haskey(scores_dict, u) || (scores_dict[u] = NamedTuple[])
    push!(scores_dict[u], (month_int=r.month_int, pc1=scores[i, 1], pc2=scores[i, 2]))
  end
  for u in keys(scores_dict)
    sort!(scores_dict[u], by=r -> r.month_int)
  end

  return scores_dict, loadings, var_exp
end

function print_results(loadings, var_exp)
  @printf "Variance explained:  PC1 = %.1f%%   PC2 = %.1f%%\n" (var_exp[1] * 100) (var_exp[2] * 100)
  println()
  println("Feature loadings:")
  @printf "  %-20s  %10s  %10s\n" "feature" "PC1" "PC2"
  for (i, f) in enumerate(FEATURE_NAMES)
    @printf "  %-20s  %10.4f  %10.4f\n" f loadings[i, 1] loadings[i, 2]
  end
  println()
end

function plot_trajectory(pts, display_name, username, var_exp, fname)
  isempty(pts) && return

  xs = [p.pc1 for p in pts]
  ys = [p.pc2 for p in pts]
  ms = [p.month_int for p in pts]

  pc1_pct = round(var_exp[1] * 100, digits=1)
  pc2_pct = round(var_exp[2] * 100, digits=1)

  fig = Figure(size=(750, 620))
  ax = Axis(fig[1, 1],
    title="Behavioral Trajectory - $display_name - 2025\n(PC1 $pc1_pct%  PC2 $pc2_pct%)",
    xlabel="PC1 ($pc1_pct% var)",
    ylabel="PC2 ($pc2_pct% var)",
  )

  hlines!(ax, [0.0], color=:grey88, linewidth=0.8, linestyle=:dash)
  vlines!(ax, [0.0], color=:grey88, linewidth=0.8, linestyle=:dash)

  lines!(ax, xs, ys, color=:grey70, linewidth=1.5)

  sc = scatter!(ax, xs, ys,
    color=Float64.(ms),
    colormap=:viridis,
    colorrange=(1.0, 12.0),
    markersize=14,
    strokecolor=:white,
    strokewidth=1,
  )

  for (x, y, m) in zip(xs, ys, ms)
    text!(ax, x, y,
      text=MONTH_ABBR[m],
      align=(:center, :bottom),
      offset=(0, 7),
      fontsize=11,
    )
  end

  Colorbar(fig[1, 2], sc,
    label="Month",
    ticks=([1, 4, 7, 10], ["Jan", "Apr", "Jul", "Oct"]),
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  println("Fetching data...")
  totals_df = get_monthly_totals()
  artist_df = get_artist_plays()
  genre_df = get_genre_plays()

  all_rows = build_features(totals_df, artist_df, genre_df)
  isempty(all_rows) && (println("No data"); return)

  println("$(length(all_rows)) (user, month) observations across $(length(USER_ORDER)) users\n")

  scores_dict, loadings, var_exp = run_pca(all_rows)
  print_results(loadings, var_exp)

  json_out = Dict{String,Any}(
    "features" => FEATURE_NAMES,
    "variance_explained" => var_exp,
    "loadings" => Dict(FEATURE_NAMES[i] => loadings[i, :] for i in 1:length(FEATURE_NAMES)),
  )

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    pts = get(scores_dict, username, NamedTuple[])
    isempty(pts) && continue

    println("$display_name  ($(length(pts)) months)")
    @printf "  %-5s  %10s  %10s\n" "month" "PC1" "PC2"
    for p in pts
      @printf "  %-5s  %10.4f  %10.4f\n" MONTH_ABBR[p.month_int] p.pc1 p.pc2
    end
    println()

    fname = joinpath(PLOTS_DIR, "genre_behavioral_pca_$(username).png")
    plot_trajectory(pts, display_name, username, var_exp, fname)

    json_out[display_name] = [
      Dict{String,Any}("month" => MONTH_ABBR[p.month_int], "pc1" => p.pc1, "pc2" => p.pc2)
      for p in pts
    ]
  end

  save_json(joinpath(SCRIPT_DIR, "genre_behavioral_pca_2025.json"), json_out)
end

main()
