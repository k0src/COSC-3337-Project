import express from "express";
import { getRecommendations, clearCache } from "./recommender";
import { USERS, USER_LIST } from "./userProfiles";

const app = express();
const PORT = 3001;

app.use(express.json());

app.get("/api/users", (_req, res) => {
  res.json(
    USER_LIST.map((u) => ({
      username: u.username,
      displayName: u.displayName,
      dominantFamilies: u.dominantFamilies.slice(0, 3),
    })),
  );
});

app.get("/api/recommendations", async (req, res) => {
  const username = req.query.user as string;
  const offset = Math.max(0, parseInt((req.query.offset as string) ?? "0", 10));
  const limit = Math.min(50, parseInt((req.query.limit as string) ?? "10", 10));

  if (!username || !USERS[username]) {
    return res.status(400).json({
      error: "Unknown user",
    });
  }

  try {
    const profile = USERS[username];
    const result = await getRecommendations(username, profile, offset, limit);
    return res.json(result);
  } catch (err) {
    console.error("Recommendation error:", err);
    return res.status(500).json({ error: "Internal server error" });
  }
});

app.listen(PORT, () => {
  console.log(PORT);
});
