include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using Dates
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "synchronized_listening_days_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]
const N_USERS = length(USER_ORDER)

const MONTH_LABELS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

function get_data()
  conn = get_connection()
  query = """
    SELECT
      username,
      DATE(timestamp)  AS date,
      COUNT(*)::int    AS plays
    FROM  listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
    GROUP BY username, date
    ORDER BY username, date
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function build_daily_matrix(df)
  all_dates = sort(unique(Date.(string.(df.date))))
  date_idx = Dict(d => i for (i, d) in enumerate(all_dates))
  n_days = length(all_dates)

  plays = zeros(Int, N_USERS, n_days)
  for row in eachrow(df)
    u = String(row.username)
    ui = findfirst(==(u), USER_ORDER)
    isnothing(ui) && continue
    d = Date(string(row.date))
    plays[ui, date_idx[d]] = Int(row.plays)
  end

  all_year_days = Date(2025, 1, 1):Day(1):Date(2025, 12, 31)
  full_plays = zeros(Int, N_USERS, length(all_year_days))
  year_idx = Dict(d => i for (i, d) in enumerate(all_year_days))
  for (di, d) in enumerate(all_dates)
    haskey(year_idx, d) || continue
    full_plays[:, year_idx[d]] = plays[:, di]
  end

  medians = [median(full_plays[ui, :]) for ui in 1:N_USERS]
  return all_dates, plays, medians
end

function compute_synchrony(all_dates, plays, medians)
  n_days = length(all_dates)
  above = zeros(Int, n_days)
  flags = zeros(Bool, N_USERS, n_days)

  for di in 1:n_days
    for ui in 1:N_USERS
      if plays[ui, di] > medians[ui]
        above[di] += 1
        flags[ui, di] = true
      end
    end
  end

  sync_days = [all_dates[di] for di in 1:n_days if above[di] == N_USERS]
  return above, flags, sync_days
end

function print_results(medians, sync_days, above, all_dates)
  println("Per-user medians (daily play count, including zero days):")
  for (ui, d) in enumerate(DISPLAY_ORDER)
    @printf "  %-12s  %.1f plays/day\n" d medians[ui]
  end
  println()

  println("$(length(sync_days)) synchronized days (all 4 users above median):")
  for d in sync_days
    di = findfirst(==(d), all_dates)
    @printf "  %s  (%s)\n" string(d) Dates.format(d, "E, d U")
  end
  println()

  monthly = zeros(Int, 12)
  for d in sync_days
    monthly[month(d)] += 1
  end
  println("Monthly count:")
  for m in 1:12
    monthly[m] > 0 && @printf "  %-5s  %d\n" MONTH_LABELS[m] monthly[m]
  end
  println()
end

function plot_timeline(all_dates, above, sync_days)
  xs = [dayofyear(d) for d in all_dates]
  ys = Float64.(above)

  month_starts = [dayofyear(Date(2025, m, 1)) for m in 1:12]

  fig = Figure(size=(1400, 500))
  ax = Axis(fig[1, 1],
    title="Users Above Daily Median - 2025 (synchronized days = all 4 users)",
    xlabel="Month",
    ylabel="Users Above Median",
    xticks=(month_starts, MONTH_LABELS),
    yticks=0:N_USERS,
    yminorticksvisible=false,
  )

  hspan!(ax, N_USERS - 0.5, N_USERS + 0.5, color=(:gold, 0.12))
  hlines!(ax, [Float64(N_USERS)], color=(:gold, 0.5), linewidth=1, linestyle=:dash)

  bar_colors = [
    above[i] == N_USERS ? Makie.wong_colors()[2] :
    above[i] >= 2 ? Makie.wong_colors()[1] :
    (:grey80)
    for i in 1:length(xs)
  ]

  barplot!(ax, xs, ys, color=bar_colors, gap=0.0, strokewidth=0)

  for d in sync_days
    doy = dayofyear(d)
    text!(ax, Float64(doy), Float64(N_USERS) + 0.12,
      text=Dates.format(d, "d/m"),
      fontsize=8,
      align=(:center, :bottom),
      rotation=pi / 3,
      color=:black,
    )
  end

  fname = joinpath(PLOTS_DIR, "synchronized_days_timeline_2025.png")
  save(fname, fig)
  println("  plot saved: $fname")
end

function plot_monthly(sync_days)
  monthly = zeros(Int, 12)
  for d in sync_days
    monthly[month(d)] += 1
  end

  fig = Figure(size=(800, 420))
  ax = Axis(fig[1, 1],
    title="Synchronized Listening Days per Month - 2025",
    xlabel="Month",
    ylabel="Synchronized Days",
    xticks=(1:12, MONTH_LABELS),
  )

  barplot!(ax, 1:12, monthly,
    color=(Makie.wong_colors()[2], 0.85),
    strokecolor=:white,
    strokewidth=0.6,
  )

  fname = joinpath(PLOTS_DIR, "synchronized_days_monthly_2025.png")
  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  all_dates, plays, medians = build_daily_matrix(df)
  above, flags, sync_days = compute_synchrony(all_dates, plays, medians)

  print_results(medians, sync_days, above, all_dates)

  plot_timeline(all_dates, above, sync_days)
  plot_monthly(sync_days)

  monthly = zeros(Int, 12)
  for d in sync_days
    monthly[month(d)] += 1
  end

  json_out = Dict{String,Any}(
    "threshold" => "plays > per_user_median (zeros included)",
    "user_medians" => Dict(DISPLAY_ORDER[ui] => medians[ui] for ui in 1:N_USERS),
    "n_sync_days" => length(sync_days),
    "sync_days" => string.(sync_days),
    "monthly_counts" => Dict(MONTH_LABELS[m] => monthly[m] for m in 1:12),
    "daily_series" => [
      Dict{String,Any}(
        "date" => string(all_dates[di]),
        "users_above" => above[di],
        "synchronized" => above[di] == N_USERS,
        "plays" => Dict(DISPLAY_ORDER[ui] => plays[ui, di] for ui in 1:N_USERS),
      )
      for di in 1:length(all_dates)
    ],
  )

  save_json(joinpath(SCRIPT_DIR, "synchronized_listening_days_2025.json"), json_out)
end

main()
