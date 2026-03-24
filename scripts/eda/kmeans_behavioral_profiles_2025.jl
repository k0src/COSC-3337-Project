include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using MultivariateStats
using Clustering
using Statistics
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "kmeans_behavioral_profiles_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const MONTH_LABELS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
const K = 4

function get_basic_stats()
  conn = get_connection()
  query = """
    SELECT
      username,
      EXTRACT(MONTH FROM timestamp)::int  AS month,
      COUNT(*)::int                       AS plays,
      AVG(skipped::int)::float            AS skip_rate,
      AVG(shuffle::int)::float            AS shuffle_rate,
      AVG(offline::int)::float            AS offline_rate
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

function get_artist_dist()
  conn = get_connection()
  query = """
    SELECT
      username,
      EXTRACT(MONTH FROM timestamp)::int AS month,
      artist_name,
      COUNT(*)::int                      AS plays
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

function get_new_artist_rate()
  conn = get_connection()
  query = """
    WITH first_seen AS (
      SELECT username, artist_name,
             DATE_TRUNC('month', MIN(timestamp)) AS first_month
      FROM   listening_history
      WHERE  artist_name IS NOT NULL
      GROUP BY username, artist_name
    ),
    new_plays AS (
      SELECT
        lh.username,
        EXTRACT(MONTH FROM lh.timestamp)::int AS month,
        COUNT(*)::int                         AS new_plays
      FROM  listening_history lh
      JOIN  first_seen fs
            ON  lh.username     = fs.username
            AND lh.artist_name  = fs.artist_name
      WHERE EXTRACT(YEAR FROM lh.timestamp)         = 2025
        AND EXTRACT(YEAR FROM fs.first_month)       = 2025
        AND EXTRACT(MONTH FROM lh.timestamp)::int
            = EXTRACT(MONTH FROM fs.first_month)::int
      GROUP BY lh.username, month
    )
    SELECT
      b.username,
      b.month,
      COALESCE(np.new_plays, 0)::float / b.plays::float AS new_rate
    FROM (
      SELECT username,
             EXTRACT(MONTH FROM timestamp)::int AS month,
             COUNT(*) AS plays
      FROM   listening_history
      WHERE  EXTRACT(YEAR FROM timestamp) = 2025
        AND  artist_name IS NOT NULL
      GROUP BY username, month
    ) b
    LEFT JOIN new_plays np ON b.username = np.username AND b.month = np.month
    ORDER BY b.username, b.month
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function entropy_bits(counts::Vector{<:Real})
  total = sum(counts)
  total == 0 && return 0.0
  h = 0.0
  for c in counts
    c > 0 && (p = c / total; h -= p * log2(p))
  end
  return h
end

function compute_entropy_map(artist_df)
  m = Dict{Tuple{String,Int},Float64}()
  grouped = groupby(artist_df, [:username, :month])
  for gdf in grouped
    u = String(gdf.username[1])
    mo = Int(gdf.month[1])
    h = entropy_bits(Int.(gdf.plays))
    m[(u, mo)] = h
  end
  return m
end


const FEATURE_NAMES = ["plays", "skip_rate", "shuffle_rate",
  "offline_rate", "entropy", "new_rate"]

function build_feature_matrix(basic_df, entropy_map, new_rate_df)
  nr_map = Dict{Tuple{String,Int},Float64}()
  for row in eachrow(new_rate_df)
    nr_map[(String(row.username), Int(row.month))] = Float64(row.new_rate)
  end

  rows = Vector{Vector{Float64}}()
  labels = Vector{Tuple{String,String,Int}}()

  user_set = Set(USER_ORDER)
  for row in eachrow(basic_df)
    u = String(row.username)
    u in user_set || continue
    mo = Int(row.month)
    di = DISPLAY_ORDER[findfirst(==(u), USER_ORDER)]

    h = get(entropy_map, (u, mo), 0.0)
    nr = get(nr_map, (u, mo), 0.0)

    push!(rows, [
      Float64(row.plays),
      Float64(row.skip_rate),
      Float64(row.shuffle_rate),
      Float64(row.offline_rate),
      h,
      nr,
    ])
    push!(labels, (u, di, mo))
  end

  isempty(rows) && return Matrix{Float64}(undef, 0, 0), labels

  X = hcat(rows...) |> Matrix{Float64}
  return X, labels
end

function standardise(X::Matrix{Float64})
  μ = mean(X, dims=2)
  σ = std(X, dims=2)
  σ[σ.==0] .= 1.0
  return (X .- μ) ./ σ, μ, σ
end

function print_cluster_profiles(X_raw, labels, assignments)
  println("Cluster profiles (feature means, raw scale):")
  @printf "  %-4s  %-8s  %6s  %8s  %10s  %10s  %8s  %8s\n" "clus" "n" "plays" "skip%" "shuffle%" "offline%" "entropy" "new%"
  for k in 1:K
    mask = assignments .== k
    sum(mask) == 0 && continue
    Xk = X_raw[:, mask]
    μk = mean(Xk, dims=2)
    @printf "  %-4d  %-8d  %6.0f  %8.1f  %10.1f  %10.1f  %8.2f  %8.1f\n" k sum(mask) μk[1] μk[2] * 100 μk[3] * 100 μk[4] * 100 μk[5] μk[6] * 100
  end
  println()

  println("User-month assignments:")
  @printf "  %-12s  %-6s  %-5s  %5s\n" "user" "month" "clus" "plays"
  for (i, (u, d, mo)) in enumerate(labels)
    @printf "  %-12s  %-6s  %-5d\n" d MONTH_LABELS[mo] assignments[i]
  end
  println()
end

const USER_MARKERS = [:circle, :rect, :diamond, :utriangle]
const CLUSTER_COLORS = Makie.wong_colors()[1:K]

function plot_pca_scatter(X_std, labels, assignments, pca_model, fname)
  emb = predict(pca_model, X_std)
  n = size(emb, 2)

  var_exp = principalvars(pca_model) ./ tvar(pca_model) .* 100

  fig = Figure(size=(950, 700))
  ax = Axis(fig[1, 1],
    title="K-Means Behavioral Clusters (K=$K) in PCA Space - 2025",
    xlabel=@sprintf("PC1 (%.1f%% var)", var_exp[1]),
    ylabel=@sprintf("PC2 (%.1f%% var)", var_exp[2]),
  )

  for (ui, (username, display_name)) in enumerate(zip(USER_ORDER, DISPLAY_ORDER))
    idx = [i for i in 1:n if labels[i][1] == username]
    isempty(idx) && continue
    scatter!(ax,
      emb[1, idx], emb[2, idx],
      marker=USER_MARKERS[ui],
      color=[CLUSTER_COLORS[assignments[i]] for i in idx],
      markersize=14,
      strokecolor=:white,
      strokewidth=1,
      label=display_name,
    )
    for i in idx
      mo_lbl = MONTH_LABELS[labels[i][3]]
      text!(ax, emb[1, i], emb[2, i],
        text=" $(display_name[1])-$mo_lbl",
        fontsize=9,
        align=(:left, :center),
        color=:grey30,
      )
    end
  end

  Legend(fig[1, 2], ax, "User", framevisible=false)

  cluster_entries = [MarkerElement(color=CLUSTER_COLORS[k], marker=:circle,
    markersize=12) for k in 1:K]
  Legend(fig[2, 1:2], cluster_entries, ["Cluster $k" for k in 1:K],
    orientation=:horizontal, framevisible=false, tellwidth=false)

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  println("Loading data...")
  basic_df = get_basic_stats()
  artist_df = get_artist_dist()
  new_rate_df = get_new_artist_rate()

  entropy_map = compute_entropy_map(artist_df)
  X_raw, labels = build_feature_matrix(basic_df, entropy_map, new_rate_df)

  (isempty(labels) || size(X_raw, 2) < K) && (println("Not enough data"); return)

  println("$(size(X_raw, 2)) user-month observations, $(size(X_raw, 1)) features")

  X_std, μ, σ = standardise(X_raw)

  best = kmeans(X_std, K; maxiter=500, init=:kmpp, display=:none)
  for _ in 1:9
    r = kmeans(X_std, K; maxiter=500, init=:kmpp, display=:none)
    r.totalcost < best.totalcost && (best = r)
  end
  assignments = best.assignments

  pca_model = fit(PCA, X_std; maxoutdim=2)

  print_cluster_profiles(X_raw, labels, assignments)

  fname = joinpath(PLOTS_DIR, "kmeans_behavioral_profiles_2025.png")
  plot_pca_scatter(X_std, labels, assignments, pca_model, fname)

  json_out = Dict{String,Any}(
    "k" => K,
    "features" => FEATURE_NAMES,
    "observations" => [
      Dict{String,Any}(
        "user" => labels[i][2],
        "month" => MONTH_LABELS[labels[i][3]],
        "cluster" => assignments[i],
        "pc1" => predict(pca_model, X_std)[1, i],
        "pc2" => predict(pca_model, X_std)[2, i],
        "features" => Dict(FEATURE_NAMES[j] => X_raw[j, i] for j in 1:length(FEATURE_NAMES)),
      )
      for i in 1:length(labels)
    ],
    "cluster_profiles" => [
      let mask = assignments .== k
        Dict{String,Any}(
          "cluster" => k,
          "n" => sum(mask),
          "means" => Dict(FEATURE_NAMES[j] => mean(X_raw[j, mask]) for j in 1:length(FEATURE_NAMES)),
        )
      end
      for k in 1:K if any(assignments .== k)
    ],
  )

  save_json(joinpath(SCRIPT_DIR, "kmeans_behavioral_profiles_2025.json"), json_out)
end

main()
