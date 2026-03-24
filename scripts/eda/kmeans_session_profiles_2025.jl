include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using MultivariateStats
using Clustering
using Statistics
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "kmeans_session_profiles_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const K = 5
const FEATURE_NAMES = ["avg_min_played", "skip_rate", "unique_genres",
  "top_genre_share", "genre_entropy"]
const CLUSTER_COLORS = Makie.wong_colors()[1:K]
const USER_MARKERS = [:circle, :rect, :diamond, :utriangle]

function get_data()
  conn = get_connection()
  query = """
    WITH sessions AS (
      SELECT
        username, timestamp, artist_name, ms_played, skipped,
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
        username, timestamp, artist_name, ms_played, skipped,
        SUM(is_new_session) OVER (PARTITION BY username ORDER BY timestamp) AS session_id
      FROM sessions
    ),
    session_basic AS (
      SELECT
        username,
        session_id,
        AVG(skipped::int)::float    AS skip_rate,
        AVG(ms_played / 60000.0)    AS avg_min_played
      FROM session_labeled
      GROUP BY username, session_id
    ),
    session_genre_counts AS (
      SELECT
        sl.username,
        sl.session_id,
        ag.genre,
        COUNT(*)::int AS genre_plays
      FROM  session_labeled sl
      JOIN  artist_genres    ag ON sl.artist_name = ag.artist_name
      GROUP BY sl.username, sl.session_id, ag.genre
    ),
    session_genre_totals AS (
      SELECT
        username, session_id, genre, genre_plays,
        SUM(genre_plays) OVER (PARTITION BY username, session_id) AS session_total
      FROM session_genre_counts
    ),
    session_genre_stats AS (
      SELECT
        username,
        session_id,
        COUNT(DISTINCT genre)::int                             AS unique_genres,
        MAX(genre_plays)::float / SUM(genre_plays)::float     AS top_genre_share,
        -SUM(
          (genre_plays::float / session_total)
          * LN(genre_plays::float / session_total)
        )                                                      AS genre_entropy
      FROM session_genre_totals
      GROUP BY username, session_id
    )
    SELECT
      sb.username,
      sb.session_id::int,
      sb.skip_rate,
      sb.avg_min_played,
      sgs.unique_genres,
      sgs.top_genre_share,
      sgs.genre_entropy
    FROM session_basic      sb
    JOIN session_genre_stats sgs
         ON sb.username = sgs.username AND sb.session_id = sgs.session_id
    ORDER BY sb.username, sb.session_id
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function build_feature_matrix(df)
  rows = Vector{Vector{Float64}}()
  labels = Vector{Tuple{String,String}}()

  user_set = Set(USER_ORDER)
  for row in eachrow(df)
    u = String(row.username)
    u in user_set || continue
    di = DISPLAY_ORDER[findfirst(==(u), USER_ORDER)]

    push!(rows, [
      Float64(row.avg_min_played),
      Float64(row.skip_rate),
      Float64(row.unique_genres),
      Float64(row.top_genre_share),
      Float64(row.genre_entropy),
    ])
    push!(labels, (u, di))
  end

  isempty(rows) && return Matrix{Float64}(undef, 0, 0), labels
  return hcat(rows...) |> Matrix{Float64}, labels
end

function standardise(X::Matrix{Float64})
  μ = mean(X, dims=2)
  σ = std(X, dims=2)
  σ[σ.==0] .= 1.0
  return (X .- μ) ./ σ
end

function print_cluster_profiles(X_raw, labels, assignments)
  n = length(labels)
  println("Cluster profiles (feature means, raw scale)  n=$n sessions")
  @printf "  %-4s  %6s  %9s  %8s  %13s  %14s  %12s\n" "clus" "n" "avg_min" "skip%" "unique_genres" "top_genre_shr" "genre_entropy"
  for k in 1:K
    mask = assignments .== k
    sum(mask) == 0 && continue
    Xk = X_raw[:, mask]
    μk = mean(Xk, dims=2)
    @printf "  %-4d  %6d  %9.2f  %8.1f  %13.1f  %14.1f  %12.3f\n" k sum(mask) μk[1] μk[2] * 100 μk[3] μk[4] * 100 μk[5]
  end
  println()

  println("Sessions per cluster per user:")
  @printf "  %-12s" "user"
  for k in 1:K
    @printf "  %8s" "clus_$k"
  end
  println()
  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    @printf "  %-12s" display_name
    for k in 1:K
      cnt = sum(labels[i][1] == username && assignments[i] == k for i in 1:n)
      @printf "  %8d" cnt
    end
    println()
  end
  println()
end

function plot_pca_scatter(X_std, labels, assignments, pca_model, fname)
  emb = predict(pca_model, X_std)
  n = size(emb, 2)
  var_exp = principalvars(pca_model) ./ tvar(pca_model) .* 100

  fig = Figure(size=(1000, 720))
  ax = Axis(fig[1, 1],
    title="K-Means Session Clusters (K=$K) in PCA Space - 2025",
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
      markersize=9,
      strokecolor=(:white, 0.6),
      strokewidth=0.8,
      alpha=0.75,
      label=display_name,
    )
  end

  for k in 1:K
    idx = findall(==(k), assignments)
    isempty(idx) && continue
    cx = mean(emb[1, idx])
    cy = mean(emb[2, idx])
    text!(ax, cx, cy,
      text="C$k",
      fontsize=14,
      font=:bold,
      color=CLUSTER_COLORS[k],
      align=(:center, :center),
    )
  end

  Legend(fig[1, 2], ax, "User", framevisible=false)

  cluster_entries = [MarkerElement(color=CLUSTER_COLORS[k], marker=:circle,
    markersize=12) for k in 1:K]
  Legend(fig[2, 1:2], cluster_entries, ["Cluster $k" for k in 1:K],
    orientation=:horizontal, framevisible=false, tellwidth=false)

  save(fname, fig)
  println("  plot saved: $fname")
end

function plot_cluster_dist(labels, assignments, fname)
  n_u = length(USER_ORDER)
  counts = zeros(Int, n_u, K)
  for (i, (username, _)) in enumerate(labels)
    ui = findfirst(==(username), USER_ORDER)
    isnothing(ui) && continue
    counts[ui, assignments[i]] += 1
  end

  fig = Figure(size=(820, 460))
  ax = Axis(fig[1, 1],
    title="Session Count per Cluster per User - 2025",
    xlabel="Cluster",
    ylabel="Sessions",
    xticks=(1:K, ["Cluster $k" for k in 1:K]),
  )

  dodge_width = 0.18
  offsets = [-1.5, -0.5, 0.5, 1.5] .* dodge_width

  for (ui, display_name) in enumerate(DISPLAY_ORDER)
    xs = (1:K) .+ offsets[ui]
    barplot!(ax, xs, Float64.(counts[ui, :]),
      width=dodge_width,
      color=(Makie.wong_colors()[ui], 0.85),
      label=display_name,
    )
  end

  Legend(fig[1, 2], ax, framevisible=false)

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  println("Loading session data...")
  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  X_raw, labels = build_feature_matrix(df)
  (isempty(labels) || size(X_raw, 2) < K) && (println("Not enough sessions"); return)

  println("$(size(X_raw, 2)) sessions, $(size(X_raw, 1)) features")

  X_std = standardise(X_raw)

  best = kmeans(X_std, K; maxiter=500, init=:kmpp, display=:none)
  for _ in 1:9
    r = kmeans(X_std, K; maxiter=500, init=:kmpp, display=:none)
    r.totalcost < best.totalcost && (best = r)
  end
  assignments = best.assignments

  pca_model = fit(PCA, X_std; maxoutdim=2)

  print_cluster_profiles(X_raw, labels, assignments)

  plot_pca_scatter(X_std, labels, assignments, pca_model,
    joinpath(PLOTS_DIR, "kmeans_session_profiles_pca_2025.png"))

  plot_cluster_dist(labels, assignments,
    joinpath(PLOTS_DIR, "kmeans_session_profiles_dist_2025.png"))

  var_exp = principalvars(pca_model) ./ tvar(pca_model) .* 100
  emb = predict(pca_model, X_std)

  json_out = Dict{String,Any}(
    "k" => K,
    "features" => FEATURE_NAMES,
    "pca_variance_explained" => [var_exp[1], var_exp[2]],
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
    "user_cluster_counts" => Dict(
      display_name => [
        sum(labels[i][1] == username && assignments[i] == k for i in 1:length(labels))
        for k in 1:K
      ]
      for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    ),
    "sessions" => [
      Dict{String,Any}(
        "user" => labels[i][2],
        "cluster" => assignments[i],
        "pc1" => emb[1, i],
        "pc2" => emb[2, i],
        "features" => Dict(FEATURE_NAMES[j] => X_raw[j, i] for j in 1:length(FEATURE_NAMES)),
      )
      for i in 1:length(labels)
    ],
  )

  save_json(joinpath(SCRIPT_DIR, "kmeans_session_profiles_2025.json"), json_out)
end

main()
