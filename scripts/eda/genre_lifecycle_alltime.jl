include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_lifecycle_alltime")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_N = 5

function get_data()
  conn = get_connection()
  query = """
    SELECT
      lh.username,
      ag.genre,
      TO_CHAR(DATE_TRUNC('month', lh.timestamp), 'YYYY-MM') AS month,
      COUNT(*)::int AS plays
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
    GROUP BY lh.username, ag.genre, month
    ORDER BY lh.username, ag.genre, month
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function month_to_yearfrac(ym::String)
  y = parse(Int, ym[1:4])
  m = parse(Int, ym[6:7])
  return y + (m - 1) / 12
end

function month_range(lo::String, hi::String)
  y1, m1 = parse(Int, lo[1:4]), parse(Int, lo[6:7])
  y2, m2 = parse(Int, hi[1:4]), parse(Int, hi[6:7])
  months = String[]
  y, m = y1, m1
  while (y, m) <= (y2, m2)
    push!(months, @sprintf("%04d-%02d", y, m))
    m += 1
    m > 12 && (m = 1; y += 1)
  end
  return months
end

function user_lifecycle(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return String[], String[], Dict{String,Vector{Int}}()

  totals = Dict{String,Int}()
  for row in eachrow(sub)
    g = String(row.genre)
    totals[g] = get(totals, g, 0) + Int(row.plays)
  end
  ranked = sort(collect(totals), by=kv -> -kv[2])
  genres = [kv[1] for kv in ranked[1:min(TOP_N, length(ranked))]]

  all_months = sort(unique(String.(sub.month)))
  months = month_range(all_months[1], all_months[end])

  month_idx = Dict(m => i for (i, m) in enumerate(months))
  series = Dict(g => zeros(Int, length(months)) for g in genres)

  for row in eachrow(sub)
    g = String(row.genre)
    g in genres || continue
    i = month_idx[String(row.month)]
    series[g][i] += Int(row.plays)
  end

  return genres, months, series
end

function print_summary(display_name, genres, months, series)
  println("$display_name  ($(length(months)) months, top $TOP_N genres)")
  @printf "  %-30s  %8s\n" "genre" "total"
  for g in genres
    @printf "  %-30s  %8d\n" g sum(series[g])
  end
  println()
end

function plot_lifecycle(genres, months, series, display_name, fname)
  isempty(months) && return

  xs = [month_to_yearfrac(m) for m in months]
  colors = Makie.wong_colors()

  tick_years = unique(parse(Int, m[1:4]) for m in months)
  tick_pos = Float64.(tick_years)
  tick_lbl = string.(tick_years)

  fig = Figure(size=(1100, 500))
  ax = Axis(fig[1, 1],
    title="Top $TOP_N Genre Monthly Plays - $display_name - All Time",
    xlabel="Year",
    ylabel="Plays per Month",
    xticks=(tick_pos, tick_lbl),
  )

  for (i, g) in enumerate(genres)
    ys = Float64.(series[g])
    lines!(ax, xs, ys, label=g, color=colors[i], linewidth=2)
    scatter!(ax, xs, ys,
      color=colors[i],
      markersize=5,
      strokewidth=0,
    )
  end

  Legend(fig[1, 2], ax, framevisible=false)

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  json_out = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    genres, months, series = user_lifecycle(df, username)
    isempty(genres) && continue

    print_summary(display_name, genres, months, series)

    fname = joinpath(PLOTS_DIR, "genre_lifecycle_$(username).png")
    plot_lifecycle(genres, months, series, display_name, fname)

    json_out[display_name] = Dict{String,Any}(
      "genres" => genres,
      "months" => months,
      "series" => Dict(g => series[g] for g in genres),
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_lifecycle_alltime.json"), json_out)
end

main()
