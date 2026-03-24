include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using OrderedCollections

const DATA_DIR = joinpath(@__DIR__, "..", "..", "data", "events_over_time_moving_avg")
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

function moving_avg(v::Vector{<:Real}, w::Int=3)
  n = length(v)
  out = fill(NaN, n)
  for i in w:n
    out[i] = sum(v[i-w+1:i]) / w
  end
  return out
end

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
      ma = moving_avg(Float64.(month_totals))
      valid = .!isnan.(ma)
      lines!(ax, (1:12)[valid], ma[valid], color=colors[i], linestyle=:dash, linewidth=1.5)
    end
  else
    all_months = sort(unique([String(d)[1:7] for d in df.date]))
    month_index = Dict(m => i for (i, m) in enumerate(all_months))

    jan_positions = [month_index[m] for m in all_months if endswith(m, "-01")]
    jan_labels = [m[1:4] for m in all_months if endswith(m, "-01")]

    ax = Axis(fig[1, 1],
      title="Listening Events Over Time - $title_label",
      xlabel="Year",
      ylabel="Listening Events",
    )
    ax.xticks = (jan_positions, jan_labels)

    for (i, (username, display_name)) in enumerate(NAMES)
      user_df = filter(row -> row.username == username, df)
      monthly = Dict{String,Int}()
      for row in eachrow(user_df)
        m = String(row.date)[1:7]
        monthly[m] = get(monthly, m, 0) + Int(row.events)
      end
      xs = [month_index[m] for m in all_months if haskey(monthly, m)]
      ys = [monthly[m] for m in all_months if haskey(monthly, m)]
      lines!(ax, xs, ys, label=display_name, color=colors[i], alpha=0.4)
      ma = moving_avg(Float64.(ys))
      valid = .!isnan.(ma)
      lines!(ax, xs[valid], ma[valid], color=colors[i], linestyle=:dash, linewidth=2.0)
    end
  end

  axislegend(ax, position=:rt)

  fname = joinpath(PLOTS_DIR, "events_over_time_$(year_label).png")
  save(fname, fig)
  println("Plot saved to $fname")
end

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
    save_json(joinpath(DATA_DIR, "events_over_time_$(year_label).json"), period_data)
  end
end

main()
