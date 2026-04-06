import { readFileSync, writeFileSync, mkdirSync } from "fs";

const DATA_DIR = "../data/listening_times";
const OUT_DIR = "./public/data/listening_times";

mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

for (const period of ["2024", "2025", "alltime"]) {
  const raw = JSON.parse(
    readFileSync(`${DATA_DIR}/listening_times_${period}.json`, "utf-8"),
  );

  // Transform: { user: { hour: count } } -> { user: [count_for_hour_0, ..., count_for_hour_23] }
  const out = {};
  for (const [displayName, hours] of Object.entries(raw)) {
    const username = DISPLAY_TO_USERNAME[displayName] || displayName;
    const arr = [];
    for (let h = 0; h < 24; h++) {
      arr.push(hours[String(h)] || 0);
    }
    out[username] = arr;
  }

  writeFileSync(`${OUT_DIR}/${period}.json`, JSON.stringify(out));
  console.log(`${period}: done`);
}

console.log("Done.");
