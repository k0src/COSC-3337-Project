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

# Data

function get_user_skip_by_shuffle(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      shuffle::TEXT AS shuffle,
      skipped::TEXT AS skipped,
      COUNT(*) AS count
    FROM listening_history
    $year_filter
    GROUP BY username, shuffle, skipped
    ORDER BY username, shuffle, skipped
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Plots

function plot_skip_by_shuffle_users(df, year_label)
  nrow(df) == 0 && return
  title_label = year_label == "alltime" ? "All-Time" : year_label

  user_keys = sort(unique(String.(df.username)))
  n_users = length(user_keys)
  shuffle_order = ["true", "false"]
  shuffle_colors = [:steelblue, :orangered]

  x_pos = Int[]
  y_vals = Float64[]
  dodge_idxs = Int[]

  for (ui, username) in enumerate(user_keys)
    user_df = filter(r -> String(r.username) == username, df)
    for (di, shuf) in enumerate(shuffle_order)
      relevant = [(String(coalesce(r.skipped, "null")), Int(r.count))
                  for r in eachrow(user_df) if String(coalesce(r.shuffle, "null")) == shuf]
      total = isempty(relevant) ? 0 : sum(c for (_, c) in relevant)
      total == 0 && continue
      skipped_n = sum((c for (s, c) in relevant if s == "true"), init=0)
      push!(x_pos, ui)
      push!(y_vals, skipped_n / total)
      push!(dodge_idxs, di)
    end
  end

  isempty(x_pos) && return

  display_labels = [get(NAMES, uk, uk) for uk in user_keys]

  fig = Figure(size=(900, 600))
  ax = Axis(fig[1, 1],
    title="Skip Rate by Shuffle - Per User - $title_label",
    ylabel="Skip Rate",
    xticks=(1:n_users, display_labels),
  )
  barplot!(ax, x_pos, y_vals; dodge=dodge_idxs, color=[shuffle_colors[d] for d in dodge_idxs])
  elems = [PolyElement(polycolor=shuffle_colors[i]) for i in 1:2]
  Legend(fig[1, 2], elems, ["Shuffle On", "Shuffle Off"], "Shuffle")

  fname = "skip_by_shuffle_users_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

# Main

function main()
  for (year, year_label) in PERIODS
    title_label = year_label == "alltime" ? "All-Time" : year_label
    println("\n$(title_label)\n")

    df = get_user_skip_by_shuffle(year=year)

    period_data = Dict{String,Any}()
    for username in sort(unique(String.(df.username)))
      display_name = get(NAMES, username, username)
      user_df = filter(r -> String(r.username) == username, df)

      user_data = Dict{String,Any}()
      for (label, shuf) in [("shuffle_on", "true"), ("shuffle_off", "false")]
        relevant = [(String(coalesce(r.skipped, "null")), Int(r.count))
                    for r in eachrow(user_df) if String(coalesce(r.shuffle, "null")) == shuf]
        total = isempty(relevant) ? 0 : sum(c for (_, c) in relevant)
        total == 0 && continue
        skipped_n = sum((c for (s, c) in relevant if s == "true"), init=0)
        user_data[label] = Dict{String,Any}(
          "skip_rate" => skipped_n / total,
          "skipped" => skipped_n,
          "completed" => total - skipped_n,
          "total" => total,
        )
      end

      period_data[display_name] = user_data
    end

    plot_skip_by_shuffle_users(df, year_label)
    save_json("skip_by_shuffle_$(year_label).json", period_data)
  end
end

main()
