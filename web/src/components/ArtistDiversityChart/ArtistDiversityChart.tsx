import { useState, useMemo } from "react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { UserCompare } from "@components";
import { useData } from "@hooks";
import { USERS, DISPLAY_NAME_TO_USERNAME } from "@types";
import type { DisplayName, Username } from "@types";
import styles from "./ArtistDiversityChart.module.css";

type Metric = "gini" | "entropy";

interface DiversityRow {
  year: string;
  [key: string]: string | number | null;
}

interface ArtistDiversityChartProps {
  mainUser: DisplayName;
  metric: Metric;
}

const TITLES: Record<Metric, string> = {
  gini: "Gini Coefficient",
  entropy: "Entropy",
};

const DESCRIPTIONS: Record<Metric, string> = {
  gini: "Concentration of listening across artists (higher = more concentrated)",
  entropy: "Diversity of artist listening (higher = more varied)",
};

const tooltipStyle: React.CSSProperties = {
  backgroundColor: "var(--color-bg-card)",
  border: "1px solid var(--color-border)",
  borderRadius: "var(--radius-md)",
  fontSize: "var(--font-size-sm)",
};

export default function ArtistDiversityChart({
  mainUser,
  metric,
}: ArtistDiversityChartProps) {
  const [compareUsers, setCompareUsers] = useState<DisplayName[]>([]);

  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;
  const { data, loading } = useData<DiversityRow[]>("artist_diversity/alltime");

  const visibleUsers = useMemo(
    () => [mainUser, ...compareUsers],
    [mainUser, compareUsers],
  );

  const yDomain = useMemo(() => {
    if (!data) return ["auto", "auto"] as const;
    let min = Infinity;
    let max = -Infinity;
    for (const row of data) {
      for (const name of visibleUsers) {
        const username = DISPLAY_NAME_TO_USERNAME[name] as Username;
        const val = row[`${username}_${metric}`];
        if (typeof val === "number") {
          if (val < min) min = val;
          if (val > max) max = val;
        }
      }
    }
    if (!isFinite(min)) return ["auto", "auto"] as const;
    const pad = (max - min) * 0.15;
    return [
      Math.max(0, parseFloat((min - pad).toFixed(2))),
      parseFloat((max + pad).toFixed(2)),
    ] as const;
  }, [data, visibleUsers, metric]);

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
          {TITLES[metric]}
        </h2>
        <UserCompare
          mainUser={mainUser}
          selected={compareUsers}
          onChange={setCompareUsers}
        />
      </div>

      <div className={styles.card}>
        <p className={styles.description}>{DESCRIPTIONS[metric]}</p>
        {loading || !data ? (
          <div className={styles.placeholder} />
        ) : (
          <ResponsiveContainer width="100%" height={240}>
            <LineChart
              data={data}
              margin={{ top: 4, right: 8, left: -8, bottom: 0 }}
            >
              <CartesianGrid
                strokeDasharray="3 3"
                vertical={false}
                stroke="var(--color-border-subtle)"
              />
              <XAxis
                dataKey="year"
                fontSize={11}
                tick={{ fill: "var(--color-text-muted)" }}
                axisLine={false}
                tickLine={false}
              />
              <YAxis
                domain={yDomain}
                fontSize={11}
                tick={{ fill: "var(--color-text-muted)" }}
                axisLine={false}
                tickLine={false}
                tickFormatter={(v: number) => v.toFixed(2)}
                width={40}
              />
              <Tooltip
                contentStyle={tooltipStyle}
                formatter={(value, name) => [
                  typeof value === "number" ? value.toFixed(4) : value,
                  String(name).replace(`_${metric}`, ""),
                ]}
                cursor={{ stroke: "rgba(255,255,255,0.1)" }}
              />
              {visibleUsers.map((name) => {
                const user = USERS.find((u) => u.displayName === name);
                const username = DISPLAY_NAME_TO_USERNAME[name] as Username;
                return (
                  <Line
                    key={name}
                    type="monotone"
                    dataKey={`${username}_${metric}`}
                    name={name}
                    stroke={user?.color}
                    strokeWidth={name === mainUser ? 2.5 : 1.5}
                    dot={{ r: 3, fill: user?.color, strokeWidth: 0 }}
                    activeDot={{ r: 5 }}
                    opacity={name === mainUser ? 1 : 0.65}
                    connectNulls
                  />
                );
              })}
            </LineChart>
          </ResponsiveContainer>
        )}
      </div>
    </div>
  );
}
