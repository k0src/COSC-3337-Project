import { useState, useCallback, useMemo } from "react";
import { TimePeriodSelector, UserCompare } from "@components";
import { useData } from "@hooks";
import { USERS, DISPLAY_NAME_TO_USERNAME } from "@types";
import type { DisplayName, TimePeriod, Username } from "@types";
import styles from "./ListeningClock.module.css";

type ListeningTimesData = Record<Username, number[]>;

interface ListeningClockProps {
  mainUser: DisplayName;
}

const HOUR_LABELS = [
  "12am",
  "1am",
  "2am",
  "3am",
  "4am",
  "5am",
  "6am",
  "7am",
  "8am",
  "9am",
  "10am",
  "11am",
  "12pm",
  "1pm",
  "2pm",
  "3pm",
  "4pm",
  "5pm",
  "6pm",
  "7pm",
  "8pm",
  "9pm",
  "10pm",
  "11pm",
];

function hexToHsl(hex: string): { h: number; s: number; l: number } {
  const r = parseInt(hex.slice(1, 3), 16) / 255;
  const g = parseInt(hex.slice(3, 5), 16) / 255;
  const b = parseInt(hex.slice(5, 7), 16) / 255;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const l = (max + min) / 2;
  if (max === min) return { h: 0, s: 0, l };
  const d = max - min;
  const s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
  let h = 0;
  if (max === r) h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
  else if (max === g) h = ((b - r) / d + 2) / 6;
  else h = ((r - g) / d + 4) / 6;
  return { h: h * 360, s, l };
}

const USER_HEX: Record<string, string> = {
  Alan: "#10b981",
  Anthony: "#06b6d4",
  Alexandra: "#f97316",
  Koren: "#d86fa8",
};

function segmentColor(userName: string, ratio: number): string {
  const hex = USER_HEX[userName] || "#8b5cf6";
  const { h, s, l } = hexToHsl(hex);
  const satFactor = 0.15 + 0.85 * ratio;
  const lightness = l + (1 - ratio) * 0.08;
  return `hsl(${h}, ${(s * satFactor * 100).toFixed(1)}%, ${(Math.min(lightness, 0.85) * 100).toFixed(1)}%)`;
}

