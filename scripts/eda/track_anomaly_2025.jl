include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "track_anomaly_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const MIN_ARTIST_TRACKS = 3

const TOP_N = 12

function truncate(s, maxlen=25)
  length(s) <= maxlen && return s
  return first(s, maxlen) * "..."
end

function get_data()
  conn = get_connection()
  query = """
    SELECT
      username,
      artist_name,
      track_name,
      COUNT(*)::int AS plays
    FROM  listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND artist_name IS NOT NULL
      AND track_name  IS NOT NULL
    GROUP BY username, artist_name, track_name
    ORDER BY username, artist_name, plays DESC
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

struct TrackEntry
  track_name::String
  artist_name::String
  actual::Int
  expected::Float64
  ratio::Float64
  log2_ratio::Float64
end

function score_user(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return TrackEntry[]

  artist_groups = Dict{String,Vector{Tuple{String,Int}}}()
  for row in eachrow(sub)
    a = String(row.artist_name)
    t = String(row.track_name)
    push!(get!(artist_groups, a, Tuple{String,Int}[]), (t, Int(row.plays)))
  end

  entries = TrackEntry[]
  for (artist, tracks) in artist_groups
    length(tracks) < MIN_ARTIST_TRACKS && continue
    mean_plays = sum(n for (_, n) in tracks) / length(tracks)
    for (track, actual) in tracks
      ratio = actual / mean_plays
      log2_ratio = log2(ratio)
      push!(entries, TrackEntry(track, artist, actual, mean_plays, ratio, log2_ratio))
    end
  end

  return entries
end


function print_anomalies(display_name, entries)
  isempty(entries) && return

  sorted = sort(entries, by=e -> -e.log2_ratio)
  n = length(sorted)

  println("$display_name")
  println("  --- TOP OBSESSIONS (plays >> expected) ---")
  @printf "  %-36s  %-24s  %7s  %8s  %7s\n" "track" "artist" "actual" "expected" "ratio"
  for e in sorted[1:min(TOP_N, n)]
    e.log2_ratio <= 0 && break
    @printf "  %-36s  %-24s  %7d  %8.1f  %7.2fx\n" truncate(e.track_name) e.artist_name e.actual e.expected e.ratio
  end

  println("  --- TOP AVOIDANCES (plays << expected) ---")
  @printf "  %-36s  %-24s  %7s  %8s  %7s\n" "track" "artist" "actual" "expected" "ratio"
  for e in sorted[max(1, n - TOP_N + 1):n]
    e.log2_ratio >= 0 && continue
    @printf "  %-36s  %-24s  %7d  %8.1f  %7.2fx\n" truncate(e.track_name) e.artist_name e.actual e.expected e.ratio
  end
  println()
end

function plot_diverging(entries, display_name, username, fname)
  isempty(entries) && return

  sorted = sort(entries, by=e -> -e.log2_ratio)
  n = length(sorted)

  obsessions = [e for e in sorted if e.log2_ratio > 0][1:min(TOP_N, n)]
  avoidances = [e for e in reverse(sorted) if e.log2_ratio < 0][1:min(TOP_N, n)]

  combined = vcat(obsessions, avoidances)
  isempty(combined) && return

  sort!(combined, by=e -> e.log2_ratio)
  nc = length(combined)

  labels = ["$(truncate(e.track_name)) ($(e.artist_name))" for e in combined]
  labels = [length(l) > 52 ? l[1:49] * "..." : l for l in labels]

  vals = [e.log2_ratio for e in combined]
  colors = [v >= 0 ? Makie.wong_colors()[2] : Makie.wong_colors()[1] for v in vals]

  fig_h = max(500, nc * 32 + 160)
  fig = Figure(size=(980, fig_h))
  ax = Axis(fig[1, 1],
    title="Track Play Anomalies - $display_name - 2025\n(log2 ratio vs artist mean; artists with 3+ distinct tracks)",
    xlabel="log2(actual / expected plays per track)",
    ylabel="Track",
    yticks=(1:nc, labels),
  )

  barplot!(ax, 1:nc, vals,
    direction=:x,
    color=colors,
    strokecolor=:white,
    strokewidth=0.5,
  )

  vlines!(ax, [0.0], color=:grey40, linewidth=1.2, linestyle=:dash)

  for (i, e) in enumerate(combined)
    x_off = e.log2_ratio >= 0 ? 0.05 : -0.05
    align = e.log2_ratio >= 0 ? (:left, :center) : (:right, :center)
    text!(ax, e.log2_ratio + x_off, i,
      text=@sprintf("%.1fx", e.ratio),
      align=align,
      fontsize=9,
      color=:grey20,
    )
  end

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
    entries = score_user(df, username)
    isempty(entries) && continue

    print_anomalies(display_name, entries)

    fname = joinpath(PLOTS_DIR, "track_anomaly_$(username).png")
    plot_diverging(entries, display_name, username, fname)

    sorted = sort(entries, by=e -> -e.log2_ratio)
    json_out[display_name] = Dict{String,Any}(
      "obsessions" => [
        Dict{String,Any}(
          "track" => e.track_name,
          "artist" => e.artist_name,
          "actual" => e.actual,
          "expected" => e.expected,
          "ratio" => e.ratio,
          "log2_ratio" => e.log2_ratio,
        )
        for e in sorted if e.log2_ratio > 0
      ],
      "avoidances" => [
        Dict{String,Any}(
          "track" => e.track_name,
          "artist" => e.artist_name,
          "actual" => e.actual,
          "expected" => e.expected,
          "ratio" => e.ratio,
          "log2_ratio" => e.log2_ratio,
        )
        for e in reverse(sorted) if e.log2_ratio < 0
      ],
    )
  end

  save_json(joinpath(SCRIPT_DIR, "track_anomaly_2025.json"), json_out)
end

main()
