import classNames from "classnames";
import { USERS } from "@types";
import type { DisplayName } from "@types";
import styles from "./StatCard.module.css";

interface ComparisonEntry {
  name: DisplayName;
  value: number;
}

interface StatCardProps {
  label: string;
  value: number;
  comparisons?: ComparisonEntry[];
}

function formatNumber(n: number): string {
  return n.toLocaleString();
}

function valueSizeClass(n: number): string {
  const len = formatNumber(n).length;
  if (len >= 11) return styles.valueXs;
  if (len >= 9) return styles.valueSm;
  if (len >= 7) return styles.valueMd;
  return "";
}

export default function StatCard({ label, value, comparisons }: StatCardProps) {
  return (
    <div className={styles.card}>
      <span className={styles.label}>{label}</span>
      <span className={classNames(styles.value, valueSizeClass(value))}>
        {formatNumber(value)}
      </span>
      {comparisons && comparisons.length > 0 && (
        <div className={styles.comparisons}>
          {comparisons.map((entry) => {
            const user = USERS.find((u) => u.displayName === entry.name);
            return (
              <div key={entry.name} className={styles.comparisonRow}>
                <span className={styles.comparisonUser}>
                  <span
                    className={styles.dot}
                    style={{ backgroundColor: user?.color }}
                  />
                  {entry.name}
                </span>
                <span className={styles.comparisonValue}>
                  {formatNumber(entry.value)}
                </span>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
