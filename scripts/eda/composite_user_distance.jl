include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "composite_user_distance")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]
const N_USERS = length(USER_ORDER)

const N_FEATURES = 12        # 11 numeric + 1 categorical
const W = 1.0 / N_FEATURES

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------

function get_basic(conn)
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
    GROUP BY username
  """
  return DataFrame(execute(conn, query))
end

function get_artist_dist(conn)
  query = """
    SELECT username, artist_name, COUNT(*)::int AS plays
    FROM   listening_history
    WHERE  artist_name IS NOT NULL
    GROUP  BY username, artist_name
  """
  return DataFrame(execute(conn, query))
end

function get_track_dist(conn)
  query = """
    SELECT username, track_name, COUNT(*)::int AS plays
    FROM   listening_history
    WHERE  artist_name IS NOT NULL AND track_name IS NOT NULL
    GROUP  BY username, track_name
  """
  return DataFrame(execute(conn, query))
end

function get_genre_dist(conn)
  query = """
    SELECT lh.username, ag.genre, COUNT(*)::int AS plays
    FROM   listening_history  lh
    JOIN   artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE  lh.artist_name IS NOT NULL
    GROUP  BY lh.username, ag.genre
  """
  return DataFrame(execute(conn, query))
end

function get_session_lengths(conn)
  query = """
    WITH sessions AS (
      SELECT username, timestamp,
        CASE
          WHEN timestamp - LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp)
               > INTERVAL '30 minutes'
            OR LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp) IS NULL
          THEN 1 ELSE 0
        END AS is_new_session
      FROM listening_history WHERE artist_name IS NOT NULL
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
# Profile struct  (11 numeric fields + 1 categorical)
# ---------------------------------------------------------------------------

struct UserProfile
  mean_min::Float64   # 1  mean play duration (min)
  skip_rate::Float64   # 2  skip rate
  shuffle_rate::Float64   # 3  shuffle rate
  artist_entropy::Float64   # 4  artist Shannon entropy
  artist_gini::Float64   # 5  artist Gini coefficient
  top1_artist_share::Float64   # 6  top-1 artist share
  genre_gini::Float64   # 7  genre Gini coefficient
  top1_track_share::Float64   # 8  top-1 track share
  mean_session_min::Float64   # 9  mean session length (min)
  mean_plays_per_track::Float64 # 10 mean plays per unique track
  late_night_frac::Float64   # 11 fraction of plays 22:00–05:00
  top_genre::String    # 12 (categorical) dominant genre
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

function compute_distance_matrix(profiles)
  field(f) = [getfield(profiles[u], f) for u in USER_ORDER]
  ranges = Dict(f => extrema(field(f)) for f in NUMERIC_FIELDS)

  mat = zeros(Float64, N_USERS, N_USERS)
  for i in 1:N_USERS, j in 1:N_USERS
    i == j && continue
    px, py = profiles[USER_ORDER[i]], profiles[USER_ORDER[j]]

    numeric = sum(
      abs(minmax_norm(getfield(px, f), ranges[f]...) -
          minmax_norm(getfield(py, f), ranges[f]...))
      for f in NUMERIC_FIELDS
    )

    nominal = δ_top(px.top_genre, py.top_genre)

    mat[i, j] = W * (numeric + nominal)
  end
  return mat
end

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

function print_equation()
  println("""
  Composite Distance d(x,y) ∈ [0,1]:

    d(x,y) = (1/12) · [ Σᵢ |x̂ᵢ − ŷᵢ|  (i = 1..11, min-max normalized)
                        + δ_top(top_genre_x, top_genre_y) ]

  Numeric features (i):
     1. mean play duration (min)
     2. skip rate
     3. shuffle rate
     4. artist entropy (bits)
     5. artist Gini coefficient
     6. top-1 artist share
     7. genre Gini coefficient
     8. top-1 track share
     9. mean session length (min)
    10. mean plays per track
    11. late-night fraction (22:00-05:00)

  Categorical feature (δ):
    12. δ_top(top genre) - 0 if same, else 1
  """)
end

function print_profiles(profiles)
  println("Per-user feature values (all-time):")
  @printf("  %-12s  %8s  %6s  %8s  %9s  %9s  %9s  %8s  %9s  %9s  %11s  %10s  %-20s\n", "user", "mean_min", "skip%", "shuffle%", "art_ent", "art_gini", "top1_art%", "gnr_gini", "top1_trk%", "sess_min", "plays/track", "late_night%", "top_genre")
  for (u, d) in zip(USER_ORDER, DISPLAY_ORDER)
    p = profiles[u]
    @printf("  %-12s  %8.2f  %6.1f  %8.1f  %9.3f  %9.3f  %9.1f  %8.3f  %9.1f  %9.2f  %11.2f  %10.1f  %-20s\n", d, p.mean_min, p.skip_rate * 100, p.shuffle_rate * 100, p.artist_entropy, p.artist_gini, p.top1_artist_share * 100, p.genre_gini, p.top1_track_share * 100, p.mean_session_min, p.mean_plays_per_track, p.late_night_frac * 100, p.top_genre)
  end
  println()
