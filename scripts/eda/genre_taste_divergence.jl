include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using LinearAlgebra
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_taste_divergence")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]
const N_USERS = length(USER_ORDER)

const YEARS = 2020:2025

const PAIRS = [(i, j) for i in 1:N_USERS for j in (i+1):N_USERS]

function get_data(year::Int)
  conn = get_connection()
  query = """
    SELECT
      lh.username,
      ag.genre,
      COUNT(*)::int AS plays
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
      AND EXTRACT(YEAR FROM lh.timestamp) = $year
    GROUP BY lh.username, ag.genre
    ORDER BY lh.username, ag.genre
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function build_tfidf(df, present_users)
  n_present = length(present_users)
  n_present < 2 && return Dict{String,Vector{Float64}}()

  genres_set = Set{String}()
  raw = Dict(u => Dict{String,Int}() for u in present_users)

  for row in eachrow(df)
    u = String(row.username)
    haskey(raw, u) || continue
    g = String(row.genre)
    push!(genres_set, g)
    raw[u][g] = get(raw[u], g, 0) + Int(row.plays)
  end

  vocab = sort(collect(genres_set))
  n_g = length(vocab)
  g_idx = Dict(g => i for (i, g) in enumerate(vocab))

  tf = Dict{String,Vector{Float64}}()
  for u in present_users
    vec = zeros(Float64, n_g)
    total = sum(values(raw[u]); init=0)
    if total > 0
      for (g, n) in raw[u]
        haskey(g_idx, g) && (vec[g_idx[g]] = n / total)
      end
    end
    tf[u] = vec
  end

  df_count = zeros(Int, n_g)
  for u in present_users
    for g in keys(raw[u])
      haskey(g_idx, g) && (df_count[g_idx[g]] += 1)
    end
  end
  idf = [df_count[i] > 0 ? log(n_present / df_count[i]) : 0.0 for i in 1:n_g]

  tfidf = Dict(u => tf[u] .* idf for u in present_users)
  return tfidf
end

function cosine_dist(a::Vector{Float64}, b::Vector{Float64})
  na, nb = norm(a), norm(b)
  (na == 0.0 || nb == 0.0) && return NaN
  return 1.0 - clamp(dot(a, b) / (na * nb), 0.0, 1.0)
end

function print_table(dist_by_year)
  pair_labels = ["$(DISPLAY_ORDER[i])-$(DISPLAY_ORDER[j])" for (i, j) in PAIRS]
  hdr = @sprintf "  %-22s" "pair"
  for y in YEARS
    hdr *= @sprintf "  %6d" y
  end
  println(hdr)
  for (pi, (i, j)) in enumerate(PAIRS)
    row = @sprintf "  %-22s" pair_labels[pi]
    for y in YEARS
      d = get(dist_by_year, (y, i, j), NaN)
      row *= isnan(d) ? "      -" : @sprintf "  %6.3f" d
    end
    println(row)
  end
  println()
end

function plot_lines(dist_by_year, fname)
  colors = Makie.wong_colors()
  markers = [:circle, :rect, :diamond, :utriangle, :dtriangle, :star5]

  fig = Figure(size=(950, 520))
  ax = Axis(fig[1, 1],
    title="Genre Taste Distance Between User Pairs by Year\n(TF-IDF cosine distance, 1 = maximally different)",
    xlabel="Year",
    ylabel="Distance [0, 1]",
    xticks=(collect(Int.(YEARS)), string.(collect(YEARS))),
    limits=(nothing, (0.0, 1.05)),
  )

  for (pi, (i, j)) in enumerate(PAIRS)
    label = "$(DISPLAY_ORDER[i]) - $(DISPLAY_ORDER[j])"
    xs, ys = Int[], Float64[]
    for y in YEARS
      d = get(dist_by_year, (y, i, j), NaN)
      isnan(d) && continue
      push!(xs, y)
      push!(ys, d)
    end
    length(xs) < 2 && continue

    lines!(ax, xs, ys, color=colors[pi], linewidth=2, label=label)
    scatter!(ax, xs, ys,
      color=colors[pi],
      marker=markers[pi],
      markersize=9,
      strokecolor=:white,
      strokewidth=1,
    )
  end

  Legend(fig[1, 2], ax, framevisible=false)

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  dist_by_year = Dict{Tuple{Int,Int,Int},Float64}()

  for year in YEARS
    df = get_data(year)

    present = [u for u in USER_ORDER if any(String(r.username) == u for r in eachrow(df))]
    length(present) < 2 && (println("  $year: fewer than 2 users, skipping"); continue)

    tfidf = build_tfidf(df, present)
    isempty(tfidf) && continue

    present_set = Set(present)
    for (i, j) in PAIRS
      u1, u2 = USER_ORDER[i], USER_ORDER[j]
      (u1 in present_set && u2 in present_set) || continue
      d = cosine_dist(tfidf[u1], tfidf[u2])
      isnan(d) || (dist_by_year[(year, i, j)] = d)
    end

    println("$year  ($(length(present)) users present)")
  end

  println()
  println("Genre taste distance (TF-IDF cosine) by year:")
  print_table(dist_by_year)

  fname = joinpath(PLOTS_DIR, "genre_taste_divergence.png")
  plot_lines(dist_by_year, fname)

  pair_labels = ["$(DISPLAY_ORDER[i])-$(DISPLAY_ORDER[j])" for (i, j) in PAIRS]
  json_out = Dict{String,Any}(
    "years" => collect(Int.(YEARS)),
    "pairs" => pair_labels,
    "metric" => "TF-IDF cosine distance (1 - cosine_similarity)",
    "series" => Dict(
      pair_labels[pi] => Dict(
        string(y) => get(dist_by_year, (y, i, j), nothing)
        for y in YEARS
      )
      for (pi, (i, j)) in enumerate(PAIRS)
    ),
  )

  save_json(joinpath(SCRIPT_DIR, "genre_taste_divergence.json"), json_out)
end

main()
