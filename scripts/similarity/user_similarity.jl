include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using LinearAlgebra
using Statistics
using Printf
using JSON3

const DATA_DIR  = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "user_similarity")
const PLOTS_DIR  = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER    = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]
const N_USERS = length(USER_ORDER)

const TOP_ARTISTS_JACCARD = 50   # top-N artists used for Jaccard component

# Audio feature weights (must sum to 1.0)
# energy + danceability + happiness = primary mood/feel axes (0.20 each)
# instrumentalness = key structural divide (vocal vs. non-vocal) (0.15)
# bpm = tempo/energy proxy (0.15), acousticness = production character (0.10)
# camelot_num = harmonic fingerprint (0.10), loudness = production level (0.05) [least discriminating]
const N_AUDIO_FEATS = 8
const AUDIO_FEAT_NAMES  = ["bpm","energy","danceability","happiness",
                            "acousticness","instrumentalness","loudness_norm","camelot_norm"]
const AUDIO_FEAT_WEIGHTS = [0.10, 0.20, 0.15, 0.15, 0.10, 0.15, 0.05, 0.10]

# Final component weights
const W_ARTIST       = 0.25
const W_GENRE        = 0.20
const W_TEMPORAL     = 0.15
const W_SESSION      = 0.10
const W_INTERACTION  = 0.10
const W_DISTRIBUTION = 0.10
const W_AUDIO        = 0.10

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------

function get_artist_plays(conn)
  DataFrame(execute(conn, """
    SELECT username, artist_name, COUNT(*)::int AS plays
    FROM   listening_history
    WHERE  artist_name IS NOT NULL
    GROUP  BY username, artist_name
  """))
end

function get_genre_plays(conn)
  DataFrame(execute(conn, """
    SELECT lh.username, ag.genre, COUNT(*)::int AS plays
    FROM   listening_history lh
    JOIN   artist_genres ag ON lh.artist_name = ag.artist_name
    WHERE  lh.artist_name IS NOT NULL
    GROUP  BY lh.username, ag.genre
  """))
end

function get_hourly_plays(conn)
  DataFrame(execute(conn, """
    SELECT username,
           EXTRACT(HOUR FROM timestamp)::int AS hour,
           COUNT(*)::int AS plays
    FROM   listening_history
    WHERE  artist_name IS NOT NULL
    GROUP  BY username, hour
  """))
end

function get_monthly_plays(conn)
  DataFrame(execute(conn, """
    SELECT username,
           EXTRACT(MONTH FROM timestamp)::int AS month,
           COUNT(*)::int AS plays
    FROM   listening_history
    WHERE  artist_name IS NOT NULL
    GROUP  BY username, month
  """))
end

function get_session_data(conn)
  DataFrame(execute(conn, """
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
      FROM labeled GROUP BY username, session_id
    )
    SELECT username, AVG(dur_min)::float AS mean_session_min
    FROM spans GROUP BY username
  """))
end

function get_track_plays(conn)
  DataFrame(execute(conn, """
    SELECT username, track_name, COUNT(*)::int AS plays
    FROM   listening_history
    WHERE  artist_name IS NOT NULL AND track_name IS NOT NULL
    GROUP  BY username, track_name
  """))
end

function get_basic_flags(conn)
  DataFrame(execute(conn, """
    SELECT username,
           AVG(skipped::int)::float AS skip_rate,
           AVG(shuffle::int)::float AS shuffle_rate
    FROM   listening_history
    WHERE  artist_name IS NOT NULL
    GROUP  BY username
  """))
end

function get_artist_genre_map(conn)
  DataFrame(execute(conn, """
    SELECT DISTINCT ag.artist_name, ag.genre
    FROM   artist_genres ag
    WHERE  ag.artist_name IN (
      SELECT DISTINCT artist_name FROM listening_history WHERE artist_name IS NOT NULL
    )
  """))
end

