import { useState } from "react";
import { TimePeriodSelector, TopList } from "@components";
import { useData } from "@hooks";
import { USERS, DISPLAY_NAME_TO_USERNAME } from "@types";
import type { DisplayName, TimePeriod } from "@types";
import styles from "./TopSection.module.css";

interface RawTrack {
  track_name: string;
  artist_name: string;
  album_name: string;
  play_count: number;
  rank: number;
  image?: string;
}

interface RawArtist {
  artist_name: string;
  play_count: number;
  rank: number;
  image?: string;
}

interface RawAlbum {
  album_name: string;
  artist_name: string;
  play_count: number;
  rank: number;
  image?: string;
}

interface RawGenre {
  genre: string;
  play_count: number;
  rank: number;
  image?: string;
}

interface Top20Data {
  tracks: RawTrack[];
  artists: RawArtist[];
  albums: RawAlbum[];
  genres: RawGenre[];
}

interface TopSectionProps {
  mainUser: DisplayName;
}

export default function TopSection({ mainUser }: TopSectionProps) {
  const [period, setPeriod] = useState<TimePeriod>("2025");
  const username = DISPLAY_NAME_TO_USERNAME[mainUser];
  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;

  const { data, loading } = useData<Top20Data>(`top_20/${period}_${username}`);

  if (loading || !data) {
    return (
      <div className={styles.section}>
        <div className={styles.toolbar}>
          <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
            Top 20
          </h2>
          <TimePeriodSelector value={period} onChange={setPeriod} />
        </div>
        <div style={{ color: "var(--color-text-muted)" }}>Loading...</div>
      </div>
    );
  }

  const trackItems = data.tracks.map((t) => ({
    rank: t.rank,
    name: t.track_name,
    subtitle: t.artist_name,
    count: t.play_count,
    image: t.image,
  }));

  const artistItems = data.artists.map((a) => ({
    rank: a.rank,
    name: a.artist_name,
    count: a.play_count,
    image: a.image,
  }));

  const albumItems = data.albums.map((a) => ({
    rank: a.rank,
    name: a.album_name,
    subtitle: a.artist_name,
    count: a.play_count,
    image: a.image,
  }));

  const genreItems = data.genres.map((g) => ({
    rank: g.rank,
    name: g.genre,
    count: g.play_count,
    image: g.image,
  }));

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
          Top 20
        </h2>
        <TimePeriodSelector value={period} onChange={setPeriod} />
      </div>

      <div className={styles.grid}>
        <TopList title="Tracks" items={trackItems} hasSubtitle />
        <TopList title="Artists" items={artistItems} />
        <TopList title="Albums" items={albumItems} hasSubtitle />
        <TopList title="Genres" items={genreItems} />
      </div>
    </div>
  );
}
