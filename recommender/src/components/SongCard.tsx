import { useState } from "react";
import styles from "./SongCard.module.css";
import { ScoredTrack } from "../types";

interface Props {
  track: ScoredTrack;
  rank: number;
}

const FAMILY_COLORS: Record<string, string> = {
  "Hip-Hop / Rap": "#a78bfa",
  "R&B": "#f472b6",
  "Soul / Funk": "#fb923c",
  Electronic: "#38bdf8",
  "House / Techno": "#2dd4bf",
  "Drum & Bass / Dubstep": "#4ade80",
  "Ambient / Lo-Fi": "#94a3b8",
  Pop: "#f9a8d4",
  "Alternative / Indie": "#fdba74",
  Rock: "#fbbf24",
  Metal: "#a3e635",
  "Punk / Emo": "#f87171",
  Jazz: "#c084fc",
  Classical: "#67e8f9",
  "Country / Folk": "#86efac",
  Latin: "#fcd34d",
  "K-Pop / J-Pop": "#f0abfc",
  Reggae: "#6ee7b7",
  Other: "#64748b",
};

function matchColor(pct: number): string {
  if (pct >= 75) return "#3ecf8e";
  if (pct >= 50) return "#f59e0b";
  return "#94a3b8";
}

function matchLabel(pct: number): string {
  if (pct >= 85) return "Excellent";
  if (pct >= 70) return "Strong";
  if (pct >= 55) return "Good";
  if (pct >= 40) return "Fair";
  return "Weak";
}

export default function SongCard({ track, rank }: Props) {
  const [expanded, setExpanded] = useState(false);

  const { genreMatch, artistAffinity, skipAvoidance, clusterAlignment } =
    track.scoreBreakdown;
  const color = matchColor(track.matchPct);

  return (
    <div className={styles.card}>
      <div className={styles.top}>
        <span className={styles.rank}>#{rank}</span>
        <div className={styles.badges}>
          {track.isNew ? (
            <span className={styles.badgeNew}>New</span>
          ) : (
            <span className={styles.badgeHeard}>
              {track.userPlayCount}× heard
            </span>
          )}
          {!track.isNew && track.userSkipRate > 0.5 && (
            <span className={styles.badgeSkip}>Often skipped</span>
          )}
        </div>
      </div>

      <div className={styles.body}>
        <div className={styles.trackInfo}>
          <p className={styles.trackName}>{track.trackName}</p>
          <p className={styles.artistName}>{track.artistName}</p>
        </div>

        <div className={styles.matchBlock} style={{ color }}>
          <span className={styles.matchPct}>{track.matchPct}%</span>
          <span className={styles.matchLabel}>
            {matchLabel(track.matchPct)}
          </span>
        </div>
      </div>

      {}
      <div className={styles.matchBarBg}>
        <div
          className={styles.matchBarFill}
          style={{ width: `${track.matchPct}%`, background: color }}
        />
      </div>

      {}
      {track.genreFamilies.length > 0 && (
        <div className={styles.genres}>
          {track.genreFamilies.map((f) => (
            <span
              key={f}
              className={styles.genreChip}
              style={{
                color: FAMILY_COLORS[f] ?? "#94a3b8",
                borderColor: (FAMILY_COLORS[f] ?? "#94a3b8") + "40",
              }}
            >
              {f}
            </span>
          ))}
        </div>
      )}

      {}
      <button
        className={styles.detailToggle}
        onClick={() => setExpanded((e) => !e)}
      >
        {expanded ? "▲ Hide breakdown" : "▼ Score breakdown"}
      </button>

      {expanded && (
        <div className={styles.breakdown}>
          <BreakdownRow
            label="Genre match"
            value={genreMatch}
            hint="Cosine similarity — track genres vs your profile"
          />
          <BreakdownRow
            label="Artist affinity"
            value={artistAffinity}
            hint="Log-normalised play count for this artist"
          />
          <BreakdownRow
            label="Skip avoidance"
            value={skipAvoidance}
            hint="1 - estimated skip probability (NB patterns)"
          />
          <BreakdownRow
            label="Cluster alignment"
            value={clusterAlignment}
            hint="K-Means genre cluster membership bonus"
          />
        </div>
      )}
    </div>
  );
}

function BreakdownRow({
  label,
  value,
  hint,
}: {
  label: string;
  value: number;
  hint: string;
}) {
  const pct = Math.round(value * 100);
  return (
    <div className={styles.bRow}>
      <div className={styles.bLabel}>
        <span>{label}</span>
        <span className={styles.bHint}>{hint}</span>
      </div>
      <div className={styles.bBarBg}>
        <div className={styles.bBarFill} style={{ width: `${pct}%` }} />
      </div>
      <span className={styles.bPct}>{pct}%</span>
    </div>
  );
}
