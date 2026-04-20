import { pool } from "./db";
import { UserProfile } from "./userProfiles";

const FAMILY_RULES: [string, string[]][] = [
  [
    "Hip-Hop / Rap",
    [
      "hip hop",
      "rap",
      "trap",
      "drill",
      "cloud rap",
      "grime",
      "phonk",
      "bounce",
    ],
  ],
  ["R&B", ["r&b", "neo soul", "contemporary r"]],
  ["Soul / Funk", ["soul", "funk", "motown", "gospel", "blues"]],
  [
    "Electronic",
    [
      "electronic",
      "electro",
      "edm",
      "synthwave",
      "synth pop",
      "industrial",
      "noise",
    ],
  ],
  [
    "House / Techno",
    ["house", "techno", "trance", "rave", "uk garage", "afrobeats"],
  ],
  [
    "Drum & Bass / Dubstep",
    [
      "drum and bass",
      "dnb",
      "dubstep",
      "jungle",
      "breakbeat",
      "drumstep",
      "liquid funk",
    ],
  ],
  [
    "Ambient / Lo-Fi",
    ["ambient", "lo-fi", "lofi", "chillhop", "chill", "drone", "new age"],
  ],
  ["Pop", ["pop"]],
  [
    "Alternative / Indie",
    [
      "alternative",
      "indie",
      "shoegaze",
      "dream",
      "post-punk",
      "new wave",
      "art rock",
    ],
  ],
  ["Rock", ["rock", "grunge", "garage", "surf"]],
  [
    "Metal",
    ["metal", "doom", "sludge", "stoner", "thrash", "death", "black metal"],
  ],
  ["Punk / Emo", ["punk", "emo", "hardcore", "screamo"]],
  ["Jazz", ["jazz", "bebop", "swing", "bossa nova", "fusion"]],
  [
    "Classical",
    [
      "classical",
      "orchestral",
      "opera",
      "baroque",
      "chamber",
      "contemporary classical",
    ],
  ],
  [
    "Country / Folk",
    [
      "country",
      "folk",
      "bluegrass",
      "americana",
      "singer-songwriter",
      "acoustic",
    ],
  ],
  [
    "Latin",
    ["latin", "reggaeton", "salsa", "bachata", "cumbia", "dembow", "corrido"],
  ],
  [
    "K-Pop / J-Pop",
    ["k-pop", "j-pop", "korean", "japanese", "anime", "city pop"],
  ],
  ["Reggae", ["reggae", "dancehall", "ska", "dub"]],
  ["Other", []],
];

function assignFamily(genre: string): string {
  const g = genre.toLowerCase();
  for (const [family, keywords] of FAMILY_RULES) {
    if (keywords.length === 0) return family;
    if (keywords.some((kw) => g.includes(kw))) return family;
  }
  return "Other";
}

function cosineSim(
  a: Record<string, number>,
  b: Record<string, number>,
): number {
  let dot = 0,
    magA = 0,
    magB = 0;
  const keys = new Set([...Object.keys(a), ...Object.keys(b)]);
  for (const k of keys) {
    const av = a[k] ?? 0;
    const bv = b[k] ?? 0;
    dot += av * bv;
    magA += av * av;
    magB += bv * bv;
  }
  if (magA === 0 || magB === 0) return 0;
  return dot / (Math.sqrt(magA) * Math.sqrt(magB));
}

function buildGenreVector(genres: string[]): Record<string, number> {
  const vec: Record<string, number> = {};
  for (const g of genres) {
    const family = assignFamily(g);
    vec[family] = (vec[family] ?? 0) + 1;
  }
  const total = Object.values(vec).reduce((s, v) => s + v, 0);
  if (total === 0) return vec;
  for (const k in vec) vec[k] /= total;
  return vec;
}

export interface ScoredTrack {
  trackName: string;
  artistName: string;
  genreFamilies: string[];
  matchPct: number;
  sortScore: number;
  userPlayCount: number;
  userSkipRate: number;
  isNew: boolean;
  scoreBreakdown: {
    genreMatch: number;
    artistAffinity: number;
    skipAvoidance: number;
    clusterAlignment: number;
  };
}

interface RawTrackRow {
  track_name: string;
  artist_name: string;
  genres: string | null;
  user_play_count: string;
  user_skip_rate: string;
  user_artist_plays: string;
  max_artist_plays: string;
}

