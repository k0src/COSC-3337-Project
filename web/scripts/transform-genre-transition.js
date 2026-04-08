import { readFileSync, writeFileSync, mkdirSync } from "fs";

const OUT_DIR = "./public/data/genre_transition";
mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

const TOP_N = 10;

const raw = JSON.parse(
  readFileSync("../data/genre_transition_matrix_2025/genre_transition_matrix_2025.json", "utf-8"),
);

const out = {};
for (const [displayName, userData] of Object.entries(raw)) {
  const username = DISPLAY_TO_USERNAME[displayName] || displayName;
  const genres = userData.genres.slice(0, TOP_N);
  const matrix = userData.row_normalised.slice(0, TOP_N).map((row) => row.slice(0, TOP_N));
  const counts = userData.raw_counts.slice(0, TOP_N).map((row) => row.slice(0, TOP_N));
  out[username] = { genres, matrix, counts };
}

writeFileSync(`${OUT_DIR}/2025.json`, JSON.stringify(out));
console.log("2025: done");
console.log("Done.");
