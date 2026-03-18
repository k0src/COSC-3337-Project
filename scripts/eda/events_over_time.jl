include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using OrderedCollections

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

function get_events_over_time(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      DATE_TRUNC('day', timestamp)::DATE::TEXT AS date,
      COUNT(*) AS events
    FROM listening_history
    $year_filter
    GROUP BY username, date
    ORDER BY username, date
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Plots

function plot_events_over_time(df, year_label; year=nothing)
  nrow(df) == 0 && return

  title_label = year_label == "alltime" ? "All-Time" : year_label
  month_names = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ]

  fig = Figure(size=(1200, 500))
  colors = Makie.wong_colors()

  if year !== nothing
    ax = Axis(fig[1, 1],
      title="Listening Events Over Time - $title_label",
      xlabel="Month",
      ylabel="Listening Events",
    )
    ax.xticks = (1:12, month_names)

    for (i, (username, display_name)) in enumerate(NAMES)
      user_df = filter(row -> row.username == username, df)
      month_totals = zeros(Int, 12)
      for row in eachrow(user_df)
        m = parse(Int, String(row.date)[6:7])
        month_totals[m] += Int(row.events)
      end
      lines!(ax, 1:12, month_totals, label=display_name, color=colors[i])
      scatter!(ax, 1:12, month_totals, color=colors[i])
    end
  else
    all_dates = sort(unique(String.(df.date)))
    date_index = Dict(d => i for (i, d) in enumerate(all_dates))

    jan_positions = [date_index[d] for d in all_dates if endswith(d, "-01-01")]
    jan_labels = [d[1:4] for d in all_dates if endswith(d, "-01-01")]

    ax = Axis(fig[1, 1],
      title="Listening Events Over Time - $title_label",
      xlabel="Year",
      ylabel="Listening Events",
    )
    ax.xticks = (jan_positions, jan_labels)

    for (i, (username, display_name)) in enumerate(NAMES)
      user_df = filter(row -> row.username == username, df)
      sort!(user_df, :date)
      xs = [date_index[d] for d in String.(user_df.date)]
      ys = Int.(user_df.events)
      lines!(ax, xs, ys, label=display_name, color=colors[i])
    end
  end

  axislegend(ax, position=:rt)

  fname = "events_over_time_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

# Main

function main()
  for (year, year_label) in PERIODS
    df = get_events_over_time(year=year)

    period_data = Dict{String,Any}()
    for (username, display_name) in NAMES
      user_df = filter(r -> String(r.username) == username, df)
      sort!(user_df, :date)
      period_data[display_name] = OrderedDict{String,Int}(
        String(r.date) => Int(r.events) for r in eachrow(user_df)
      )
    end

    plot_events_over_time(df, year_label, year=year)
    save_json("events_over_time_$(year_label).json", period_data)
  end
end

main()
