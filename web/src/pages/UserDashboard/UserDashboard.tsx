import { useParams } from "react-router-dom";
import { Helmet } from "react-helmet-async";
import {
  SummaryStats,
  EventsOverTime,
  TopSection,
  Discoveries,
  ListeningClock,
  CalendarHeatmap,
  ArtistDiversityChart,
} from "@components";
import { USERNAME_TO_DISPLAY } from "@types";
import type { Username, DisplayName } from "@types";
import styles from "./UserDashboard.module.css";

export default function UserDashboard() {
  const { username } = useParams<{ username: string }>();
  const displayName = (USERNAME_TO_DISPLAY[username as Username] ??
    username) as DisplayName;

  return (
    <>
      <Helmet>
        <title>{displayName} - Spotify Stats</title>
      </Helmet>

      <div className={styles.page}>
        <div className={styles.pageHeader}>
          <h1 className={styles.pageTitle}>{displayName}</h1>
          <p className={styles.pageSubtitle}>Listening history and stats</p>
        </div>

        <SummaryStats mainUser={displayName} />
        <EventsOverTime mainUser={displayName} />
        <TopSection mainUser={displayName} />
        <Discoveries mainUser={displayName} />
        <CalendarHeatmap mainUser={displayName} />
        <div className={styles.halfGrid}>
          <ArtistDiversityChart mainUser={displayName} metric="gini" />
          <ArtistDiversityChart mainUser={displayName} metric="entropy" />
        </div>
        <div className={styles.halfGrid}>
          <ListeningClock mainUser={displayName} />
        </div>
      </div>
    </>
  );
}
