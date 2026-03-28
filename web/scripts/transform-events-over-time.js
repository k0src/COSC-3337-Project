import { readFileSync, writeFileSync, mkdirSync } from "fs";

const DATA_DIR = "../data/events_over_time";
const OUT_DIR = "./public/data/events_over_time";

mkdirSync(OUT_DIR, { recursive: true });

function transformDaily(inputFile, outputFile) {
  const raw = JSON.parse(readFileSync(inputFile, "utf-8"));
  const users = Object.keys(raw);

  // Collect all dates across all users
  const dateSet = new Set();
  for (const user of users) {
    for (const date of Object.keys(raw[user])) {
      dateSet.add(date);
    }
  }

  const dates = [...dateSet].sort();

  const result = dates.map((date) => {
    const row = { date };
    for (const user of users) {
      row[user] = raw[user][date] ?? 0;
    }
    return row;
  });

  writeFileSync(outputFile, JSON.stringify(result));
  console.log(`${outputFile}: ${result.length} rows`);
}

function transformMonthly(inputFile, outputFile) {
  const raw = JSON.parse(readFileSync(inputFile, "utf-8"));
  const users = Object.keys(raw);

  // Aggregate daily -> monthly
  const monthlyMap = {};
  for (const user of users) {
    for (const [date, count] of Object.entries(raw[user])) {
      const month = date.slice(0, 7); // "2021-03"
      if (!monthlyMap[month]) monthlyMap[month] = {};
      monthlyMap[month][user] = (monthlyMap[month][user] ?? 0) + count;
    }
  }

  const months = Object.keys(monthlyMap)
    .filter((m) => m < "2026")
    .sort();

  const result = months.map((month) => {
    const row = { date: month };
    for (const user of users) {
      row[user] = monthlyMap[month][user] ?? 0;
    }
    return row;
  });

  writeFileSync(outputFile, JSON.stringify(result));
  console.log(`${outputFile}: ${result.length} rows`);
}

transformDaily(`${DATA_DIR}/events_over_time_2024.json`, `${OUT_DIR}/2024.json`);
transformDaily(`${DATA_DIR}/events_over_time_2025.json`, `${OUT_DIR}/2025.json`);
transformMonthly(`${DATA_DIR}/events_over_time_alltime.json`, `${OUT_DIR}/alltime.json`);

console.log("Done.");
