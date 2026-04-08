import { readFileSync, writeFileSync, mkdirSync } from "fs";

const OUT_DIR = "./public/data/repeat_vs_new";
mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

for (const period of ["2024", "2025", "alltime"]) {
  const raw = JSON.parse(
    readFileSync(`../data/repeat_vs_new/repeat_vs_new_${period}.json`, "utf-8"),
  );
  const out = {};
  for (const [displayName, vals] of Object.entries(raw)) {
    const username = DISPLAY_TO_USERNAME[displayName] || displayName;
    out[username] = vals;
  }
  writeFileSync(`${OUT_DIR}/${period}.json`, JSON.stringify(out));
  console.log(`${period}: done`);
}
console.log("Done.");
