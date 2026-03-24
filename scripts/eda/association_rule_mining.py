import os
import sys
import json
import warnings
from collections import defaultdict

import numpy as np
import pandas as pd
import psycopg2
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpec
from dotenv import load_dotenv

warnings.filterwarnings("ignore")

from mlxtend.preprocessing import TransactionEncoder
from mlxtend.frequent_patterns import apriori
from mlxtend.frequent_patterns import association_rules as mlx_rules

ENV_PATH = r"C:\Users\clips\!Code\COSC-3337\.env"
OUT_DIR = r"C:\Users\clips\!Code\COSC-3337\data\association_rule_mining"
PLOT_DIR = os.path.join(OUT_DIR, "plots")
os.makedirs(PLOT_DIR, exist_ok=True)

USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
DISPLAY = {
    "alanjzamora": "Alan",
    "alexxxxxrs": "Alexandra",
    "dasucc": "Anthony",
    "korenns": "Koren",
}
COLORS = {
    "alanjzamora": "#4C72B0",
    "alexxxxxrs": "#DD8452",
    "dasucc": "#55A868",
    "korenns": "#C44E52",
}

MIN_SESSION_ARTISTS = 3
MIN_ARTIST_SESSIONS = 10
MIN_CONFIDENCE = 0.50
MIN_LIFT = 1.50
SUPPORT_LEVELS = [0.05, 0.04, 0.03, 0.02, 0.015, 0.01]
TARGET_MIN_RULES = 50
TOP_RULES_EXPORT = 20
TOP_CLUSTERS = 5
DPI = 300


def get_conn():
    load_dotenv(ENV_PATH)
    return psycopg2.connect(os.environ["DATABASE_URL"])


def fetch_sessions(conn):
    sql = """
    WITH ordered AS (
        SELECT username,
               artist_name,
               timestamp,
               LAG(timestamp) OVER (PARTITION BY username ORDER BY timestamp) AS prev_ts
        FROM listening_history
    ),
    flagged AS (
        SELECT username,
               artist_name,
               timestamp,
               CASE
                   WHEN prev_ts IS NULL
                     OR EXTRACT(EPOCH FROM (timestamp - prev_ts)) > 1800
                   THEN 1 ELSE 0
               END AS is_new
        FROM ordered
    ),
    sessioned AS (
        SELECT username,
               artist_name,
               timestamp,
               SUM(is_new) OVER (
                   PARTITION BY username
                   ORDER BY timestamp
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
               ) AS sess_id
        FROM flagged
    )
    SELECT username,
           sess_id,
           EXTRACT(YEAR FROM MIN(timestamp))::int AS session_year,
           array_agg(DISTINCT artist_name)        AS artists
    FROM sessioned
    GROUP BY username, sess_id
    ORDER BY username, sess_id
    """
    print("Fetching sessions …")
    df = pd.read_sql(sql, conn)
    print(f"  Raw sessions fetched: {len(df):,}")
    return df


def build_transactions(sessions_df, username, year_filter=None, valid_artists=None):
    df = sessions_df[sessions_df.username == username].copy()

    if year_filter == "pre2022":
        df = df[df.session_year < 2022]
    elif year_filter == "2022-2024":
        df = df[(df.session_year >= 2022) & (df.session_year < 2025)]
    elif year_filter == "2025":
        df = df[df.session_year == 2025]

    df = df[df.artists.apply(len) >= MIN_SESSION_ARTISTS]

    if len(df) == 0:
        return [], set(), {"n_sessions": 0, "vocab_size": 0, "mean_size": 0.0}

    if valid_artists is None:
        freq = defaultdict(int)
        for arts in df.artists:
            for a in set(arts):
                freq[a] += 1
        valid_artists = {a for a, c in freq.items() if c >= MIN_ARTIST_SESSIONS}

    transactions = []
    for arts in df.artists:
        filtered = [a for a in arts if a in valid_artists]
        if len(filtered) >= MIN_SESSION_ARTISTS:
            transactions.append(filtered)

    sizes = [len(t) for t in transactions]
    stats = {
        "n_sessions": len(transactions),
        "vocab_size": len({a for t in transactions for a in t}),
        "mean_size": round(float(np.mean(sizes)), 2) if sizes else 0.0,
    }
    return transactions, valid_artists, stats


