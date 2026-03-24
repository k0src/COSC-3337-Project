include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "user_self_drift")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]
const N_USERS = length(USER_ORDER)

const N_FEATURES = 12
const W = 1.0 / N_FEATURES

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------

function get_basic(conn, year::Int)
  query = """
    SELECT
      username,
      AVG(ms_played) / 60000.0                                         AS mean_min,
      AVG(skipped::int)::float                                          AS skip_rate,
      AVG(shuffle::int)::float                                          AS shuffle_rate,
      SUM(CASE WHEN EXTRACT(HOUR FROM timestamp) >= 22
                 OR EXTRACT(HOUR FROM timestamp) <  5
               THEN 1 ELSE 0 END)::float / COUNT(*)                    AS late_night_frac
    FROM  listening_history
    WHERE artist_name IS NOT NULL
      AND EXTRACT(YEAR FROM timestamp) = $year
    GROUP BY username
  """
  return DataFrame(execute(conn, query))
end

function get_artist_dist(conn, year::Int)
  query = """
    SELECT username, artist_name, COUNT(*)::int AS plays
    FROM   listening_history
    WHERE  artist_name IS NOT NULL
      AND  EXTRACT(YEAR FROM timestamp) = $year
    GROUP  BY username, artist_name
  """
  return DataFrame(execute(conn, query))
end

function get_track_dist(conn, year::Int)
  query = """
    SELECT username, track_name, COUNT(*)::int AS plays
    FROM   listening_history
    WHERE  artist_name IS NOT NULL AND track_name IS NOT NULL
      AND  EXTRACT(YEAR FROM timestamp) = $year
    GROUP  BY username, track_name
  """
  return DataFrame(execute(conn, query))
end

function get_genre_dist(conn, year::Int)
  query = """
    SELECT lh.username, ag.genre, COUNT(*)::int AS plays
    FROM   listening_history  lh
    JOIN   artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE  lh.artist_name IS NOT NULL
      AND  EXTRACT(YEAR FROM lh.timestamp) = $year
    GROUP  BY lh.username, ag.genre
  """
  return DataFrame(execute(conn, query))
end

function get_session_lengths(conn, year::Int)
  query = """
    WITH sessions AS (
      SELECT username, timestamp,
        CASE
          WHEN timestamp - LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp)
               > INTERVAL '30 minutes'
            OR LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp) IS NULL
          THEN 1 ELSE 0
        END AS is_new_session
      FROM listening_history
      WHERE artist_name IS NOT NULL
        AND EXTRACT(YEAR FROM timestamp) = $year
    ),
    labeled AS (
      SELECT username, timestamp,
        SUM(is_new_session) OVER (PARTITION BY username ORDER BY timestamp) AS session_id
      FROM sessions
    ),
    spans AS (
      SELECT username, session_id,
        EXTRACT(EPOCH FROM (MAX(timestamp) - MIN(timestamp))) / 60.0 AS dur_min
      FROM labeled
      GROUP BY username, session_id
    )
    SELECT username, AVG(dur_min)::float AS mean_session_min
    FROM spans
    GROUP BY username
  """
  return DataFrame(execute(conn, query))
end

# ---------------------------------------------------------------------------
# Statistics helpers
# ---------------------------------------------------------------------------

function entropy_bits(counts)
  total = sum(counts)
  total == 0 && return 0.0
  h = 0.0
  for c in counts
    c > 0 && (p = c / total; h -= p * log2(p))
  end
  return h
end

function gini(counts)
  n = length(counts)
  n == 0 && return 0.0
  s = sort(Float64.(counts))
  cs = cumsum(s)
  total = cs[end]
  total == 0 && return 0.0
  lorenz = cs ./ total
  prepend!(lorenz, 0.0)
  area = sum((lorenz[i] + lorenz[i+1]) / 2 for i in 1:n) / n
  return 1.0 - 2 * area
end

# ---------------------------------------------------------------------------
# Profile struct (11 numeric + 1 categorical) — identical to composite_user_distance.jl
# ---------------------------------------------------------------------------

struct UserProfile
  mean_min::Float64            # 1  mean play duration (min)
  skip_rate::Float64           # 2  skip rate
  shuffle_rate::Float64        # 3  shuffle rate
  artist_entropy::Float64      # 4  artist Shannon entropy
  artist_gini::Float64         # 5  artist Gini coefficient
  top1_artist_share::Float64   # 6  top-1 artist share
  genre_gini::Float64          # 7  genre Gini coefficient
  top1_track_share::Float64    # 8  top-1 track share
  mean_session_min::Float64    # 9  mean session length (min)
  mean_plays_per_track::Float64 # 10 mean plays per unique track
  late_night_frac::Float64     # 11 fraction of plays 22:00–05:00
  top_genre::String            # 12 (categorical) dominant genre
end

const NUMERIC_FIELDS = [
  :mean_min, :skip_rate, :shuffle_rate,
  :artist_entropy, :artist_gini, :top1_artist_share,
  :genre_gini, :top1_track_share,
  :mean_session_min, :mean_plays_per_track, :late_night_frac,
]