# ---------------------------------------------------------------------------
# Similarity matrices (artist↔artist and genre↔genre via Jaccard)
# ---------------------------------------------------------------------------

function build_artist_sim_matrix(ag_df, artist_list)
  genre_sets = Dict{String,Set{String}}()
  for r in eachrow(ag_df)
    a = String(r.artist_name)
    g = String(r.genre)
    s = get!(genre_sets, a, Set{String}())
    push!(s, g)
  end

  n = length(artist_list)
  S = Matrix{Float64}(I, n, n)
  for i in 1:n, j in (i+1):n
    g1 = get(genre_sets, artist_list[i], Set{String}())
    g2 = get(genre_sets, artist_list[j], Set{String}())
    if !isempty(g1) && !isempty(g2)
      inter  = length(intersect(g1, g2))
      union_ = length(g1) + length(g2) - inter
      S[i,j] = S[j,i] = union_ > 0 ? inter / union_ : 0.0
    end
  end
  return S
end

function build_genre_sim_matrix(ag_df, genre_list)
  artist_sets = Dict{String,Set{String}}()
  for r in eachrow(ag_df)
    a = String(r.artist_name)
    g = String(r.genre)
    s = get!(artist_sets, g, Set{String}())
    push!(s, a)
  end

  n = length(genre_list)
  G = Matrix{Float64}(I, n, n)
  for i in 1:n, j in (i+1):n
    a1 = get(artist_sets, genre_list[i], Set{String}())
    a2 = get(artist_sets, genre_list[j], Set{String}())
    if !isempty(a1) && !isempty(a2)
      inter  = length(intersect(a1, a2))
      union_ = length(a1) + length(a2) - inter
      G[i,j] = G[j,i] = union_ > 0 ? inter / union_ : 0.0
    end
  end
  return G
end

# ---------------------------------------------------------------------------
# Cosine helpers
# ---------------------------------------------------------------------------

function cosine_sim(a::Vector{Float64}, b::Vector{Float64})
  na, nb = norm(a), norm(b)
  (na == 0.0 || nb == 0.0) && return 0.0
  return clamp(dot(a, b) / (na * nb), 0.0, 1.0)
end

# Soft (matrix-weighted) cosine: sim = (a' S b) / sqrt(a' S a * b' S b)
function soft_cosine(a::Vector{Float64}, b::Vector{Float64}, S::Matrix{Float64})
  Sa = S * a
  ab = dot(b, Sa)
  aa = dot(a, Sa)
  Sb = S * b
  bb = dot(b, Sb)
  (aa <= 0.0 || bb <= 0.0) && return 0.0
  return clamp(ab / sqrt(aa * bb), 0.0, 1.0)
end

# ---------------------------------------------------------------------------
# Component 1: Artist similarity (weight 0.25)
# ---------------------------------------------------------------------------

