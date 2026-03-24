include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using Printf

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["dasucc", "alanjzamora", "alexxxxxrs", "korenns"]
const DISPLAY_ORDER = ["Anthony", "Alan", "Alexandra", "Koren"]

const PERIODS = [
  ("2024", 2024),
  ("2025", 2025),
  ("alltime", nothing),
]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      lh.username,
      EXTRACT(YEAR FROM lh.timestamp)::INT  AS year,
      ag.genre,
      COUNT(*)                              AS play_count
    FROM listening_history   lh
    JOIN artist_genres        ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
    GROUP BY lh.username,
             EXTRACT(YEAR FROM lh.timestamp)::INT,
             ag.genre
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function filter_period(df, year_filter)
  year_filter === nothing && return df
  filter(r -> r.year == year_filter, df)
end

function genre_play_counts(df)
  result = Dict{String,Int}()
  for row in eachrow(df)
    g = String(row.genre)
    result[g] = get(result, g, 0) + Int(row.play_count)
  end
  return collect(values(result))
end

function summary_stats(counts)
  n = length(counts)
  Dict{String,Any}(
    "n_genres" => n,
    "min" => minimum(counts),
    "max" => maximum(counts),
    "mean" => mean(counts),
    "median" => median(counts),
    "pct_under_10" => round(count(c -> c < 10, counts) / n * 100.0, digits=2),
    "pct_under_100" => round(count(c -> c < 100, counts) / n * 100.0, digits=2),
  )
end

function plot_linear(counts, title, fname)
  vals = Float64.(counts)

  fig = Figure(size=(750, 500))
  ax = Axis(fig[1, 1],
    title=title,
    xlabel="Play Count (per genre)",
    ylabel="Density",
  )
  hist!(ax, vals, normalization=:pdf, bins=40, color=(Makie.wong_colors()[1], 0.6))
  density!(ax, vals, color=(:black, 0.0), strokecolor=:black, strokewidth=2)

  save(fname, fig)
  println("  plot saved: $fname")
end

function plot_log(counts, title, fname)
  vals = log10.(Float64.(counts))

  raw_min = floor(minimum(vals))
  raw_max = ceil(maximum(vals))
  tick_positions = collect(raw_min:raw_max)
  tick_labels = ["10^$(Int(p))" for p in tick_positions]

  fig = Figure(size=(750, 500))
  ax = Axis(fig[1, 1],
    title=title,
    xlabel="Play Count (log10 scale)",
    ylabel="Density",
    xticks=(tick_positions, tick_labels),
  )
  hist!(ax, vals, normalization=:pdf, bins=40, color=(Makie.wong_colors()[2], 0.6))
  density!(ax, vals, color=(:black, 0.0), strokecolor=:black, strokewidth=2)

  save(fname, fig)
  println("  plot saved: $fname")
end

function print_summary(display_name, period_label, stats)
  println("$display_name - $period_label")
  println("  n_genres:     $(stats["n_genres"])")
  println("  min/max:      $(stats["min"]) / $(stats["max"]) plays")
  @printf "  mean/median:  %.1f / %.1f plays\n" stats["mean"] stats["median"]
  println("  < 10 plays:   $(stats["pct_under_10"])% of genres")
  println("  < 100 plays:  $(stats["pct_under_100"])% of genres")
  println()
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  all_data = Dict{String,Any}()

  for (period_label, year_filter) in PERIODS
    period_df = filter_period(df, year_filter)
    nrow(period_df) == 0 && continue

    all_data[period_label] = Dict{String,Any}()

    for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
      user_df = filter(r -> String(r.username) == username, period_df)
      nrow(user_df) == 0 && continue

      counts = genre_play_counts(user_df)
      length(counts) < 5 && continue

      stats = summary_stats(counts)
      print_summary(display_name, period_label, stats)

      plot_linear(counts,
        "Genre Play Count Distribution - $display_name - $period_label",
        "genre_hist_linear_$(username)_$(period_label).png")

      plot_log(counts,
        "Genre Play Count Distribution (Log Scale) - $display_name - $period_label",
        "genre_hist_log_$(username)_$(period_label).png")

      all_data[period_label][display_name] = Dict{String,Any}(
        "genre_play_counts" => counts,
        "stats" => stats,
      )
    end
  end

  save_json("genre_histogram.json", all_data)
end

main()