export default function ListeningClock({ mainUser }: ListeningClockProps) {
  const [period, setPeriod] = useState<TimePeriod>("2025");
  const [compareUsers, setCompareUsers] = useState<DisplayName[]>([]);
  const [hoveredHour, setHoveredHour] = useState<number | null>(null);
  const [tooltipPos, setTooltipPos] = useState<{ x: number; y: number }>({
    x: 0,
    y: 0,
  });

  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;

  const { data, loading } = useData<ListeningTimesData>(
    `listening_times/${period}`,
  );

  const handleMouseMove = useCallback((hour: number, e: React.MouseEvent) => {
    setHoveredHour(hour);
    setTooltipPos({ x: e.clientX, y: e.clientY });
  }, []);

  const handleMouseLeave = useCallback(() => {
    setHoveredHour(null);
  }, []);

  const visibleUsers = useMemo(
    () => [mainUser, ...compareUsers],
    [mainUser, compareUsers],
  );

  const { globalMax, userMaxes } = useMemo(() => {
    let gMax = 0;
    const uMaxes: Record<string, number> = {};
    if (!data) return { globalMax: 1, userMaxes: uMaxes };
    for (const name of visibleUsers) {
      const username = DISPLAY_NAME_TO_USERNAME[name];
      const hours = data[username];
      if (!hours) continue;
      let uMax = 0;
      for (const v of hours) {
        if (v > gMax) gMax = v;
        if (v > uMax) uMax = v;
      }
      uMaxes[name] = uMax;
    }
    return { globalMax: gMax || 1, userMaxes: uMaxes };
  }, [data, visibleUsers]);

  if (loading || !data) {
    return (
      <div className={styles.section}>
        <div className={styles.toolbar}>
          <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
            Listening Times
          </h2>
        </div>
      </div>
    );
  }

  const cx = 200;
  const cy = 200;
  const innerRadius = 40;
  const outerRadius = 170;
  const labelRadius = 188;

  function segmentPath(hour: number, value: number) {
    const segAngle = (2 * Math.PI) / 24;
    const startAngle = hour * segAngle - Math.PI / 2;
    const endAngle = startAngle + segAngle;
    const r = innerRadius + (value / globalMax) * (outerRadius - innerRadius);

    const x1i = cx + innerRadius * Math.cos(startAngle);
    const y1i = cy + innerRadius * Math.sin(startAngle);
    const x1o = cx + r * Math.cos(startAngle);
    const y1o = cy + r * Math.sin(startAngle);
    const x2i = cx + innerRadius * Math.cos(endAngle);
    const y2i = cy + innerRadius * Math.sin(endAngle);
    const x2o = cx + r * Math.cos(endAngle);
    const y2o = cy + r * Math.sin(endAngle);

    return `M ${x1i} ${y1i} L ${x1o} ${y1o} A ${r} ${r} 0 0 1 ${x2o} ${y2o} L ${x2i} ${y2i} A ${innerRadius} ${innerRadius} 0 0 0 ${x1i} ${y1i}`;
  }

  function fullSegmentPath(hour: number) {
    const segAngle = (2 * Math.PI) / 24;
    const startAngle = hour * segAngle - Math.PI / 2;
    const endAngle = startAngle + segAngle;
    const r = outerRadius;

    const x1i = cx + innerRadius * Math.cos(startAngle);
    const y1i = cy + innerRadius * Math.sin(startAngle);
    const x1o = cx + r * Math.cos(startAngle);
    const y1o = cy + r * Math.sin(startAngle);
    const x2i = cx + innerRadius * Math.cos(endAngle);
    const y2i = cy + innerRadius * Math.sin(endAngle);
    const x2o = cx + r * Math.cos(endAngle);
    const y2o = cy + r * Math.sin(endAngle);

    return `M ${x1i} ${y1i} L ${x1o} ${y1o} A ${r} ${r} 0 0 1 ${x2o} ${y2o} L ${x2i} ${y2i} A ${innerRadius} ${innerRadius} 0 0 0 ${x1i} ${y1i}`;
  }

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
          Listening Times
        </h2>
        <div className={styles.toolbarControls}>
          <TimePeriodSelector value={period} onChange={setPeriod} />
          <UserCompare
            mainUser={mainUser}
            selected={compareUsers}
            onChange={setCompareUsers}
          />
        </div>
      </div>

      <div className={styles.card}>
        <div className={styles.clockWrapper}>
          <svg viewBox="0 0 400 400" width="100%" height="100%">
            {HOUR_LABELS.map((label, i) => {
              const angle = (i * (2 * Math.PI)) / 24 - Math.PI / 2;
              const midAngle = angle + Math.PI / 24;
              const lx = cx + labelRadius * Math.cos(midAngle);
              const ly = cy + labelRadius * Math.sin(midAngle);
              return (
                <text
                  key={i}
                  x={lx}
                  y={ly}
                  textAnchor="middle"
                  dominantBaseline="central"
                  fill="var(--color-text-muted)"
                  fontSize="9"
                  fontFamily="var(--font-family)"
                >
                  {label}
                </text>
              );
            })}

            {[0.25, 0.5, 0.75, 1].map((frac) => {
              const r = innerRadius + frac * (outerRadius - innerRadius);
              return (
                <circle
                  key={frac}
                  cx={cx}
                  cy={cy}
                  r={r}
                  fill="none"
                  stroke="var(--color-border-subtle)"
                  strokeWidth="0.5"
                />
              );
            })}

            <circle
              cx={cx}
              cy={cy}
              r={innerRadius}
              fill="var(--color-bg-primary)"
              stroke="var(--color-border-subtle)"
              strokeWidth="0.5"
            />

            {(() => {
              const username = DISPLAY_NAME_TO_USERNAME[mainUser];
              const hours = data[username];
              if (!hours) return null;
              const uMax = userMaxes[mainUser] || 1;
              return hours.map((value, hour) => {
                const ratio = value / uMax;
                const isHovered = hoveredHour === hour;
                const fill = segmentColor(mainUser, ratio);
                return (
                  <path
                    key={`main-${hour}`}
                    d={segmentPath(hour, value)}
                    fill={fill}
                    opacity={isHovered ? 1 : 0.85}
                    stroke="var(--color-bg-card)"
                    strokeWidth="0.5"
                    filter={isHovered ? "brightness(1.1)" : undefined}
                  />
                );
              });
            })()}

            {compareUsers.map((name) => {
              const user = USERS.find((u) => u.displayName === name);
              const username = DISPLAY_NAME_TO_USERNAME[name];
              const hours = data[username];
              if (!hours || !user) return null;
              const uMax = userMaxes[name] || 1;

              return hours.map((value, hour) => {
                const ratio = value / uMax;
                const isHovered = hoveredHour === hour;
                const fill = segmentColor(name, ratio);
                return (
                  <path
                    key={`${name}-${hour}`}
                    d={segmentPath(hour, value)}
                    fill={fill}
                    opacity={isHovered ? 0.45 : 0.25}
                    stroke="var(--color-bg-card)"
                    strokeWidth="0.5"
                  />
                );
              });
            })}

            {hoveredHour !== null && (
              <path
                d={fullSegmentPath(hoveredHour)}
                fill="white"
                opacity="0.06"
                pointerEvents="none"
              />
            )}

            {Array.from({ length: 24 }, (_, hour) => (
              <path
                key={`hover-${hour}`}
                d={fullSegmentPath(hour)}
                fill="transparent"
                onMouseMove={(e) => handleMouseMove(hour, e)}
                onMouseLeave={handleMouseLeave}
              />
            ))}
          </svg>
        </div>
      </div>

      {hoveredHour !== null && (
        <div
          className={styles.tooltip}
          style={{
            left: tooltipPos.x + 12,
            top: tooltipPos.y - 10,
          }}
        >
          <span className={styles.tooltipHour}>{HOUR_LABELS[hoveredHour]}</span>
          {visibleUsers.map((name) => {
            const user = USERS.find((u) => u.displayName === name);
            const username = DISPLAY_NAME_TO_USERNAME[name];
            const hours = data[username];
            if (!hours || !user) return null;
            return (
              <div key={name} className={styles.tooltipRow}>
                <span
                  className={styles.tooltipDot}
                  style={{ backgroundColor: user.color }}
                />
                <span>{name}</span>
                <span className={styles.tooltipValue}>
                  {hours[hoveredHour].toLocaleString()}
                </span>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
