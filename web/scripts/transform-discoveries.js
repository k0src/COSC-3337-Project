import { readFileSync, writeFileSync, mkdirSync } from "fs";

const INPUT = "../data/discoveries/discoveries_2025.json";
const OUT_DIR = "./public/data/discoveries";

mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

function slugify(str) {
  return str
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_|_$/g, "");
}

const raw = JSON.parse(readFileSync(INPUT, "utf-8"));

for (const [displayName, data] of Object.entries(raw)) {
  const username = DISPLAY_TO_USERNAME[displayName];

  // Add image to the #1 item of each category
  const categories = [
    "discovered_artists",
    "discovered_tracks",
    "discovered_albums",
    "rediscovered_artists",
    "rediscovered_tracks",
    "rediscovered_albums",
  ];

  const out = {
    threshold_days: data.threshold_days,
    span_days: data.span_days,
  };

  for (const cat of categories) {
    const items = data[cat] || [];
    out[cat] = items.map((item, i) => {
      const entry = { ...item, rank: i + 1 };
      if (i === 0) {
        if (cat.includes("artist")) {
          entry.image = `artist_${slugify(item.artist_name)}.webp`;
        } else if (cat.includes("track")) {
          entry.image = `track_${slugify(item.track_name)}.webp`;
        } else if (cat.includes("album")) {
          entry.image = `album_${slugify(item.album_name)}.webp`;
        }
      }
      return entry;
    });
  }

  writeFileSync(`${OUT_DIR}/${username}.json`, JSON.stringify(out));
}

console.log("Done.");
