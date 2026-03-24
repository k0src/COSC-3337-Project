import os
import json
import numpy as np
import psycopg2
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from scipy.cluster.hierarchy import linkage, dendrogram
from scipy.spatial.distance import pdist
from dotenv import load_dotenv

DATA_DIR = r"C:\Users\clips\!Code\COSC-3337\data"
SCRIPT_DIR = os.path.join(DATA_DIR, "hierarchical_clustering_users")
PLOTS_DIR = os.path.join(SCRIPT_DIR, "plots")
ENV_PATH = os.path.join(DATA_DIR, "..", ".env")

USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

PERIODS = [
    ("alltime", None),
    ("2024", 2024),
    ("2025", 2025),
]

FEATURE_NAMES = [
    "skip_rate",
    "shuffle_rate",
    "offline_rate",
    "avg_min_played",
    "artist_entropy",
    "top1_artist_share",
]


def get_connection():
    load_dotenv(ENV_PATH)
    url = os.environ["DATABASE_URL"]
    return psycopg2.connect(url)


def fetch(conn, query) -> list[dict]:
    with conn.cursor() as cur:
        cur.execute(query)
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, row)) for row in cur.fetchall()]


def get_basic(conn, year: int | None) -> list[dict]:
    yf = f"AND EXTRACT(YEAR FROM timestamp) = {year}" if year else ""
    return fetch(
        conn,
        f"""
        SELECT
            username,
            AVG(skipped::int)::float     AS skip_rate,
            AVG(shuffle::int)::float     AS shuffle_rate,
            AVG(offline::int)::float     AS offline_rate,
            AVG(ms_played / 60000.0)     AS avg_min_played
        FROM  listening_history
        WHERE artist_name IS NOT NULL {yf}
        GROUP BY username
    """,
    )


def get_artist_dist(conn, year: int | None) -> list[dict]:
    yf = f"AND EXTRACT(YEAR FROM timestamp) = {year}" if year else ""
    return fetch(
        conn,
        f"""
        SELECT username, artist_name, COUNT(*)::int AS plays
        FROM  listening_history
        WHERE artist_name IS NOT NULL {yf}
        GROUP BY username, artist_name
    """,
    )


def artist_metrics(dist_rows: list[dict], username: str) -> tuple[float, float]:
    counts = np.array(
        [r["plays"] for r in dist_rows if r["username"] == username], dtype=float
    )
    if len(counts) == 0:
        return 0.0, 0.0
    ps = counts / counts.sum()
    h = -np.sum(ps * np.log2(ps + 1e-12))
    top1 = counts.max() / counts.sum()
    return h, top1


def build_features(basic_rows: list[dict], dist_rows: list[dict]) -> np.ndarray:
    basic_map = {r["username"]: r for r in basic_rows}
    n_feat = len(FEATURE_NAMES)
    X = np.zeros((n_feat, len(USER_ORDER)))

    for i, username in enumerate(USER_ORDER):
        if username not in basic_map:
            continue
        row = basic_map[username]
        h, top1 = artist_metrics(dist_rows, username)
        X[:, i] = [
            float(row["skip_rate"]),
            float(row["shuffle_rate"]),
            float(row["offline_rate"]),
            float(row["avg_min_played"]),
            h,
            top1,
        ]
    return X


def standardise(X: np.ndarray) -> np.ndarray:
    mu = X.mean(axis=1, keepdims=True)
    sig = X.std(axis=1, keepdims=True)
    sig[sig == 0] = 1.0
    return (X - mu) / sig


def print_period(label: str, X_raw: np.ndarray, Z: np.ndarray):
    print(f"=== {label} ===")
    print(f"  {'feature':<18}", end="")
    for d in DISPLAY_ORDER:
        print(f"  {d:>10}", end="")
    print()
    for fi, fname in enumerate(FEATURE_NAMES):
        print(f"  {fname:<18}", end="")
        for ui in range(len(USER_ORDER)):
            print(f"  {X_raw[fi, ui]:>10.3f}", end="")
        print()
    print()


