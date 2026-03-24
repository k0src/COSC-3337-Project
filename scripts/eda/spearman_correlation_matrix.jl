include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using StatsBase
using Printf

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const VARS = ["ms_played", "hour", "dow", "month", "year", "skip", "shuffle", "offline"]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      username,
      ms_played,
      EXTRACT(HOUR  FROM timestamp)::INT          AS hour,
      EXTRACT(ISODOW FROM timestamp)::INT         AS dow,
      EXTRACT(MONTH FROM timestamp)::INT          AS month,
      EXTRACT(YEAR  FROM timestamp)::INT          AS year,
      CASE WHEN skipped THEN 1 ELSE 0 END         AS skip,
      CASE WHEN shuffle THEN 1 ELSE 0 END         AS shuffle_ind,
      CASE WHEN offline THEN 1 ELSE 0 END         AS offline_ind
    FROM listening_history
    WHERE ms_played IS NOT NULL
      AND skipped   IS NOT NULL
      AND shuffle   IS NOT NULL
      AND offline   IS NOT NULL
    ORDER BY username
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function build_obs_matrix(df)
  X = Matrix{Float64}(undef, nrow(df), 8)
  X[:, 1] = Float64.(df.ms_played)
  X[:, 2] = Float64.(df.hour)
  X[:, 3] = Float64.(df.dow)
  X[:, 4] = Float64.(df.month)
  X[:, 5] = Float64.(df.year)
  X[:, 6] = Float64.(df.skip)
  X[:, 7] = Float64.(df.shuffle_ind)
  X[:, 8] = Float64.(df.offline_ind)
  return X
end

function print_corr_matrix(C, label)
  p = length(VARS)
  println("$label  (n = $(size(C, 1) == p ? "?" : "?"))")
  @printf "%-11s" ""
  for v in VARS
    @printf "%10s" v
  end
  println()
  for i in 1:p
    @printf "%-11s" VARS[i]
    for j in 1:p
      @printf "%10.3f" C[i, j]
    end
    println()
  end
  println()
end

function print_corr_matrix(C, label, n)
  p = length(VARS)
  println("$label  (n = $n)")
  @printf "%-11s" ""
  for v in VARS
    @printf "%10s" v
  end
  println()
  for i in 1:p
    @printf "%-11s" VARS[i]
    for j in 1:p
      @printf "%10.3f" C[i, j]
    end
    println()
  end
  println()
end

function plot_corr_matrix(C, label, fname)
  p = length(VARS)

  fig = Figure(size=(750, 650))
  ax = Axis(fig[1, 1],
    title="Spearman Correlation Matrix — $label",
    xticks=(1:p, VARS),
    yticks=(1:p, VARS),
    xticklabelrotation=π / 4,
    yreversed=true,
  )

  hm = heatmap!(ax, C, colormap=:RdBu, colorrange=(-1.0, 1.0))

  for i in 1:p, j in 1:p
    val = C[i, j]
    txtcolor = abs(val) > 0.5 ? :white : :black
    text!(ax, i, j,
      text=@sprintf("%.2f", val),
      align=(:center, :center),
      fontsize=11,
      color=txtcolor,
    )
  end

  Colorbar(fig[1, 2], hm, label="Spearman (rho)")

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  all_data = Dict{String,Any}(
    "variables" => VARS,
  )

  for (username, display_name) in NAMES
    user_df = filter(r -> String(r.username) == username, df)
    nrow(user_df) < 10 && continue

    X = build_obs_matrix(user_df)
    C = corspearman(X)

    print_corr_matrix(C, display_name, nrow(user_df))
    plot_corr_matrix(C, display_name, "spearman_corr_$(username).png")

    all_data[display_name] = Dict{String,Any}(
      "n" => nrow(user_df),
      "matrix" => [[C[i, j] for j in 1:8] for i in 1:8],
    )
  end

  X_pool = build_obs_matrix(df)
  C_pool = corspearman(X_pool)

  print_corr_matrix(C_pool, "Pooled (all users)", nrow(df))
  plot_corr_matrix(C_pool, "All Users (Pooled)", "spearman_corr_pooled.png")

  all_data["pooled"] = Dict{String,Any}(
    "n" => nrow(df),
    "matrix" => [[C_pool[i, j] for j in 1:8] for i in 1:8],
  )

  save_json("spearman_correlation_matrix.json", all_data)
end

main()
