include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["dasucc", "alanjzamora", "alexxxxxrs", "korenns"]

const PAIRS = [
  ("dasucc", "alanjzamora"),
  ("dasucc", "alexxxxxrs"),
  ("dasucc", "korenns"),
  ("alanjzamora", "alexxxxxrs"),
  ("alanjzamora", "korenns"),
  ("alexxxxxrs", "korenns"),
]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      lh.username,
      ag.genre,
      COUNT(*)  AS play_count
    FROM listening_history   lh
    JOIN artist_genres        ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
      AND EXTRACT(YEAR FROM lh.timestamp)::INT = 2025
    GROUP BY lh.username, ag.genre
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function user_genre_counts(df, username)
  sub = filter(r -> String(r.username) == username, df)
  result = Dict{String,Int}()
  for row in eachrow(sub)
    g = String(row.genre)
    result[g] = get(result, g, 0) + Int(row.play_count)
  end
  return Float64.(collect(values(result)))
end

function qq_points(x::Vector{Float64}, y::Vector{Float64})
  n = min(length(x), length(y))
  probs = range(0.0, 1.0, length=n)
  qx = [quantile(x, p) for p in probs]
  qy = [quantile(y, p) for p in probs]
  return qx, qy
end

function plot_all_pairs(pair_data)
  fig = Figure(size=(1200, 820))

  Label(fig[0, 1:3],
    "Q-Q Plot: Genre Play Count Distribution - Pairwise User Comparison - 2025",
    fontsize=15,
    tellwidth=false,
  )

  for (idx, (key, pd)) in enumerate(pair_data)
    row = (idx - 1) ÷ 3 + 1
    col = (idx - 1) % 3 + 1
    d1, d2 = pd["user1"], pd["user2"]
    qx = Float64.(pd["quantiles_user1"])
    qy = Float64.(pd["quantiles_user2"])

    ax = Axis(fig[row, col],
      title="$d1 vs $d2",
      xlabel="$d1 plays",
      ylabel="$d2 plays",
    )

    scatter!(ax, qx, qy, markersize=5, color=Makie.wong_colors()[1])

    lo = min(minimum(qx), minimum(qy))
    hi = max(maximum(qx), maximum(qy))
    lines!(ax, [lo, hi], [lo, hi], color=:black, linestyle=:dash, linewidth=1.5)
  end

  fname = "genre_qq_2025.png"
  save(fname, fig)
  println("Plot saved: $fname")
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data for 2025"); return)

  user_counts = Dict(u => user_genre_counts(df, u) for u in USER_ORDER)

  all_data = Dict{String,Any}()

  for (u1, u2) in PAIRS
    d1 = NAMES[u1]
    d2 = NAMES[u2]
    x = user_counts[u1]
    y = user_counts[u2]
    qx, qy = qq_points(x, y)

    println("$d1 vs $d2: $(length(x)) genres / $(length(y)) genres -> $(length(qx)) quantile points")

    key = "$(d1)_vs_$(d2)"
    all_data[key] = Dict{String,Any}(
      "user1" => d1,
      "user2" => d2,
      "n_genres_user1" => length(x),
      "n_genres_user2" => length(y),
      "n_quantile_points" => length(qx),
      "quantiles_user1" => qx,
      "quantiles_user2" => qy,
    )
  end

  println()
  plot_all_pairs(all_data)
  save_json("genre_qq_2025.json", all_data)
end

main()
