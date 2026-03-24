include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "artist_loyalty_decay_alltime")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_N = 20
const MAX_MONTHS = 48

function get_data()
  conn = get_connection()
  query = """
    WITH artist_totals AS (
      SELECT username, artist_name, COUNT(*) AS total_plays
      FROM  listening_history
      WHERE artist_name IS NOT NULL
      GROUP BY username, artist_name
    ),
    top_artists AS (
      SELECT username, artist_name, total_plays,
        ROW_NUMBER() OVER (PARTITION BY username ORDER BY total_plays DESC) AS rnk
      FROM artist_totals
    ),
    monthly_plays AS (
      SELECT
        lh.username,
        lh.artist_name,
        DATE_TRUNC('month', lh.timestamp) AS month,
        COUNT(*)::int                     AS plays
      FROM  listening_history lh
      JOIN  top_artists ta
            ON  lh.username    = ta.username
            AND lh.artist_name = ta.artist_name
      WHERE ta.rnk <= $TOP_N
        AND lh.artist_name IS NOT NULL
      GROUP BY lh.username, lh.artist_name, month
    ),
    first_months AS (
      SELECT username, artist_name, MIN(month) AS first_month
      FROM  monthly_plays
      GROUP BY username, artist_name
    )
    SELECT
      mp.username,
      mp.artist_name,
      mp.plays,
      ta.total_plays,
      (
        (EXTRACT(YEAR  FROM mp.month)::int - EXTRACT(YEAR  FROM fm.first_month)::int) * 12 +
        (EXTRACT(MONTH FROM mp.month)::int - EXTRACT(MONTH FROM fm.first_month)::int)
      ) AS months_since_first
    FROM  monthly_plays mp
    JOIN  first_months fm ON mp.username = fm.username AND mp.artist_name = fm.artist_name
    JOIN  top_artists  ta ON mp.username = ta.username AND mp.artist_name = ta.artist_name
    ORDER BY mp.username, mp.artist_name, months_since_first
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function user_series(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return NamedTuple[]

  artists = unique(String.(sub.artist_name))
  result = []

  for artist in artists
    rows = filter(r -> String(r.artist_name) == artist, sub)
    isempty(rows) && continue

    total_plays = Int(rows.total_plays[1])
    months = Int.(rows.months_since_first)
    plays = Int.(rows.plays)

    max_m = min(maximum(months), MAX_MONTHS)
    series = zeros(Int, max_m + 1)
    for (m, p) in zip(months, plays)
      m <= MAX_MONTHS && (series[m+1] = p)
    end

    push!(result, (artist=artist, total_plays=total_plays, months=0:max_m, series=series))
  end

  return sort(result, by=r -> -r.total_plays)
end

function mean_decay(artist_series)
  isempty(artist_series) && return Int[], Float64[]
  max_m = maximum(length(r.series) for r in artist_series) - 1
  sums = zeros(Float64, max_m + 1)
  cnts = zeros(Int, max_m + 1)

  for r in artist_series
    peak = maximum(r.series)
    peak == 0 && continue
    for (i, p) in enumerate(r.series)
      sums[i] += p / peak
      cnts[i] += 1
    end
  end

  means = [cnts[i] > 0 ? sums[i] / cnts[i] : NaN for i in eachindex(sums)]
  return 0:max_m, means
end

function print_summary(display_name, artist_series)
  println("$display_name  (top $TOP_N artists by total plays)")
  @printf "  %-32s  %8s  %8s  %8s  %8s\n" "artist" "total" "peak_mo" "max_mo" "peak_pl"
  for r in artist_series[1:min(10, length(artist_series))]
    peak_mo = argmax(r.series) - 1
    @printf "  %-32s  %8d  %8d  %8d  %8d\n" r.artist r.total_plays peak_mo length(r.series) - 1 maximum(r.series)
  end
  println()
end

function plot_decay(artist_series, display_name, username, fname)
  isempty(artist_series) && return

  n = length(artist_series)
  total_plays = Float64.([r.total_plays for r in artist_series])
  tp_min, tp_max = minimum(total_plays), maximum(total_plays)

  decay_ms, decay_means = mean_decay(artist_series)
  has_mean = !isempty(decay_ms)

  fig = Figure(size=(1000, 560))
  ax = Axis(fig[1, 1],
    title="Artist Loyalty Decay - $display_name - All Time (top $TOP_N artists)",
    xlabel="Months Since First Listen",
    ylabel="Plays",
  )

  cmap = cgrad(:plasma)
  for r in artist_series
    t = tp_max > tp_min ? (r.total_plays - tp_min) / (tp_max - tp_min) : 0.5
    col = cmap[t]
    lines!(ax, collect(r.months), Float64.(r.series),
      color=(col, 0.35), linewidth=1.0)
  end

  if has_mean
    scale = tp_max * 0.6
    valid = .!isnan.(decay_means)
    xs_v = collect(decay_ms)[valid]
    ys_v = decay_means[valid] .* scale
    lines!(ax, xs_v, ys_v,
      color=:black, linewidth=2.2, linestyle=:dash, label="Mean (norm. × scale)")
  end

  Colorbar(fig[1, 2],
    colormap=:plasma,
    limits=(tp_min, tp_max),
    label="Total Plays (artist)",
    labelsize=10,
  )

  if has_mean
    Legend(fig[1, 3], ax, framevisible=false, labelsize=9)
  end

  xlims!(ax, 0, MAX_MONTHS)
  ylims!(ax, 0, nothing)

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
    artist_series = user_series(df, username)
    isempty(artist_series) && continue

    print_summary(display_name, artist_series)

    fname = joinpath(PLOTS_DIR, "artist_loyalty_decay_$(username).png")
    plot_decay(artist_series, display_name, username, fname)

    json_out[display_name] = Dict{String,Any}(
      "artists" => [
        Dict{String,Any}(
          "artist" => r.artist,
          "total_plays" => r.total_plays,
          "max_months" => length(r.series) - 1,
          "series" => collect(r.series),
        )
        for r in artist_series
      ],
    )
  end

  save_json(joinpath(SCRIPT_DIR, "artist_loyalty_decay_alltime.json"), json_out)
end

main()
