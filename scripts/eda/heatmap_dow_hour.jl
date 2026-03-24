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

function get_dow_hour_counts(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      EXTRACT(DOW FROM timestamp)::INT   AS dow,
      EXTRACT(HOUR FROM timestamp)::INT  AS hour,
      COUNT(*) AS play_count
    FROM listening_history
    $year_filter
    GROUP BY username, dow, hour
    ORDER BY username, dow, hour
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function plot_dow_hour_heatmap(df, username, year_label)
  display_name = get(NAMES, username, username)
  title_label = year_label == "alltime" ? "All-Time" : year_label

  user_df = filter(r -> String(r.username) == username, df)
  nrow(user_df) == 0 && return

  grid = zeros(Float64, 24, 7)
  for row in eachrow(user_df)
    grid[Int(row.hour)+1, Int(row.dow)+1] = Float64(row.play_count)
  end

  day_names = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

  fig = Figure(size=(900, 400))
  ax = Axis(fig[1, 1],
    title="Listening Heatmap - $display_name - $title_label",
    xlabel="Hour of Day",
    ylabel="Day of Week",
    xticks=([1, 7, 13, 19], ["12am", "6am", "12pm", "6pm"]),
    yticks=(1:7, day_names),
  )
  hm = heatmap!(ax, 1:24, 1:7, grid, colormap=:inferno)
  Colorbar(fig[1, 2], hm, label="Play Count")

  fname = "heatmap_dow_hour_$(username)_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function main()
  for (year, year_label) in PERIODS
    title_label = year_label == "alltime" ? "All-Time" : year_label
    println("\n$(title_label)\n")

    df = get_dow_hour_counts(year=year)
    nrow(df) == 0 && continue

    period_data = Dict{String,Any}()

    for (username, display_name) in NAMES
      plot_dow_hour_heatmap(df, username, year_label)

      user_df = filter(r -> String(r.username) == username, df)
      user_data = Dict{String,Any}()
      for dow in 0:6
        dow_df = filter(r -> Int(r.dow) == dow, user_df)
        user_data[string(dow)] = Dict{String,Int}(
          string(Int(r.hour)) => Int(r.play_count) for r in eachrow(dow_df)
        )
      end
      period_data[display_name] = user_data
    end

    save_json("heatmap_dow_hour_$(year_label).json", period_data)
  end
end

main()