function artist_similarity(artist_df, ag_df)
  raw = Dict(u => Dict{String,Int}() for u in USER_ORDER)
  for r in eachrow(artist_df)
    u = String(r.username)
    haskey(raw, u) || continue
    raw[u][String(r.artist_name)] = Int(r.plays)
  end

  artist_list = sort(collect(union(keys.(values(raw))...)))
  n_a  = length(artist_list)
  a_idx = Dict(a => i for (i,a) in enumerate(artist_list))

  # TF-IDF vectors (unit-normalized)
  tf = Dict{String,Vector{Float64}}()
  for u in USER_ORDER
    vec = zeros(Float64, n_a)
    total = sum(values(raw[u]); init=0)
    total == 0 && (tf[u] = vec; continue)
    for (a,n) in raw[u]
      haskey(a_idx,a) && (vec[a_idx[a]] = n / total)
    end
    tf[u] = vec
  end

  df_count = zeros(Int, n_a)
  for u in USER_ORDER, a in keys(raw[u])
    haskey(a_idx,a) && (df_count[a_idx[a]] += 1)
  end
  idf = [df_count[i] > 0 ? log(N_USERS / df_count[i]) : 0.0 for i in 1:n_a]

  tfidf = Dict{String,Vector{Float64}}()
  for u in USER_ORDER
    v = tf[u] .* idf
    n = norm(v)
    tfidf[u] = n > 0 ? v ./ n : v
  end

  # Artist-artist similarity matrix (Jaccard over genres)
  println("  Building artist similarity matrix ($n_a artists)...")
  S_a = build_artist_sim_matrix(ag_df, artist_list)

  sim_cos = Dict{Tuple{Int,Int},Float64}()
  for i in 1:N_USERS, j in (i+1):N_USERS
    sc = soft_cosine(tfidf[USER_ORDER[i]], tfidf[USER_ORDER[j]], S_a)
    sim_cos[(i,j)] = sim_cos[(j,i)] = sc
  end

  # Jaccard over top-50 artists per user
  top50 = Dict{String,Set{String}}()
  for u in USER_ORDER
    sorted = sort(collect(raw[u]), by=kv->-kv[2])
    top50[u] = Set(kv[1] for kv in sorted[1:min(TOP_ARTISTS_JACCARD,length(sorted))])
  end

  sim_jacc = Dict{Tuple{Int,Int},Float64}()
  for i in 1:N_USERS, j in (i+1):N_USERS
    a1, a2 = top50[USER_ORDER[i]], top50[USER_ORDER[j]]
    inter  = length(intersect(a1,a2))
    union_ = length(a1) + length(a2) - inter
    jac = union_ > 0 ? inter / union_ : 0.0
    sim_jacc[(i,j)] = sim_jacc[(j,i)] = jac
  end

  # Final: 0.8 * soft-cosine + 0.2 * Jaccard
  result = Dict{Tuple{Int,Int},Float64}()
  for i in 1:N_USERS, j in (i+1):N_USERS
    v = 0.8 * sim_cos[(i,j)] + 0.2 * sim_jacc[(i,j)]
    result[(i,j)] = result[(j,i)] = v
  end
  return result, sim_cos, sim_jacc
end

# ---------------------------------------------------------------------------
# Component 2: Genre similarity (weight 0.20)
# ---------------------------------------------------------------------------

function genre_similarity(genre_df, ag_df)
  raw = Dict(u => Dict{String,Int}() for u in USER_ORDER)
  for r in eachrow(genre_df)
    u = String(r.username)
    haskey(raw, u) || continue
    g = String(r.genre)
    raw[u][g] = get(raw[u], g, 0) + Int(r.plays)
  end

  genre_list = sort(collect(union(keys.(values(raw))...)))
  n_g  = length(genre_list)
  g_idx = Dict(g => i for (i,g) in enumerate(genre_list))

  vecs = Dict{String,Vector{Float64}}()
  for u in USER_ORDER
    vec = zeros(Float64, n_g)
    total = sum(values(raw[u]); init=0)
    total == 0 && (vecs[u] = vec; continue)
    for (g,n) in raw[u]
      haskey(g_idx,g) && (vec[g_idx[g]] = n / total)
    end
    vecs[u] = vec
  end

  println("  Building genre similarity matrix ($n_g genres)...")
  S_g = build_genre_sim_matrix(ag_df, genre_list)

  result = Dict{Tuple{Int,Int},Float64}()
  for i in 1:N_USERS, j in (i+1):N_USERS
    sc = soft_cosine(vecs[USER_ORDER[i]], vecs[USER_ORDER[j]], S_g)
    result[(i,j)] = result[(j,i)] = sc
  end
  return result
end

# ---------------------------------------------------------------------------
# Component 3: Temporal behavior (weight 0.15) — hourly × 0.6 + monthly × 0.4
# ---------------------------------------------------------------------------

