import { useState, useCallback, useMemo } from "react";
import classNames from "classnames";
import { TimePeriodSelector } from "@components";
import { useData } from "@hooks";
import { USERS, DISPLAY_NAME_TO_USERNAME } from "@types";
import type { DisplayName, TimePeriod, Username } from "@types";
import styles from "./CalendarHeatmap.module.css";

type HeatmapData = Record<Username, Record<string, number>>;

interface CalendarHeatmapProps {
  mainUser: DisplayName;
}

const USER_HEX: Record<string, string> = {
  Alan: "#10b981",
  Anthony: "#06b6d4",
  Alexandra: "#f97316",
  Koren: "#d86fa8",
};

const MONTH_NAMES = [
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
];

const CELL = 13;
const GAP = 2;
const STEP = CELL + GAP;
const LABEL_W = 24;
const LABEL_H = 16;

function buildCalendarCells(year: number) {
  const isLeap = (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
  const totalDays = isLeap ? 366 : 365;
  const jan1Dow = new Date(year, 0, 1).getDay();

  const cells: Array<{ date: string; week: number; dow: number }> = [];
  const monthStarts: Array<{ month: number; week: number }> = [];
  let lastMonth = -1;

  for (let d = 0; d < totalDays; d++) {
    const date = new Date(year, 0, d + 1);
    const yyyy = date.getFullYear();
    const mm = String(date.getMonth() + 1).padStart(2, "0");
    const dd = String(date.getDate()).padStart(2, "0");
    const dateStr = `${yyyy}-${mm}-${dd}`;
    const dow = date.getDay();
    const week = Math.floor((d + jan1Dow) / 7);
    const month = date.getMonth();

    if (month !== lastMonth) {
      monthStarts.push({ month, week });
      lastMonth = month;
    }
    cells.push({ date: dateStr, week, dow });
  }

  const numWeeks = Math.ceil((totalDays + jan1Dow) / 7);
  return { cells, monthStarts, numWeeks };
}

function cellFill(hex: string, value: number, maxValue: number): string {
  if (value === 0) return "var(--color-border-subtle)";
  const intensity = Math.pow(value / maxValue, 0.55);
  const opacity = 0.18 + 0.82 * intensity;
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r},${g},${b},${opacity.toFixed(2)})`;
}

const CALENDAR_PERIODS: TimePeriod[] = ["2024", "2025"];

export default function CalendarHeatmap({ mainUser }: CalendarHeatmapProps) {
  const [period, setPeriod] = useState<TimePeriod>("2025");
  const [tooltip, setTooltip] = useState<{ date: string; x: number; y: number } | null>(null);

  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;
  const { data, loading } = useData<HeatmapData>(`calendar_heatmap/${period}`);

  const year = parseInt(period);
  const { cells, monthStarts, numWeeks } = useMemo(
    () => buildCalendarCells(year),
    [year],
  );

  const username = DISPLAY_NAME_TO_USERNAME[mainUser] as Username;
  const userDates = data?.[username] || {};
  const userMax = useMemo(() => {
    const vals = Object.values(userDates);
    return vals.length > 0 ? Math.max(...vals) : 1;
  }, [userDates]);

  const hex = USER_HEX[mainUser] || "#8b5cf6";
  const svgW = LABEL_W + numWeeks * STEP;
  const svgH = LABEL_H + 7 * STEP;

  const handleEnter = useCallback((date: string, e: React.MouseEvent) => {
    setTooltip({ date, x: e.clientX, y: e.clientY });
  }, []);
  const handleMove = useCallback((date: string, e: React.MouseEvent) => {
    setTooltip({ date, x: e.clientX, y: e.clientY });
  }, []);
  const handleLeave = useCallback(() => setTooltip(null), []);

  if (loading || !data) {
    return (
      <div className={styles.section}>
        <div className={styles.toolbar}>
          <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
            Play History
          </h2>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
          Play History
        </h2>
        <TimePeriodSelector
          value={period}
          onChange={setPeriod}
          periods={CALENDAR_PERIODS}
        />
      </div>

      <div className={styles.card}>
        <div className={styles.heatmapRow}>
          <svg viewBox={`0 0 ${svgW} ${svgH}`} width="100%" style={{ display: "block" }}>
            {monthStarts.map(({ month, week }) => (
              <text
                key={month}
                x={LABEL_W + week * STEP}
                y={LABEL_H - 3}
                fontSize="9"
                fill="var(--color-text-muted)"
                fontFamily="var(--font-family)"
              >
                {MONTH_NAMES[month]}
              </text>
            ))}

            {[1, 3, 5].map((dow, i) => (
              <text
                key={dow}
                x={LABEL_W - 3}
                y={LABEL_H + dow * STEP + CELL / 2 + 3}
                fontSize="9"
                fill="var(--color-text-muted)"
                fontFamily="var(--font-family)"
                textAnchor="end"
              >
                {["M", "W", "F"][i]}
              </text>
            ))}

            {cells.map(({ date, week, dow }) => {
              const value = userDates[date] || 0;
              return (
                <rect
                  key={date}
                  x={LABEL_W + week * STEP}
                  y={LABEL_H + dow * STEP}
                  width={CELL}
                  height={CELL}
                  rx={2}
                  fill={cellFill(hex, value, userMax)}
                  className={classNames({ [styles.cellHover]: value > 0 })}
                  onMouseEnter={(e) => handleEnter(date, e)}
                  onMouseMove={(e) => handleMove(date, e)}
                  onMouseLeave={handleLeave}
                />
              );
            })}
          </svg>
        </div>
      </div>

      {tooltip && (
        <div
          className={styles.tooltip}
          style={{ left: tooltip.x + 12, top: tooltip.y - 10 }}
        >
          <span className={styles.tooltipDate}>
            {new Date(tooltip.date + "T12:00:00").toLocaleDateString("en-US", {
              weekday: "short",
              month: "short",
              day: "numeric",
              year: "numeric",
            })}
          </span>
          <div className={styles.tooltipRow}>
            <span
              className={styles.tooltipDot}
              style={{ backgroundColor: mainUserColor }}
            />
            <span>{mainUser}</span>
            <span className={styles.tooltipValue}>
              {(userDates[tooltip.date] || 0).toLocaleString()}
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
