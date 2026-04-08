import { useState, useCallback } from "react";
import { useData } from "@hooks";
import { USERS, DISPLAY_NAME_TO_USERNAME } from "@types";
import type { DisplayName, Username } from "@types";
import styles from "./GenreTransitionMatrix.module.css";

interface TransitionData {
  genres: string[];
  matrix: number[][];
  counts: number[][];
}

type AllData = Record<Username, TransitionData>;

interface GenreTransitionMatrixProps {
  mainUser: DisplayName;
}

const USER_HEX: Record<string, string> = {
  Alan: "#10b981",
  Anthony: "#06b6d4",
  Alexandra: "#f97316",
  Koren: "#d86fa8",
};

function matrixMax(matrix: number[][]): number {
  let max = 0;
  for (const row of matrix) for (const v of row) if (v > max) max = v;
  return max;
}

function cellFill(hex: string, value: number, maxValue: number): string {
  const ratio = maxValue > 0 ? value / maxValue : 0;
  const opacity = 0.08 + 0.92 * ratio;
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r},${g},${b},${opacity.toFixed(2)})`;
}

const CELL = 34;
const GAP = 1;
const ROW_LABEL_W = 70;
const COL_LABEL_H = 52;

function truncRow(s: string) {
  return s.length > 11 ? s.slice(0, 10) + "…" : s;
}
function truncCol(s: string) {
  return s.length > 10 ? s.slice(0, 9) + "…" : s;
}

export default function GenreTransitionMatrix({
  mainUser,
}: GenreTransitionMatrixProps) {
  const [tooltip, setTooltip] = useState<{
    from: string;
    to: string;
    prob: number;
    count: number;
    x: number;
    y: number;
  } | null>(null);

  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;
  const { data, loading } = useData<AllData>("genre_transition/2025");

  const handleMove = useCallback(
    (
      from: string,
      to: string,
      prob: number,
      count: number,
      e: React.MouseEvent,
    ) => {
      setTooltip({ from, to, prob, count, x: e.clientX, y: e.clientY });
    },
    [],
  );
  const handleLeave = useCallback(() => setTooltip(null), []);

  if (loading || !data) {
    return (
      <div className={styles.section}>
        <div className={styles.toolbar}>
          <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
            Genre Transition Matrix
          </h2>
        </div>
      </div>
    );
  }

  const username = DISPLAY_NAME_TO_USERNAME[mainUser] as Username;
  const userData = data[username];
  if (!userData) return null;

  const { genres, matrix, counts } = userData;
  const n = genres.length;
  const hex = USER_HEX[mainUser] || "#8b5cf6";
  const maxVal = matrixMax(matrix);

  const svgW = ROW_LABEL_W + n * (CELL + GAP);
  const svgH = COL_LABEL_H + n * (CELL + GAP);

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
          Genre Transition Matrix
        </h2>
      </div>

      <div className={styles.card}>
        <p className={styles.description}>
          Probability of playing one genre after another (row to column)
        </p>
        <svg
          viewBox={`0 0 ${svgW} ${svgH}`}
          width="100%"
          style={{ display: "block" }}
        >
          {genres.map((genre, ci) => {
            const x = ROW_LABEL_W + ci * (CELL + GAP) + CELL / 2;
            const y = COL_LABEL_H - 10;
            return (
              <text
                key={`col-${ci}`}
                x={x}
                y={y}
                textAnchor="start"
                dominantBaseline="middle"
                fontSize="10"
                fill="var(--color-text-muted)"
                fontFamily="var(--font-family)"
                transform={`rotate(-45, ${x}, ${y})`}
              >
                {truncCol(genre)}
              </text>
            );
          })}

          {genres.map((genre, ri) => (
            <text
              key={`row-${ri}`}
              x={ROW_LABEL_W - 6}
              y={COL_LABEL_H + ri * (CELL + GAP) + CELL / 2 + 4}
              textAnchor="end"
              fontSize="10"
              fill="var(--color-text-muted)"
              fontFamily="var(--font-family)"
            >
              {truncRow(genre)}
            </text>
          ))}

          {genres.map((fromGenre, ri) =>
            genres.map((toGenre, ci) => {
              const val = matrix[ri]?.[ci] ?? 0;
              const count = counts[ri]?.[ci] ?? 0;
              return (
                <rect
                  key={`${ri}-${ci}`}
                  x={ROW_LABEL_W + ci * (CELL + GAP)}
                  y={COL_LABEL_H + ri * (CELL + GAP)}
                  width={CELL}
                  height={CELL}
                  rx={2}
                  fill={cellFill(hex, val, maxVal)}
                  className={styles.cell}
                  onMouseMove={(e) =>
                    handleMove(fromGenre, toGenre, val, count, e)
                  }
                  onMouseLeave={handleLeave}
                />
              );
            }),
          )}
        </svg>
      </div>

      {tooltip && (
        <div
          className={styles.tooltip}
          style={{ left: tooltip.x + 12, top: tooltip.y - 10 }}
        >
          <span className={styles.tooltipTitle}>
            {tooltip.from} to {tooltip.to}
          </span>
          <div className={styles.tooltipRow}>
            <span className={styles.tooltipLabel}>Probability</span>
            <span className={styles.tooltipValue}>
              {(tooltip.prob * 100).toFixed(1)}%
            </span>
          </div>
          <div className={styles.tooltipRow}>
            <span className={styles.tooltipLabel}>Count</span>
            <span className={styles.tooltipValue}>
              {tooltip.count.toLocaleString()}
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
