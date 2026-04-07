import type { ReactNode } from "react";
import styles from "./ChartCard.module.css";

interface ChartCardProps {
  title?: string;
  subtitle?: string;
  children: ReactNode;
  actions?: ReactNode;
}

export default function ChartCard({
  title,
  subtitle,
  children,
  actions,
}: ChartCardProps) {
  return (
    <div className={styles.card}>
      <div className={styles.header}>
        <div>
          <h3 className={styles.title}>{title}</h3>
          {subtitle && <p className={styles.subtitle}>{subtitle}</p>}
        </div>
        {actions}
      </div>
      <div className={styles.body}>{children}</div>
    </div>
  );
}
