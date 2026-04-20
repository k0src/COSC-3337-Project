import { useState, useMemo } from "react";
import { useData } from "@hooks";
import { DISPLAY_NAME_TO_USERNAME } from "@types";
import type { DisplayName, Username } from "@types";
import styles from "./GenreFirstAppearance.module.css";

interface GenreEntry {
  genre: string;
  play_count: number;
  first_seen: string;
  year_frac: number;
}

type AllData = Record<Username, GenreEntry[]>;

interface GenreFirstAppearanceProps {
  mainUser: DisplayName;
}

const USER_HEX: Record<string, string> = {
  Alan: "#10b981",
  Anthony: "#06b6d4",
  Alexandra: "#f97316",
  Koren: "#d86fa8",
};

const MAX_LABEL = 18;
function truncate(s: string) {
  return s.length > MAX_LABEL ? s.slice(0, MAX_LABEL - 1) + "\u2026" : s;
}

const ROW_H = 24;
const LABEL_W = 132;
const RIGHT_PAD = 16;
const CHART_W = 400;
const DOT_AREA_W = CHART_W - LABEL_W - RIGHT_PAD;
const AXIS_H = 26;
const TOP_PAD = 8;
const DOT_R = 4;

const X_MIN = 2019.5;
const X_MAX = 2026;

const X_TICKS = [2020, 2021, 2022, 2023, 2024, 2025];

function toX(yearFrac: number): number {
  return LABEL_W + ((yearFrac - X_MIN) / (X_MAX - X_MIN)) * DOT_AREA_W;
}

export default function GenreFirstAppearance({
  mainUser,
}: GenreFirstAppearanceProps) {
  const [tooltip, setTooltip] = useState<{
    genre: string;
    firstSeen: string;
    playCount: number;
    x: number;
    y: number;
  } | null>(null);

  const hex = USER_HEX[mainUser] ?? "#8b5cf6";
  const { data, loading } = useData<AllData>("genre_first_appearance/alltime");

  const mainUsername = DISPLAY_NAME_TO_USERNAME[mainUser] as Username;

  const chartData = useMemo(() => {
    if (!data) return [];
    return (data[mainUsername] ?? []).map((entry) => ({
      genre: entry.genre,
      label: truncate(entry.genre),
      playCount: entry.play_count,
      firstSeen: entry.first_seen,
      yearFrac: entry.year_frac,
    }));
  }, [data, mainUsername]);

  const n = chartData.length;
  const svgH = TOP_PAD + n * ROW_H + AXIS_H;

  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  const dotFill = `rgba(${r},${g},${b},0.85)`;

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: hex }}>
          Recent Genres
        </h2>
      </div>

      <div className={styles.card}>
        <p className={styles.description}>
          30 most recently discovered genres and when they first appeared
        </p>
        {loading || !data ? (
          <div className={styles.placeholder} />
        ) : (
          <svg
            viewBox={`0 0 ${CHART_W} ${svgH}`}
            width="100%"
            style={{ display: "block" }}
          >
            {X_TICKS.map((yr) => {
              const x = toX(yr);
              return (
                <line
                  key={`grid-${yr}`}
                  x1={x}
                  y1={TOP_PAD}
                  x2={x}
                  y2={TOP_PAD + n * ROW_H}
                  stroke="var(--color-border-subtle)"
                  strokeWidth={1}
                  strokeDasharray="3 3"
                />
              );
            })}

            {chartData.map((row, i) => {
              const y = TOP_PAD + i * ROW_H + ROW_H / 2;
              const x = toX(row.yearFrac);
              return (
                <g key={row.genre}>
                  <text
                    x={LABEL_W - 8}
                    y={y + 4}
                    textAnchor="end"
                    fontSize={10}
                    fill="var(--color-text-muted)"
                    fontFamily="var(--font-family)"
                  >
                    {row.label}
                  </text>
                  <line
                    x1={LABEL_W}
                    y1={y}
                    x2={x}
                    y2={y}
                    stroke={`rgba(${r},${g},${b},0.2)`}
                    strokeWidth={1}
                  />
                  <circle
                    cx={x}
                    cy={y}
                    r={DOT_R}
                    fill={dotFill}
                    className={styles.dot}
                    onMouseMove={(e) =>
                      setTooltip({
                        genre: row.genre,
                        firstSeen: row.firstSeen,
                        playCount: row.playCount,
                        x: e.clientX,
                        y: e.clientY,
                      })
                    }
                    onMouseLeave={() => setTooltip(null)}
                  />
                </g>
              );
            })}

            <line
              x1={LABEL_W}
              y1={TOP_PAD + n * ROW_H}
              x2={CHART_W - RIGHT_PAD}
              y2={TOP_PAD + n * ROW_H}
              stroke="var(--color-border-subtle)"
              strokeWidth={1}
            />

            {X_TICKS.map((yr) => {
              const x = toX(yr);
              return (
                <text
                  key={`tick-${yr}`}
                  x={x}
                  y={TOP_PAD + n * ROW_H + 16}
                  textAnchor="middle"
                  fontSize={10}
                  fill="var(--color-text-muted)"
                  fontFamily="var(--font-family)"
                >
                  {yr}
                </text>
              );
            })}
          </svg>
        )}
      </div>

      {tooltip && (
        <div
          className={styles.tooltip}
          style={{ left: tooltip.x + 12, top: tooltip.y - 10 }}
        >
          <span className={styles.tooltipTitle}>{tooltip.genre}</span>
          <div className={styles.tooltipRow}>
            <span className={styles.tooltipLabel}>First seen</span>
            <span className={styles.tooltipValue}>{tooltip.firstSeen}</span>
          </div>
          <div className={styles.tooltipRow}>
            <span className={styles.tooltipLabel}>Total plays</span>
            <span className={styles.tooltipValue}>
              {tooltip.playCount.toLocaleString()}
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
