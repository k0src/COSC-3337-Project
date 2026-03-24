include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

function get_shuffle_ms_played()
  conn = get_connection()

  query = """
    SELECT
      username,
      shuffle,
      ms_played
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND ms_played IS NOT NULL
    ORDER BY username, shuffle
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function boxplot_stats(values)
  length(values) < 2 && return nothing
  q1 = quantile(values, 0.25)
  q3 = quantile(values, 0.75)
  iqr = q3 - q1
  Dict{String,Any}(
    "n" => length(values),
    "mean" => mean(values),
    "median" => median(values),
    "q1" => q1,
    "q3" => q3,
    "iqr" => iqr,
    "whisker_lo" => max(minimum(values), q1 - 1.5 * iqr),
    "whisker_hi" => min(maximum(values), q3 + 1.5 * iqr),
  )
end

function plot_shuffle_ms_played(user_df, username, display_name)
  nrow(user_df) == 0 && return

  min_vals = Float64.(user_df.ms_played) ./ 60000.0
  x_pos = [Bool(r.shuffle) ? 2 : 1 for r in eachrow(user_df)]

  fig = Figure(size=(600, 500))
  ax = Axis(fig[1, 1],
    title="Shuffle vs. Play Duration - $display_name - 2025",
    ylabel="Play Duration (minutes)",
    xticks=(1:2, ["Shuffle Off", "Shuffle On"]),
  )
  boxplot!(ax, x_pos, min_vals, show_outliers=true)

  fname = "shuffle_ms_played_$(username)_2025.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function main()
  df = get_shuffle_ms_played()
  nrow(df) == 0 && (println("No data for 2025"); return)

  all_data = Dict{String,Any}()

  for (username, display_name) in NAMES
    user_df = filter(r -> String(r.username) == username, df)
    nrow(user_df) == 0 && continue

    plot_shuffle_ms_played(user_df, username, display_name)

    println("$display_name:")
    user_data = Dict{String,Any}()

    for (flag, label) in [(false, "shuffle_off"), (true, "shuffle_on")]
      vals = Float64.(filter(r -> Bool(r.shuffle) == flag, user_df).ms_played) ./ 60000.0
      isempty(vals) && continue
      stats = boxplot_stats(vals)
      stats === nothing && continue
      println("  $label: mean = $(round(stats["mean"], digits=4)) min")
      user_data[label] = stats
    end

    println()
    all_data[display_name] = user_data
  end

  save_json("shuffle_ms_played_2025.json", all_data)
end

main()
