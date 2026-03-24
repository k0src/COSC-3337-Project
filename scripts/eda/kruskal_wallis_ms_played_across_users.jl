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

const USER_ORDER = ["dasucc", "alanjzamora", "alexxxxxrs", "korenns"]
const DISPLAY_ORDER = ["Anthony", "Alan", "Alexandra", "Koren"]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      username,
      ms_played
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND ms_played IS NOT NULL
    ORDER BY username
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function rank_data(x::Vector{Float64})
  n = length(x)
  order = sortperm(x)
  ranks = zeros(Float64, n)
  i = 1
  while i <= n
    j = i
    while j < n && x[order[j+1]] == x[order[j]]
      j += 1
    end
    avg = (i + j) / 2.0
    for k in i:j
      ranks[order[k]] = avg
    end
    i = j + 1
  end
  return ranks
end

function tie_sum(sorted_vals::Vector{Float64})
  s = 0.0
  i = 1
  n = length(sorted_vals)
  while i <= n
    j = i
    while j < n && sorted_vals[j+1] == sorted_vals[j]
      j += 1
    end
    t = Float64(j - i + 1)
    if t > 1
      s += t^3 - t
    end
    i = j + 1
  end
  return s
end

function kruskal_wallis(groups::Vector{Vector{Float64}})
  all_vals = vcat(groups...)
  N = length(all_vals)
  ranks = rank_data(all_vals)

  H = 0.0
  offset = 0
  mean_ranks = Float64[]

  for g in groups
    n_i = length(g)
    R_bar = mean(ranks[(offset+1):(offset+n_i)])
    push!(mean_ranks, R_bar)
    H += n_i * R_bar^2
    offset += n_i
  end

  H = 12.0 / (N * (N + 1)) * H - 3.0 * (N + 1)

  ts = tie_sum(sort(all_vals))
  correction = 1.0 - ts / (Float64(N)^3 - N)
  H_c = correction > 0.0 ? H / correction : H

  df = length(groups) - 1
  p = ccdf(Chisq(df), H_c)

  return H_c, df, p, mean_ranks
end

function dunn_test(groups::Vector{Vector{Float64}}, names::Vector{String})
  all_vals = vcat(groups...)
  N = length(all_vals)
  ranks = rank_data(all_vals)

  ns = [length(g) for g in groups]
  mean_ranks = Float64[]
  offset = 0
  for g in groups
    n_i = length(g)
    push!(mean_ranks, mean(ranks[(offset+1):(offset+n_i)]))
    offset += n_i
  end

  ts = tie_sum(sort(all_vals))
  σ² = (N * (N + 1) / 12.0) - ts / (12.0 * (N - 1))

  k = length(groups)
  m = k * (k - 1) ÷ 2

  results = NamedTuple[]
  for i in 1:(k-1)
    for j in (i+1):k
      se = sqrt(σ² * (1.0 / ns[i] + 1.0 / ns[j]))
      z = (mean_ranks[i] - mean_ranks[j]) / se
      p_raw = 2.0 * ccdf(Normal(0, 1), abs(z))
      p_bon = min(1.0, p_raw * m)
      push!(results, (
        group1=names[i],
        group2=names[j],
        z=z,
        p_raw=p_raw,
        p_bonf=p_bon,
        mean_rank_1=mean_ranks[i],
        mean_rank_2=mean_ranks[j],
        sig=p_bon < 0.05,
      ))
    end
  end

  return results
end

function print_kw(H, df, p, names, mean_ranks, groups)
  p_str = p < 0.0001 ? "< 0.0001" : @sprintf("%.4f", p)
  println("Kruskal-Wallis: ms_played across users (2025)")
  println("  H = $(@sprintf("%.4f", H))  |  df = $df  |  p = $p_str")
  println()
  println("  Group summary:")
  @printf "    %-12s  %10s  %12s  %12s  %12s\n" "user" "n" "mean_rank" "median_min" "mean_min"
  for (name, mr, g) in zip(names, mean_ranks, groups)
    @printf "    %-12s  %10d  %12.2f  %12.4f  %12.4f\n" name length(g) mr median(g) mean(g)
  end
  println()
end

function print_dunn(results)
  println("  Dunn's post-hoc (Bonferroni, m = $(length(results)) comparisons, α = 0.05):")
  @printf "    %-12s  %-12s  %10s  %10s  %10s  %6s\n" "group1" "group2" "z" "p_raw" "p_bonf" "sig"
  for r in results
    sig_str = r.sig ? "✓" : ""
    p_raw_str = r.p_raw < 0.0001 ? "< 0.0001" : @sprintf("%.4f", r.p_raw)
    p_bon_str = r.p_bonf < 0.0001 ? "< 0.0001" : @sprintf("%.4f", r.p_bonf)
    @printf "    %-12s  %-12s  %10.4f  %10s  %10s  %6s\n" r.group1 r.group2 r.z p_raw_str p_bon_str sig_str
  end
  println()
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data for 2025"); return)

  groups = Vector{Float64}[]
  names = String[]
  ns = Dict{String,Int}()

  for (u, display) in zip(USER_ORDER, DISPLAY_ORDER)
    vals = Float64.(filter(r -> String(r.username) == u, df).ms_played) ./ 60000.0
    length(vals) < 3 && continue
    push!(groups, vals)
    push!(names, display)
    ns[display] = length(vals)
  end

  H, df_val, p, mean_ranks = kruskal_wallis(groups)
  print_kw(H, df_val, p, names, mean_ranks, groups)

  dunn_results = dunn_test(groups, names)
  print_dunn(dunn_results)

  all_data = Dict{String,Any}(
    "year" => 2025,
    "kruskal_wallis" => Dict{String,Any}(
      "H" => H,
      "df" => df_val,
      "p_value" => p,
      "groups" => [
        Dict{String,Any}(
          "user" => name,
          "n" => length(g),
          "mean_rank" => mr,
          "median_min" => median(g),
          "mean_min" => mean(g),
        )
        for (name, g, mr) in zip(names, groups, mean_ranks)
      ],
    ),
    "dunn_bonferroni" => [
      Dict{String,Any}(
        "group1" => r.group1,
        "group2" => r.group2,
        "z" => r.z,
        "p_raw" => r.p_raw,
        "p_bonferroni" => r.p_bonf,
        "mean_rank_1" => r.mean_rank_1,
        "mean_rank_2" => r.mean_rank_2,
        "significant" => r.sig,
      )
      for r in dunn_results
    ],
  )

  save_json("kruskal_wallis_ms_played_across_users_2025.json", all_data)
end

main()
