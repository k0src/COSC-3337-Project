import { useState, useEffect, useCallback } from "react";
import styles from "./App.module.css";
import SongCard from "./components/SongCard";
import UserSelector from "./components/UserSelector";
import { ScoredTrack, RecommendationsResponse, UserInfo } from "./types";

const PAGE_SIZE = 10;

export default function App() {
  const [users, setUsers] = useState<UserInfo[]>([]);
  const [activeUser, setActiveUser] = useState<UserInfo | null>(null);
  const [tracks, setTracks] = useState<ScoredTrack[]>([]);
  const [total, setTotal] = useState(0);
  const [offset, setOffset] = useState(0);
  const [loading, setLoading] = useState(false);
  const [initialLoad, setInitialLoad] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch("/api/users")
      .then((r) => r.json())
      .then((data: UserInfo[]) => {
        setUsers(data);
        setActiveUser(data[0] ?? null);
      })
      .catch(() => setError("Failed to load users"));
  }, []);

  const fetchPage = useCallback(
    async (user: UserInfo, nextOffset: number, append: boolean) => {
      setLoading(true);
      setError(null);
      try {
        const res = await fetch(
          `/api/recommendations?user=${user.username}&offset=${nextOffset}&limit=${PAGE_SIZE}`,
        );
        if (!res.ok) throw new Error(await res.text());
        const data: RecommendationsResponse = await res.json();
        setTracks((prev) => (append ? [...prev, ...data.tracks] : data.tracks));
        setTotal(data.total);
        setOffset(nextOffset + data.tracks.length);
      } catch (err: unknown) {
        setError(err instanceof Error ? err.message : "Unknown error");
      } finally {
        setLoading(false);
        setInitialLoad(false);
      }
    },
    [],
  );

  useEffect(() => {
    if (!activeUser) return;
    setTracks([]);
    setOffset(0);
    setTotal(0);
    setInitialLoad(true);
    fetchPage(activeUser, 0, false);
  }, [activeUser, fetchPage]);

  const handleLoadMore = () => {
    if (!activeUser || loading) return;
    fetchPage(activeUser, offset, true);
  };

  const handleUserChange = (user: UserInfo) => {
    if (user.username === activeUser?.username) return;
    setActiveUser(user);
  };

  const hasMore = offset < total;

  return (
    <div className={styles.app}>
      <header className={styles.header}>
        <div className={styles.headerInner}>
          <div className={styles.brand}>
            <span className={styles.brandIcon}>♫</span>
            <span className={styles.brandName}>Music Recommender</span>
            <span className={styles.brandSub}>
              COSC-3337 / Spotify Data Project
            </span>
          </div>
          {users.length > 0 && (
            <UserSelector
              users={users}
              activeUser={activeUser}
              onChange={handleUserChange}
            />
          )}
        </div>
      </header>

      <main className={styles.main}>
        {activeUser && (
          <div className={styles.profileBanner}>
            <div className={styles.profileInfo}>
              <h2 className={styles.profileName}>{activeUser.displayName}</h2>
            </div>
            <div className={styles.profileGenres}>
              {activeUser.dominantFamilies.map((f) => (
                <span key={f} className={styles.genreChip}>
                  {f}
                </span>
              ))}
            </div>
            {!initialLoad && (
              <span className={styles.totalCount}>
                {total.toLocaleString()} candidates scored
              </span>
            )}
          </div>
        )}

        {error && <div className={styles.error}>⚠ {error}</div>}

        {initialLoad && (
          <div className={styles.loadingState}>
            <div className={styles.spinner} />
            <p>Scoring tracks…</p>
          </div>
        )}

        {!initialLoad && tracks.length > 0 && (
          <>
            <div className={styles.grid}>
              {tracks.map((track, i) => (
                <SongCard
                  key={`${track.trackName}|${track.artistName}|${i}`}
                  track={track}
                  rank={i + 1}
                />
              ))}
            </div>

            {hasMore && (
              <div className={styles.footer}>
                <button
                  className={styles.loadMore}
                  onClick={handleLoadMore}
                  disabled={loading}
                >
                  {loading ? "Loading..." : `Load next ${PAGE_SIZE}`}
                </button>
                <span className={styles.pageCount}>
                  Showing {tracks.length} of {total.toLocaleString()}
                </span>
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
