include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "listening_dna_radar")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const PERIODS = [
  ("alltime", nothing),
  ("2024", 2024),
  ("2025", 2025),
]

const PERIOD_COLORS = Makie.wong_colors()[1:3]
const USER_COLORS = Makie.wong_colors()[1:4]

const AXIS_LABELS = [
  "Avg Play\nLength",
  "Skip Rate",
  "Shuffle Rate",
  "Offline Rate",
  "Artist\nDiversity",
  "Top-1\nArtist Share",
  "Discovery\nRate",
  "Session\nLength",
  "Genre\nDiversity",
]
const N_AXES = length(AXIS_LABELS)

function get_basic(year::Union{Int,Nothing})
  conn = get_connection()
  yf = isnothing(year) ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"
  query = """
    SELECT
      username,
      AVG(ms_played / 60000.0)                              AS avg_min_played,
      AVG(skipped::int)::float                              AS skip_rate,
      AVG(shuffle::int)::float                              AS shuffle_rate,
      AVG(offline::int)::float                              AS offline_rate,
      COUNT(DISTINCT artist_name)::float / COUNT(*)::float  AS discovery_rate
    FROM  listening_history
    WHERE artist_name IS NOT NULL $yf
    GROUP BY username
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_artist_dist(year::Union{Int,Nothing})
  conn = get_connection()
  yf = isnothing(year) ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"
  query = """
    SELECT username, artist_name, COUNT(*)::int AS plays
    FROM  listening_history
    WHERE artist_name IS NOT NULL $yf
    GROUP BY username, artist_name
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_genre_dist(year::Union{Int,Nothing})
  conn = get_connection()
  yf = isnothing(year) ? "" : "AND EXTRACT(YEAR FROM lh.timestamp) = $year"
  query = """
    SELECT lh.username, ag.genre, COUNT(*)::int AS plays
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL $yf
    GROUP BY lh.username, ag.genre
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_session_lengths(year::Union{Int,Nothing})
  conn = get_connection()
  yf = isnothing(year) ? "" : "AND EXTRACT(YEAR FROM timestamp) = $year"
  query = """
    WITH sessions AS (
      SELECT username, timestamp, ms_played,
        CASE
          WHEN timestamp - LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp)
               > INTERVAL '30 minutes'
            OR LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp) IS NULL
          THEN 1 ELSE 0
        END AS is_new_session
      FROM listening_history
      WHERE artist_name IS NOT NULL $yf
    ),
    session_labeled AS (
      SELECT username, ms_played,
        SUM(is_new_session) OVER (PARTITION BY username ORDER BY timestamp) AS session_id
      FROM sessions
    ),
    session_totals AS (
      SELECT username, session_id, SUM(ms_played) / 60000.0 AS session_min
      FROM session_labeled
      GROUP BY username, session_id
    )
    SELECT username, AVG(session_min)::float AS mean_session_min
    FROM session_totals
    GROUP BY username
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function shannon_entropy(counts::Vector{<:Real})
  total = sum(counts)
  total == 0 && return 0.0
  ps = counts ./ total
  return -sum(p * log2(p) for p in ps if p > 0)
end

function user_entropy_top1(dist_df, col_name, username)
  sub = filter(r -> String(r.username) == username, dist_df)
  isempty(sub) && return 0.0, 0.0
  counts = Float64.(sub[!, col_name])
  return shannon_entropy(counts), maximum(counts) / sum(counts)
end

function extract_features(basic_df, artist_df, genre_df, session_df)
  basic_map = Dict(String(r.username) => r for r in eachrow(basic_df))
  session_map = Dict(String(r.username) => Float64(r.mean_session_min) for r in eachrow(session_df))

  result = Dict{String,Vector{Float64}}()
  for username in USER_ORDER
    haskey(basic_map, username) || continue
    row = basic_map[username]

    artist_h, top1 = user_entropy_top1(artist_df, :plays, username)
    genre_h, _ = user_entropy_top1(genre_df, :plays, username)
    sess_min = get(session_map, username, 0.0)

    result[username] = [
      Float64(row.avg_min_played),
      Float64(row.skip_rate),
      Float64(row.shuffle_rate),
      Float64(row.offline_rate),
      artist_h,
      top1,
      Float64(row.discovery_rate),
      sess_min,
      genre_h,
    ]
  end
  return result
end

function global_normalise(all_raw::Dict{String,Dict{String,Vector{Float64}}})
  feat_min = fill(Inf, N_AXES)
  feat_max = fill(-Inf, N_AXES)

  for period_data in values(all_raw)
    for vals in values(period_data)
      for (fi, v) in enumerate(vals)
        v < feat_min[fi] && (feat_min[fi] = v)
        v > feat_max[fi] && (feat_max[fi] = v)
      end
    end
  end

  normed = Dict{String,Dict{String,Vector{Float64}}}()
  for (period, period_data) in all_raw
    normed[period] = Dict{String,Vector{Float64}}()
    for (username, vals) in period_data
      normed[period][username] = [
        feat_max[fi] > feat_min[fi] ?
        0.05 + 0.95 * (vals[fi] - feat_min[fi]) / (feat_max[fi] - feat_min[fi]) :
        0.5
        for fi in 1:N_AXES
      ]
    end
  end

  return normed, feat_min, feat_max
end

radar_angles(n) = [π / 2 - 2π * (i - 1) / n for i in 1:n]

