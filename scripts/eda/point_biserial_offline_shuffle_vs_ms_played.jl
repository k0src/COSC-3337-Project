include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using Statistics
using Distributions
using Printf

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

function get_data()
  conn = get_connection()

  query = """
    SELECT
      username,
      offline,
      shuffle,
      ms_played
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND offline   IS NOT NULL
      AND shuffle   IS NOT NULL
      AND ms_played IS NOT NULL
    ORDER BY username
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function compute_rpb(binary::Vector{Float64}, continuous::Vector{Float64})
  n = length(binary)
  r = cor(binary, continuous)
  t = r * sqrt(n - 2) / sqrt(max(1.0 - r^2, 1e-12))
  p = 2.0 * ccdf(TDist(n - 2), abs(t))

  idx0 = binary .== 0.0
  idx1 = binary .== 1.0
  mean0 = mean(continuous[idx0])
  mean1 = mean(continuous[idx1])

  return r, t, p, mean0, mean1, sum(idx0), sum(idx1)
end

function print_result(display_name, predictor, n, r, t, p, mean0, mean1, n0, n1)
  p_str = p < 0.0001 ? "< 0.0001" : @sprintf("%.4f", p)
  label0 = "$predictor=false"
  label1 = "$predictor=true"
  println("$display_name  (n = $n)")
  println("  r_pb = $(@sprintf("%.4f", r))  |  t = $(@sprintf("%.4f", t))  |  p = $p_str")
  println("  mean duration — $label0: $(@sprintf("%.4f", mean0)) min  (n = $n0)")
  println("  mean duration — $label1: $(@sprintf("%.4f", mean1)) min  (n = $n1)")
  println()
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data for 2025"); return)

  pairs = [
    (:offline, "offline", "point_biserial_offline_vs_ms_played_2025.json"),
    (:shuffle, "shuffle", "point_biserial_shuffle_vs_ms_played_2025.json"),
  ]

  for (col, predictor, fname) in pairs
    println("── $predictor vs ms_played ──────────────────────────────────────────────")
    all_data = Dict{String,Any}()

    for (username, display_name) in NAMES
      user_df = filter(r -> String(r.username) == username, df)
      nrow(user_df) < 3 && continue

      binary = Float64.([Bool(getproperty(r, col)) ? 1.0 : 0.0 for r in eachrow(user_df)])
      continuous = Float64.(user_df.ms_played) ./ 60000.0

      r, t, p, mean0, mean1, n0, n1 = compute_rpb(binary, continuous)

      print_result(display_name, predictor, nrow(user_df), r, t, p, mean0, mean1, n0, n1)

      all_data[display_name] = Dict{String,Any}(
        "n" => nrow(user_df),
        "r_pb" => r,
        "t" => t,
        "p_value" => p,
        "mean_minutes_$(predictor)_false" => mean0,
        "mean_minutes_$(predictor)_true" => mean1,
        "n_$(predictor)_false" => n0,
        "n_$(predictor)_true" => n1,
      )
    end

    save_json(fname, all_data)
  end
end

main()
