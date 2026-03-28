import classNames from "classnames";
import type { TimePeriod } from "@types";
import styles from "./TimePeriodSelector.module.css";

interface TimePeriodSelectorProps {
  value: TimePeriod;
  onChange: (period: TimePeriod) => void;
}

const PERIODS: { value: TimePeriod; label: string }[] = [
  { value: "2024", label: "2024" },
  { value: "2025", label: "2025" },
  { value: "alltime", label: "All-Time" },
];

export default function TimePeriodSelector({
  value,
  onChange,
}: TimePeriodSelectorProps) {
  return (
    <div className={styles.selector}>
      {PERIODS.map((period) => (
        <button
          key={period.value}
          className={classNames(styles.option, {
            [styles.optionActive]: value === period.value,
          })}
          onClick={() => onChange(period.value)}
        >
          {period.label}
        </button>
      ))}
    </div>
  );
}
