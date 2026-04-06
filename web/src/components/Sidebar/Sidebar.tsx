import { NavLink } from "react-router-dom";
import classNames from "classnames";
import { USERS } from "@types";
import styles from "./Sidebar.module.css";

export default function Sidebar() {
  const linkClass = ({ isActive }: { isActive: boolean }) =>
    classNames(styles.navLink, { [styles.navLinkActive]: isActive });

  return (
    <aside className={styles.sidebar}>
      <div className={styles.logo}>
        Spotify <span className={styles.logoAccent}>Stats</span>
      </div>

      <nav className={styles.nav}>
        <span className={styles.sectionLabel}>Overview</span>
        <NavLink to="/" className={linkClass}>
          Dashboard
        </NavLink>

        <span className={styles.sectionLabel}>Users</span>
        {USERS.map((user) => (
          <NavLink
            key={user.username}
            to={`/user/${user.username}`}
            className={linkClass}
          >
            <span
              className={styles.userDot}
              style={{ backgroundColor: user.color }}
            />
            {user.displayName}
          </NavLink>
        ))}
      </nav>
    </aside>
  );
}
