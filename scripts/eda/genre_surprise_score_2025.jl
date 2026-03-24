include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Dates
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_surprise_score_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const WINDOW_DAYS = 30
const TOP_N = 3

const MONTH_LABELS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

function get_plays()
  conn = get_connection()
  query = """
    SELECT username, timestamp, artist_name
    FROM  listening_history
    WHERE timestamp >= '2024-12-01'
      AND timestamp <  '2026-01-01'
      AND artist_name IS NOT NULL
    ORDER BY username, timestamp
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_genres_map()
  conn = get_connection()
  query = "SELECT DISTINCT artist_name, genre FROM artist_genres"
  df = DataFrame(execute(conn, query))
  close(conn)

  m = Dict{String,Vector{String}}()
  for row in eachrow(df)
    a = String(row.artist_name)
    g = String(row.genre)
    push!(get!(m, a, String[]), g)
  end
  return m
end

function compute_surprises(plays_sub, genres_map)
  n = nrow(plays_sub)
  window_counts = Dict{String,Int}()
  left = 1

  results = Vector{Union{Missing,Bool}}(missing, n)

  for i in 1:n
    ts = plays_sub.timestamp[i]
    cutoff = ts - Day(WINDOW_DAYS)

    while left < i && plays_sub.timestamp[left] < cutoff
      for g in get(genres_map, String(plays_sub.artist_name[left]), String[])
        cnt = get(window_counts, g, 1) - 1
        cnt <= 0 ? delete!(window_counts, g) : (window_counts[g] = cnt)
      end
      left += 1
    end

    if year(ts) == 2025 && !isempty(window_counts)
      sorted = sort(collect(window_counts), by=kv -> -kv[2])
      top_set = Set(kv[1] for kv in sorted[1:min(TOP_N, length(sorted))])

      play_genres = get(genres_map, String(plays_sub.artist_name[i]), String[])
      if !isempty(play_genres)
        results[i] = !any(g in top_set for g in play_genres)
      end
    end

    for g in get(genres_map, String(plays_sub.artist_name[i]), String[])
      window_counts[g] = get(window_counts, g, 0) + 1
    end
  end

  return results
end

function monthly_rates(plays_sub, surprises)
  totals = zeros(Int, 12)
  n_surp = zeros(Int, 12)

  for i in 1:nrow(plays_sub)
    ts = plays_sub.timestamp[i]
    year(ts) == 2025 || continue
    ismissing(surprises[i]) && continue
    m = month(ts)
    totals[m] += 1
    n_surp[m] += surprises[i] ? 1 : 0
  end

  rates = [totals[m] > 0 ? n_surp[m] / totals[m] : NaN for m in 1:12]
  return totals, n_surp, rates
end

function print_results(display_name, totals, n_surp, rates)
  total_plays = sum(totals)
  total_surp = sum(n_surp)
  overall = total_plays > 0 ? total_surp / total_plays : NaN
  println("$display_name  (overall surprise rate: $(round(overall*100,digits=1))%,  $total_surp / $total_plays plays)")
  @printf "  %-5s  %8s  %10s  %10s\n" "month" "plays" "surprising" "rate"
  for m in 1:12
    totals[m] == 0 && continue
    @printf "  %-5s  %8d  %10d  %9.1f%%\n" MONTH_LABELS[m] totals[m] n_surp[m] (rates[m] * 100)
  end
  println()
end

function plot_series(months_with_data, rates, display_name, username, fname)
  isempty(months_with_data) && return

  xs = Float64.(months_with_data)
  ys = rates[months_with_data]
  labels = MONTH_LABELS[months_with_data]

  fig = Figure(size=(800, 460))
  ax = Axis(fig[1, 1],
    title="Genre Surprise Rate - $display_name - 2025\n(play's genre outside top-$TOP_N genres of prior $WINDOW_DAYS-day window)",
    xlabel="Month",
    ylabel="Surprise Rate",
    xticks=(xs, labels),
    ytickformat=vs -> [@sprintf("%.0f%%", v * 100) for v in vs],
  )

  hlines!(ax, [0.0], color=:grey85, linewidth=0.8, linestyle=:dash)

  lines!(ax, xs, ys, linewidth=2, color=Makie.wong_colors()[1])
  scatter!(ax, xs, ys,
    markersize=9,
    color=Makie.wong_colors()[1],
    strokecolor=:white,
    strokewidth=1,
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  println("Loading plays and genre map...")
  plays_df = get_plays()
  genres_map = get_genres_map()

  nrow(plays_df) == 0 && (println("No data"); return)

  json_out = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    sub = filter(r -> String(r.username) == username, plays_df)
    isempty(sub) && continue

    println("Computing surprises for $display_name ($(nrow(sub)) plays)...")
    surprises = compute_surprises(sub, genres_map)

    totals, n_surp, rates = monthly_rates(sub, surprises)
    print_results(display_name, totals, n_surp, rates)

    months_with_data = [m for m in 1:12 if totals[m] > 0]
    fname = joinpath(PLOTS_DIR, "genre_surprise_score_$(username).png")
    plot_series(months_with_data, rates, display_name, username, fname)

    overall = sum(totals) > 0 ? sum(n_surp) / sum(totals) : NaN
    json_out[display_name] = Dict{String,Any}(
      "month_labels" => MONTH_LABELS,
      "plays_per_month" => totals,
      "surprising_per_month" => n_surp,
      "surprise_rate" => [isnan(r) ? nothing : r for r in rates],
      "overall_surprise_rate" => overall,
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_surprise_score_2025.json"), json_out)
end

main()
