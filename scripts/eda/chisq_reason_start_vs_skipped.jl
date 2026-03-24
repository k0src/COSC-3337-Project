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

const COL_LABELS = ["skipped=false", "skipped=true"]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      username,
      reason_start,
      skipped
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND reason_start IS NOT NULL
      AND skipped      IS NOT NULL
    ORDER BY username, reason_start
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function build_observed(df, reasons)
  reason_idx = Dict(r => i for (i, r) in enumerate(reasons))
  obs = zeros(Int, length(reasons), 2)
  for row in eachrow(df)
    i = reason_idx[String(row.reason_start)]
    j = Bool(row.skipped) ? 2 : 1
    obs[i, j] += 1
  end
  return obs
end

function build_expected(obs)
  n = sum(obs)
  row_sums = sum(obs, dims=2)
  col_sums = sum(obs, dims=1)
  return Float64[row_sums[i] * col_sums[j] / n for i in 1:size(obs, 1), j in 1:size(obs, 2)]
end

function run_chisq(obs, exp)
  χ² = sum((Float64.(obs) .- exp) .^ 2 ./ exp)
  df = (size(obs, 1) - 1) * (size(obs, 2) - 1)
  p = ccdf(Chisq(df), χ²)
  return χ², df, p
end

function print_result(label, obs, exp, χ², df, p, row_labels)
  n = sum(obs)
  nrows = length(row_labels)
  p_str = p < 0.0001 ? "< 0.0001" : @sprintf("%.4f", p)

  println("$label  (n = $n)")

  println("  Observed:")
  @printf "    %-18s  %14s  %14s  %10s\n" "" COL_LABELS[1] COL_LABELS[2] "row total"
  for i in 1:nrows
    @printf "    %-18s  %14d  %14d  %10d\n" row_labels[i] obs[i, 1] obs[i, 2] sum(obs[i, :])
  end
  @printf "    %-18s  %14d  %14d  %10d\n" "col total" sum(obs[:, 1]) sum(obs[:, 2]) n
  println()

  println("  Expected:")
  @printf "    %-18s  %14s  %14s\n" "" COL_LABELS[1] COL_LABELS[2]
  for i in 1:nrows
    @printf "    %-18s  %14.2f  %14.2f\n" row_labels[i] exp[i, 1] exp[i, 2]
  end
  println()

  n_low = count(x -> x < 5.0, exp)
  if n_low > 0
    println("  ⚠  $n_low cell(s) with expected < 5 — chi-square result may be unreliable")
  end

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

    reasons = sort(unique(String.(user_df.reason_start)))
    obs = build_observed(user_df, reasons)
    exp = build_expected(obs)
    χ², df_val, p = run_chisq(obs, exp)

    print_result(display_name, obs, exp, χ², df_val, p, reasons)

    n_low = count(x -> x < 5.0, exp)

    all_data[display_name] = Dict{String,Any}(
      "n" => nrow(user_df),
      "row_labels" => reasons,
      "col_labels" => COL_LABELS,
      "observed" => [[obs[i, j] for j in 1:2] for i in 1:length(reasons)],
      "expected" => [[exp[i, j] for j in 1:2] for i in 1:length(reasons)],
      "chi2" => χ²,
      "df" => df_val,
      "p_value" => p,
      "n_low_expected" => n_low,
    )
  end

  save_json("chisq_reason_start_vs_skipped_2025.json", all_data)
end

main()