function draw_radar_bg!(ax, n::Int)
  angles = radar_angles(n)
  for r in [0.25, 0.5, 0.75, 1.0]
    θ = range(0, 2π; length=300)
    lines!(ax, r .* cos.(θ), r .* sin.(θ), color=:grey88, linewidth=0.7)
    text!(ax, 0.0, r; text=@sprintf("%.0f%%", r * 100),
      fontsize=7, align=(:center, :bottom), color=:grey65)
  end
  for angle in angles
    lines!(ax, [0.0, cos(angle)], [0.0, sin(angle)], color=:grey82, linewidth=0.7)
  end
end

function add_axis_labels!(ax, labels::Vector{String}, n::Int; r_label=1.25)
  angles = radar_angles(n)
  for (lbl, angle) in zip(labels, angles)
    x = r_label * cos(angle)
    y = r_label * sin(angle)
    ha = abs(cos(angle)) < 0.2 ? :center : (cos(angle) > 0 ? :left : :right)
    va = abs(sin(angle)) < 0.2 ? :center : (sin(angle) > 0 ? :bottom : :top)
    text!(ax, x, y; text=lbl, fontsize=8.5, align=(ha, va), color=:grey20)
  end
end

function draw_radar_series!(ax, values::Vector{Float64}, color; label="", alpha=0.12)
  angles = radar_angles(length(values))
  xs = [v * cos(angles[i]) for (i, v) in enumerate(values)]
  ys = [v * sin(angles[i]) for (i, v) in enumerate(values)]
  poly!(ax, Point2f.(collect(zip(xs, ys))),
    color=(color, alpha), strokecolor=color, strokewidth=1.8)
  lines!(ax, [xs; xs[1]], [ys; ys[1]], color=color, linewidth=1.8, label=label)
  scatter!(ax, xs, ys, color=color, markersize=6, strokecolor=:white, strokewidth=0.8)
end

function make_radar_axis(fig_pos, title::String)
  ax = Axis(fig_pos;
    title=title, titlesize=12,
    aspect=DataAspect(),
    xgridvisible=false, ygridvisible=false,
    xticksvisible=false, yticksvisible=false,
    xticklabelsvisible=false, yticklabelsvisible=false,
    topspinevisible=false, bottomspinevisible=false,
    leftspinevisible=false, rightspinevisible=false,
  )
  limits!(ax, -1.62, 1.62, -1.62, 1.62)
  return ax
end

function plot_per_user(normed, fname_fn)
  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    fig = Figure(size=(700, 720))
    ax = make_radar_axis(fig[1, 1], "Listening DNA - $display_name")

    draw_radar_bg!(ax, N_AXES)
    add_axis_labels!(ax, AXIS_LABELS, N_AXES)

    for (pi, (label, _)) in enumerate(PERIODS)
      haskey(normed[label], username) || continue
      draw_radar_series!(ax, normed[label][username], PERIOD_COLORS[pi]; label=label)
    end

    Legend(fig[2, 1], ax; orientation=:horizontal, framevisible=false,
      tellwidth=false, labelsize=10)

    fname = fname_fn(username)
    save(fname, fig)
    println("  plot saved: $fname")
  end
end

function plot_per_period(normed, fname_fn)
  for (label, _) in PERIODS
    fig = Figure(size=(700, 720))
    ax = make_radar_axis(fig[1, 1], "Listening DNA - $label")

    draw_radar_bg!(ax, N_AXES)
    add_axis_labels!(ax, AXIS_LABELS, N_AXES)

    for (ui, (username, display_name)) in enumerate(zip(USER_ORDER, DISPLAY_ORDER))
      haskey(normed[label], username) || continue
      draw_radar_series!(ax, normed[label][username], USER_COLORS[ui]; label=display_name)
    end

    Legend(fig[2, 1], ax; orientation=:horizontal, framevisible=false,
      tellwidth=false, labelsize=10)

    fname = fname_fn(label)
    save(fname, fig)
    println("  plot saved: $fname")
  end
end

function print_features(label, raw_period, feat_min, feat_max)
  println("=== $label (raw values) ===")
  @printf "  %-22s" "feature"
  for d in DISPLAY_ORDER
    @printf "  %10s" d
  end
  println()
  for (fi, fname) in enumerate(AXIS_LABELS)
    short = replace(fname, "\n" => " ")
    @printf "  %-22s" short
    for username in USER_ORDER
      v = get(raw_period, username, zeros(N_AXES))[fi]
      @printf "  %10.4f" v
    end
    println()
  end
  println()
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  all_raw = Dict{String,Dict{String,Vector{Float64}}}()

  for (label, year) in PERIODS
    println("Fetching $label...")
    basic_df = get_basic(year)
    artist_df = get_artist_dist(year)
    genre_df = get_genre_dist(year)
    session_df = get_session_lengths(year)

    all_raw[label] = extract_features(basic_df, artist_df, genre_df, session_df)
  end

  normed, feat_min, feat_max = global_normalise(all_raw)

  for (label, _) in PERIODS
    print_features(label, all_raw[label], feat_min, feat_max)
  end

  plot_per_user(normed, username -> joinpath(PLOTS_DIR, "listening_dna_$(username).png"))
  plot_per_period(normed, label -> joinpath(PLOTS_DIR, "listening_dna_$(label).png"))

  json_out = Dict{String,Any}(
    "axes" => AXIS_LABELS,
    "feat_min" => feat_min,
    "feat_max" => feat_max,
    "periods" => Dict(
      label => Dict(
        DISPLAY_ORDER[findfirst(==(u), USER_ORDER)] => Dict{String,Any}(
          "raw" => all_raw[label][u],
          "normed" => normed[label][u],
        )
        for u in USER_ORDER if haskey(all_raw[label], u)
      )
      for (label, _) in PERIODS
    ),
  )

  save_json(joinpath(SCRIPT_DIR, "listening_dna_radar.json"), json_out)
end

main()