def run_apriori(transactions, min_support):
    if len(transactions) < 20:
        return None

    te = TransactionEncoder()
    te_arr = te.fit_transform(transactions)
    df_enc = pd.DataFrame(te_arr, columns=te.columns_)

    freq = apriori(df_enc, min_support=min_support, use_colnames=True, max_len=4)
    if len(freq) == 0:
        return None

    try:
        rules = mlx_rules(
            freq,
            metric="confidence",
            min_threshold=MIN_CONFIDENCE,
            num_itemsets=len(freq),
        )
    except TypeError:
        rules = mlx_rules(freq, metric="confidence", min_threshold=MIN_CONFIDENCE)

    rules = rules[rules.lift >= MIN_LIFT].copy()

    rules["conviction"] = rules.conviction.replace([np.inf], 99.9)

    return rules if len(rules) > 0 else None


def adaptive_apriori(transactions, username):
    threshold_report = []
    best_rules, best_support = None, SUPPORT_LEVELS[-1]

    for sup in SUPPORT_LEVELS:
        r = run_apriori(transactions, min_support=sup)
        n = len(r) if r is not None else 0
        threshold_report.append({"support": sup, "n_rules": n})
        print(f"    {DISPLAY[username]:10s}  sup={sup:.3f} → {n:4d} rules")

        if r is not None and n >= TARGET_MIN_RULES and best_rules is None:
            best_rules, best_support = r, sup

    if best_rules is None:
        best_rules = run_apriori(transactions, min_support=SUPPORT_LEVELS[-1])
        best_support = SUPPORT_LEVELS[-1]

    return best_rules, best_support, threshold_report


def find_clusters(rules, top_n=TOP_CLUSTERS):
    if rules is None or len(rules) == 0:
        return []

    all_artists = sorted(
        {
            a
            for _, row in rules.iterrows()
            for a in list(row.antecedents) + list(row.consequents)
        }
    )
    idx = {a: i for i, a in enumerate(all_artists)}
    parent = list(range(len(all_artists)))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for _, row in rules.iterrows():
        members = list(row.antecedents) + list(row.consequents)
        for i in range(1, len(members)):
            union(idx[members[0]], idx[members[i]])

    comp_artists = defaultdict(list)
    for a in all_artists:
        comp_artists[find(idx[a])].append(a)

    comp_rules = defaultdict(list)
    for _, row in rules.iterrows():
        root = find(idx[list(row.antecedents)[0]])
        comp_rules[root].append(row)

    clusters = []
    for root in comp_artists:
        c_rules = comp_rules.get(root, [])
        if not c_rules:
            continue
        lifts = [r.lift for r in c_rules]
        best = max(c_rules, key=lambda r: r.lift)
        clusters.append(
            {
                "artists": sorted(comp_artists[root]),
                "n_rules": len(c_rules),
                "mean_lift": round(float(np.mean(lifts)), 3),
                "max_lift": round(float(max(lifts)), 3),
                "best_antecedents": sorted(best.antecedents),
                "best_consequents": sorted(best.consequents),
                "best_lift": round(float(best.lift), 3),
            }
        )

    clusters.sort(key=lambda x: x["mean_lift"], reverse=True)
    return clusters[:top_n]


def _short_label(row, max_chars=30):
    def abbrev(artists):
        parts = [a.split()[-1] for a in sorted(artists)]
        s = " + ".join(parts)
        return s if len(s) <= 18 else s[:17] + "…"

    label = f"{abbrev(row.antecedents)} → {abbrev(row.consequents)}"
    return label if len(label) <= max_chars else label[: max_chars - 1] + "…"


