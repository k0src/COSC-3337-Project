import { useState, useCallback } from "react";
import { TimePeriodSelector } from "@components";
import { useData } from "@hooks";
import { USERS, DISPLAY_NAME_TO_USERNAME } from "@types";
import type { DisplayName, TimePeriod, Username } from "@types";
import styles from "./GenreShareDow.module.css";

interface GenreShareData {
  genres: string[];
  dow: {
    labels: string[];
    matrix: number[][];
  };
}

type AllData = Record<Username, GenreShareData>;

interface GenreShareDowProps {
  mainUser: DisplayName;
}

const USER_HEX: Record<string, string> = {
  Alan: "#10b981",
  Anthony: "#06b6d4",
  Alexandra: "#f97316",
  Koren: "#d86fa8",
};

const MAX_GENRE_LEN = 14;
function truncate(s: string) {
  return s.length > MAX_GENRE_LEN ? s.slice(0, MAX_GENRE_LEN - 1) + "…" : s;
}

function cellFill(hex: string, value: number, maxValue: number): string {
  const ratio = maxValue > 0 ? value / maxValue : 0;
  const opacity = 0.1 + 0.9 * ratio;
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r},${g},${b},${opacity.toFixed(2)})`;
}

function matrixMax(matrix: number[][]): number {
  let max = 0;
  for (const row of matrix) for (const v of row) if (v > max) max = v;
  return max;
}

const CELL_W = 32;
const CELL_H = 18;
const GAP = 2;
const LABEL_W = 90;
const HEADER_H = 20;

export default function GenreShareDow({ mainUser }: GenreShareDowProps) {
  const [period, setPeriod] = useState<TimePeriod>("2025");
  const [tooltip, setTooltip] = useState<{
    genre: string;
    day: string;
    value: number;
    x: number;
    y: number;
  } | null>(null);

  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;
  const { data, loading } = useData<AllData>(`genre_share_time/${period}`);

  const handleMove = useCallback(
    (genre: string, day: string, value: number, e: React.MouseEvent) => {
      setTooltip({ genre, day, value, x: e.clientX, y: e.clientY });
    },
    [],
  );
  const handleLeave = useCallback(() => setTooltip(null), []);

  if (loading || !data) {
    return (
      <div className={styles.section}>
        <div className={styles.toolbar}>
          <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
            Genre Share by Day of Week
          </h2>
        </div>
      </div>
    );
  }

  const username = DISPLAY_NAME_TO_USERNAME[mainUser] as Username;
  const userData = data[username];
  if (!userData) return null;

  const { genres, dow } = userData;
  const numGenres = genres.length;
  const numDays = dow.labels.length;
  const userMax = matrixMax(userData.dow.matrix);
  const hex = USER_HEX[mainUser] || "#8b5cf6";

  const svgW = LABEL_W + numDays * (CELL_W + GAP);
  const svgH = HEADER_H + numGenres * (CELL_H + GAP);

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
          Genre Share by Day of Week
        </h2>
        <TimePeriodSelector value={period} onChange={setPeriod} />
      </div>

      <div className={styles.card}>
        <svg
          viewBox={`0 0 ${svgW} ${svgH}`}
          width="100%"
          style={{ display: "block" }}
        >
          {dow.labels.map((day, di) => (
            <text
              key={day}
              x={LABEL_W + di * (CELL_W + GAP) + CELL_W / 2}
              y={HEADER_H - 4}
              textAnchor="middle"
              fontSize="10"
              fill="var(--color-text-muted)"
              fontFamily="var(--font-family)"
            >
              {day}
            </text>
          ))}

          {genres.map((genre, gi) => {
            const rowValues = userData.dow.matrix[gi] ?? [];
            return (
              <g key={genre}>
                <text
                  x={LABEL_W - 6}
                  y={HEADER_H + gi * (CELL_H + GAP) + CELL_H / 2 + 4}
                  textAnchor="end"
                  fontSize="10"
                  fill="var(--color-text-muted)"
                  fontFamily="var(--font-family)"
                >
                  {truncate(genre)}
                </text>
                {dow.labels.map((day, di) => {
                  const val = rowValues[di] ?? 0;
                  return (
                    <rect
                      key={day}
                      x={LABEL_W + di * (CELL_W + GAP)}
                      y={HEADER_H + gi * (CELL_H + GAP)}
                      width={CELL_W}
                      height={CELL_H}
                      rx={3}
                      fill={cellFill(hex, val, userMax)}
                      className={styles.cell}
                      onMouseMove={(e) => handleMove(genre, day, val, e)}
                      onMouseLeave={handleLeave}
                    />
                  );
                })}
              </g>
            );
          })}
        </svg>
      </div>

      {tooltip && (
        <div
          className={styles.tooltip}
          style={{ left: tooltip.x + 12, top: tooltip.y - 10 }}
        >
          <span className={styles.tooltipTitle}>{tooltip.genre}</span>
          <div className={styles.tooltipRow}>
            <span className={styles.tooltipDay}>{tooltip.day}</span>
            <span className={styles.tooltipValue}>
              {(tooltip.value * 100).toFixed(1)}%
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
