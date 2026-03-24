include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie

const DATA_DIR = joinpath(@__DIR__, "..", "..", "data", "bool_flags")
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

function get_user_bool_flags(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      SUM(CASE WHEN shuffle      THEN 1 ELSE 0 END) AS shuffle_true,
      SUM(CASE WHEN NOT shuffle  THEN 1 ELSE 0 END) AS shuffle_false,
      SUM(CASE WHEN skipped      THEN 1 ELSE 0 END) AS skipped_true,
      SUM(CASE WHEN NOT skipped  THEN 1 ELSE 0 END) AS skipped_false,
      SUM(CASE WHEN offline      THEN 1 ELSE 0 END) AS offline_true,
      SUM(CASE WHEN NOT offline  THEN 1 ELSE 0 END) AS offline_false,
      COUNT(*) AS total
    FROM listening_history
    $year_filter
    GROUP BY username
    ORDER BY username
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function plot_bool_flags_users(df, year_label)
  nrow(df) == 0 && return
  title_label = year_label == "alltime" ? "All-Time" : year_label

  flag_colors = [:steelblue, :orangered, :seagreen]
  n_users = nrow(df)
  display_labels = [get(NAMES, String(row.username), String(row.username)) for row in eachrow(df)]

  x_pos = Int[]
  y_vals = Float64[]
  dodge_idxs = Int[]

  for (ui, row) in enumerate(eachrow(df))
    total = Int(row.total)
    total == 0 && continue
    push!(x_pos, ui)
    push!(y_vals, row.shuffle_true / total)
    push!(dodge_idxs, 1)
    push!(x_pos, ui)
    push!(y_vals, row.skipped_true / total)
    push!(dodge_idxs, 2)
    push!(x_pos, ui)
    push!(y_vals, row.offline_true / total)
    push!(dodge_idxs, 3)
  end

  isempty(x_pos) && return

  fig = Figure(size=(900, 600))
  ax = Axis(fig[1, 1],
    title="Shuffle, Skipped, Offline - Per User - $title_label",
    ylabel="Rate",
    xticks=(1:n_users, display_labels),
  )
  barplot!(ax, x_pos, y_vals; dodge=dodge_idxs, color=[flag_colors[d] for d in dodge_idxs])
  elems = [PolyElement(polycolor=flag_colors[i]) for i in 1:3]
  Legend(fig[1, 2], elems, ["Shuffle", "Skipped", "Offline"], "Flag")

  fname = joinpath(PLOTS_DIR, "bool_flags_users_$(year_label).png")
  save(fname, fig)
  println("Plot saved to $fname")
end

function main()
  for (year, year_label) in PERIODS
    title_label = year_label == "alltime" ? "All-Time" : year_label
    println("\n$(title_label)\n")

    df = get_user_bool_flags(year=year)

    period_data = Dict{String,Any}()
    for row in eachrow(df)
      display_name = get(NAMES, String(row.username), String(row.username))
      total = Int(row.total)
      total == 0 && continue
      period_data[display_name] = Dict{String,Any}(
        "shuffle_true" => Int(row.shuffle_true),
        "shuffle_false" => Int(row.shuffle_false),
        "shuffle_rate" => row.shuffle_true / total,
        "skipped_true" => Int(row.skipped_true),
        "skipped_false" => Int(row.skipped_false),
        "skip_rate" => row.skipped_true / total,
        "offline_true" => Int(row.offline_true),
        "offline_false" => Int(row.offline_false),
        "offline_rate" => row.offline_true / total,
        "total" => total,
      )
    end

    plot_bool_flags_users(df, year_label)
    save_json(joinpath(DATA_DIR, "bool_flags_$(year_label).json"), period_data)
  end
end

main()
