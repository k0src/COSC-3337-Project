import { useState } from "react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts";
import { ChartCard, TimePeriodSelector, UserCompare } from "@components";
import { useData } from "@hooks";
import { USERS } from "@types";
import type { DisplayName, TimePeriod } from "@types";
import styles from "./EventsOverTime.module.css";

interface EventRow {
  date: string;
  [user: string]: string | number;
}

const tooltipStyle: React.CSSProperties = {
  backgroundColor: "var(--color-bg-card)",
  border: "1px solid var(--color-border)",
  borderRadius: "var(--radius-md)",
  fontSize: "var(--font-size-sm)",
};

function formatDateLabel(date: string): string {
  if (date.length === 7) {
    const [y, m] = date.split("-");
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return `${months[parseInt(m) - 1]} '${y.slice(2)}`;
  }
  const [, m, d] = date.split("-");
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return `${months[parseInt(m) - 1]} ${parseInt(d)}`;
}

interface EventsOverTimeProps {
  mainUser: DisplayName;
}

export default function EventsOverTime({ mainUser }: EventsOverTimeProps) {
  const [period, setPeriod] = useState<TimePeriod>("2025");
  const [compareUsers, setCompareUsers] = useState<DisplayName[]>([]);

  const { data, loading } = useData<EventRow[]>(`events_over_time/${period}`);

  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;
  const visibleUsers = [mainUser, ...compareUsers];

  const tickInterval = period === "alltime" ? 5 : 29;

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
          Listening Events Over Time
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

      <ChartCard
        subtitle={
          period === "alltime"
            ? "Aggregated monthly listening events (2015\u20132025)"
            : `Daily listening events in ${period}`
        }
      >
        {loading || !data ? (
          <div
            style={{
              height: 350,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              color: "var(--color-text-muted)",
            }}
          >
            Loading...
          </div>
        ) : (
          <ResponsiveContainer key={period} width="100%" height={350}>
            <LineChart data={data}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} />
              <XAxis
                dataKey="date"
                tickFormatter={formatDateLabel}
                interval={tickInterval}
                fontSize={11}
              />
              <YAxis />
              <Tooltip
                contentStyle={tooltipStyle}
                labelFormatter={(label) => formatDateLabel(String(label))}
                cursor={{ stroke: "rgba(255,255,255,0.1)" }}
              />
              <Legend />
              {visibleUsers.map((name) => {
                const user = USERS.find((u) => u.displayName === name);
                return (
                  <Line
                    key={name}
                    type="monotone"
                    dataKey={name}
                    stroke={user?.color}
                    strokeWidth={name === mainUser ? 2 : 1.5}
                    dot={false}
                    opacity={name === mainUser ? 1 : 0.7}
                  />
                );
              })}
            </LineChart>
          </ResponsiveContainer>
        )}
      </ChartCard>
    </div>
  );
}
