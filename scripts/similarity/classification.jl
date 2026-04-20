import Pkg
if !haskey(Pkg.project().dependencies, "DecisionTree")
  println("Installing DecisionTree.jl...")
  Pkg.add("DecisionTree")
end

include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using Statistics
using Printf
using Random
using LinearAlgebra
using Distributions
using DecisionTree

Random.seed!(42)

const DATA_DIR   = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "classification")

const USER_ORDER    = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]
const N_USERS = length(USER_ORDER)

# 9 features — each mirrors a component from the similarity measure
const FEAT_NAMES = [
  "hour",              # temporal component: time-of-day
  "dow",               # temporal component: day-of-week
  "month",             # temporal component: seasonality
  "shuffle",           # interaction component: shuffle mode
  "reason_start",      # behavioral context: how play was initiated
  "log_artist_plays",  # artist familiarity (mirrors TF-IDF in artist similarity)
  "log_track_plays",   # track familiarity (mirrors plays-per-track in session component)
  "genre_match",       # genre affinity score (directly from genre similarity component)
  "session_momentum",  # fraction of last 3 plays in this session that were skipped
]
const N_FEATS = length(FEAT_NAMES)

# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------

function get_plays(conn)
  DataFrame(execute(conn, """
    SELECT
      lh.username,
      lh.skipped::int                           AS skipped,
      lh.shuffle::int                           AS shuffle,
      COALESCE(lh.reason_start, 'unknown')      AS reason_start,
      EXTRACT(HOUR  FROM lh.timestamp)::int     AS hour,
      EXTRACT(DOW   FROM lh.timestamp)::int     AS dow,
      EXTRACT(MONTH FROM lh.timestamp)::int     AS month,
      EXTRACT(EPOCH FROM lh.timestamp)::float     AS epoch_sec,
      lh.artist_name,
      lh.track_name
    FROM listening_history lh
    WHERE lh.artist_name IS NOT NULL
      AND lh.skipped     IS NOT NULL
      AND lh.track_name  IS NOT NULL
  """))
end