function temporal_similarity(hourly_df, monthly_df)
  hourly = Dict(u => zeros(Float64,24) for u in USER_ORDER)
  for r in eachrow(hourly_df)
    u = String(r.username)
    haskey(hourly,u) || continue
    hourly[u][Int(r.hour)+1] += Float64(r.plays)
  end
  for u in USER_ORDER; s=sum(hourly[u]); s>0 && (hourly[u]./=s); end

  monthly = Dict(u => zeros(Float64,12) for u in USER_ORDER)
  for r in eachrow(monthly_df)
    u = String(r.username)
    haskey(monthly,u) || continue
    monthly[u][Int(r.month)] += Float64(r.plays)
  end
  for u in USER_ORDER; s=sum(monthly[u]); s>0 && (monthly[u]./=s); end

  result  = Dict{Tuple{Int,Int},Float64}()
  d_sims  = Dict{Tuple{Int,Int},Float64}()
  m_sims  = Dict{Tuple{Int,Int},Float64}()
  for i in 1:N_USERS, j in (i+1):N_USERS
    ds = cosine_sim(hourly[USER_ORDER[i]],  hourly[USER_ORDER[j]])
    ms = cosine_sim(monthly[USER_ORDER[i]], monthly[USER_ORDER[j]])
    v  = 0.6*ds + 0.4*ms
    result[(i,j)] = result[(j,i)] = v
    d_sims[(i,j)]  = d_sims[(j,i)]  = ds
    m_sims[(i,j)]  = m_sims[(j,i)]  = ms
  end
  return result, d_sims, m_sims
end

# ---------------------------------------------------------------------------
# Component 4: Session behavior (weight 0.10) — session length + plays/track
# ---------------------------------------------------------------------------

function session_similarity(session_df, track_df)
  sess_map = Dict(String(r.username) => Float64(r.mean_session_min)
                  for r in eachrow(session_df))

  ppt = Dict{String,Float64}()
  tc  = Dict(u => Dict{String,Int}() for u in USER_ORDER)
  for r in eachrow(track_df)
    u = String(r.username)
    haskey(tc,u) || continue
    tc[u][String(r.track_name)] = Int(r.plays)
  end
  for u in USER_ORDER
    total    = sum(values(tc[u]); init=0)
    n_tracks = length(tc[u])
    ppt[u] = n_tracks > 0 ? total / n_tracks : 0.0
  end

  sess_vals = [get(sess_map,u,0.0) for u in USER_ORDER]
  ppt_vals  = [ppt[u]               for u in USER_ORDER]
  sess_std  = std(sess_vals)
  ppt_std   = std(ppt_vals)

  result   = Dict{Tuple{Int,Int},Float64}()
  sl_sims  = Dict{Tuple{Int,Int},Float64}()
  ppt_sims = Dict{Tuple{Int,Int},Float64}()
  for i in 1:N_USERS, j in (i+1):N_USERS
    s1, s2 = get(sess_map,USER_ORDER[i],0.0), get(sess_map,USER_ORDER[j],0.0)
    ss = sess_std > 0 ? exp(-abs(s1-s2)/sess_std) : 1.0

    p1, p2 = ppt[USER_ORDER[i]], ppt[USER_ORDER[j]]
    ps = ppt_std > 0 ? exp(-abs(p1-p2)/ppt_std) : 1.0

    v = 0.5*ss + 0.5*ps
    result[(i,j)]  = result[(j,i)]  = v
    sl_sims[(i,j)] = sl_sims[(j,i)] = ss
    ppt_sims[(i,j)]= ppt_sims[(j,i)]= ps
  end
  return result, sl_sims, ppt_sims
end

# ---------------------------------------------------------------------------
# Component 5: Interaction behavior (weight 0.10) — skip + shuffle
# ---------------------------------------------------------------------------

