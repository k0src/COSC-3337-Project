import { readFileSync, writeFileSync, mkdirSync } from "fs";

const OUT_DIR = "./public/data/artist_transition";
mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

const raw = JSON.parse(
  readFileSync("../data/artist_transition_matrix_2025/artist_transition_matrix_2025.json", "utf-8"),
);

const out = {};
for (const [displayName, userData] of Object.entries(raw)) {
  const username = DISPLAY_TO_USERNAME[displayName] || displayName;
  out[username] = {
    artists: userData.artists,
    matrix: userData.row_normalised,
    counts: userData.raw_counts,
  };
}

writeFileSync(`${OUT_DIR}/2025.json`, JSON.stringify(out));
console.log("2025: done");
console.log("Done.");
