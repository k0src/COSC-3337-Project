import { readFileSync, writeFileSync, mkdirSync } from "fs";

const OUT_DIR = "./public/data/session_opening_artist";
mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

const raw = JSON.parse(
  readFileSync("../data/session_opening_artist/session_opening_artist.json", "utf-8"),
);

for (const period of ["2024", "2025", "alltime"]) {
  const out = {};
  for (const [displayName, userData] of Object.entries(raw[period])) {
    const username = DISPLAY_TO_USERNAME[displayName] || displayName;
    out[username] = userData.artists;
  }
  writeFileSync(`${OUT_DIR}/${period}.json`, JSON.stringify(out));
  console.log(`${period}: done`);
}

console.log("Done.");
