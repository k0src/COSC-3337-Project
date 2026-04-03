import { readFileSync, writeFileSync, mkdirSync } from "fs";

const INPUT = "../data/top_20/top_20.json";
const OUT_DIR = "./public/data/top_20";

mkdirSync(OUT_DIR, { recursive: true });

const raw = JSON.parse(readFileSync(INPUT, "utf-8"));

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

// Transform per user per period, adding image paths
for (const [period, users] of Object.entries(raw)) {
  for (const [user, categories] of Object.entries(users)) {
    const out = {};

    for (const [category, items] of Object.entries(categories)) {
      out[category] = items.map((item, i) => {
        const entry = { ...item, rank: i + 1 };

        // Add image slug for #1 item
        if (i === 0) {
          if (category === "artists") {
            entry.image = `artist_${slugify(item.artist_name)}.webp`;
          } else if (category === "albums") {
            entry.image = `album_${slugify(item.album_name)}.webp`;
          } else if (category === "tracks") {
            entry.image = `track_${slugify(item.track_name)}.webp`;
          } else if (category === "genres") {
            entry.image = `genre_${slugify(item.genre)}.webp`;
          }
        }

        return entry;
      });
    }

    const username = DISPLAY_TO_USERNAME[user] || slugify(user);
    writeFileSync(
      `${OUT_DIR}/${period}_${username}.json`,
      JSON.stringify(out),
    );
  }
}

console.log("Done. Files written to", OUT_DIR);
