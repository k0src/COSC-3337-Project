include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_diversity_vs_new_artist_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const MONTH_ABBR = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

function get_genre_plays()
  conn = get_connection()
  query = """
    SELECT
      lh.username,
      TO_CHAR(DATE_TRUNC('month', lh.timestamp), 'YYYY-MM') AS month,
      ag.genre,
      COUNT(*)::int AS plays
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE EXTRACT(YEAR FROM lh.timestamp) = 2025
      AND lh.artist_name IS NOT NULL
    GROUP BY lh.username, month, ag.genre
    ORDER BY lh.username, month, ag.genre
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_new_artist_rate()
  conn = get_connection()
  query = """
    WITH first_seen AS (
      SELECT
        username,
        artist_name,
        DATE_TRUNC('month', MIN(timestamp)) AS first_month
      FROM  listening_history
      WHERE artist_name IS NOT NULL
      GROUP BY username, artist_name
    )
    SELECT
      lh.username,
      TO_CHAR(DATE_TRUNC('month', lh.timestamp), 'YYYY-MM') AS month,
      COUNT(*)::int                                           AS total_plays,
      SUM(CASE
        WHEN fs.first_month = DATE_TRUNC('month', lh.timestamp) THEN 1 ELSE 0
      END)::int                                              AS new_artist_plays
    FROM  listening_history lh
    JOIN  first_seen fs
      ON  lh.username    = fs.username
      AND lh.artist_name = fs.artist_name
    WHERE EXTRACT(YEAR FROM lh.timestamp) = 2025
      AND lh.artist_name IS NOT NULL
    GROUP BY lh.username, month
    ORDER BY lh.username, month
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function shannon_entropy(counts::Vector{Int})
  total = sum(counts)
  total == 0 && return 0.0
  h = 0.0
  for c in counts
    c == 0 && continue
    p = c / total
    h -= p * log2(p)
  end
  return h
end

function user_series(genre_df, rate_df, username)
  g_sub = filter(r -> String(r.username) == username, genre_df)
  r_sub = filter(r -> String(r.username) == username, rate_df)
  (isempty(g_sub) || isempty(r_sub)) && return NamedTuple[]

  entropy_by_month = Dict{String,Float64}()
  for month in unique(String.(g_sub.month))
    counts = [Int(row.plays)
              for row in eachrow(g_sub) if String(row.month) == month]
    entropy_by_month[month] = shannon_entropy(counts)
  end

  rate_by_month = Dict{String,Float64}()
  for row in eachrow(r_sub)
    m = String(row.month)
    tp = Int(row.total_plays)
    tp == 0 && continue
    rate_by_month[m] = Int(row.new_artist_plays) / tp
  end

  months = sort(collect(intersect(keys(entropy_by_month), keys(rate_by_month))))
  isempty(months) && return NamedTuple[]

  return [
    (
      month=m,
      month_int=parse(Int, m[6:7]),
      entropy=entropy_by_month[m],
      new_rate=rate_by_month[m],
    )
    for m in months
  ]
end

function print_table(display_name, pts)
  r = length(pts) >= 2 ? cor([p.entropy for p in pts], [p.new_rate for p in pts]) : NaN
  println("$display_name  (n=$(length(pts)) months, Pearson r=$(round(r, digits=3)))")
  @printf "  %-7s  %10s  %12s\n" "month" "entropy" "new_art_%"
  for p in pts
    @printf "  %-7s  %10.3f  %11.1f%%\n" p.month p.entropy (p.new_rate * 100)
  end
  println()
end

function plot_scatter(pts, display_name, username, fname)
  isempty(pts) && return

  xs = [p.new_rate * 100 for p in pts]
  ys = [p.entropy for p in pts]
  ms = [p.month_int for p in pts]

  r = length(pts) >= 2 ? cor(xs, ys) : NaN
  r_str = isnan(r) ? "n/a" : @sprintf("%.3f", r)

  fig = Figure(size=(700, 520))
  ax = Axis(fig[1, 1],
    title="Genre Entropy vs New Artist Rate - $display_name - 2025\nPearson r = $r_str",
    xlabel="New Artist Plays (%)",
    ylabel="Genre Entropy (bits)",
  )

  sc = scatter!(ax, xs, ys,
    color=Float64.(ms),
    colormap=:viridis,
    colorrange=(1.0, 12.0),
    markersize=14,
    strokecolor=:white,
    strokewidth=1,
  )

  for (x, y, m) in zip(xs, ys, ms)
    text!(ax, x, y,
      text=MONTH_ABBR[m],
      align=(:center, :bottom),
      offset=(0, 6),
      fontsize=11,
    )
  end

  Colorbar(fig[1, 2], sc,
    label="Month",
    ticks=([1, 4, 7, 10], ["Jan", "Apr", "Jul", "Oct"]),
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  println("Fetching genre plays...")
  genre_df = get_genre_plays()
  println("Fetching new artist rates...")
  rate_df = get_new_artist_rate()

  json_out = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    pts = user_series(genre_df, rate_df, username)
    isempty(pts) && continue

    print_table(display_name, pts)

    fname = joinpath(PLOTS_DIR, "genre_diversity_vs_new_artist_$(username).png")
    plot_scatter(pts, display_name, username, fname)

    r = length(pts) >= 2 ? cor([p.entropy for p in pts], [p.new_rate for p in pts]) : NaN

    json_out[display_name] = Dict{String,Any}(
      "pearson_r" => isnan(r) ? nothing : r,
      "months" => [
        Dict{String,Any}(
          "month" => p.month,
          "genre_entropy" => p.entropy,
          "new_artist_rate" => p.new_rate,
        )
        for p in pts
      ],
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_diversity_vs_new_artist_2025.json"), json_out)
end

main()
