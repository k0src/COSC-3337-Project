import { readFileSync, writeFileSync, mkdirSync } from "fs";

const OUT_DIR = "./public/data/artist_diversity";
mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

const raw = JSON.parse(
  readFileSync("../data/artist_diversity/artist_diversity_over_time.json", "utf-8"),
);

// Collect all years
const yearSet = new Set();
for (const userData of Object.values(raw)) {
  for (const year of Object.keys(userData)) yearSet.add(year);
}
const years = [...yearSet].sort();

const rows = years.map((year) => {
  const row = { year };
  for (const [displayName, userData] of Object.entries(raw)) {
    const username = DISPLAY_TO_USERNAME[displayName] || displayName;
    const entry = userData[year];
    row[`${username}_gini`] = entry?.gini ?? null;
    row[`${username}_entropy`] = entry?.entropy ?? null;
  }
  return row;
});

writeFileSync(`${OUT_DIR}/alltime.json`, JSON.stringify(rows));
console.log(`alltime: ${rows.length} rows`);
console.log("Done.");
