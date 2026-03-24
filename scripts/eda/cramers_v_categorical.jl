include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Distributions
using Printf

const VARS = ["shuffle", "skipped", "offline", "reason_start", "reason_end", "username"]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      username,
      reason_start,
      reason_end,
      shuffle,
      skipped,
      offline
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND shuffle      IS NOT NULL
      AND skipped      IS NOT NULL
      AND offline      IS NOT NULL
      AND reason_start IS NOT NULL
      AND reason_end   IS NOT NULL
    ORDER BY username
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_col(df, var)
  if var == "shuffle"
    return [Bool(r.shuffle) ? "true" : "false" for r in eachrow(df)]
  elseif var == "skipped"
    return [Bool(r.skipped) ? "true" : "false" for r in eachrow(df)]
  elseif var == "offline"
    return [Bool(r.offline) ? "true" : "false" for r in eachrow(df)]
  elseif var == "reason_start"
    return String.(df.reason_start)
  elseif var == "reason_end"
    return String.(df.reason_end)
  elseif var == "username"
    return String.(df.username)
  else
    error("unknown variable: $var")
  end
end

function cramers_v(x::Vector{String}, y::Vector{String})
  cats_x = sort(unique(x))
  cats_y = sort(unique(y))
  r, c = length(cats_x), length(cats_y)

  idx_x = Dict(v => i for (i, v) in enumerate(cats_x))
  idx_y = Dict(v => i for (i, v) in enumerate(cats_y))

  obs = zeros(Int, r, c)
  for (xi, yi) in zip(x, y)
    obs[idx_x[xi], idx_y[yi]] += 1
  end

  n = sum(obs)
  row_sums = sum(obs, dims=2)
  col_sums = sum(obs, dims=1)
  exp = Float64[row_sums[i] * col_sums[j] / n for i in 1:r, j in 1:c]

  χ² = sum((Float64.(obs) .- exp) .^ 2 ./ exp)
  df = (r - 1) * (c - 1)
  p = df > 0 ? ccdf(Chisq(df), χ²) : 1.0
  V = sqrt(χ² / (n * max(1, min(r - 1, c - 1))))

  return V, χ², df, p, r, c
end

function build_v_matrix(df)
  p = length(VARS)
  V_mat = zeros(Float64, p, p)
  pairs = Dict{String,Any}()

  cols = [get_col(df, v) for v in VARS]

  for i in 1:p
    V_mat[i, i] = 1.0
    for j in (i+1):p
      V, χ², df_val, pval, r, c = cramers_v(cols[i], cols[j])
      V_mat[i, j] = V
      V_mat[j, i] = V

      key = "$(VARS[i])|$(VARS[j])"
      pairs[key] = Dict{String,Any}(
        "v" => V,
        "chi2" => χ²,
        "df" => df_val,
        "p_value" => pval,
        "n_cats_x" => r,
        "n_cats_y" => c,
      )
    end
  end

  return V_mat, pairs
end

function print_v_matrix(V_mat, n)
  p = length(VARS)
  println("Cramér's V — all categorical pairs  (n = $n, pooled, 2025)")
  @printf "%-14s" ""
  for v in VARS
    @printf "%14s" v
  end
  println()
  for i in 1:p
    @printf "%-14s" VARS[i]
    for j in 1:p
      @printf "%14.4f" V_mat[i, j]
    end
    println()
  end
  println()
end

function plot_v_matrix(V_mat, fname)
  p = length(VARS)

  fig = Figure(size=(750, 650))
  ax = Axis(fig[1, 1],
    title="Cramér's V — Categorical Pairs (Pooled, 2025)",
    xticks=(1:p, VARS),
    yticks=(1:p, VARS),
    xticklabelrotation=π / 4,
    yreversed=true,
  )

  hm = heatmap!(ax, V_mat, colormap=:Blues, colorrange=(0.0, 1.0))

  for i in 1:p, j in 1:p
    val = V_mat[i, j]
    txtcolor = val > 0.6 ? :white : :black
    text!(ax, i, j,
      text=@sprintf("%.2f", val),
      align=(:center, :center),
      fontsize=11,
      color=txtcolor,
    )
  end

  Colorbar(fig[1, 2], hm, label="Cramér's V")

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data for 2025"); return)

  V_mat, pairs = build_v_matrix(df)

  print_v_matrix(V_mat, nrow(df))
  plot_v_matrix(V_mat, "cramers_v_categorical_2025.png")

  all_data = Dict{String,Any}(
    "n" => nrow(df),
    "variables" => VARS,
    "matrix" => [[V_mat[i, j] for j in 1:length(VARS)] for i in 1:length(VARS)],
    "pairs" => pairs,
  )

  save_json("cramers_v_categorical_2025.json", all_data)
end

main()