end

function print_matrix(mat)
  println("Composite distance matrix d(x,y):")
  hdr = @sprintf "  %-12s" ""
  for d in DISPLAY_ORDER
    hdr *= @sprintf "  %10s" d
  end
  println(hdr)
  for i in 1:N_USERS
    row = @sprintf "  %-12s" DISPLAY_ORDER[i]
    for j in 1:N_USERS
      row *= @sprintf "  %10.4f" mat[i, j]
    end
    println(row)
  end
  println()
end

function plot_heatmap(mat, fname)
  fig = Figure(size=(560, 480))
  ax = Axis(fig[1, 1],
    title="Composite User-User Distance - All Time",
    xlabel="User",
    ylabel="User",
    xticks=(1:N_USERS, DISPLAY_ORDER),
    yticks=(1:N_USERS, DISPLAY_ORDER),
    yreversed=true,
  )

  hm = heatmap!(ax, 1:N_USERS, 1:N_USERS, mat,
    colormap=Reverse(:RdYlGn),
    colorrange=(0.0, 1.0),
  )

  for i in 1:N_USERS, j in 1:N_USERS
    v = mat[i, j]
    text!(ax, i, j,
      text=@sprintf("%.3f", v),
      align=(:center, :center),
      fontsize=14,
      color=v > 0.55 ? :white : :black,
    )
  end

  Colorbar(fig[1, 2], hm,
    label="Distance (0 = identical, 1 = maximally different)",
    colorrange=(0.0, 1.0),
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

  print_equation()

  conn = get_connection()
  basic_df = get_basic(conn)
  artist_df = get_artist_dist(conn)
  track_df = get_track_dist(conn)
  genre_df = get_genre_dist(conn)
  session_df = get_session_lengths(conn)
  close(conn)

  profiles = build_profiles(basic_df, artist_df, track_df, genre_df, session_df)

  print_profiles(profiles)

  mat = compute_distance_matrix(profiles)
  print_matrix(mat)

  fname = joinpath(PLOTS_DIR, "composite_user_distance_alltime.png")
  plot_heatmap(mat, fname)

  json_out = Dict{String,Any}(
    "features" => Dict(
      "numeric" => [
        "mean_play_min", "skip_rate", "shuffle_rate",
        "artist_entropy", "artist_gini", "top1_artist_share",
        "genre_gini", "top1_track_share",
        "mean_session_min", "mean_plays_per_track", "late_night_frac",
      ],
      "nominal" => ["top_genre_match"],
    ),
    "weight_per_feature" => W,
    "profiles" => Dict(
      DISPLAY_ORDER[i] => Dict{String,Any}(
        "mean_play_min" => profiles[USER_ORDER[i]].mean_min,
        "skip_rate" => profiles[USER_ORDER[i]].skip_rate,
        "shuffle_rate" => profiles[USER_ORDER[i]].shuffle_rate,
        "artist_entropy" => profiles[USER_ORDER[i]].artist_entropy,
        "artist_gini" => profiles[USER_ORDER[i]].artist_gini,
        "top1_artist_share" => profiles[USER_ORDER[i]].top1_artist_share,
        "genre_gini" => profiles[USER_ORDER[i]].genre_gini,
        "top1_track_share" => profiles[USER_ORDER[i]].top1_track_share,
        "mean_session_min" => profiles[USER_ORDER[i]].mean_session_min,
        "mean_plays_per_track" => profiles[USER_ORDER[i]].mean_plays_per_track,
        "late_night_frac" => profiles[USER_ORDER[i]].late_night_frac,
        "top_genre" => profiles[USER_ORDER[i]].top_genre,
      )
      for i in 1:N_USERS
    ),
    "matrix" => [[mat[i, j] for j in 1:N_USERS] for i in 1:N_USERS],
    "users" => DISPLAY_ORDER,
    "pairs" => [
      Dict{String,Any}(
        "users" => [DISPLAY_ORDER[i], DISPLAY_ORDER[j]],
        "distance" => mat[i, j],
      )
      for i in 1:N_USERS for j in (i+1):N_USERS
    ],
  )

  save_json(joinpath(SCRIPT_DIR, "composite_user_distance.json"), json_out)
end

main()
