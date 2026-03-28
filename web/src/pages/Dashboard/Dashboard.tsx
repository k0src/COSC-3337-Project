import { Helmet } from "react-helmet-async";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts";
import { ChartCard } from "@components";
import styles from "./Dashboard.module.css";

const DUMMY_DATA = [
  { month: "Jan", Alan: 4200, Anthony: 2100, Alexandra: 1400, Koren: 3100 },
  { month: "Feb", Alan: 3800, Anthony: 2400, Alexandra: 1200, Koren: 2900 },
  { month: "Mar", Alan: 5100, Anthony: 1800, Alexandra: 1600, Koren: 3400 },
  { month: "Apr", Alan: 4600, Anthony: 2200, Alexandra: 900, Koren: 2700 },
  { month: "May", Alan: 3900, Anthony: 2600, Alexandra: 1100, Koren: 3200 },
  { month: "Jun", Alan: 4400, Anthony: 1900, Alexandra: 1300, Koren: 2800 },
];

const USER_COLORS = {
  Alan: "var(--color-user-alan)",
  Anthony: "var(--color-user-anthony)",
  Alexandra: "var(--color-user-alexandra)",
  Koren: "var(--color-user-koren)",
};

const tooltipStyle = {
  backgroundColor: "var(--color-bg-card)",
  border: "1px solid var(--color-border)",
  borderRadius: "var(--radius-md)",
  fontSize: "var(--font-size-sm)",
};

export default function Dashboard() {
  return (
    <>
      <Helmet>
        <title>Dashboard - Spotify Stats</title>
      </Helmet>

      <div className={styles.page}>
        <div className={styles.pageHeader}>
          <h1 className={styles.pageTitle}>Dashboard</h1>
          <p className={styles.pageSubtitle}>
            Overview of listening activity across all users
          </p>
        </div>

        <div className={styles.grid}>
          <ChartCard title="Monthly Listening Events" subtitle="dummy data">
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={DUMMY_DATA}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} />
                <XAxis dataKey="month" />
                <YAxis />
                <Tooltip
                  contentStyle={tooltipStyle}
                  cursor={{ fill: "rgba(255,255,255,0.03)" }}
                />
                <Legend />
                {Object.entries(USER_COLORS).map(([name, color]) => (
                  <Bar
                    key={name}
                    dataKey={name}
                    fill={color}
                    radius={[4, 4, 0, 0]}
                  />
                ))}
              </BarChart>
            </ResponsiveContainer>
          </ChartCard>
        </div>
      </div>
    </>
  );
}