function interaction_similarity(flags_df)
  flags = Dict(String(r.username) => (skip=Float64(r.skip_rate), shuf=Float64(r.shuffle_rate))
               for r in eachrow(flags_df))

  result    = Dict{Tuple{Int,Int},Float64}()
  skip_sims = Dict{Tuple{Int,Int},Float64}()
  shuf_sims = Dict{Tuple{Int,Int},Float64}()
  for i in 1:N_USERS, j in (i+1):N_USERS
    f1 = get(flags, USER_ORDER[i], (skip=0.0, shuf=0.0))
    f2 = get(flags, USER_ORDER[j], (skip=0.0, shuf=0.0))
    sk = 1.0 - abs(f1.skip - f2.skip)
    sh = 1.0 - abs(f1.shuf - f2.shuf)
    v  = 0.5*sk + 0.5*sh
    result[(i,j)]    = result[(j,i)]    = v
    skip_sims[(i,j)] = skip_sims[(j,i)] = sk
    shuf_sims[(i,j)] = shuf_sims[(j,i)] = sh
  end
  return result, skip_sims, shuf_sims
end

# ---------------------------------------------------------------------------
# Component 6: Distribution structure (weight 0.10) — top-artist share + entropy
# ---------------------------------------------------------------------------

function entropy_bits(vals)
  total = sum(vals)
  total == 0 && return 0.0
  h = 0.0
  for v in vals; v > 0 && (p=v/total; h -= p*log2(p)); end
  return h
end

function distribution_similarity(artist_df)
  raw = Dict(u => Dict{String,Int}() for u in USER_ORDER)
  for r in eachrow(artist_df)
    u = String(r.username)
    haskey(raw,u) || continue
    raw[u][String(r.artist_name)] = Int(r.plays)
  end

  top_sh = Dict{String,Float64}()
  ent_n  = Dict{String,Float64}()
  for u in USER_ORDER
    vals  = collect(values(raw[u]))
    total = sum(vals; init=0)
    top_sh[u] = total > 0 ? maximum(vals; init=0)/total : 0.0
    n_art = length(vals)
    max_h = n_art > 1 ? log2(n_art) : 1.0
    ent_n[u]  = max_h > 0 ? entropy_bits(vals)/max_h : 0.0
  end

  result   = Dict{Tuple{Int,Int},Float64}()
  top_sims = Dict{Tuple{Int,Int},Float64}()
  ent_sims = Dict{Tuple{Int,Int},Float64}()
  for i in 1:N_USERS, j in (i+1):N_USERS
    ts = 1.0 - abs(top_sh[USER_ORDER[i]] - top_sh[USER_ORDER[j]])
    es = 1.0 - abs(ent_n[USER_ORDER[i]]  - ent_n[USER_ORDER[j]])
    v  = 0.5*ts + 0.5*es
    result[(i,j)]   = result[(j,i)]   = v
    top_sims[(i,j)] = top_sims[(j,i)] = ts
    ent_sims[(i,j)] = ent_sims[(j,i)] = es
  end
  return result, top_sims, ent_sims
end

# ---------------------------------------------------------------------------
# Component 7: Audio feature similarity (weight 0.10)
# ---------------------------------------------------------------------------

function parse_camelot_num(c::String)
  m = match(r"^(\d+)[AB]$", c)
  isnothing(m) && return 0.0
  return parse(Float64, m.captures[1]) / 12.0
end

