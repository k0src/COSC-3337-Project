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

const USER_ORDER = sort(collect(keys(NAMES)))

function get_repeat_vs_new(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    WITH ranked AS (
      SELECT
        username,
        track_id,
        ROW_NUMBER() OVER (PARTITION BY username, track_id ORDER BY timestamp) AS play_num
      FROM listening_history
      $year_filter
    )
    SELECT
      username,
      SUM(CASE WHEN play_num = 1 THEN 1 ELSE 0 END) AS new_plays,
      SUM(CASE WHEN play_num > 1 THEN 1 ELSE 0 END) AS repeat_plays,
      COUNT(*) AS total_plays
    FROM ranked
    GROUP BY username
    ORDER BY username
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function draw_donut!(ax, fracs, colors; inner_r=0.35, outer_r=0.85, arc_steps=200)
  angle = π / 2
  for (frac, color) in zip(fracs, colors)
    frac == 0.0 && continue
    angle_end = angle - frac * 2π
    n = max(2, round(Int, arc_steps * frac))
    angles = range(angle, angle_end, length=n)
    outer_pts = [Point2f(outer_r * cos(a), outer_r * sin(a)) for a in angles]
    inner_pts = [Point2f(inner_r * cos(a), inner_r * sin(a)) for a in reverse(angles)]
    poly!(ax, vcat(outer_pts, inner_pts), color=color, strokecolor=:white, strokewidth=2)
    angle = angle_end
  end
end

function plot_repeat_vs_new(df, year_label)
  nrow(df) == 0 && return
  title_label = year_label == "alltime" ? "All-Time" : year_label

  donut_colors = [:steelblue, :orangered]
  positions = [(1, 1), (1, 2), (2, 1), (2, 2)]

  fig = Figure(size=(1000, 950))
  Label(fig[0, 1:2], "Repeat vs. New Plays - $title_label", fontsize=18, font=:bold)

  for (idx, username) in enumerate(USER_ORDER)
    display_name = get(NAMES, username, username)
    row_df = filter(r -> String(r.username) == username, df)
    nrow(row_df) == 0 && continue

    row = first(row_df)
    total = Int(row.total_plays)
    total == 0 && continue

    new_frac = Int(row.new_plays) / total
    repeat_frac = Int(row.repeat_plays) / total

    ri, ci = positions[idx]
    ax = Axis(fig[ri, ci], title=display_name, aspect=DataAspect())
    hidedecorations!(ax)
    hidespines!(ax)
    limits!(ax, -1.1, 1.1, -1.1, 1.1)

    draw_donut!(ax, [new_frac, repeat_frac], donut_colors)

    text!(ax, 0, 0.12,
      text="$(round(Int, new_frac * 100))% new",
      align=(:center, :center), fontsize=13, color=:steelblue,
    )
    text!(ax, 0, -0.12,
      text="$(round(Int, repeat_frac * 100))% repeat",
      align=(:center, :center), fontsize=13, color=:orangered,
    )
  end

  elems = [PolyElement(polycolor=donut_colors[i]) for i in 1:2]
  Legend(fig[3, 1:2], elems, ["New Plays", "Repeat Plays"],
    orientation=:horizontal, tellwidth=false)

  fname = "repeat_vs_new_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function main()
  for (year, year_label) in PERIODS
    title_label = year_label == "alltime" ? "All-Time" : year_label
    println("\n$(title_label)\n")

    df = get_repeat_vs_new(year=year)
    nrow(df) == 0 && continue

    period_data = Dict{String,Any}()
    for row in eachrow(df)
      display_name = get(NAMES, String(row.username), String(row.username))
      total = Int(row.total_plays)
      total == 0 && continue
      period_data[display_name] = Dict{String,Any}(
        "new_plays" => Int(row.new_plays),
        "repeat_plays" => Int(row.repeat_plays),
        "total_plays" => total,
        "new_rate" => Int(row.new_plays) / total,
        "repeat_rate" => Int(row.repeat_plays) / total,
      )
    end

    plot_repeat_vs_new(df, year_label)
    save_json("repeat_vs_new_$(year_label).json", period_data)
  end
end

main()
