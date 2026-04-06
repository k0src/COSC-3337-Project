import { useState } from "react";
import { ChevronDown, ChevronUp } from "lucide-react";
import styles from "./TopList.module.css";

interface TopItem {
  rank: number;
  name: string;
  subtitle?: string;
  count: number;
  image?: string;
}

interface TopListProps {
  title: string;
  items: TopItem[];
  hasSubtitle?: boolean;
}

export default function TopList({ title, items, hasSubtitle }: TopListProps) {
  const [expanded, setExpanded] = useState(false);

  if (items.length === 0) return null;

  const featured = items[0];
  const rest = items.slice(1);

  return (
    <div className={styles.card}>
      <div className={styles.cardTop}>
        <span className={styles.cardTitle}>{title}</span>

        <div className={styles.featured}>
          <img
            className={styles.featuredImage}
            src={featured.image ? `/images/${featured.image}` : ""}
            alt={featured.name}
          />
          <div className={styles.featuredInfo}>
            <span className={styles.featuredRank}>#1</span>
            <span className={styles.featuredName} title={featured.name}>
              {featured.name}
            </span>
            {featured.subtitle && (
              <span className={styles.featuredSub} title={featured.subtitle}>
                {featured.subtitle}
              </span>
            )}
            <span className={styles.featuredCount}>
              {featured.count.toLocaleString()} plays
            </span>
          </div>
        </div>
      </div>

      {expanded && (
        <div className={styles.expandedList}>
          <div className={styles.listHeader}>
            <span className={styles.listHeaderRank}>#</span>
            <span className={styles.listHeaderName}>
              {hasSubtitle ? "Name / Artist" : "Name"}
            </span>
            <span className={styles.listHeaderCount}>Plays</span>
          </div>
          <div className={styles.list}>
            {rest.map((item) => (
              <ListRow key={item.rank} item={item} />
            ))}
          </div>
        </div>
      )}

      {rest.length > 0 && (
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

function ListRow({ item }: { item: TopItem }) {
  return (
    <div className={styles.listItem}>
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
      <span className={styles.itemCount}>{item.count.toLocaleString()}</span>
    </div>
  );
}
