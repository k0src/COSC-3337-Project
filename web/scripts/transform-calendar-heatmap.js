import { readFileSync, writeFileSync, mkdirSync } from "fs";

const OUT_DIR = "./public/data/calendar_heatmap";
mkdirSync(OUT_DIR, { recursive: true });

const DISPLAY_TO_USERNAME = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

function transform(raw) {
  const out = {};
  for (const [displayName, dates] of Object.entries(raw)) {
    const username = DISPLAY_TO_USERNAME[displayName] || displayName;
    out[username] = dates;
  }
  return out;
}

// 2025: use dedicated calendar heatmap file
const raw2025 = JSON.parse(
  readFileSync("../data/calendar_heatmap/calendar_heatmap_2025.json", "utf-8"),
);
writeFileSync(`${OUT_DIR}/2025.json`, JSON.stringify(transform(raw2025)));
console.log("2025: done");

// 2024: derive from events_over_time daily data (same format)
const raw2024 = JSON.parse(
  readFileSync(
    "../data/events_over_time/events_over_time_2024.json",
    "utf-8",
  ),
);
writeFileSync(`${OUT_DIR}/2024.json`, JSON.stringify(transform(raw2024)));
console.log("2024: done");

console.log("Done.");