function scoreTrack(row: RawTrackRow, profile: UserProfile): ScoredTrack {
  const genres = row.genres ? row.genres.split("|").filter(Boolean) : [];
  const userPlayCount = parseInt(row.user_play_count, 10) || 0;
  const userSkipRate = parseFloat(row.user_skip_rate);
  const artistPlays = parseInt(row.user_artist_plays, 10) || 0;
  const maxArtist = parseFloat(row.max_artist_plays) || 1;

  const genreFamilies = [...new Set(genres.map(assignFamily))].filter(
    (f) => f !== "Other",
  );

  const trackGenreVec = buildGenreVector(genres);
  const genreMatch = cosineSim(trackGenreVec, profile.genreProfile);

  const artistAffinity =
    artistPlays > 0 ? Math.log1p(artistPlays) / Math.log1p(maxArtist) : 0;

  let estimatedSkipRate: number;
  if (userSkipRate >= 0) {
    const genreEstimate =
      profile.baseSkipRate + (1 - genreMatch) * profile.genreMatchSensitivity;
    estimatedSkipRate = 0.7 * userSkipRate + 0.3 * genreEstimate;
  } else {
    estimatedSkipRate =
      profile.baseSkipRate + (1 - genreMatch) * profile.genreMatchSensitivity;
  }
  estimatedSkipRate = Math.max(0, Math.min(0.95, estimatedSkipRate));
  const skipAvoidance = 1 - estimatedSkipRate;

  const topFive = profile.dominantFamilies.slice(0, 5);
  const topThree = profile.dominantFamilies.slice(0, 3);
  let clusterAlignment = 0;
  if (genreFamilies.some((f) => topThree.includes(f))) {
    clusterAlignment = 1.0;
  } else if (genreFamilies.some((f) => topFive.includes(f))) {
    clusterAlignment = 0.5;
  }

  const contentScore =
    0.4 * genreMatch +
    0.25 * artistAffinity +
    0.2 * skipAvoidance +
    0.15 * clusterAlignment;

  let noveltyMultiplier: number;
  const isNew = userPlayCount === 0;
  if (isNew) {
    noveltyMultiplier = 1.3;
  } else if (userPlayCount > profile.outlierPlayThreshold) {
    noveltyMultiplier = userSkipRate < 0.3 ? 0.55 : 0.3;
  } else if (userSkipRate < 0.3) {
    noveltyMultiplier = 0.7;
  } else if (userSkipRate < 0.6) {
    noveltyMultiplier = 0.45;
  } else {
    noveltyMultiplier = 0.25;
  }

  const matchPct = Math.round(contentScore * 100);
  const sortScore = contentScore * noveltyMultiplier;

  return {
    trackName: row.track_name,
    artistName: row.artist_name,
    genreFamilies: genreFamilies.slice(0, 3),
    matchPct,
    sortScore,
    userPlayCount,
    userSkipRate,
    isNew,
    scoreBreakdown: {
      genreMatch,
      artistAffinity,
      skipAvoidance,
      clusterAlignment,
    },
  };
}

const cache = new Map<string, ScoredTrack[]>();

export async function getRecommendations(
  username: string,
  profile: UserProfile,
  offset: number,
  limit: number,
): Promise<{ tracks: ScoredTrack[]; total: number }> {
  if (!cache.has(username)) {
    const ranked = await buildRanking(username, profile);
    cache.set(username, ranked);
  }

  const ranked = cache.get(username)!;
  return {
    tracks: ranked.slice(offset, offset + limit),
    total: ranked.length,
  };
}

export function clearCache(username?: string) {
  if (username) cache.delete(username);
  else cache.clear();
}

async function buildRanking(
  username: string,
  profile: UserProfile,
): Promise<ScoredTrack[]> {
  const query = `
    WITH top_tracks AS (
      SELECT track_name, artist_name, COUNT(*) AS total_plays
      FROM   listening_history
      WHERE  artist_name IS NOT NULL
        AND  track_name  IS NOT NULL
      GROUP  BY track_name, artist_name
      ORDER  BY total_plays DESC
      LIMIT  8000
    ),
    user_track_stats AS (
      SELECT
        track_name,
        artist_name,
        COUNT(*)::int AS user_play_count,
        AVG(CASE WHEN skipped THEN 1.0 ELSE 0.0 END)::float AS user_skip_rate
      FROM  listening_history
      WHERE username = $1
        AND artist_name IS NOT NULL
        AND track_name  IS NOT NULL
      GROUP BY track_name, artist_name
    ),
    user_artist_stats AS (
      SELECT artist_name, COUNT(*)::int AS artist_plays
      FROM   listening_history
      WHERE  username = $1 AND artist_name IS NOT NULL
      GROUP  BY artist_name
    ),
    max_artist AS (
      SELECT GREATEST(MAX(artist_plays)::float, 1) AS max_plays
      FROM   user_artist_stats
    ),
    track_genres AS (
      SELECT artist_name, STRING_AGG(DISTINCT genre, '|') AS genres
      FROM artist_genres
      GROUP BY artist_name
    )
    SELECT
      t.track_name,
      t.artist_name,
      tg.genres,
      COALESCE(uts.user_play_count, 0)::text   AS user_play_count,
      COALESCE(uts.user_skip_rate,  -1.0)::text AS user_skip_rate,
      COALESCE(uas.artist_plays,    0)::text    AS user_artist_plays,
      m.max_plays::text                         AS max_artist_plays
    FROM  top_tracks        t
    LEFT  JOIN user_track_stats  uts ON t.track_name  = uts.track_name
                                    AND t.artist_name = uts.artist_name
    LEFT  JOIN user_artist_stats uas ON t.artist_name = uas.artist_name
    LEFT  JOIN track_genres      tg  ON t.artist_name = tg.artist_name
    CROSS JOIN max_artist m
  `;

  const client = await pool.connect();
  try {
    const result = await client.query<RawTrackRow>(query, [username]);
    const rows = result.rows;

    const scored = rows
      .map((row) => scoreTrack(row, profile))
      .filter((t) => t.matchPct > 0)
      .sort((a, b) => b.sortScore - a.sortScore);

    return scored;
  } finally {
    client.release();
  }
}