function audio_similarity(json_path::String)
  data = JSON3.read(read(json_path, String))

  # Collect raw feature vectors per user (one per track)
  raw_by_user = Dict{String,Vector{Vector{Float64}}}()
  for entry in data
    u = String(entry[:user])
    raw_by_user[u] = Vector{Vector{Float64}}()
    for t in entry[:tracks]
      vec = [
        Float64(t[:bpm]),
        Float64(t[:energy]),
        Float64(t[:danceability]),
        Float64(t[:happiness]),
        Float64(t[:acousticness]),
        Float64(t[:instrumentalness]),
        Float64(t[:loudness_db]),
        parse_camelot_num(String(t[:camelot])),
      ]
      push!(raw_by_user[u], vec)
    end
  end

  # Min-max normalize each feature dimension across all 40 tracks
  all_tracks = vcat(values(raw_by_user)...)
  feat_min = [minimum(v[f] for v in all_tracks) for f in 1:N_AUDIO_FEATS]
  feat_max = [maximum(v[f] for v in all_tracks) for f in 1:N_AUDIO_FEATS]

  # Average normalized, weighted features per user
  user_vecs = Dict{String,Vector{Float64}}()
  for u in DISPLAY_ORDER
    if !haskey(raw_by_user, u)
      user_vecs[u] = zeros(Float64, N_AUDIO_FEATS)
      continue
    end
    tracks = raw_by_user[u]
    n_t = length(tracks)
    avg = zeros(Float64, N_AUDIO_FEATS)
    for t in tracks, f in 1:N_AUDIO_FEATS
      rng = feat_max[f] - feat_min[f]
      avg[f] += rng > 0 ? (t[f] - feat_min[f]) / rng : 0.0
    end
    avg ./= n_t
    user_vecs[u] = avg .* AUDIO_FEAT_WEIGHTS
  end

  result = Dict{Tuple{Int,Int},Float64}()
  for i in 1:N_USERS, j in (i+1):N_USERS
    sc = cosine_sim(user_vecs[DISPLAY_ORDER[i]], user_vecs[DISPLAY_ORDER[j]])
    result[(i,j)] = result[(j,i)] = sc
  end
  return result, user_vecs
end

# ---------------------------------------------------------------------------
# Combine
# ---------------------------------------------------------------------------

function combine_components(art, gen, temp, sess, inter, dist, aud)
  result = Dict{Tuple{Int,Int},Float64}()
  for i in 1:N_USERS, j in (i+1):N_USERS
    v = W_ARTIST       * art[(i,j)]  +
        W_GENRE        * gen[(i,j)]  +
        W_TEMPORAL     * temp[(i,j)] +
        W_SESSION      * sess[(i,j)] +
        W_INTERACTION  * inter[(i,j)]+
        W_DISTRIBUTION * dist[(i,j)] +
        W_AUDIO        * aud[(i,j)]
    result[(i,j)] = result[(j,i)] = v
  end
  return result
end

# ---------------------------------------------------------------------------
# Print
# ---------------------------------------------------------------------------

function print_pair_table(label, d)
  println("  $label")
  for i in 1:N_USERS, j in (i+1):N_USERS
    @printf("    %-12s — %-12s  %.4f\n", DISPLAY_ORDER[i], DISPLAY_ORDER[j], d[(i,j)])
  end
end

