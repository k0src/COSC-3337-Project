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

function get_hourly_counts(username; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      EXTRACT(HOUR FROM timestamp)::INT AS hour,
      COUNT(*) AS events
    FROM listening_history
    WHERE username = '$username'
    $year_filter
    GROUP BY hour
    ORDER BY hour
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Plots

function plot_listening_times(username, df, year_label)
  display_name = get(NAMES, username, username)
  title_label = year_label == "alltime" ? "All-Time" : year_label

  counts = zeros(Int, 24)
  for row in eachrow(df)
    counts[Int(row.hour)+1] = Int(row.events)
  end

  max_count = maximum(counts)
  max_count == 0 && return
  norm_counts = counts ./ max_count

  fig = Figure(size=(750, 700))
  ax = Axis(fig[1, 1], title="Listening Times - $display_name - $title_label", aspect=DataAspect())
  hidedecorations!(ax)
  hidespines!(ax)
  limits!(ax, -1.25, 1.25, -1.25, 1.25)

  cmap = cgrad(:inferno)
  inner_r = 0.18
  max_r = 0.82
  label_r = 0.98
  arc_steps = 40

  for h in 0:23
    angle_start = π / 2 - h * (2π / 24)
    angle_end = π / 2 - (h + 1) * (2π / 24)

    r_outer = inner_r + norm_counts[h+1] * (max_r - inner_r)

    angles = range(angle_start, angle_end, length=arc_steps)
    outer_pts = [Point2f(r_outer * cos(a), r_outer * sin(a)) for a in angles]
    inner_pts = [Point2f(inner_r * cos(a), inner_r * sin(a)) for a in reverse(angles)]

    poly!(ax, vcat(outer_pts, inner_pts),
      color=cmap[norm_counts[h+1]],
      strokecolor=:white, strokewidth=0.8)
  end

  for h in 0:23
    mid_angle = π / 2 - (h + 0.5) * (2π / 24)
    lx = label_r * cos(mid_angle)
    ly = label_r * sin(mid_angle)

    label = if h == 0
      "12am"
    elseif h == 12
      "12pm"
    elseif h < 12
      "$(h)am"
    else
      "$(h - 12)pm"
    end

    text!(ax, lx, ly, text=label, align=(:center, :center), fontsize=11)
  end

  Colorbar(fig[1, 2], colormap=:inferno, limits=(0, max_count),
    label="Events", height=Relative(0.6))

  fname = "listening_times_$(username)_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

# Main

function main()
  for (year, year_label) in PERIODS
    title_label = year_label == "alltime" ? "All-Time" : year_label
    println("\n$(title_label)\n")

    period_data = Dict{String,Any}()

    for (username, display_name) in NAMES
      df = get_hourly_counts(username, year=year)
      nrow(df) == 0 && continue

      plot_listening_times(username, df, year_label)

      counts = zeros(Int, 24)
      for row in eachrow(df)
        counts[Int(row.hour)+1] = Int(row.events)
      end

      period_data[display_name] = Dict{String,Int}(
        string(h) => counts[h+1] for h in 0:23
      )
    end

    save_json("listening_times_$(year_label).json", period_data)
  end
end

main()
