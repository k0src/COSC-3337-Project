import { readFileSync, writeFileSync, mkdirSync } from "fs";

const OUT_DIR = "./public/data/genre_share_time";
mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

for (const period of ["2024", "2025", "alltime"]) {
  const raw = JSON.parse(
    readFileSync(`../data/genre_share_time_${period}/genre_share_time_${period}.json`, "utf-8"),
  );
  const out = {};
  for (const [displayName, userData] of Object.entries(raw)) {
    const username = DISPLAY_TO_USERNAME[displayName] || displayName;
    out[username] = {
      genres: userData.genres,
      dow: {
        labels: userData.dow.labels,
        matrix: userData.dow.matrix,
      },
    };
  }
  writeFileSync(`${OUT_DIR}/${period}.json`, JSON.stringify(out));
  console.log(`${period}: done`);
}

console.log("Done.");
