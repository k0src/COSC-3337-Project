import { readFileSync, writeFileSync, mkdirSync } from "fs";

const OUT_DIR = "./public/data/genre_first_appearance";
mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

const TOP_N = 30;

const raw = JSON.parse(
  readFileSync("../data/genre_first_appearance/genre_first_appearance.json", "utf-8"),
);

const out = {};
for (const [displayName, userData] of Object.entries(raw)) {
  const username = DISPLAY_TO_USERNAME[displayName] || displayName;
  // sort by most recently discovered first, take top 30
  const sorted = [...(userData.genres ?? [])].sort((a, b) => b.year_frac - a.year_frac);
  out[username] = sorted.slice(0, TOP_N);
}

writeFileSync(`${OUT_DIR}/alltime.json`, JSON.stringify(out));
console.log("Done.");