function print_results(art, art_cos, art_jacc, gen, temp, d_sim, m_sim,
                       sess, sl_sim, ppt_sim, inter, skip_sim, shuf_sim,
                       dist, top_sim, ent_sim, aud, final)
  println("\n" * "="^65)
  println("INTERMEDIATE COMPONENT SIMILARITIES")
  println("="^65)

  println("\n▸ Artist Similarity  (w=0.25)")
  print_pair_table("  soft-cosine (TF-IDF, artist sim matrix):", art_cos)
  print_pair_table("  Jaccard top-50 artists:", art_jacc)
  print_pair_table("  combined (0.8×cos + 0.2×jacc):", art)

  println("\n▸ Genre Similarity  (w=0.20)")
  print_pair_table("  soft-cosine (play-share, genre sim matrix):", gen)

  println("\n▸ Temporal Similarity  (w=0.15)")
  print_pair_table("  hourly cosine:", d_sim)
  print_pair_table("  monthly cosine:", m_sim)
  print_pair_table("  combined (0.6×hourly + 0.4×monthly):", temp)

  println("\n▸ Session Similarity  (w=0.10)")
  print_pair_table("  session length (exp decay):", sl_sim)
  print_pair_table("  plays per track (exp decay):", ppt_sim)
  print_pair_table("  combined (equal weight):", sess)

  println("\n▸ Interaction Similarity  (w=0.10)")
  print_pair_table("  skip rate (1 - |diff|):", skip_sim)
  print_pair_table("  shuffle rate (1 - |diff|):", shuf_sim)
  print_pair_table("  combined (equal weight):", inter)

  println("\n▸ Distribution Structure  (w=0.10)")
  print_pair_table("  top-artist share (1 - |diff|):", top_sim)
  print_pair_table("  normalized entropy (1 - |diff|):", ent_sim)
  print_pair_table("  combined (equal weight):", dist)

  println("\n▸ Audio Feature Similarity  (w=0.10)")
  print_pair_table("  cosine of weighted avg feature vectors:", aud)

  println("\n" * "="^65)
  println("FINAL WEIGHTED SIMILARITY MATRIX")
  println("="^65)
  hdr = @sprintf("  %-14s", "")
  for d in DISPLAY_ORDER; hdr *= @sprintf("  %-12s", d); end
  println(hdr)
  for i in 1:N_USERS
    row = @sprintf("  %-14s", DISPLAY_ORDER[i])
    for j in 1:N_USERS
      v = i==j ? 1.0 : final[(i,j)]
      row *= @sprintf("  %-12.4f", v)
    end
    println(row)
  end

  pairs = [(i,j,final[(i,j)]) for i in 1:N_USERS for j in (i+1):N_USERS]
  sort!(pairs, by=t->-t[3])
  println()
  println("  Most similar:  $(DISPLAY_ORDER[pairs[1][1]]) — $(DISPLAY_ORDER[pairs[1][2]])  ($(round(pairs[1][3],digits=4)))")
  println("  Least similar: $(DISPLAY_ORDER[pairs[end][1]]) — $(DISPLAY_ORDER[pairs[end][2]])  ($(round(pairs[end][3],digits=4)))")
  println()
end

# ---------------------------------------------------------------------------
# Plot
# ---------------------------------------------------------------------------