function get_artist_plays(conn)
  DataFrame(execute(conn, """
    SELECT username, artist_name, COUNT(*)::int AS plays
    FROM   listening_history
    WHERE  artist_name IS NOT NULL
    GROUP  BY username, artist_name
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

function get_genre_plays(conn)
  DataFrame(execute(conn, """
    SELECT lh.username, ag.genre, COUNT(*)::int AS plays
    FROM   listening_history lh
    JOIN   artist_genres ag ON lh.artist_name = ag.artist_name
    WHERE  lh.artist_name IS NOT NULL
    GROUP  BY lh.username, ag.genre
  """))
end

function get_artist_genre_map(conn)
  DataFrame(execute(conn, """
    SELECT DISTINCT artist_name, genre
    FROM   artist_genres
    WHERE  artist_name IN (
      SELECT DISTINCT artist_name FROM listening_history WHERE artist_name IS NOT NULL
    )
  """))
end

# ---------------------------------------------------------------------------
# Session momentum
# ---------------------------------------------------------------------------

# For each play (sorted by epoch_sec within user), compute the fraction of the
# last WINDOW plays in the same session that were skipped. Uses epoch_sec to
# define sessions (gap > GAP_MIN minutes → new session). The result vector is
# aligned to the original (unsorted) row order of plays_df.
function compute_session_momentum(plays_df; window=3, gap_min=30.0)
  n = nrow(plays_df)
  momentum = zeros(Float64, n)

  # Group row indices by user
  user_rows = Dict{String, Vector{Int}}()
  for i in 1:n
    u = String(plays_df.username[i])
    push!(get!(user_rows, u, Int[]), i)
  end

  for (_, row_idxs) in user_rows
    # Sort this user's rows by epoch_sec
    epochs = [Float64(plays_df.epoch_sec[i]) for i in row_idxs]
    order  = sortperm(epochs)
    sorted_idxs  = row_idxs[order]
    sorted_epochs = epochs[order]
    sorted_skips = [Int(plays_df.skipped[i]) for i in sorted_idxs]

    m = length(sorted_idxs)

    # Assign session ids: new session when gap > gap_min minutes
    sess = ones(Int, m)
    for i in 2:m
      gap_sec = sorted_epochs[i] - sorted_epochs[i-1]
      sess[i] = gap_sec > gap_min * 60.0 ? sess[i-1] + 1 : sess[i-1]
    end

    # Per-session rolling buffer: compute momentum BEFORE appending current skip
    sess_buf = Dict{Int, Vector{Int}}()
    for i in 1:m
      sid = sess[i]
      buf = get!(sess_buf, sid, Int[])
      if isempty(buf)
        momentum[sorted_idxs[i]] = 0.0
      else
        w_start = max(1, length(buf) - window + 1)
        momentum[sorted_idxs[i]] = mean(buf[w_start:end])
      end
      push!(buf, sorted_skips[i])
    end
  end

  return momentum
end

# ---------------------------------------------------------------------------
# Feature engineering
# ---------------------------------------------------------------------------

function encode_reason(r::String)
  r == "trackdone" && return 0.0   # autoplay: neutral
  r == "clickrow"  && return 1.0   # user chose: lower skip risk
  r == "fwdbtn"    && return 2.0   # prev track skipped: higher skip risk
  r == "appload"   && return 3.0   # app open: neutral
  r == "backbtn"   && return 4.0   # rewind: engaged
  return 5.0                       # other / unknown
end

function cosine_sim(a::Vector{Float64}, b::Vector{Float64})
  na, nb = norm(a), norm(b)
  (na == 0.0 || nb == 0.0) && return 0.0
  clamp(dot(a, b) / (na * nb), 0.0, 1.0)
end

function build_feature_matrix(plays_df, ap_df, tp_df, gp_df, ag_df, momentum::Vector{Float64})
  # (user, artist) -> plays
  ap_map = Dict{Tuple{String,String}, Float64}()
  max_ap = Dict{String, Float64}()
  for r in eachrow(ap_df)
    u, a = String(r.username), String(r.artist_name)
    p = Float64(r.plays)
    ap_map[(u,a)] = p
    max_ap[u] = max(get(max_ap, u, 0.0), p)
  end

  # (user, track) -> plays
  tp_map = Dict{Tuple{String,String}, Float64}()
  max_tp = Dict{String, Float64}()
  for r in eachrow(tp_df)
    u, t = String(r.username), String(r.track_name)
    p = Float64(r.plays)
    tp_map[(u,t)] = p
    max_tp[u] = max(get(max_tp, u, 0.0), p)
  end

  # Genre vocabulary over artists in listening history
  all_genres = sort(collect(Set(String.(ag_df.genre))))
  n_g   = length(all_genres)
  g_idx = Dict(g => i for (i,g) in enumerate(all_genres))

  # Binary artist genre vectors
  artist_gv = Dict{String, Vector{Float64}}()
  for r in eachrow(ag_df)
    a, g = String(r.artist_name), String(r.genre)
    v = get!(artist_gv, a, zeros(Float64, n_g))
    haskey(g_idx, g) && (v[g_idx[g]] = 1.0)
  end

  # Normalized user genre profiles (play-share)
  user_gv = Dict{String, Vector{Float64}}()
  for r in eachrow(gp_df)
    u, g = String(r.username), String(r.genre)
    v = get!(user_gv, u, zeros(Float64, n_g))
    haskey(g_idx, g) && (v[g_idx[g]] += Float64(r.plays))
  end
  for (u,v) in user_gv
    s = sum(v); s > 0 && (user_gv[u] = v ./ s)
  end

  n  = nrow(plays_df)
  X  = zeros(Float64, n, N_FEATS)
  y  = zeros(Int, n)
  us = fill("", n)

  for (i,r) in enumerate(eachrow(plays_df))
    u, a, t = String(r.username), String(r.artist_name), String(r.track_name)

    ap = get(ap_map, (u,a), 0.0)
    tp = get(tp_map, (u,t), 0.0)
    ma = max(get(max_ap, u, 1.0), 1.0)
    mt = max(get(max_tp, u, 1.0), 1.0)

    ag_v = get(artist_gv, a, zeros(Float64, n_g))
    ug_v = get(user_gv,   u, zeros(Float64, n_g))

    X[i,1] = Float64(r.hour)
    X[i,2] = Float64(r.dow)
    X[i,3] = Float64(r.month)
    X[i,4] = Float64(r.shuffle)
    X[i,5] = encode_reason(String(r.reason_start))
    X[i,6] = log(1.0 + ap) / log(1.0 + ma)   # [0,1], 1 = most-played artist
    X[i,7] = log(1.0 + tp) / log(1.0 + mt)   # [0,1], 1 = most-replayed track
    X[i,8] = cosine_sim(ag_v, ug_v)           # genre affinity [0,1]
    X[i,9] = momentum[i]                      # session skip momentum [0,1]

    y[i]  = Int(r.skipped)
    us[i] = u
  end

  return X, y, us
end

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

function stratified_split(y::Vector{Int}; frac=0.20)
  train_idx, test_idx = Int[], Int[]
  for c in sort(unique(y))
    idx = shuffle(findall(==(c), y))
    n_te = max(1, round(Int, length(idx) * frac))
    append!(test_idx,  idx[1:n_te])
    append!(train_idx, idx[(n_te+1):end])
  end
  return train_idx, test_idx
end

function auc_roc(y_true::Vector{Int}, y_score::Vector{Float64})
  n_pos = sum(y_true); n_neg = length(y_true) - n_pos
  (n_pos == 0 || n_neg == 0) && return 0.5
  ord = sortperm(y_score, rev=true)
  ys  = y_true[ord]
  tpr = cumsum(ys)        ./ n_pos
  fpr = cumsum(1 .- ys)   ./ n_neg
  auc = 0.0
  for i in 2:length(tpr)
    auc += (fpr[i]-fpr[i-1]) * (tpr[i]+tpr[i-1]) / 2
  end
  return auc
end

# Permutation importance: mean accuracy drop when feature is shuffled
function perm_importance(predict_fn, X_te::Matrix{Float64}, y_te::Vector{Int}; reps=5)
  base = mean(predict_fn(X_te) .== y_te)
  imp  = zeros(Float64, N_FEATS)
  for f in 1:N_FEATS
    drops = Float64[]
    for _ in 1:reps
      Xp = copy(X_te)
      Xp[:,f] = shuffle(Xp[:,f])
      push!(drops, base - mean(predict_fn(Xp) .== y_te))
    end
    imp[f] = mean(drops)
  end
  return imp
end

# ---------------------------------------------------------------------------
# Gaussian Naive Bayes (from scratch via Distributions.jl)
# ---------------------------------------------------------------------------

struct GaussianNB
  log_prior :: Vector{Float64}
  mu        :: Matrix{Float64}   # [n_classes × n_feats]
  sigma     :: Matrix{Float64}
  classes   :: Vector{Int}
end

function fit_gnb(X::Matrix{Float64}, y::Vector{Int})
  classes = sort(unique(y))
  n_c, n_f = length(classes), size(X, 2)
  n = length(y)
  log_prior = [log(count(==(c), y) / n) for c in classes]
  mu    = zeros(Float64, n_c, n_f)
  sigma = zeros(Float64, n_c, n_f)
  for (ci,c) in enumerate(classes)
    Xc = X[y .== c, :]
    for f in 1:n_f
      mu[ci,f]    = mean(Xc[:,f])
      sigma[ci,f] = max(std(Xc[:,f]), 1e-9)
    end
  end
  GaussianNB(log_prior, mu, sigma, classes)
end

function gnb_log_proba(m::GaussianNB, X::Matrix{Float64})
  n, n_c = size(X,1), length(m.classes)
  lp = zeros(Float64, n, n_c)
  for i in 1:n, ci in 1:n_c
    lp[i,ci] = m.log_prior[ci]
    for f in 1:size(X,2)
      lp[i,ci] += logpdf(Normal(m.mu[ci,f], m.sigma[ci,f]), X[i,f])
    end
  end
  lp
end

function gnb_proba(m::GaussianNB, X::Matrix{Float64})
  lp = gnb_log_proba(m, X)
  probs = zeros(Float64, size(lp)...)
  for i in 1:size(lp,1)
    mx = maximum(lp[i,:]); ex = exp.(lp[i,:] .- mx)
    probs[i,:] = ex ./ sum(ex)
  end
  probs
end

function gnb_predict(m::GaussianNB, X::Matrix{Float64})
  probs = gnb_proba(m, X)
  [m.classes[argmax(probs[i,:])] for i in 1:size(X,1)]
end

# ---------------------------------------------------------------------------
# Print helpers
# ---------------------------------------------------------------------------

function print_model_table(rows, model_name)
  println("\n$(model_name) Results — Skip Prediction")
  println("─"^80)
  @printf("  %-12s  %10s  %10s  %10s  %12s  %12s\n",
          "User","Accuracy","AUC-ROC","Baseline","Improvement","Sample Size")
  println("─"^80)
  for r in rows
    @printf("  %-12s  %9.1f%%  %10.4f  %9.1f%%  %+11.1f%%  %12d\n",
            r.name, r.acc*100, r.auc, r.baseline*100,
            (r.acc-r.baseline)*100, r.n)
  end
  println("─"^80)
end

function print_importance_table(rows)
  println("\nDecision Tree — Top Feature per User (permutation importance)")
  println("─"^60)
  @printf("  %-12s  %-22s  %s\n", "User","Top Feature","Importance (acc drop)")
  println("─"^60)
  for r in rows
    @printf("  %-12s  %-22s  %.4f\n", r.name, r.top_feat, r.top_imp)
  end
  println("─"^60)
end

function print_nb_patterns(rows)
  println("\nNaive Bayes — Class-Conditional Feature Means (Skipped vs Not Skipped)")
  println("─"^90)
  hdr = @sprintf("  %-12s", "User")
  for fn in FEAT_NAMES; hdr *= @sprintf("  %12s", fn[1:min(12,end)]); end
  println(hdr)
  for r in rows
    row0 = @sprintf("  %-12s", r.name*" (no)")
    row1 = @sprintf("  %-12s", r.name*" (skip)")
    for f in 1:N_FEATS
      row0 *= @sprintf("  %12.4f", r.mu0[f])
      row1 *= @sprintf("  %12.4f", r.mu1[f])
    end
    println(row0)
    println(row1)
    diff = r.mu1 .- r.mu0
    rowd = @sprintf("  %-12s", "  Δ")
    for d in diff
      rowd *= @sprintf("  %+12.4f", d)
    end
    println(rowd)
    println()
  end
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

function main()
  mkpath(SCRIPT_DIR)

  println("Loading data from database...")
  conn   = get_connection()
  plays  = get_plays(conn)
  ap_df  = get_artist_plays(conn)
  tp_df  = get_track_plays(conn)
  gp_df  = get_genre_plays(conn)
  ag_df  = get_artist_genre_map(conn)
  close(conn)

  println("Engineering features ($(nrow(plays)) plays)...")
  println("Computing session momentum...")
  momentum = compute_session_momentum(plays)
  @printf("  momentum > 0 in %.1f%% of plays\n",
          count(>(0.0), momentum) / length(momentum) * 100)
  X, y, us = build_feature_matrix(plays, ap_df, tp_df, gp_df, ag_df, momentum)

  dt_table   = []
  dt_imp_tab = []
  nb_table   = []
  nb_pat_tab = []

  json_out = Dict{String,Any}()

  for (u, d) in zip(USER_ORDER, DISPLAY_ORDER)
    println("\n--- $d ---")
    mask = us .== u
    Xu   = X[mask, :]
    yu   = y[mask]
    n    = length(yu)

    skip_rate = mean(yu)
    baseline  = max(skip_rate, 1.0-skip_rate)

    train_idx, test_idx = stratified_split(yu)
    Xtr, ytr = Xu[train_idx, :], yu[train_idx]
    Xte, yte = Xu[test_idx,  :], yu[test_idx]

    @printf("  n=%d  skip_rate=%.1f%%  baseline=%.1f%%  train=%d  test=%d\n",
            n, skip_rate*100, baseline*100, length(train_idx), length(test_idx))

    # ---- Decision Tree (Random Forest ensemble of decision trees) ----
    rf = RandomForestClassifier(n_trees=100, max_depth=10, min_samples_leaf=10)
    fit!(rf, Xtr, ytr)

    y_pred_rf  = predict(rf, Xte)
    y_prob_rf  = predict_proba(rf, Xte)[:, 2]  # P(skip=1)
    acc_rf     = mean(y_pred_rf .== yte)
    auc_rf     = auc_roc(yte, y_prob_rf)

    pred_fn_rf = X_in -> predict(rf, X_in)
    imp_rf     = perm_importance(pred_fn_rf, Xte, yte)
    top_idx    = argmax(imp_rf)
    top_feat   = FEAT_NAMES[top_idx]
    top_imp    = imp_rf[top_idx]

    @printf("  DT (RF) accuracy=%.1f%%  AUC=%.4f  top_feat=%s (%.4f)\n",
            acc_rf*100, auc_rf, top_feat, top_imp)

    push!(dt_table,   (name=d, acc=acc_rf, auc=auc_rf, baseline=baseline, n=n))
    push!(dt_imp_tab, (name=d, top_feat=top_feat, top_imp=top_imp, importances=imp_rf))

    # ---- Gaussian Naive Bayes ----
    nb  = fit_gnb(Xtr, ytr)
    y_pred_nb = gnb_predict(nb, Xte)
    ci1 = findfirst(==(1), nb.classes)  # index for class=1 (skip)
    y_prob_nb = gnb_proba(nb, Xte)[:, ci1]
    acc_nb    = mean(y_pred_nb .== yte)
    auc_nb    = auc_roc(yte, y_prob_nb)

    ci0 = findfirst(==(0), nb.classes)
    mu0 = nb.mu[ci0, :]
    mu1 = nb.mu[ci1, :]

    @printf("  NB accuracy=%.1f%%  AUC=%.4f\n", acc_nb*100, auc_nb)

    push!(nb_table,   (name=d, acc=acc_nb, auc=auc_nb, baseline=baseline, n=n))
    push!(nb_pat_tab, (name=d, mu0=mu0, mu1=mu1))

    json_out[d] = Dict{String,Any}(
      "n" => n,
      "skip_rate" => skip_rate,
      "baseline"  => baseline,
      "decision_tree" => Dict{String,Any}(
        "accuracy"    => acc_rf,
        "auc_roc"     => auc_rf,
        "improvement" => acc_rf - baseline,
        "feature_importances" => Dict(FEAT_NAMES[f] => imp_rf[f] for f in 1:N_FEATS),
        "top_feature" => top_feat,
      ),
      "naive_bayes" => Dict{String,Any}(
        "accuracy"     => acc_nb,
        "auc_roc"      => auc_nb,
        "improvement"  => acc_nb - baseline,
        "mu_not_skipped" => Dict(FEAT_NAMES[f] => mu0[f] for f in 1:N_FEATS),
        "mu_skipped"     => Dict(FEAT_NAMES[f] => mu1[f] for f in 1:N_FEATS),
        "delta"          => Dict(FEAT_NAMES[f] => mu1[f]-mu0[f] for f in 1:N_FEATS),
      ),
    )
  end

  # Print all tables
  print_model_table(dt_table,   "Decision Tree (Random Forest)")
  println()
  println("Full feature importance rankings:")
  println("─"^70)
  @printf("  %-12s  ", "Feature")
  for d in DISPLAY_ORDER; @printf("  %12s", d); end
  println()
  println("─"^70)
  for f in 1:N_FEATS
    @printf("  %-12s  ", FEAT_NAMES[f][1:min(12,end)])
    for di in eachindex(dt_imp_tab)
      @printf("  %12.4f", dt_imp_tab[di].importances[f])
    end
    println()
  end
  println("─"^70)

  print_model_table(nb_table, "Gaussian Naive Bayes")
  print_nb_patterns(nb_pat_tab)

  save_json(joinpath(SCRIPT_DIR, "classification.json"), json_out)
end

main()