def plot_scatter_all(all_rules):
    fig, axes = plt.subplots(2, 2, figsize=(15, 11))
    fig.suptitle(
        "Association Rules: Lift vs Confidence\n"
        "Point size = support  |  top-10 rules by lift x confidence labeled",
        fontsize=13,
        fontweight="bold",
        y=0.99,
    )

    for ax, username in zip(axes.flat, USER_ORDER):
        rules = all_rules.get(username)
        color = COLORS[username]

        if rules is None or len(rules) == 0:
            ax.text(
                0.5,
                0.5,
                "No rules generated",
                ha="center",
                va="center",
                transform=ax.transAxes,
                color="gray",
            )
            ax.set_title(DISPLAY[username], fontsize=11, fontweight="bold")
            continue

        sizes = (rules.support / rules.support.max()) * 180 + 15

        ax.scatter(
            rules.confidence,
            rules.lift,
            s=sizes,
            c=color,
            alpha=0.55,
            edgecolors="white",
            linewidths=0.4,
            zorder=3,
        )

        ax.axvline(0.70, color="gray", lw=0.6, ls="--", alpha=0.45)
        ax.axhline(2.50, color="gray", lw=0.6, ls="--", alpha=0.45)

        scored = rules.copy()
        scored["_score"] = scored.lift * scored.confidence
        top10 = scored.nlargest(10, "_score")

        for _, row in top10.iterrows():
            ax.annotate(
                _short_label(row),
                xy=(row.confidence, row.lift),
                xytext=(7, 3),
                textcoords="offset points",
                fontsize=5,
                color="#222222",
                arrowprops=dict(arrowstyle="-", color="#999999", lw=0.4),
            )

        ax.set_xlabel("Confidence", fontsize=9)
        ax.set_ylabel("Lift", fontsize=9)
        ax.set_title(DISPLAY[username], fontsize=11, fontweight="bold")
        ax.set_xlim(MIN_CONFIDENCE - 0.04, 1.06)
        ax.set_ylim(MIN_LIFT - 0.3, None)
        ax.tick_params(labelsize=8)
        ax.grid(True, alpha=0.25, lw=0.5)
        ax.text(
            0.02,
            0.97,
            f"n = {len(rules)} rules",
            transform=ax.transAxes,
            fontsize=8,
            va="top",
            color="gray",
        )

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    path = os.path.join(PLOT_DIR, "lift_confidence_scatter.png")
    plt.savefig(path, dpi=DPI, bbox_inches="tight")
    plt.close()
    print(f"  Saved: {path}")


def cross_user_analysis(all_rules):
    art_cons = defaultdict(lambda: defaultdict(set))
    for username, rules in all_rules.items():
        if rules is None:
            continue
        for _, row in rules.iterrows():
            for ant in row.antecedents:
                for con in row.consequents:
                    art_cons[ant][username].add(con)

    return {a: d for a, d in art_cons.items() if len(d) >= 2}


def _jaccard_dist(a, b):
    if not a and not b:
        return 0.0
    return 1.0 - len(a & b) / len(a | b)


def compute_divergence(shared):
    pairs = [(u1, u2) for i, u1 in enumerate(USER_ORDER) for u2 in USER_ORDER[i + 1 :]]
    pair_dists = defaultdict(list)
    per_artist = []

    for artist, user_cons in shared.items():
        for u1, u2 in pairs:
            if u1 in user_cons and u2 in user_cons:
                d = _jaccard_dist(user_cons[u1], user_cons[u2])
                pair_dists[(u1, u2)].append(d)
                per_artist.append(
                    {
                        "artist": artist,
                        "user1": DISPLAY[u1],
                        "user2": DISPLAY[u2],
                        "jaccard": round(d, 3),
                        "cons_u1": sorted(user_cons[u1]),
                        "cons_u2": sorted(user_cons[u2]),
                    }
                )

    matrix = np.zeros((4, 4))
    for (u1, u2), dists in pair_dists.items():
        i, j = USER_ORDER.index(u1), USER_ORDER.index(u2)
        v = float(np.mean(dists))
        matrix[i, j] = v
        matrix[j, i] = v

    per_artist.sort(key=lambda x: x["jaccard"], reverse=True)
    return matrix, per_artist


