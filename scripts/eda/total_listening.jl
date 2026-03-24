include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie

const DATA_DIR = joinpath(@__DIR__, "..", "..", "data", "total_listening")
const PLOTS_DIR = joinpath(DATA_DIR, "plots")
mkpath(PLOTS_DIR)

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const PERIODS = [
  (nothing, "alltime"),
  (2024, "2024"),
  (2025, "2025"),
]

function get_user_total_listening(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      COUNT(*) AS play_count,
      COALESCE(SUM(ms_played), 0) / 60000.0 AS total_minutes
    FROM listening_history
    $year_filter
    GROUP BY username
    ORDER BY username
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function plot_total_listening(df, year_label)
  nrow(df) == 0 && return
  title_label = year_label == "alltime" ? "All-Time" : year_label

  user_keys = sort(unique(String.(df.username)))
  n = length(user_keys)
  display_labels = [get(NAMES, uk, uk) for uk in user_keys]

  play_counts = [Int(first(filter(r -> String(r.username) == uk, df)).play_count) for uk in user_keys]
  total_minutes = [Float64(first(filter(r -> String(r.username) == uk, df)).total_minutes) for uk in user_keys]

  metric_colors = [:steelblue, :orangered]

  x_pos = Int[]
  y_vals = Float64[]
  dodge_idxs = Int[]

  for (ui, _) in enumerate(user_keys)
    push!(x_pos, ui)
    push!(y_vals, Float64(play_counts[ui]))
    push!(dodge_idxs, 1)
    push!(x_pos, ui)
    push!(y_vals, total_minutes[ui])
    push!(dodge_idxs, 2)
  end

  fig = Figure(size=(1000, 600))
  ax = Axis(fig[1, 1],
    title="Total Listening - Per User - $title_label",
    ylabel="Count / Minutes",
    xticks=(1:n, display_labels),
  )
  barplot!(ax, x_pos, y_vals; dodge=dodge_idxs, color=[metric_colors[d] for d in dodge_idxs])

  elems = [PolyElement(polycolor=metric_colors[i]) for i in 1:2]
  Legend(fig[1, 2], elems, ["Play Count", "Total Minutes"])

  fname = joinpath(PLOTS_DIR, "total_listening_$(year_label).png")
  save(fname, fig)
  println("Plot saved to $fname")
end

function build_json(df)
  period_data = Dict{String,Any}()
  for row in eachrow(df)
    display_name = get(NAMES, String(row.username), String(row.username))
    total_minutes = Float64(row.total_minutes)
    period_data[display_name] = Dict{String,Any}(
      "play_count" => Int(row.play_count),
      "total_minutes" => total_minutes,
      "total_hours" => total_minutes / 60.0,
    )
  end
  return period_data
end

function main()
  for (year, year_label) in PERIODS
    title_label = year_label == "alltime" ? "All-Time" : year_label
    println("\n$(title_label)\n")

    df = get_user_total_listening(year=year)
    nrow(df) == 0 && continue

    plot_total_listening(df, year_label)
    save_json(joinpath(DATA_DIR, "total_listening_$(year_label).json"), build_json(df))
  end
end

main()
