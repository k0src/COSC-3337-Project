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

function get_monthly_plays(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      TO_CHAR(DATE_TRUNC('month', timestamp), 'YYYY-MM') AS month,
      COUNT(*) AS play_count
    FROM listening_history
    $year_filter
    GROUP BY username, month
    ORDER BY username, month
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Plots

function plot_monthly_plays(df, year_label; year=nothing)
  nrow(df) == 0 && return

  title_label = year_label == "alltime" ? "All-Time" : year_label
  month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

  fig = Figure(size=(1200, 500))
  colors = Makie.wong_colors()

  if year !== nothing
    ax = Axis(fig[1, 1],
      title="Monthly Play Count - $title_label",
      xlabel="Month",
      ylabel="Play Count",
    )
    ax.xticks = (1:12, month_names)

    for (i, (username, display_name)) in enumerate(NAMES)
      user_df = filter(r -> String(r.username) == username, df)
      month_totals = zeros(Int, 12)
      for row in eachrow(user_df)
        m = parse(Int, String(row.month)[6:7])
        month_totals[m] += Int(row.play_count)
      end
      lines!(ax, 1:12, month_totals, label=display_name, color=colors[i])
      scatter!(ax, 1:12, month_totals, color=colors[i])
    end
  else
    all_months = sort(unique(String.(df.month)))
    month_index = Dict(m => i for (i, m) in enumerate(all_months))

    jan_positions = [month_index[m] for m in all_months if endswith(m, "-01")]
    jan_labels = [m[1:4] for m in all_months if endswith(m, "-01")]

    ax = Axis(fig[1, 1],
      title="Monthly Play Count - $title_label",
      xlabel="Year",
      ylabel="Play Count",
    )
    ax.xticks = (jan_positions, jan_labels)

    for (i, (username, display_name)) in enumerate(NAMES)
      user_df = filter(r -> String(r.username) == username, df)
      sort!(user_df, :month)
      xs = [month_index[String(r.month)] for r in eachrow(user_df)]
      ys = Int.(user_df.play_count)
      lines!(ax, xs, ys, label=display_name, color=colors[i])
      scatter!(ax, xs, ys, color=colors[i])
    end
  end

  axislegend(ax, position=:rt)

  fname = "monthly_plays_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

# Main

function main()
  for (year, year_label) in PERIODS
    df = get_monthly_plays(year=year)

    period_data = Dict{String,Any}()
    for (username, display_name) in NAMES
      user_df = filter(r -> String(r.username) == username, df)
      sort!(user_df, :month)
      period_data[display_name] = OrderedDict{String,Int}(
        String(r.month) => Int(r.play_count) for r in eachrow(user_df)
      )
    end

    plot_monthly_plays(df, year_label, year=year)
    save_json("monthly_plays_$(year_label).json", period_data)
  end
end

main()
