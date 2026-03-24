include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using LinearAlgebra
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "artist_cosine_similarity")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const PERIODS = [
  ("2024", 2024),
  ("2025", 2025),
  ("alltime", nothing),
]

const N_USERS = length(USER_ORDER)
const TOP_TFIDF = 8

function get_data(year::Union{Int,Nothing})
  conn = get_connection()

  year_filter = isnothing(year) ? "" :
                "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      artist_name,
      COUNT(*)::int AS plays
    FROM  listening_history
    WHERE artist_name IS NOT NULL
      $year_filter
    GROUP BY username, artist_name
    ORDER BY username, artist_name
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function build_tfidf(df)
  artists_set = Set{String}()
  raw = Dict(u => Dict{String,Int}() for u in USER_ORDER)

  for row in eachrow(df)
    u = String(row.username)
    a = String(row.artist_name)
    haskey(raw, u) || continue
    push!(artists_set, a)
    raw[u][a] = get(raw[u], a, 0) + Int(row.plays)
  end

  vocab = sort(collect(artists_set))
  n_a = length(vocab)
  a_idx = Dict(a => i for (i, a) in enumerate(vocab))

  tf = Dict{String,Vector{Float64}}()
  for u in USER_ORDER
    vec = zeros(Float64, n_a)
    total = sum(values(raw[u]); init=0)
    total == 0 && (tf[u] = vec; continue)
    for (a, n) in raw[u]
      haskey(a_idx, a) && (vec[a_idx[a]] = n / total)
    end
    tf[u] = vec
  end

  df_count = zeros(Int, n_a)
  for u in USER_ORDER
    for a in keys(raw[u])
      haskey(a_idx, a) && (df_count[a_idx[a]] += 1)
    end
  end
  idf = [df_count[i] > 0 ? log(N_USERS / df_count[i]) : 0.0 for i in 1:n_a]

  tfidf = Dict{String,Vector{Float64}}()
  for u in USER_ORDER
    tfidf[u] = tf[u] .* idf
  end

  return vocab, tfidf
end

function cosine_sim(a::Vector{Float64}, b::Vector{Float64})
  na, nb = norm(a), norm(b)
  (na == 0.0 || nb == 0.0) && return 0.0
  return clamp(dot(a, b) / (na * nb), 0.0, 1.0)
end

function build_matrix(tfidf)
  mat = zeros(Float64, N_USERS, N_USERS)
  for i in 1:N_USERS, j in 1:N_USERS
    mat[i, j] = cosine_sim(tfidf[USER_ORDER[i]], tfidf[USER_ORDER[j]])
  end
  return mat
end

function print_results(label, vocab, tfidf, mat)
  println("=== $label ===")
  println("  Vocabulary: $(length(vocab)) artists")

  for (u, d) in zip(USER_ORDER, DISPLAY_ORDER)
    v = tfidf[u]
    ranked = sortperm(v, rev=true)[1:min(TOP_TFIDF, length(v))]
    top_str = join(["$(vocab[i]) ($(round(v[i], digits=4)))" for i in ranked], ", ")
    println("  $d top artists: $top_str")
  end
  println()

  println("  Cosine similarity matrix:")
  hdr = @sprintf "    %-12s" ""
  for d in DISPLAY_ORDER
    hdr *= @sprintf "  %10s" d
  end
  println(hdr)
  for i in 1:N_USERS
    row_str = @sprintf "    %-12s" DISPLAY_ORDER[i]
    for j in 1:N_USERS
      row_str *= @sprintf "  %10.3f" mat[i, j]
    end
    println(row_str)
  end
  println()
end

function plot_heatmap(mat, label, fname)
  n = N_USERS

  fig = Figure(size=(560, 480))
  ax = Axis(fig[1, 1],
    title="Artist Cosine Similarity (TF-IDF) - $label",
    xticks=(1:n, DISPLAY_ORDER),
    yticks=(1:n, DISPLAY_ORDER),
    yreversed=true,
  )

  hm = heatmap!(ax, 1:n, 1:n, mat,
    colormap=:Greens,
    colorrange=(0.0, 1.0),
  )

  for i in 1:n, j in 1:n
    v = mat[i, j]
    text!(ax, i, j,
      text=@sprintf("%.3f", v),
      align=(:center, :center),
      fontsize=13,
      color=v > 0.55 ? :white : :black,
    )
  end

  Colorbar(fig[1, 2], hm, label="Cosine Similarity", colorrange=(0.0, 1.0))

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  json_out = Dict{String,Any}()

  for (label, year) in PERIODS
    df = get_data(year)
    nrow(df) == 0 && (println("No data for $label"); continue)

    vocab, tfidf = build_tfidf(df)
    mat = build_matrix(tfidf)

    print_results(label, vocab, tfidf, mat)

    fname = joinpath(PLOTS_DIR, "artist_cosine_$(label).png")
    plot_heatmap(mat, label, fname)

    json_out[label] = Dict{String,Any}(
      "matrix" => [[mat[i, j] for j in 1:N_USERS] for i in 1:N_USERS],
      "users" => DISPLAY_ORDER,
      "vocab_size" => length(vocab),
      "pairs" => [
        Dict{String,Any}(
          "users" => [DISPLAY_ORDER[i], DISPLAY_ORDER[j]],
          "cosine" => mat[i, j],
        )
        for i in 1:N_USERS for j in (i+1):N_USERS
      ],
    )
  end

  save_json(joinpath(SCRIPT_DIR, "artist_cosine_similarity.json"), json_out)
end

main()