# ---------------------------------------------------------------------------
# Build profiles
# ---------------------------------------------------------------------------

function build_profiles(basic_df, artist_df, track_df, genre_df, session_df)
  basic_map = Dict(
    String(r.username) => (
      mean_min=Float64(r.mean_min),
      skip=Float64(r.skip_rate),
      shuf=Float64(r.shuffle_rate),
      late_night=Float64(r.late_night_frac),
    )
    for r in eachrow(basic_df)
  )

  session_map = Dict(
    String(r.username) => Float64(r.mean_session_min)
    for r in eachrow(session_df)
  )

  artist_counts = Dict(u => Dict{String,Int}() for u in USER_ORDER)
  for r in eachrow(artist_df)
    u = String(r.username)
    haskey(artist_counts, u) || continue
    artist_counts[u][String(r.artist_name)] = Int(r.plays)
  end

  track_counts = Dict(u => Dict{String,Int}() for u in USER_ORDER)
  for r in eachrow(track_df)
    u = String(r.username)
    haskey(track_counts, u) || continue
    track_counts[u][String(r.track_name)] = Int(r.plays)
  end

  genre_counts = Dict(u => Dict{String,Int}() for u in USER_ORDER)
  for r in eachrow(genre_df)
    u = String(r.username)
    haskey(genre_counts, u) || continue
    g = String(r.genre)
    genre_counts[u][g] = get(genre_counts[u], g, 0) + Int(r.plays)
  end

  profiles = Dict{String,UserProfile}()
  for u in USER_ORDER
    b = get(basic_map, u, (mean_min=0.0, skip=0.0, shuf=0.0, late_night=0.0))
    ac = artist_counts[u]
    tc = track_counts[u]
    gc = genre_counts[u]

    ac_vals = collect(values(ac))
    tc_vals = collect(values(tc))
    gc_vals = collect(values(gc))

    total_a = sum(ac_vals; init=0)
    top1_artist = total_a > 0 ? maximum(ac_vals; init=0) / total_a : 0.0

    total_t = sum(tc_vals; init=0)
    n_tracks = length(tc_vals)
    top1_track = total_t > 0 ? maximum(tc_vals; init=0) / total_t : 0.0
    mean_plays_per_track = n_tracks > 0 ? total_t / n_tracks : 0.0

    profiles[u] = UserProfile(
      b.mean_min,
      b.skip,
      b.shuf,
      entropy_bits(ac_vals),
      gini(ac_vals),
      top1_artist,
      gini(gc_vals),
      top1_track,
      get(session_map, u, 0.0),
      mean_plays_per_track,
      b.late_night,
      isempty(gc) ? "" : argmax(gc),
    )
  end
  return profiles
end

# ---------------------------------------------------------------------------
# Distance
# ---------------------------------------------------------------------------

minmax_norm(v, lo, hi) = (hi == lo) ? 0.0 : clamp((v - lo) / (hi - lo), 0.0, 1.0)
δ_top(a::String, b::String) = (a == b || isempty(a) || isempty(b)) ? 0.0 : 1.0

function user_drift(p24::UserProfile, p25::UserProfile, ranges)
  numeric = sum(
    abs(minmax_norm(getfield(p24, f), ranges[f]...) -
        minmax_norm(getfield(p25, f), ranges[f]...))
    for f in NUMERIC_FIELDS
  )
  nominal = δ_top(p24.top_genre, p25.top_genre)
  return W * (numeric + nominal)
end

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------

function print_results(drifts, profiles_24, profiles_25)
  println("Self-drift  d(user_2024, user_2025)  [same metric as cross-user composite distance]")
  @printf("  %-12s  %8s  %-20s  %-20s\n", "user", "drift", "top_genre_2024", "top_genre_2025")
  for (u, d) in zip(USER_ORDER, DISPLAY_ORDER)
    @printf("  %-12s  %8.4f  %-20s  %-20s\n", d, drifts[u], profiles_24[u].top_genre, profiles_25[u].top_genre)
  end
  println()

  drift_vals = [drifts[u] for u in USER_ORDER]
  println("  mean self-drift : $(round(mean(drift_vals), digits=4))")
  println("  max self-drift  : $(round(maximum(drift_vals), digits=4))  ($(DISPLAY_ORDER[argmax(drift_vals)]))")
  println("  min self-drift  : $(round(minimum(drift_vals), digits=4))  ($(DISPLAY_ORDER[argmin(drift_vals)]))")
  println()
end

