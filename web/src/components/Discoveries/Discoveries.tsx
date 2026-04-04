import { useState } from "react";
import classNames from "classnames";
import { ChevronDown, ChevronUp } from "lucide-react";
import { useData } from "@hooks";
import { USERS, DISPLAY_NAME_TO_USERNAME } from "@types";
import type { DisplayName } from "@types";
import styles from "./Discoveries.module.css";

interface ArtistItem {
  artist_name: string;
  plays: number;
  rank: number;
  image?: string;
}

interface TrackItem {
  track_name: string;
  artist_name: string;
  plays: number;
  rank: number;
  image?: string;
}

interface AlbumItem {
  album_name: string;
  artist_name: string;
  plays: number;
  gap_days?: number;
  rank: number;
  image?: string;
}

interface DiscoveriesData {
  threshold_days: number;
  span_days: number;
  discovered_artists: ArtistItem[];
  discovered_tracks: TrackItem[];
  discovered_albums: AlbumItem[];
  rediscovered_artists: ArtistItem[];
  rediscovered_tracks: TrackItem[];
  rediscovered_albums: AlbumItem[];
}

type Tab = "discovered" | "rediscovered";

interface DiscoveriesProps {
  mainUser: DisplayName;
}

export default function Discoveries({ mainUser }: DiscoveriesProps) {
  const [tab, setTab] = useState<Tab>("discovered");
  const username = DISPLAY_NAME_TO_USERNAME[mainUser];
  const mainUserColor = USERS.find((u) => u.displayName === mainUser)?.color;

  const { data, loading } = useData<DiscoveriesData>(`discoveries/${username}`);

  if (loading || !data) return null;

  const discoveredCount =
    data.discovered_artists.length +
    data.discovered_tracks.length +
    data.discovered_albums.length;
  const rediscoveredCount =
    data.rediscovered_artists.length +
    data.rediscovered_tracks.length +
    data.rediscovered_albums.length;

  if (discoveredCount === 0 && rediscoveredCount === 0) return null;

  const artists =
    tab === "discovered" ? data.discovered_artists : data.rediscovered_artists;
  const tracks =
    tab === "discovered" ? data.discovered_tracks : data.rediscovered_tracks;
  const albums =
    tab === "discovered" ? data.discovered_albums : data.rediscovered_albums;

  const thresholdYears = Math.round(data.threshold_days / 365);

  const cards: { label: string; hasSubtitle: boolean; items: CardItem[] }[] =
    [];

  if (artists.length > 0) {
    cards.push({
      label: "Artists",
      hasSubtitle: false,
      items: artists.map((a) => ({
        rank: a.rank,
        name: a.artist_name,
        meta: `${a.plays} plays`,
        image: a.image,
      })),
    });
  }

  if (tracks.length > 0) {
    cards.push({
      label: "Tracks",
      hasSubtitle: true,
      items: tracks.map((t) => ({
        rank: t.rank,
        name: t.track_name,
        subtitle: t.artist_name,
        meta: `${t.plays} plays`,
        image: t.image,
      })),
    });
  }

  if (albums.length > 0) {
    cards.push({
      label: "Albums",
      hasSubtitle: true,
      items: albums.map((a) => ({
        rank: a.rank,
        name: a.album_name,
        subtitle: a.artist_name,
        meta: a.gap_days
          ? `${a.plays} plays · ${a.gap_days}d gap`
          : `${a.plays} plays`,
        image: a.image,
      })),
    });
  }

  if (cards.length === 0) return null;

  return (
    <div className={styles.section}>
      <div className={styles.toolbar}>
        <div>
          <h2 className={styles.toolbarTitle} style={{ color: mainUserColor }}>
            Discoveries
          </h2>
          <p className={styles.toolbarSub}>
            {tab === "discovered"
              ? `Artists, tracks, and albums first listened to in 2025`
              : `Returning favorites after ${thresholdYears}+ years away`}
          </p>
        </div>
        <div className={styles.tabs}>
          <button
            className={classNames(styles.tab, {
              [styles.tabActive]: tab === "discovered",
            })}
            onClick={() => setTab("discovered")}
          >
            Discovered{" "}
            <span className={styles.tabBadge}>{discoveredCount}</span>
          </button>
          <button
            className={classNames(styles.tab, {
              [styles.tabActive]: tab === "rediscovered",
            })}
            onClick={() => setTab("rediscovered")}
          >
            Rediscovered{" "}
            <span className={styles.tabBadge}>{rediscoveredCount}</span>
          </button>
        </div>
      </div>

      <div className={styles.grid}>
        {cards.map((card) => (
          <DiscoveryCard
            key={card.label}
            label={card.label}
            hasSubtitle={card.hasSubtitle}
            items={card.items}
          />
        ))}
      </div>
    </div>
  );
}

interface CardItem {
  rank: number;
  name: string;
  subtitle?: string;
  meta: string;
  image?: string;
}

function DiscoveryCard({
  label,
  hasSubtitle,
  items,
}: {
  label: string;
  hasSubtitle: boolean;
  items: CardItem[];
}) {
  const [expanded, setExpanded] = useState(false);

  const featured = items[0];
  const rest = items.slice(1);
  const hasToggle = rest.length > 0;

  return (
    <div
      className={classNames(styles.card, {
        [styles.cardNoToggle]: !hasToggle,
      })}
    >
      <div className={styles.cardHeader}>
        <span className={styles.cardLabel}>{label}</span>
        <span className={styles.cardCount}>{items.length} total</span>
      </div>

      <div className={styles.featured}>
        {featured.image && (
          <img
            className={styles.featuredImage}
            src={`/images/${featured.image}`}
            alt={featured.name}
          />
        )}
        <div className={styles.featuredInfo}>
          <span className={styles.featuredName} title={featured.name}>
            {featured.name}
          </span>
          {featured.subtitle && (
            <span className={styles.featuredSub} title={featured.subtitle}>
              {featured.subtitle}
            </span>
          )}
          <span className={styles.featuredMeta}>{featured.meta}</span>
        </div>
      </div>

      {expanded && (
        <>
          <div className={styles.listHeader}>
            <span className={styles.listHeaderRank}>#</span>
            <span className={styles.listHeaderName}>
              {hasSubtitle ? "Name / Artist" : "Name"}
            </span>
            <span className={styles.listHeaderCount}>Plays</span>
          </div>
          <div className={styles.list}>
            {rest.map((item) => (
              <div key={item.rank} className={styles.listItem}>
                <span className={styles.rank}>{item.rank}</span>
                <div className={styles.itemInfo}>
                  <span className={styles.itemName} title={item.name}>
                    {item.name}
                  </span>
                  {item.subtitle && (
                    <span className={styles.itemSub} title={item.subtitle}>
                      {item.subtitle}
                    </span>
                  )}
                </div>
                <span className={styles.itemMeta}>{item.meta}</span>
              </div>
            ))}
          </div>
        </>
      )}

      {hasToggle && (
        <button
          className={styles.toggleButton}
          onClick={() => setExpanded(!expanded)}
        >
          {expanded ? (
            <>
              Show less <ChevronUp size={14} />
            </>
          ) : (
            <>
              Show more <ChevronDown size={14} />
            </>
          )}
        </button>
      )}
    </div>
  );
}
