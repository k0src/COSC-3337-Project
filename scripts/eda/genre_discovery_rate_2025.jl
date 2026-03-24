include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Dates
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_discovery_rate_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const MONTH_LABELS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

function get_data()
  conn = get_connection()

  query = """
    WITH first_seen AS (
      SELECT
        lh.username,
        ag.genre,
        MIN(lh.timestamp) AS first_seen
      FROM  listening_history lh
      JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
      WHERE lh.artist_name IS NOT NULL
      GROUP BY lh.username, ag.genre
    )
    SELECT
      username,
      EXTRACT(MONTH FROM first_seen)::int AS month,
      COUNT(*)::int                       AS new_genres
    FROM  first_seen
    WHERE EXTRACT(YEAR FROM first_seen) = 2025
    GROUP BY username, month
    ORDER BY username, month
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function user_series(df, username)
  sub = filter(r -> String(r.username) == username, df)
  counts = zeros(Int, 12)
  for row in eachrow(sub)
    counts[Int(row.month)] = Int(row.new_genres)
  end
  return counts
end

function print_table(display_name, counts)
  total = sum(counts)
  println("$display_name - 2025  (total new genres: $total)")
  @printf "  %-5s  %10s\n" "month" "new_genres"
  for (m, c) in enumerate(counts)
    @printf "  %-5s  %10d\n" MONTH_LABELS[m] c
  end
  println()
end

function plot_individual(counts, display_name, fname)
  xs = 1:12

  fig = Figure(size=(750, 450))
  ax = Axis(fig[1, 1],
    title="New Genres Discovered per Month - $display_name - 2025",
    xlabel="Month",
    ylabel="New Genres",
    xticks=(1:12, MONTH_LABELS),
  )

  lines!(ax, xs, counts, linewidth=2, color=Makie.wong_colors()[1])
  scatter!(ax, xs, counts,
    markersize=9,
    color=Makie.wong_colors()[1],
    strokecolor=:white,
    strokewidth=1,
  )

  hlines!(ax, [0], color=:grey80, linewidth=0.8, linestyle=:dash)

  save(fname, fig)
  println("  plot saved: $fname")
end

function plot_combined(all_counts)
  xs = 1:12
  colors = Makie.wong_colors()

  fig = Figure(size=(1100, 750))

  for (i, (username, display_name)) in enumerate(zip(USER_ORDER, DISPLAY_ORDER))
    row = (i - 1) ÷ 2 + 1
    col = (i - 1) % 2 + 1
    counts = all_counts[username]

    ax = Axis(fig[row, col],
      title=display_name,
      xlabel="Month",
      ylabel="New Genres",
      xticks=(1:12, MONTH_LABELS),
    )

    lines!(ax, xs, counts, linewidth=2, color=colors[i])
    scatter!(ax, xs, counts,
      markersize=9,
      color=colors[i],
      strokecolor=:white,
      strokewidth=1,
    )
    hlines!(ax, [0], color=:grey80, linewidth=0.8, linestyle=:dash)
  end

  Label(fig[0, :], "New Genres Discovered per Month - 2025",
    fontsize=16, font=:bold)

  fname = joinpath(PLOTS_DIR, "genre_discovery_rate_2025_combined.png")
  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  all_counts = Dict{String,Vector{Int}}()
  json_out = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    counts = user_series(df, username)
    all_counts[username] = counts

    print_table(display_name, counts)

    fname = joinpath(PLOTS_DIR, "genre_discovery_rate_2025_$(username).png")
    plot_individual(counts, display_name, fname)

    json_out[display_name] = Dict{String,Any}(
      "months" => MONTH_LABELS,
      "new_genres" => counts,
      "total_2025" => sum(counts),
    )
  end

  plot_combined(all_counts)

  save_json(joinpath(SCRIPT_DIR, "genre_discovery_rate_2025.json"), json_out)
end

main()