function plot_bar(drifts, fname)
  vals = [drifts[u] for u in USER_ORDER]
  colors = Makie.wong_colors()[1:N_USERS]

  fig = Figure(size=(680, 480))
  ax = Axis(fig[1, 1],
    title="Behavioral Self-Drift 2024 to 2025\nd(User 2024, User 2025) - composite distance metric",
    xlabel="User",
    ylabel="Distance",
    xticks=(1:N_USERS, DISPLAY_ORDER),
    limits=(nothing, (0.0, min(1.0, maximum(vals) * 1.3))),
  )

  barplot!(ax, 1:N_USERS, vals,
    color=colors,
    strokecolor=:white,
    strokewidth=0.5,
  )

  for (i, v) in enumerate(vals)
    text!(ax, i, v + 0.005,
      text=@sprintf("%.4f", v),
      align=(:center, :bottom),
      fontsize=12,
    )
  end

  mu = mean(vals)
  hlines!(ax, [mu], color=:grey50, linewidth=1.5, linestyle=:dash)
  text!(ax, N_USERS + 0.45, mu,
    text=@sprintf("mean=%.4f", mu),
    align=(:right, :bottom),
    fontsize=10,
    color=:grey40,
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  println("Loading 2024 data...")
  conn = get_connection()
  basic_24   = get_basic(conn, 2024)
  artist_24  = get_artist_dist(conn, 2024)
  track_24   = get_track_dist(conn, 2024)
  genre_24   = get_genre_dist(conn, 2024)
  session_24 = get_session_lengths(conn, 2024)

  println("Loading 2025 data...")
  basic_25   = get_basic(conn, 2025)
  artist_25  = get_artist_dist(conn, 2025)
  track_25   = get_track_dist(conn, 2025)
  genre_25   = get_genre_dist(conn, 2025)
  session_25 = get_session_lengths(conn, 2025)
  close(conn)

  profiles_24 = build_profiles(basic_24, artist_24, track_24, genre_24, session_24)
  profiles_25 = build_profiles(basic_25, artist_25, track_25, genre_25, session_25)

  # Ranges computed over all 8 profiles (4 users × 2 years) for consistent normalization
  all_profiles = merge(
    Dict("$(u)_24" => profiles_24[u] for u in USER_ORDER),
    Dict("$(u)_25" => profiles_25[u] for u in USER_ORDER),
  )
  ranges = Dict(f => extrema(getfield(p, f) for p in values(all_profiles))
                for f in NUMERIC_FIELDS)

  drifts = Dict{String,Float64}()
  for u in USER_ORDER
    drifts[u] = user_drift(profiles_24[u], profiles_25[u], ranges)
  end

  print_results(drifts, profiles_24, profiles_25)

  fname = joinpath(PLOTS_DIR, "user_self_drift_2024_2025.png")
  plot_bar(drifts, fname)

  json_out = Dict{String,Any}(
    "description" => "d(user_2024, user_2025) using same composite distance function as cross-user matrix",
    "users" => DISPLAY_ORDER,
    "drifts" => Dict(DISPLAY_ORDER[i] => drifts[USER_ORDER[i]] for i in 1:N_USERS),
    "mean_drift" => mean(values(drifts)),
    "profiles_2024" => Dict(
      DISPLAY_ORDER[i] => Dict{String,Any}(
        "mean_play_min"        => profiles_24[USER_ORDER[i]].mean_min,
        "skip_rate"            => profiles_24[USER_ORDER[i]].skip_rate,
        "shuffle_rate"         => profiles_24[USER_ORDER[i]].shuffle_rate,
        "artist_entropy"       => profiles_24[USER_ORDER[i]].artist_entropy,
        "artist_gini"          => profiles_24[USER_ORDER[i]].artist_gini,
        "top1_artist_share"    => profiles_24[USER_ORDER[i]].top1_artist_share,
        "genre_gini"           => profiles_24[USER_ORDER[i]].genre_gini,
        "top1_track_share"     => profiles_24[USER_ORDER[i]].top1_track_share,
        "mean_session_min"     => profiles_24[USER_ORDER[i]].mean_session_min,
        "mean_plays_per_track" => profiles_24[USER_ORDER[i]].mean_plays_per_track,
        "late_night_frac"      => profiles_24[USER_ORDER[i]].late_night_frac,
        "top_genre"            => profiles_24[USER_ORDER[i]].top_genre,
      ) for i in 1:N_USERS
    ),
    "profiles_2025" => Dict(
      DISPLAY_ORDER[i] => Dict{String,Any}(
        "mean_play_min"        => profiles_25[USER_ORDER[i]].mean_min,
        "skip_rate"            => profiles_25[USER_ORDER[i]].skip_rate,
        "shuffle_rate"         => profiles_25[USER_ORDER[i]].shuffle_rate,
        "artist_entropy"       => profiles_25[USER_ORDER[i]].artist_entropy,
        "artist_gini"          => profiles_25[USER_ORDER[i]].artist_gini,
        "top1_artist_share"    => profiles_25[USER_ORDER[i]].top1_artist_share,
        "genre_gini"           => profiles_25[USER_ORDER[i]].genre_gini,
        "top1_track_share"     => profiles_25[USER_ORDER[i]].top1_track_share,
        "mean_session_min"     => profiles_25[USER_ORDER[i]].mean_session_min,
        "mean_plays_per_track" => profiles_25[USER_ORDER[i]].mean_plays_per_track,
        "late_night_frac"      => profiles_25[USER_ORDER[i]].late_night_frac,
        "top_genre"            => profiles_25[USER_ORDER[i]].top_genre,
      ) for i in 1:N_USERS
    ),
  )

  save_json(joinpath(SCRIPT_DIR, "user_self_drift.json"), json_out)
end

main()
