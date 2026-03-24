include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using MultivariateStats
using Clustering
using Statistics
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "kmeans_genre_profiles_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const MONTH_LABELS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
const K = 4

const FAMILY_RULES = [
  ("Hip-Hop / Rap", ["hip hop", "rap", "trap", "drill", "cloud rap", "grime", "phonk", "bounce"]),
  ("R&B", ["r&b", "neo soul", "contemporary r"]),
  ("Soul / Funk", ["soul", "funk", "motown", "gospel", "blues"]),
  ("Electronic", ["electronic", "electro", "edm", "synthwave", "synth pop", "industrial", "noise"]),
  ("House / Techno", ["house", "techno", "trance", "rave", "uk garage", "afrobeats"]),
  ("Drum & Bass / Dubstep", ["drum and bass", "dnb", "dubstep", "jungle", "breakbeat", "drumstep", "liquid funk"]),
  ("Ambient / Lo-Fi", ["ambient", "lo-fi", "lofi", "chillhop", "chill", "drone", "new age"]),
  ("Pop", ["pop"]),
  ("Alternative / Indie", ["alternative", "indie", "shoegaze", "dream", "post-punk", "new wave", "art rock"]),
  ("Rock", ["rock", "grunge", "garage", "surf"]),
  ("Metal", ["metal", "doom", "sludge", "stoner", "thrash", "death", "black metal"]),
  ("Punk / Emo", ["punk", "emo", "hardcore", "screamo"]),
  ("Jazz", ["jazz", "bebop", "swing", "bossa nova", "fusion"]),
  ("Classical", ["classical", "orchestral", "opera", "baroque", "chamber", "contemporary classical"]),
  ("Country / Folk", ["country", "folk", "bluegrass", "americana", "singer-songwriter", "acoustic"]),
  ("Latin", ["latin", "reggaeton", "salsa", "bachata", "cumbia", "dembow", "corrido"]),
  ("K-Pop / J-Pop", ["k-pop", "j-pop", "korean", "japanese", "anime", "city pop"]),
  ("Reggae", ["reggae", "dancehall", "ska", "dub"]),
  ("Other", String[]),
]

const FAMILIES = [r[1] for r in FAMILY_RULES]

function assign_family(genre::String)
  g = lowercase(genre)
  for (family, keywords) in FAMILY_RULES
    isempty(keywords) && return family
    any(occursin(kw, g) for kw in keywords) && return family
  end
  return "Other"
end

