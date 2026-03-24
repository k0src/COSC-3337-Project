include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Dates

const DATA_DIR = joinpath(@__DIR__, "..", "..", "data", "calendar_heatmap")
const PLOTS_DIR = joinpath(DATA_DIR, "plots")
mkpath(PLOTS_DIR)

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = sort(collect(keys(NAMES)))

function get_daily_plays(year)
  conn = get_connection()

  query = """
    SELECT
      username,
      DATE(timestamp) AS day,
      COUNT(*) AS play_count
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = $year
    GROUP BY username, day
    ORDER BY username, day
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function plot_calendar_heatmap(df, year)
  nrow(df) == 0 && return

  year_start = Date(year, 1, 1)
  year_end = Date(year, 12, 31)

  dow(d) = Dates.dayofweek(d) - 1

  start_offset = dow(year_start)
  week_of(d) = div(Dates.value(d - year_start) + start_offset, 7)
  total_weeks = week_of(year_end) + 1

  month_weeks = [week_of(Date(year, m, 1)) + 1 for m in 1:12]
  month_labels = [Dates.monthabbr(Date(year, m, 1)) for m in 1:12]
  day_labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

  cell_gap = 0.12
  lo, hi = cell_gap / 2, 1.0 - cell_gap / 2

  colors = cgrad(:Greens)

  for username in USER_ORDER
    display_name = get(NAMES, username, username)
    user_df = filter(r -> String(r.username) == username, df)

    day_counts = Dict{Date,Int}()
    for r in eachrow(user_df)
      day_counts[Date(string(r.day))] = Int(r.play_count)
    end

    grid = fill(NaN, 7, total_weeks)
    d = year_start
    while d <= year_end
      r = dow(d) + 1
      c = week_of(d) + 1
      grid[r, c] = get(day_counts, d, 0)
      d += Day(1)
    end

    vals = filter(!isnan, grid)
    max_count = isempty(vals) ? 1 : max(1, maximum(vals))

    fig = Figure(size=(1400, 270))
    Label(fig[0, 1], "Daily Play Count - $display_name - $year",
      fontsize=15, font=:bold, tellwidth=false)

    ax = Axis(fig[1, 1],
      yticks=(1:7, day_labels),
      xticks=(month_weeks, month_labels),
      xgridvisible=false,
      ygridvisible=false,
      yreversed=false,
      leftspinevisible=false,
      rightspinevisible=false,
      topspinevisible=false,
      bottomspinevisible=false,
    )

    for c in 1:total_weeks, r in 1:7
      val = grid[r, c]
      isnan(val) && continue
      col = val == 0 ? RGBf(0.88, 0.88, 0.88) : colors[val/max_count]
      poly!(ax,
        Point2f[(c - hi, r - hi), (c - lo, r - hi),
          (c - lo, r - lo), (c - hi, r - lo)],
        color=col, strokewidth=0,
      )
    end

    xlims!(ax, 0.0, total_weeks + 0.6)
    ylims!(ax, 0.0, 7.6)

    Colorbar(fig[1, 2],
      limits=(0.0, Float64(max_count)),
      colormap=:Greens,
      label="Play Count",
      width=15,
      tellheight=false,
    )

    colsize!(fig.layout, 1, Relative(0.93))

    fname = joinpath(PLOTS_DIR, "calendar_heatmap_$(lowercase(display_name))_$(year).png")
    save(fname, fig)
    println("Saved $fname")
  end
end

function main()
  year = 2025
  df = get_daily_plays(year)
  nrow(df) == 0 && return

  plot_calendar_heatmap(df, year)

  json_data = Dict{String,Any}()
  for username in USER_ORDER
    display_name = get(NAMES, username, username)
    user_df = filter(r -> String(r.username) == username, df)
    user_data = Dict{String,Any}()
    for r in eachrow(user_df)
      user_data[string(Date(string(r.day)))] = Int(r.play_count)
    end
    json_data[display_name] = user_data
  end

  save_json(joinpath(DATA_DIR, "calendar_heatmap_2025.json"), json_data)
end

main()
