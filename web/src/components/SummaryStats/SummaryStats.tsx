import { useState } from "react";
import { TimePeriodSelector, UserCompare, StatCard } from "@components";
import { USERS } from "@types";
import type { DisplayName, TimePeriod } from "@types";
import styles from "./SummaryStats.module.css";

interface UserStats {
  uniqueTracks: number;
  uniqueArtists: number;
  uniqueAlbums: number;
  uniqueGenres: number;
  totalEvents: number;
}

const SUMMARY_DATA: Record<TimePeriod, Record<DisplayName, UserStats>> = {
  alltime: {
    Alan: {
      uniqueTracks: 10560,
      uniqueArtists: 1687,
      uniqueAlbums: 3761,
      uniqueGenres: 407,
      totalEvents: 1910079,
    },
    Anthony: {
      uniqueTracks: 9061,
      uniqueArtists: 1291,
      uniqueAlbums: 4247,
      uniqueGenres: 290,
      totalEvents: 283029,
    },
    Alexandra: {
      uniqueTracks: 5246,
      uniqueArtists: 1061,
      uniqueAlbums: 2347,
      uniqueGenres: 322,
      totalEvents: 467926,
    },
    Koren: {
      uniqueTracks: 15074,
      uniqueArtists: 3979,
      uniqueAlbums: 7864,
      uniqueGenres: 528,
      totalEvents: 618654,
    },
  },
  "2024": {
    Alan: {
      uniqueTracks: 3923,
      uniqueArtists: 796,
      uniqueAlbums: 1439,
      uniqueGenres: 298,
      totalEvents: 231266,
    },
    Anthony: {
      uniqueTracks: 2733,
      uniqueArtists: 549,
      uniqueAlbums: 1440,
      uniqueGenres: 207,
      totalEvents: 44348,
    },
    Alexandra: {
      uniqueTracks: 2177,
      uniqueArtists: 531,
      uniqueAlbums: 1123,
      uniqueGenres: 233,
      totalEvents: 44308,
    },
    Koren: {
      uniqueTracks: 2973,
      uniqueArtists: 1255,
      uniqueAlbums: 1906,
      uniqueGenres: 351,
      totalEvents: 42766,
    },
  },
  "2025": {
    Alan: {
      uniqueTracks: 3223,
      uniqueArtists: 477,
      uniqueAlbums: 972,
      uniqueGenres: 267,
      totalEvents: 117121,
    },
    Anthony: {
      uniqueTracks: 3509,
      uniqueArtists: 543,
      uniqueAlbums: 1622,
      uniqueGenres: 180,
      totalEvents: 53263,
    },
    Alexandra: {
      uniqueTracks: 2137,
      uniqueArtists: 503,
      uniqueAlbums: 1064,
      uniqueGenres: 231,
      totalEvents: 30725,
    },
    Koren: {
      uniqueTracks: 3730,
      uniqueArtists: 1396,
      uniqueAlbums: 2304,
      uniqueGenres: 365,
      totalEvents: 53353,
    },
  },
};

const STAT_KEYS: { key: keyof UserStats; label: string }[] = [
  { key: "totalEvents", label: "Total Events" },
  { key: "uniqueTracks", label: "Unique Tracks" },
  { key: "uniqueArtists", label: "Unique Artists" },
  { key: "uniqueAlbums", label: "Unique Albums" },
  { key: "uniqueGenres", label: "Unique Genres" },
];

interface SummaryStatsProps {
  mainUser: DisplayName;
}

export default function SummaryStats({ mainUser }: SummaryStatsProps) {
  const [period, setPeriod] = useState<TimePeriod>("2025");
  const [compareUsers, setCompareUsers] = useState<DisplayName[]>([]);

  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;
  const mainData = SUMMARY_DATA[period][mainUser];

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
          Summary
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

      <div className={styles.grid}>
        {STAT_KEYS.map(({ key, label }) => (
          <StatCard
            key={key}
            label={label}
            value={mainData[key]}
            comparisons={compareUsers.map((name) => ({
              name,
              value: SUMMARY_DATA[period][name][key],
            }))}
          />
        ))}
      </div>
    </div>
  );
}
