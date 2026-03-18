include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie

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

const COLORS = [
  :steelblue, :orangered, :seagreen, :goldenrod, :mediumpurple,
  :deeppink, :darkcyan, :coral, :slateblue, :olivedrab,
]

# Data

function get_user_reason_start(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      COALESCE(reason_start, 'unknown') AS reason_start,
      COUNT(*) AS count
    FROM listening_history
    $year_filter
    GROUP BY username, reason_start
    ORDER BY username, count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_user_reason_end(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      COALESCE(reason_end, 'unknown') AS reason_end,
      COUNT(*) AS count
    FROM listening_history
    $year_filter
    GROUP BY username, reason_end
    ORDER BY username, count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Plots

function plot_reason_proportions_users(df, col, title_str, year_label)
  nrow(df) == 0 && return
  title_label = year_label == "alltime" ? "All-Time" : year_label

  all_cats = sort(unique(String.(df[!, col])))
  isempty(all_cats) && return

  user_keys = sort(unique(String.(df.username)))
  n_users = length(user_keys)
  n_cats = length(all_cats)

  x_pos = Int[]
  y_vals = Float64[]
  stk = Int[]

  for (ui, username) in enumerate(user_keys)
    user_df = filter(r -> String(r.username) == username, df)
    total = nrow(user_df) == 0 ? 0 : sum(user_df.count)
    total == 0 && continue
    cat_counts = Dict(String(r[col]) => Int(r.count) for r in eachrow(user_df))
    for (ci, cat) in enumerate(all_cats)
      push!(x_pos, ui)
      push!(y_vals, get(cat_counts, cat, 0) / total)
      push!(stk, ci)
    end
  end

  isempty(x_pos) && return

  display_labels = [get(NAMES, uk, uk) for uk in user_keys]
  colors = [COLORS[mod1(s, length(COLORS))] for s in stk]

  fig = Figure(size=(1000, 600))
  ax = Axis(fig[1, 1],
    title="$title_str - Per User - $title_label",
    ylabel="Proportion",
    xticks=(1:n_users, display_labels),
  )
  barplot!(ax, x_pos, y_vals; stack=stk, color=colors)
  elems = [PolyElement(polycolor=COLORS[mod1(i, length(COLORS))]) for i in 1:n_cats]
  Legend(fig[1, 2], elems, all_cats, "Category")

  fname = "$(col)_users_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

# Helpers

function build_json(df, col)
  period_data = Dict{String,Any}()
  for username in sort(unique(String.(df.username)))
    display_name = get(NAMES, username, username)
    user_df = filter(r -> String(r.username) == username, df)
    total = sum(user_df.count)
    period_data[display_name] = [
      Dict{String,Any}(
        "category" => String(r[col]),
        "count" => Int(r.count),
        "proportion" => Int(r.count) / total,
      )
      for r in eachrow(user_df)
    ]
  end
  return period_data
end

# Main

function main()
  for (year, year_label) in PERIODS
    title_label = year_label == "alltime" ? "All-Time" : year_label
    println("\n$(title_label)\n")

    rs_df = get_user_reason_start(year=year)
    re_df = get_user_reason_end(year=year)

    plot_reason_proportions_users(rs_df, :reason_start, "reason_start", year_label)
    plot_reason_proportions_users(re_df, :reason_end, "reason_end", year_label)

    save_json("reason_start_$(year_label).json", build_json(rs_df, :reason_start))
    save_json("reason_end_$(year_label).json", build_json(re_df, :reason_end))
  end
end

main()
