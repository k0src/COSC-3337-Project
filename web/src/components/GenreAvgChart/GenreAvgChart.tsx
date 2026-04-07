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
import styles from "./GenreAvgChart.module.css";

interface GenreEntry {
  genre: string;
  play_count: number;
  avg_min: number;
}

type GenreData = Record<Username, GenreEntry[]>;

interface GenreAvgChartProps {
  mainUser: DisplayName;
}

const tooltipStyle: React.CSSProperties = {
  backgroundColor: "var(--color-bg-card)",
  border: "1px solid var(--color-border)",
  borderRadius: "var(--radius-md)",
  fontSize: "var(--font-size-sm)",
};

const MAX_LABEL = 16;

function truncate(s: string): string {
  return s.length > MAX_LABEL ? s.slice(0, MAX_LABEL - 1) + "…" : s;
}

export default function GenreAvgChart({ mainUser }: GenreAvgChartProps) {
  const [period, setPeriod] = useState<TimePeriod>("2025");

  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;
  const { data, loading } = useData<GenreData>(`genre_avg_ms_played/${period}`);

  const mainUsername = DISPLAY_NAME_TO_USERNAME[mainUser] as Username;
  const mainUser_ = USERS.find((u) => u.displayName === mainUser);

  const chartData = useMemo(() => {
    if (!data) return [];
    const mainGenres = data[mainUsername] ?? [];
    return mainGenres.map((entry) => ({
      genre: entry.genre,
      label: truncate(entry.genre),
      value: parseFloat(entry.avg_min.toFixed(3)),
    }));
  }, [data, mainUsername]);

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
          Average Play Duration by Genre
        </h2>
        <TimePeriodSelector value={period} onChange={setPeriod} />
      </div>

      <div className={styles.card}>
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
                tickFormatter={(v: number) => `${v.toFixed(1)}m`}
              />
              <YAxis
                type="category"
                dataKey="label"
                width={110}
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
                formatter={(value) => [
                  typeof value === "number" ? `${value.toFixed(3)} min` : value,
                  mainUser,
                ]}
              />
              <Bar
                dataKey="value"
                name={mainUser}
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
