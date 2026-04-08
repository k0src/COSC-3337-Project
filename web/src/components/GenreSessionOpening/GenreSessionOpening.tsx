import { useState, useMemo } from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { TimePeriodSelector } from "@components";
import { useData } from "@hooks";
import { USERS, DISPLAY_NAME_TO_USERNAME } from "@types";
import type { DisplayName, TimePeriod, Username } from "@types";
import styles from "./GenreSessionOpening.module.css";

interface GenreEntry {
  genre: string;
  n_sessions: number;
}

type SessionData = Record<Username, GenreEntry[]>;

interface GenreSessionOpeningProps {
  mainUser: DisplayName;
}

const tooltipStyle: React.CSSProperties = {
  backgroundColor: "var(--color-bg-card)",
  border: "1px solid var(--color-border)",
  borderRadius: "var(--radius-md)",
  fontSize: "var(--font-size-sm)",
};

const MAX_LABEL = 16;
function truncate(s: string) {
  return s.length > MAX_LABEL ? s.slice(0, MAX_LABEL - 1) + "…" : s;
}

export default function GenreSessionOpening({ mainUser }: GenreSessionOpeningProps) {
  const [period, setPeriod] = useState<TimePeriod>("2025");

  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;
  const mainUser_ = USERS.find((u) => u.displayName === mainUser);
  const { data, loading } = useData<SessionData>(`genre_session_opening/${period}`);

  const mainUsername = DISPLAY_NAME_TO_USERNAME[mainUser] as Username;

  const chartData = useMemo(() => {
    if (!data) return [];
    return (data[mainUsername] ?? []).map((entry) => ({
      genre: entry.genre,
      label: truncate(entry.genre),
      sessions: entry.n_sessions,
    }));
  }, [data, mainUsername]);

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
          Session Opening Genres
        </h2>
        <TimePeriodSelector value={period} onChange={setPeriod} />
      </div>

      <div className={styles.card}>
        <p className={styles.description}>
          Genres most often played first in a listening session
        </p>
        {loading || !data ? (
          <div className={styles.placeholder} />
        ) : (
          <ResponsiveContainer width="100%" height={chartData.length * 28 + 20}>
            <BarChart
              layout="vertical"
              data={chartData}
              margin={{ top: 0, right: 16, left: 0, bottom: 0 }}
              barCategoryGap="20%"
            >
              <CartesianGrid
                strokeDasharray="3 3"
                horizontal={false}
                stroke="var(--color-border-subtle)"
              />
              <XAxis
                type="number"
                fontSize={11}
                tick={{ fill: "var(--color-text-muted)" }}
                axisLine={false}
                tickLine={false}
              />
              <YAxis
                type="category"
                dataKey="label"
                width={Math.max(...chartData.map((r) => r.label.length)) * 7 + 8}
                fontSize={11}
                tick={{ fill: "var(--color-text-muted)" }}
                axisLine={false}
                tickLine={false}
                interval={0}
              />
              <Tooltip
                contentStyle={tooltipStyle}
                cursor={{ fill: "rgba(255,255,255,0.04)" }}
                labelFormatter={(label) => {
                  const row = chartData.find((r) => r.label === label);
                  return row ? row.genre : String(label);
                }}
                formatter={(value) => [value, "Sessions opened"]}
              />
              <Bar
                dataKey="sessions"
                name="Sessions opened"
                fill={mainUser_?.color}
                radius={[0, 3, 3, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        )}
      </div>
    </div>
  );
}
