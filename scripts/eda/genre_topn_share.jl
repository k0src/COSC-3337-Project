include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
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

const TOP_NS = [1, 5, 10]

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

function sorted_counts(df, username)
  sub = filter(r -> String(r.username) == username, df)
  result = Dict{String,Int}()
  for row in eachrow(sub)
    g = String(row.genre)
    result[g] = get(result, g, 0) + Int(row.play_count)
  end
  return sort(collect(values(result)), rev=true)
end

function topn_share(counts, n)
  length(counts) == 0 && return NaN
  total = sum(counts)
  top = sum(counts[1:min(n, length(counts))])
  return top / total * 100.0
end

function plot_topn_share(user_data, display_name, fname)
  period_labels = [p for (p, _) in PERIODS if haskey(user_data, p)]
  n_periods = length(period_labels)
  n_periods == 0 && return

  xs = Int[]
  groups = Int[]
  vals = Float64[]

  for (xi, period_label) in enumerate(period_labels)
    d = user_data[period_label]
    for (gi, n) in enumerate(TOP_NS)
      key = "top$(n)"
      push!(xs, xi)
      push!(groups, gi)
      push!(vals, d[key])
    end
  end

  colors = Makie.wong_colors()[[1, 2, 3]]

  fig = Figure(size=(700, 500))
  ax = Axis(fig[1, 1],
    title="Top-N Genre Share - $display_name",
    ylabel="Share of Total Plays (%)",
    xticks=(1:n_periods, period_labels),
    limits=(nothing, nothing, 0, nothing),
  )

  barplot!(ax, xs, vals, dodge=groups, color=colors[groups])

  Legend(fig[1, 2],
    [PolyElement(color=colors[i]) for i in 1:3],
    ["Top 1", "Top 5", "Top 10"],
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

function print_table(all_data)
  println("\nTop-N Genre Share (% of total plays):")
  @printf "  %-12s  %-10s  %8s  %8s  %8s\n" "user" "period" "top-1" "top-5" "top-10"
  println("  " * "-"^52)
  for display_name in DISPLAY_ORDER
    haskey(all_data, display_name) || continue
    for (period_label, _) in PERIODS
      haskey(all_data[display_name], period_label) || continue
      d = all_data[display_name][period_label]
      @printf "  %-12s  %-10s  %7.2f%%  %7.2f%%  %7.2f%%\n" display_name period_label d["top1"] d["top5"] d["top10"]
    end
    println()
  end
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  all_data = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    all_data[display_name] = Dict{String,Any}()

    for (period_label, year_filter) in PERIODS
      period_df = filter_period(df, year_filter)
      counts = sorted_counts(period_df, username)
      isempty(counts) && continue

      all_data[display_name][period_label] = Dict{String,Any}(
        "n_genres" => length(counts),
        "top1" => topn_share(counts, 1),
        "top5" => topn_share(counts, 5),
        "top10" => topn_share(counts, 10),
      )
    end

    plot_topn_share(all_data[display_name], display_name,
      "genre_topn_share_$(username).png")
  end

  print_table(all_data)
  save_json("genre_topn_share.json", all_data)
end

main()
