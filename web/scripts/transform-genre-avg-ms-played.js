import { readFileSync, writeFileSync, mkdirSync } from "fs";

const OUT_DIR = "./public/data/genre_avg_ms_played";
mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

const raw = JSON.parse(
  readFileSync("../data/genre_avg_ms_played/genre_avg_ms_played.json", "utf-8"),
);

for (const period of ["2024", "2025", "alltime"]) {
  const out = {};
  for (const [displayName, periods] of Object.entries(raw)) {
    const username = DISPLAY_TO_USERNAME[displayName] || displayName;
    out[username] = periods[period]?.genres ?? [];
  }
  writeFileSync(`${OUT_DIR}/${period}.json`, JSON.stringify(out));
  console.log(`${period}: done`);
}

console.log("Done.");