SPINE_COLOR = "#cccccc"


def style_ax(ax):
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_color(SPINE_COLOR)
    ax.spines["bottom"].set_color(SPINE_COLOR)
    ax.tick_params(colors="#444444")
    ax.yaxis.label.set_color("#444444")
    ax.xaxis.label.set_color("#444444")
    ax.title.set_color("#222222")


def plot_dendrogram_single(Z, label: str, fname: str):
    fig, ax = plt.subplots(figsize=(5.4, 4.6), facecolor="white")
    ax.set_facecolor("white")

    dendrogram(
        Z,
        labels=DISPLAY_ORDER,
        ax=ax,
        color_threshold=0,
        above_threshold_color="#4878CF",
        link_color_func=lambda _: "#4878CF",
    )

    ax.set_title(
        f"User Similarity — {label}\n(Ward linkage, Euclidean)", fontsize=12, pad=10
    )
    ax.set_ylabel("Ward Distance", fontsize=10)
    ax.tick_params(axis="x", labelsize=11)
    style_ax(ax)

    fig.tight_layout()
    fig.savefig(fname, dpi=300, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(f"  plot saved: {fname}")


def plot_combined(all_Z: dict, fname: str):
    fig, axes = plt.subplots(1, 3, figsize=(11.5, 5.0), facecolor="white")
    fig.suptitle(
        "User Similarity — Hierarchical Clustering (Ward, Euclidean)\nAll Behavioral Metrics",
        fontsize=13,
        y=1.01,
    )

    for ax, (label, _) in zip(axes, PERIODS):
        Z = all_Z[label]
        ax.set_facecolor("white")
        dendrogram(
            Z,
            labels=DISPLAY_ORDER,
            ax=ax,
            color_threshold=0,
            above_threshold_color="#4878CF",
            link_color_func=lambda _: "#4878CF",
        )
        ax.set_title(label, fontsize=11)
        ax.set_ylabel("Ward Distance" if ax is axes[0] else "", fontsize=9)
        ax.tick_params(axis="x", labelsize=10)
        style_ax(ax)

    fig.tight_layout()
    fig.savefig(fname, dpi=300, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(f"  plot saved: {fname}")


def save_json(path: str, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    print(f"Data saved to {path}")


def main():
    os.makedirs(PLOTS_DIR, exist_ok=True)

    conn = get_connection()
    all_Z = {}
    out = {}

    for label, year in PERIODS:
        print(f"Computing {label}...")
        basic_rows = get_basic(conn, year)
        dist_rows = get_artist_dist(conn, year)

        X_raw = build_features(basic_rows, dist_rows)
        X_std = standardise(X_raw)

        Z = linkage(X_std.T, method="ward", metric="euclidean")
        all_Z[label] = Z

        print_period(label, X_raw, Z)

        fname_single = os.path.join(
            PLOTS_DIR, f"hierarchical_clustering_users_{label}.png"
        )
        plot_dendrogram_single(Z, label, fname_single)

        D = pdist(X_std.T, metric="euclidean")
        from scipy.spatial.distance import squareform

        D_sq = squareform(D).tolist()

        out[label] = {
            "features": FEATURE_NAMES,
            "users": DISPLAY_ORDER,
            "feature_matrix": {
                DISPLAY_ORDER[i]: {
                    FEATURE_NAMES[j]: float(X_raw[j, i])
                    for j in range(len(FEATURE_NAMES))
                }
                for i in range(len(USER_ORDER))
            },
            "distance_matrix": D_sq,
            "linkage_matrix": Z.tolist(),
        }

    conn.close()

    plot_combined(
        all_Z, os.path.join(PLOTS_DIR, "hierarchical_clustering_users_combined.png")
    )
    save_json(os.path.join(SCRIPT_DIR, "hierarchical_clustering_users.json"), out)


if __name__ == "__main__":
    main()