def plot_cross_user_divergence(matrix, per_artist):
    fig = plt.figure(figsize=(16, 6.5))
    gs = GridSpec(1, 2, figure=fig, width_ratios=[1, 1.6], wspace=0.38)

    ax_h = fig.add_subplot(gs[0])
    labels = [DISPLAY[u] for u in USER_ORDER]
    im = ax_h.imshow(matrix, cmap="RdYlGn_r", vmin=0, vmax=1)
    ax_h.set_xticks(range(4))
    ax_h.set_xticklabels(labels, fontsize=10)
    ax_h.set_yticks(range(4))
    ax_h.set_yticklabels(labels, fontsize=10)
    ax_h.set_title(
        "Mean Rule Divergence\n(Jaccard distance of consequent sets per shared antecedent)",
        fontsize=10,
        fontweight="bold",
    )
    plt.colorbar(im, ax=ax_h, fraction=0.046, pad=0.04)
    for i in range(4):
        for j in range(4):
            v = matrix[i, j]
            ax_h.text(
                j,
                i,
                f"{v:.2f}",
                ha="center",
                va="center",
                fontsize=10,
                color="black" if v < 0.65 else "white",
                fontweight="bold",
            )

    ax_b = fig.add_subplot(gs[1])
    top = per_artist[:15]

    if top:
        display_to_key = {v: k for k, v in DISPLAY.items()}
        y_labels = [f"{r['artist']}\n({r['user1']} vs {r['user2']})" for r in top]
        x_vals = [r["jaccard"] for r in top]
        bar_cols = [COLORS[display_to_key[r["user1"]]] for r in top]

        bars = ax_b.barh(
            range(len(top)),
            x_vals,
            color=bar_cols,
            alpha=0.78,
            edgecolor="white",
            linewidth=0.6,
        )
        ax_b.set_yticks(range(len(top)))
        ax_b.set_yticklabels(y_labels, fontsize=8)
        ax_b.invert_yaxis()
        ax_b.set_xlabel(
            "Jaccard Distance  (0 = identical associations, 1 = completely different)",
            fontsize=8.5,
        )
        ax_b.set_title(
            "Most Divergent Shared Antecedent Artists\n"
            "(same artist triggers completely different associations per user)",
            fontsize=10,
            fontweight="bold",
        )
        ax_b.set_xlim(0, 1.05)
        ax_b.axvline(0.5, color="gray", lw=0.8, ls="--", alpha=0.5)
        ax_b.grid(True, axis="x", alpha=0.25, lw=0.5)
        for bar, val in zip(bars, x_vals):
            ax_b.text(
                val + 0.01,
                bar.get_y() + bar.get_height() / 2,
                f"{val:.2f}",
                va="center",
                fontsize=8,
            )
    else:
        ax_b.text(
            0.5,
            0.5,
            "No shared antecedents found",
            ha="center",
            va="center",
            transform=ax_b.transAxes,
            color="gray",
        )

    fig.suptitle(
        "Cross-User Rule Divergence: The Same Artist, Different Listening Contexts",
        fontsize=13,
        fontweight="bold",
    )
    path = os.path.join(PLOT_DIR, "cross_user_divergence.png")
    plt.savefig(path, dpi=DPI, bbox_inches="tight")
    plt.close()
    print(f"  Saved: {path}")


def _rule_set(rules):
    if rules is None or len(rules) == 0:
        return frozenset()
    return frozenset(
        (frozenset(row.antecedents), frozenset(row.consequents))
        for _, row in rules.iterrows()
    )


def _fmt_key(key):
    ants, cons = key
    return f"{' + '.join(sorted(ants))} → {' + '.join(sorted(cons))}"


def temporal_apriori(sessions_df, username, valid_artists):
    windows = {
        "pre-2022": "pre2022",
        "2022-2024": "2022-2024",
        "2025": "2025",
    }

    period_keys = {}
    period_stats = {}

    for period_name, yf in windows.items():
        txns, _, stats = build_transactions(
            sessions_df, username, year_filter=yf, valid_artists=valid_artists
        )
        period_stats[period_name] = stats

        if stats["n_sessions"] < 30:
            print(f"    {period_name}: {stats['n_sessions']} sessions (too few, skip)")
            period_keys[period_name] = frozenset()
            continue

        rules = None
        for sup in [0.03, 0.02, 0.015, 0.01]:
            rules = run_apriori(txns, min_support=sup)
            if rules is not None and len(rules) >= 10:
                break

        n = len(rules) if rules is not None else 0
        print(f"    {period_name}: {n} rules  ({stats['n_sessions']} sessions)")
        period_keys[period_name] = _rule_set(rules)

    pre = period_keys["pre-2022"]
    mid = period_keys["2022-2024"]
    cur = period_keys["2025"]

    stable = pre & mid & cur
    new_rules = cur - pre - mid
    dissolved = pre - mid - cur

    def top_examples(key_set, n=5):
        return [_fmt_key(k) for k in sorted(key_set, key=str)[:n]]

    return {
        "n_stable": len(stable),
        "n_new": len(new_rules),
        "n_dissolved": len(dissolved),
        "n_pre2022": len(pre),
        "n_2022_2024": len(mid),
        "n_2025": len(cur),
        "stable_examples": top_examples(stable),
        "new_examples": top_examples(new_rules),
        "dissolved_examples": top_examples(dissolved),
        "period_stats": period_stats,
    }


