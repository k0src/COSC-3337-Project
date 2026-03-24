include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "artist_jaccard_similarity")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const MIN_PLAYS = 25

const PERIODS = [
  ("2024", 2024),
  ("2025", 2025),
  ("alltime", nothing),
]

function get_artist_sets(year::Union{Int,Nothing})
  conn = get_connection()

  year_filter = isnothing(year) ? "" :
                "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      artist_name
    FROM  listening_history
    WHERE artist_name IS NOT NULL
      $year_filter
    GROUP BY username, artist_name
    HAVING COUNT(*) >= $MIN_PLAYS
    ORDER BY username, artist_name
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  sets = Dict(u => Set{String}() for u in USER_ORDER)
  for row in eachrow(df)
    u = String(row.username)
    haskey(sets, u) && push!(sets[u], String(row.artist_name))
  end
  return sets
end

function jaccard(a::Set{String}, b::Set{String})
  isempty(a) && isempty(b) && return 1.0
  (isempty(a) || isempty(b)) && return 0.0
  return length(intersect(a, b)) / length(union(a, b))
end

function build_matrix(sets)
  n = length(USER_ORDER)
  mat = zeros(Float64, n, n)
  for i in 1:n, j in 1:n
    mat[i, j] = jaccard(sets[USER_ORDER[i]], sets[USER_ORDER[j]])
  end
  return mat
end

function print_results(label, sets, mat)
  n = length(USER_ORDER)
  println("$label  (min $MIN_PLAYS plays per artist)")
  println("  Artist set sizes:")
  for (u, d) in zip(USER_ORDER, DISPLAY_ORDER)
    @printf "    %-12s  %d artists\n" d length(sets[u])
  end
  println()
  println("  Pairwise Jaccard:")
  @printf "    %-14s  %-14s  %12s  %8s  %8s\n" "user_a" "user_b" "intersection" "union" "jaccard"
  for i in 1:n, j in (i+1):n
    a, b = sets[USER_ORDER[i]], sets[USER_ORDER[j]]
    inter = length(intersect(a, b))
    uni = length(union(a, b))
    @printf "    %-14s  %-14s  %12d  %8d  %8.3f\n" DISPLAY_ORDER[i] DISPLAY_ORDER[j] inter uni mat[i, j]
  end
  println()
end

function plot_heatmap(mat, label, fname)
  n = length(DISPLAY_ORDER)

  fig = Figure(size=(540, 480))
  ax = Axis(fig[1, 1],
    title="Artist Jaccard Similarity - $label (min $MIN_PLAYS plays)",
    xticks=(1:n, DISPLAY_ORDER),
    yticks=(1:n, DISPLAY_ORDER),
    yreversed=true,
  )

  hm = heatmap!(ax, 1:n, 1:n, mat,
    colormap=:Blues,
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

  Colorbar(fig[1, 2], hm, label="Jaccard Similarity", colorrange=(0.0, 1.0))

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  json_out = Dict{String,Any}()
  n = length(USER_ORDER)

  for (label, year) in PERIODS
    println("=== $label ===")
    sets = get_artist_sets(year)
    mat = build_matrix(sets)

    print_results(label, sets, mat)

    fname = joinpath(PLOTS_DIR, "artist_jaccard_$(label).png")
    plot_heatmap(mat, label, fname)

    pairs = Dict{String,Any}[]
    for i in 1:n, j in (i+1):n
      a, b = sets[USER_ORDER[i]], sets[USER_ORDER[j]]
      push!(pairs, Dict{String,Any}(
        "users" => [DISPLAY_ORDER[i], DISPLAY_ORDER[j]],
        "intersection" => length(intersect(a, b)),
        "union" => length(union(a, b)),
        "jaccard" => mat[i, j],
      ))
    end

    json_out[label] = Dict{String,Any}(
      "matrix" => [[mat[i, j] for j in 1:n] for i in 1:n],
      "users" => DISPLAY_ORDER,
      "artist_set_sizes" => Dict(DISPLAY_ORDER[i] => length(sets[USER_ORDER[i]]) for i in 1:n),
      "pairs" => pairs,
    )
  end

  save_json(joinpath(SCRIPT_DIR, "artist_jaccard_similarity.json"), json_out)
end

main()
