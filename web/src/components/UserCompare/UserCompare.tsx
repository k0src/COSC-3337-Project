import { useState, useRef, useEffect } from "react";
import classNames from "classnames";
import { ChevronDown, Check } from "lucide-react";
import { USERS } from "@types";
import type { DisplayName } from "@types";
import styles from "./UserCompare.module.css";

interface UserCompareProps {
  mainUser: DisplayName;
  selected: DisplayName[];
  onChange: (selected: DisplayName[]) => void;
}

export default function UserCompare({
  mainUser,
  selected,
  onChange,
}: UserCompareProps) {
  const [open, setOpen] = useState(false);
  const wrapperRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (
        wrapperRef.current &&
        !wrapperRef.current.contains(e.target as Node)
      ) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const comparableUsers = USERS.filter((u) => u.displayName !== mainUser);

  function toggle(name: DisplayName) {
    if (selected.includes(name)) {
      onChange(selected.filter((n) => n !== name));
    } else {
      onChange([...selected, name]);
    }
  }

  return (
    <div className={styles.wrapper} ref={wrapperRef}>
      <button
        className={classNames(styles.trigger, {
          [styles.triggerActive]: selected.length > 0,
        })}
        onClick={() => setOpen(!open)}
      >
        Compare
        {selected.length > 0 && (
          <span className={styles.badge}>{selected.length}</span>
        )}
        <ChevronDown
          size={14}
          className={classNames(styles.chevron, {
            [styles.chevronOpen]: open,
          })}
        />
      </button>

      {open && (
        <div className={styles.dropdown}>
          {comparableUsers.map((user) => {
            const checked = selected.includes(user.displayName);
            return (
              <label
                key={user.username}
                className={styles.option}
                onClick={() => toggle(user.displayName)}
              >
                <span
                  className={classNames(styles.checkbox, {
                    [styles.checkboxChecked]: checked,
                  })}
                >
                  {checked && <Check size={12} className={styles.checkmark} />}
                </span>
                <span
                  className={styles.dot}
                  style={{ backgroundColor: user.color }}
                />
                {user.displayName}
              </label>
            );
          })}
          {selected.length > 0 && (
            <>
              <div className={styles.divider} />
              <button
                className={styles.clearButton}
                onClick={() => {
                  onChange([]);
                  setOpen(false);
                }}
              >
                Clear all
              </button>
            </>
          )}
        </div>
      )}
    </div>
  );
}