function plot_similarity_matrix(final, fname)
  mat = [i==j ? 1.0 : final[(i,j)] for i in 1:N_USERS, j in 1:N_USERS]
  fig = Figure(size=(580,500))
  ax  = Axis(fig[1,1],
    title="User Similarity Matrix\n(7-component weighted composite, all-time)",
    xticks=(1:N_USERS, DISPLAY_ORDER),
    yticks=(1:N_USERS, DISPLAY_ORDER),
    yreversed=true,
  )
  hm = heatmap!(ax, 1:N_USERS, 1:N_USERS, mat,
    colormap=:Blues, colorrange=(0.0,1.0))
  for i in 1:N_USERS, j in 1:N_USERS
    v = mat[i,j]
    text!(ax, i, j,
      text=@sprintf("%.4f", v),
      align=(:center,:center),
      fontsize=13,
      color=v > 0.65 ? :white : :black,
    )
  end
  Colorbar(fig[1,2], hm, label="Similarity", colorrange=(0.0,1.0))
  save(fname, fig)
  println("  plot saved: $fname")
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  println("Loading data from database...")
  conn       = get_connection()
  artist_df  = get_artist_plays(conn)
  genre_df   = get_genre_plays(conn)
  hourly_df  = get_hourly_plays(conn)
  monthly_df = get_monthly_plays(conn)
  session_df = get_session_data(conn)
  track_df   = get_track_plays(conn)
  flags_df   = get_basic_flags(conn)
  ag_df      = get_artist_genre_map(conn)
  close(conn)

  println("Computing artist similarity...")
  art, art_cos, art_jacc = artist_similarity(artist_df, ag_df)

  println("Computing genre similarity...")
  gen = genre_similarity(genre_df, ag_df)

  println("Computing temporal similarity...")
  temp, d_sim, m_sim = temporal_similarity(hourly_df, monthly_df)

  println("Computing session similarity...")
  sess, sl_sim, ppt_sim = session_similarity(session_df, track_df)

  println("Computing interaction similarity...")
  inter, skip_sim, shuf_sim = interaction_similarity(flags_df)

  println("Computing distribution similarity...")
  dist, top_sim, ent_sim = distribution_similarity(artist_df)

  println("Computing audio feature similarity...")
  json_path = joinpath(@__DIR__, "..", "..", "top-10-tracks-stats.json")
  aud, _ = audio_similarity(json_path)

  final = combine_components(art, gen, temp, sess, inter, dist, aud)

  print_results(art, art_cos, art_jacc, gen, temp, d_sim, m_sim,
                sess, sl_sim, ppt_sim, inter, skip_sim, shuf_sim,
                dist, top_sim, ent_sim, aud, final)

  plot_similarity_matrix(final, joinpath(PLOTS_DIR, "user_similarity_matrix.png"))

  pk = [(i,j) for i in 1:N_USERS for j in (i+1):N_USERS]
  pn(i,j) = "$(DISPLAY_ORDER[i])_$(DISPLAY_ORDER[j])"

  pairs_ranked = sort([(i,j,final[(i,j)]) for (i,j) in pk], by=t->-t[3])

  json_out = Dict{String,Any}(
    "weights" => Dict{String,Float64}(
      "artist"=>W_ARTIST, "genre"=>W_GENRE, "temporal"=>W_TEMPORAL,
      "session"=>W_SESSION, "interaction"=>W_INTERACTION,
      "distribution"=>W_DISTRIBUTION, "audio"=>W_AUDIO,
    ),
    "final_similarity" => Dict(pn(i,j) => final[(i,j)] for (i,j) in pk),
    "most_similar"  => "$(DISPLAY_ORDER[pairs_ranked[1][1]]) — $(DISPLAY_ORDER[pairs_ranked[1][2]]) ($(round(pairs_ranked[1][3],digits=4)))",
    "least_similar" => "$(DISPLAY_ORDER[pairs_ranked[end][1]]) — $(DISPLAY_ORDER[pairs_ranked[end][2]]) ($(round(pairs_ranked[end][3],digits=4)))",
    "components" => Dict{String,Any}(
      "artist"              => Dict(pn(i,j)=>art[(i,j)]      for (i,j) in pk),
      "artist_soft_cosine"  => Dict(pn(i,j)=>art_cos[(i,j)]  for (i,j) in pk),
      "artist_jaccard_top50"=> Dict(pn(i,j)=>art_jacc[(i,j)] for (i,j) in pk),
      "genre"               => Dict(pn(i,j)=>gen[(i,j)]      for (i,j) in pk),
      "temporal"            => Dict(pn(i,j)=>temp[(i,j)]     for (i,j) in pk),
      "temporal_hourly"     => Dict(pn(i,j)=>d_sim[(i,j)]    for (i,j) in pk),
      "temporal_monthly"    => Dict(pn(i,j)=>m_sim[(i,j)]    for (i,j) in pk),
      "session"             => Dict(pn(i,j)=>sess[(i,j)]     for (i,j) in pk),
      "session_length"      => Dict(pn(i,j)=>sl_sim[(i,j)]   for (i,j) in pk),
      "plays_per_track"     => Dict(pn(i,j)=>ppt_sim[(i,j)]  for (i,j) in pk),
      "interaction"         => Dict(pn(i,j)=>inter[(i,j)]    for (i,j) in pk),
      "skip_rate"           => Dict(pn(i,j)=>skip_sim[(i,j)] for (i,j) in pk),
      "shuffle_rate"        => Dict(pn(i,j)=>shuf_sim[(i,j)] for (i,j) in pk),
      "distribution"        => Dict(pn(i,j)=>dist[(i,j)]     for (i,j) in pk),
      "top_artist_share"    => Dict(pn(i,j)=>top_sim[(i,j)]  for (i,j) in pk),
      "artist_entropy"      => Dict(pn(i,j)=>ent_sim[(i,j)]  for (i,j) in pk),
      "audio"               => Dict(pn(i,j)=>aud[(i,j)]      for (i,j) in pk),
    ),
  )
  save_json(joinpath(SCRIPT_DIR, "user_similarity.json"), json_out)
end

main()