def plot_temporal(temporal_data):
    fig, axes = plt.subplots(2, 2, figsize=(13, 8))
    fig.suptitle(
        "Temporal Rule Comparison: Stable, New, and Dissolved Listening Grammar",
        fontsize=13,
        fontweight="bold",
    )

    cat_colors = {
        "Stable\n(all 3 periods)": "#4C72B0",
        "New\n(2025 only)": "#55A868",
        "Dissolved\n(pre-2022 only)": "#C44E52",
    }

    for ax, username in zip(axes.flat, USER_ORDER):
        data = temporal_data.get(username, {})
        cats = list(cat_colors.keys())
        vals = [
            data.get("n_stable", 0),
            data.get("n_new", 0),
            data.get("n_dissolved", 0),
        ]
        cols = list(cat_colors.values())

        bars = ax.bar(
            cats,
            vals,
            color=cols,
            alpha=0.82,
            edgecolor="white",
            linewidth=0.8,
            width=0.55,
        )
        for bar, val in zip(bars, vals):
            ax.text(
                bar.get_x() + bar.get_width() / 2,
                bar.get_height() + max(vals) * 0.02 + 0.5,
                str(val),
                ha="center",
                va="bottom",
                fontsize=10,
                fontweight="bold",
            )

        ax.set_title(DISPLAY[username], fontsize=11, fontweight="bold")
        ax.set_ylabel("Number of Rules", fontsize=9)
        ax.tick_params(labelsize=9)
        ax.grid(True, axis="y", alpha=0.25, lw=0.5)
        ax.set_ylim(0, max(vals) * 1.25 + 2 if any(vals) else 10)

        n_pre = data.get("n_pre2022", 0)
        n_mid = data.get("n_2022_2024", 0)
        n_cur = data.get("n_2025", 0)
        ax.text(
            0.97,
            0.97,
            f"pre-2022: {n_pre}\n2022-24: {n_mid}\n2025: {n_cur}",
            transform=ax.transAxes,
            fontsize=8,
            va="top",
            ha="right",
            color="gray",
        )

    plt.tight_layout()
    path = os.path.join(PLOT_DIR, "temporal_comparison.png")
    plt.savefig(path, dpi=DPI, bbox_inches="tight")
    plt.close()
    print(f"  Saved: {path}")


def _rule_english(row):
    ants = sorted(row.antecedents)
    cons = sorted(row.consequents)
    ant_str = " + ".join(f'"{a}"' for a in ants)
    con_str = " + ".join(f'"{c}"' for c in cons)
    conv = float(row.conviction)
    return (
        f"When listening to {ant_str}, also listen to {con_str} "
        f"(support={row.support:.3f}, confidence={row.confidence:.3f}, "
        f"lift={row.lift:.2f}, conviction={conv:.2f})"
    )


def format_top_rules(rules, n=TOP_RULES_EXPORT):
    if rules is None or len(rules) == 0:
        return []
    top = rules.nlargest(n, "lift")
    results = []
    for _, row in top.iterrows():
        results.append(
            {
                "antecedents": sorted(row.antecedents),
                "consequents": sorted(row.consequents),
                "support": round(float(row.support), 4),
                "confidence": round(float(row.confidence), 4),
                "lift": round(float(row.lift), 4),
                "leverage": round(float(row.leverage), 6),
                "conviction": round(float(row.conviction), 3),
                "english": _rule_english(row),
            }
        )
    return results


