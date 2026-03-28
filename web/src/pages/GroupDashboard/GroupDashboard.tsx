import { Helmet } from "react-helmet-async";
import styles from "./GroupDashboard.module.css";

export default function GroupDashboard() {
  return (
    <>
      <Helmet>
        <title>Group - Spotify Stats</title>
      </Helmet>

      <div className={styles.page}>
        <div className={styles.pageHeader}>
          <h1 className={styles.pageTitle}>Group</h1>
          <p className={styles.pageSubtitle}>
            Combined listening data across all users
          </p>
        </div>

        <div className={styles.grid}>{/* charts */}</div>
      </div>
    </>
  );
}
