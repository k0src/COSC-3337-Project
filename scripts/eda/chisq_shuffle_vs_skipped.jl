include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using Distributions
using Printf

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const ROW_LABELS = ["shuffle=false", "shuffle=true"]
const COL_LABELS = ["skipped=false", "skipped=true"]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      username,
      shuffle,
      skipped
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND shuffle IS NOT NULL
      AND skipped IS NOT NULL
    ORDER BY username
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function build_observed(df)
  obs = zeros(Int, 2, 2)
  for row in eachrow(df)
    i = Bool(row.shuffle) ? 2 : 1
    j = Bool(row.skipped) ? 2 : 1
    obs[i, j] += 1
  end
  return obs
end

function build_expected(obs)
  n = sum(obs)
  row_sums = sum(obs, dims=2)
  col_sums = sum(obs, dims=1)
  return Float64[row_sums[i] * col_sums[j] / n for i in 1:2, j in 1:2]
end

function run_chisq(obs, exp)
  χ² = sum((Float64.(obs) .- exp) .^ 2 ./ exp)
  df = (size(obs, 1) - 1) * (size(obs, 2) - 1)
  p = ccdf(Chisq(df), χ²)
  return χ², df, p
end

function print_result(label, obs, exp, χ², df, p)
  n = sum(obs)
  p_str = p < 0.0001 ? "< 0.0001" : @sprintf("%.4f", p)

  println("$label  (n = $n)")

  println("  Observed:")
  @printf "    %-16s  %16s  %16s  %10s\n" "" COL_LABELS[1] COL_LABELS[2] "row total"
  for i in 1:2
    @printf "    %-16s  %16d  %16d  %10d\n" ROW_LABELS[i] obs[i, 1] obs[i, 2] sum(obs[i, :])
  end
  @printf "    %-16s  %16d  %16d  %10d\n" "col total" sum(obs[:, 1]) sum(obs[:, 2]) n
  println()

  println("  Expected:")
  @printf "    %-16s  %16s  %16s\n" "" COL_LABELS[1] COL_LABELS[2]
  for i in 1:2
    @printf "    %-16s  %16.2f  %16.2f\n" ROW_LABELS[i] exp[i, 1] exp[i, 2]
  end
  println()

  println("  χ² = $(@sprintf("%.4f", χ²))  |  df = $df  |  p = $p_str")
  println()
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data for 2025"); return)

  all_data = Dict{String,Any}()

  for (username, display_name) in NAMES
    user_df = filter(r -> String(r.username) == username, df)
    nrow(user_df) == 0 && continue

    obs = build_observed(user_df)
    exp = build_expected(obs)
    χ², df_val, p = run_chisq(obs, exp)

    print_result(display_name, obs, exp, χ², df_val, p)

    all_data[display_name] = Dict{String,Any}(
      "n" => nrow(user_df),
      "row_labels" => ROW_LABELS,
      "col_labels" => COL_LABELS,
      "observed" => [[obs[i, j] for j in 1:2] for i in 1:2],
      "expected" => [[exp[i, j] for j in 1:2] for i in 1:2],
      "chi2" => χ²,
      "df" => df_val,
      "p_value" => p,
    )
  end

  obs_p = build_observed(df)
  exp_p = build_expected(obs_p)
  χ²_p, df_p, p_p = run_chisq(obs_p, exp_p)

  print_result("Pooled (all users)", obs_p, exp_p, χ²_p, df_p, p_p)

  all_data["pooled"] = Dict{String,Any}(
    "n" => nrow(df),
    "row_labels" => ROW_LABELS,
    "col_labels" => COL_LABELS,
    "observed" => [[obs_p[i, j] for j in 1:2] for i in 1:2],
    "expected" => [[exp_p[i, j] for j in 1:2] for i in 1:2],
    "chi2" => χ²_p,
    "df" => df_p,
    "p_value" => p_p,
  )

  save_json("chisq_shuffle_vs_skipped_2025.json", all_data)
end

main()