def main():
    conn = get_conn()
    sessions_df = fetch_sessions(conn)
    conn.close()

    print("\nTransaction Database & Apriori Threshold Sweep")
    tx_summary = {}
    threshold_reports = {}
    all_rules = {}
    all_valid = {}

    for username in USER_ORDER:
        print(f"\n  [{DISPLAY[username]}]")
        txns, valid_artists, stats = build_transactions(sessions_df, username)
        all_valid[username] = valid_artists
        tx_summary[username] = {
            **stats,
            "username": username,
            "display": DISPLAY[username],
        }

        print(f"    Transactions : {stats['n_sessions']:,}")
        print(f"    Vocabulary   : {stats['vocab_size']} artists")
        print(f"    Mean size    : {stats['mean_size']:.1f} artists/session")
        print(f"    Threshold sweep:")

        rules, best_sup, thresh = adaptive_apriori(txns, username)
        threshold_reports[username] = thresh
        all_rules[username] = rules
        n_final = len(rules) if rules is not None else 0
        print(
            f"    → selected support={best_sup:.3f} → {n_final} rules "
            f"(conf≥{MIN_CONFIDENCE}, lift≥{MIN_LIFT})"
        )

    print("\nListening Clusters (by connected artist components)")
    all_clusters = {}
    for username in USER_ORDER:
        clusters = find_clusters(all_rules[username])
        all_clusters[username] = clusters
        print(f"\n  {DISPLAY[username]} — Top {len(clusters)} clusters:")
        for i, c in enumerate(clusters, 1):
            arts = ", ".join(c["artists"][:6])
            if len(c["artists"]) > 6:
                arts += f" (+{len(c['artists']) - 6} more)"
            print(
                f"    #{i}  [{c['n_rules']} rules, mean lift {c['mean_lift']:.2f}]  {arts}"
            )

    print("\nLift vs Confidence Scatter Plots")
    plot_scatter_all(all_rules)

    print("\nCross-User Rule Divergence")
    shared = cross_user_analysis(all_rules)
    print(f"  Shared antecedent artists (rules of ≥2 users): {len(shared)}")

    div_matrix, per_artist = compute_divergence(shared)
    plot_cross_user_divergence(div_matrix, per_artist)

    print("  Mean Jaccard divergence matrix:")
    header = "              " + "  ".join(f"{DISPLAY[u]:10s}" for u in USER_ORDER)
    print(f"  {header}")
    for i, u in enumerate(USER_ORDER):
        row_str = "  ".join(f"{div_matrix[i, j]:.3f}     " for j in range(4))
        print(f"  {DISPLAY[u]:14s}{row_str}")

    print("\nTemporal Apriori (pre-2022 / 2022-2024 / 2025)")
    temporal_data = {}
    for username in USER_ORDER:
        print(f"\n  [{DISPLAY[username]}]")
        data = temporal_apriori(sessions_df, username, all_valid[username])
        temporal_data[username] = data
        print(
            f"    Stable: {data['n_stable']}  |  New: {data['n_new']}  |  "
            f"Dissolved: {data['n_dissolved']}"
        )
        if data["stable_examples"]:
            print("    Stable examples:")
            for ex in data["stable_examples"][:3]:
                print(f"      · {ex}")
        if data["new_examples"]:
            print("    New (2025) examples:")
            for ex in data["new_examples"][:3]:
                print(f"      · {ex}")
        if data["dissolved_examples"]:
            print("    Dissolved (gone by 2025) examples:")
            for ex in data["dissolved_examples"][:3]:
                print(f"      · {ex}")

    plot_temporal(temporal_data)

    print("\nTop Rules per User (by lift)")
    top_rules_by_user = {}
    for username in USER_ORDER:
        top = format_top_rules(all_rules[username])
        top_rules_by_user[username] = top
        print(f"\n  {DISPLAY[username]} ({len(top)} rules shown):")
        for i, r in enumerate(top, 1):
            print(f"    {i:2d}. {r['english']}")

    print("\nSaving JSON outputs")

    def _save(obj, filename):
        path = os.path.join(OUT_DIR, filename)
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(obj, fh, indent=2, ensure_ascii=False)
        print(f"  {path}")

    _save(
        {u: tx_summary[u] for u in USER_ORDER},
        "transaction_summary.json",
    )

    _save(
        {u: threshold_reports[u] for u in USER_ORDER},
        "threshold_report.json",
    )

    for username in USER_ORDER:
        _save(
            top_rules_by_user[username], f"top{TOP_RULES_EXPORT}_rules_{username}.json"
        )

    _save(
        {u: all_clusters[u] for u in USER_ORDER},
        "clusters.json",
    )

    _save(
        {
            "shared_antecedent_artists": len(shared),
            "mean_jaccard_matrix": {
                DISPLAY[u]: {
                    DISPLAY[v]: round(float(div_matrix[i, j]), 3)
                    for j, v in enumerate(USER_ORDER)
                }
                for i, u in enumerate(USER_ORDER)
            },
            "top_divergent_pairs": per_artist[:40],
        },
        "cross_user_divergence.json",
    )

    _save(
        {
            DISPLAY[u]: {
                "n_stable": temporal_data[u]["n_stable"],
                "n_new": temporal_data[u]["n_new"],
                "n_dissolved": temporal_data[u]["n_dissolved"],
                "n_pre2022": temporal_data[u]["n_pre2022"],
                "n_2022_2024": temporal_data[u]["n_2022_2024"],
                "n_2025": temporal_data[u]["n_2025"],
                "stable_examples": temporal_data[u]["stable_examples"],
                "new_examples": temporal_data[u]["new_examples"],
                "dissolved_examples": temporal_data[u]["dissolved_examples"],
            }
            for u in USER_ORDER
        },
        "temporal_rules.json",
    )


if __name__ == "__main__":
    main()