function get_data()
  conn = get_connection()
  query = """
    SELECT
      lh.username,
      EXTRACT(MONTH FROM lh.timestamp)::int AS month,
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

function build_feature_matrix(df)
  fam_idx = Dict(f => i for (i, f) in enumerate(FAMILIES))
  n_fam = length(FAMILIES)

  key_plays = Dict{Tuple{String,Int},Vector{Float64}}()

  for row in eachrow(df)
    u = String(row.username)
    u in USER_ORDER || continue
    mo = Int(row.month)
    k = (u, mo)
    v = get!(key_plays, k, zeros(Float64, n_fam))
    fi = fam_idx[assign_family(String(row.genre))]
    v[fi] += Float64(row.plays)
  end

  keys_sorted = sort(collect(keys(key_plays)), by=k -> (findfirst(==(k[1]), USER_ORDER), k[2]))

  rows = Vector{Vector{Float64}}()
  labels = Vector{Tuple{String,String,Int}}()

  for (u, mo) in keys_sorted
    v = key_plays[(u, mo)]
    total = sum(v)
    total == 0 && continue
    push!(rows, v ./ total)
    di = DISPLAY_ORDER[findfirst(==(u), USER_ORDER)]
    push!(labels, (u, di, mo))
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
  println("Cluster profiles (mean genre family share %, raw)  n=$n user-months")
  @printf "  %-4s  %6s" "clus" "n"
  for f in FAMILIES
    short = length(f) > 12 ? f[1:12] : f
    @printf "  %12s" short
  end
  println()
  for k in 1:K
    mask = assignments .== k
    sum(mask) == 0 && continue
    Xk = X_raw[:, mask]
    μk = mean(Xk, dims=2)
    @printf "  %-4d  %6d" k sum(mask)
    for fi in 1:length(FAMILIES)
      @printf "  %11.1f%%" μk[fi] * 100
    end
    println()
  end
  println()

  println("User-month cluster assignments:")
  @printf "  %-12s  %-6s  %5s\n" "user" "month" "clus"
  for (i, (_, d, mo)) in enumerate(labels)
    @printf "  %-12s  %-6s  %5d\n" d MONTH_LABELS[mo] assignments[i]
  end
  println()
end

const CLUSTER_COLORS = Makie.wong_colors()[1:K]
const USER_MARKERS = [:circle, :rect, :diamond, :utriangle]

function plot_pca_scatter(X_std, labels, assignments, pca_model, fname)
  emb = predict(pca_model, X_std)
  n = size(emb, 2)
  var_exp = principalvars(pca_model) ./ tvar(pca_model) .* 100

  fig = Figure(size=(1000, 720))
  ax = Axis(fig[1, 1],
    title="K-Means Genre Profile Clusters (K=$K) in PCA Space - 2025",
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
      text!(ax, emb[1, i], emb[2, i],
        text=" $(labels[i][2][1])-$(MONTH_LABELS[labels[i][3]])",
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

function plot_pc_loadings(pca_model, fname)
  loadings = projection(pca_model)
  n_fam = length(FAMILIES)
  n_pc = min(2, size(loadings, 2))

  fig = Figure(size=(900, max(400, n_fam * 28 + 180)))

  for pc in 1:n_pc
    ax = Axis(fig[pc, 1],
      title="PC$pc Genre Family Loadings",
      xlabel="Loading",
      ylabel="Genre Family",
      yticks=(1:n_fam, FAMILIES),
      yreversed=true,
    )
    vals = loadings[:, pc]
    colors = [v >= 0 ? Makie.wong_colors()[1] : Makie.wong_colors()[2] for v in vals]
    barplot!(ax, 1:n_fam, vals, direction=:x, color=colors,
      strokecolor=:white, strokewidth=0.5)
    vlines!(ax, [0.0], color=:grey50, linewidth=0.8)
  end

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  println("Loading data...")
  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  X_raw, labels = build_feature_matrix(df)
  (isempty(labels) || size(X_raw, 2) < K) && (println("Not enough data"); return)

  println("$(size(X_raw, 2)) user-month observations over $(length(FAMILIES)) genre families")

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
    joinpath(PLOTS_DIR, "kmeans_genre_profiles_pca_2025.png"))
  plot_pc_loadings(pca_model,
    joinpath(PLOTS_DIR, "kmeans_genre_profiles_loadings_2025.png"))

  var_exp = principalvars(pca_model) ./ tvar(pca_model) .* 100
  emb = predict(pca_model, X_std)

  json_out = Dict{String,Any}(
    "k" => K,
    "genre_families" => FAMILIES,
    "pca_variance_explained" => [var_exp[1], var_exp[2]],
    "cluster_profiles" => [
      let mask = assignments .== k
        Dict{String,Any}(
          "cluster" => k,
          "n" => sum(mask),
          "means" => Dict(FAMILIES[fi] => mean(X_raw[fi, mask]) for fi in 1:length(FAMILIES)),
        )
      end
      for k in 1:K if any(assignments .== k)
    ],
    "observations" => [
      Dict{String,Any}(
        "user" => labels[i][2],
        "month" => MONTH_LABELS[labels[i][3]],
        "cluster" => assignments[i],
        "pc1" => emb[1, i],
        "pc2" => emb[2, i],
        "shares" => Dict(FAMILIES[fi] => X_raw[fi, i] for fi in 1:length(FAMILIES)),
      )
      for i in 1:length(labels)
    ],
  )

  save_json(joinpath(SCRIPT_DIR, "kmeans_genre_profiles_2025.json"), json_out)
end

main()
