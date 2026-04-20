export interface UserProfile {
  username: string;
  displayName: string;
  genreProfile: Record<string, number>;
  dominantFamilies: string[];
  baseSkipRate: number;
  genreMatchSensitivity: number;
  outlierPlayThreshold: number;
}

export const USERS: Record<string, UserProfile> = {
  alanjzamora: {
    username: "alanjzamora",
    displayName: "Alan",
    genreProfile: {
      "Hip-Hop / Rap": 0.48,
      Pop: 0.11,
      "Soul / Funk": 0.06,
      "Alternative / Indie": 0.06,
      "R&B": 0.05,
      Electronic: 0.03,
      "Drum & Bass / Dubstep": 0.02,
      "Ambient / Lo-Fi": 0.02,
    },
    dominantFamilies: [
      "Hip-Hop / Rap",
      "Pop",
      "Soul / Funk",
      "Alternative / Indie",
      "R&B",
    ],
    baseSkipRate: 0.26,
    genreMatchSensitivity: 0.15,
    outlierPlayThreshold: 18,
  },

  alexxxxxrs: {
    username: "alexxxxxrs",
    displayName: "Alexandra",
    genreProfile: {
      Pop: 0.21,
      Metal: 0.19,
      "Alternative / Indie": 0.14,
      "Punk / Emo": 0.14,
      Rock: 0.12,
      Electronic: 0.08,
      "R&B": 0.04,
      "Soul / Funk": 0.02,
    },
    dominantFamilies: [
      "Metal",
      "Punk / Emo",
      "Rock",
      "Alternative / Indie",
      "Pop",
    ],
    baseSkipRate: 0.117,
    genreMatchSensitivity: 0.08,
    outlierPlayThreshold: 12,
  },

  dasucc: {
    username: "dasucc",
    displayName: "Anthony",
    genreProfile: {
      "Hip-Hop / Rap": 0.71,
      "R&B": 0.08,
      Pop: 0.05,
      "Soul / Funk": 0.03,
      Electronic: 0.02,
    },
    dominantFamilies: ["Hip-Hop / Rap", "R&B", "Pop"],
    baseSkipRate: 0.341,
    genreMatchSensitivity: 0.02,
    outlierPlayThreshold: 15,
  },

  korenns: {
    username: "korenns",
    displayName: "Koren",
    genreProfile: {
      "Hip-Hop / Rap": 0.34,
      "Drum & Bass / Dubstep": 0.19,
      "Soul / Funk": 0.09,
      "R&B": 0.06,
      Electronic: 0.05,
      "Ambient / Lo-Fi": 0.04,
      "House / Techno": 0.03,
    },
    dominantFamilies: [
      "Hip-Hop / Rap",
      "Drum & Bass / Dubstep",
      "Soul / Funk",
      "R&B",
      "Electronic",
    ],
    baseSkipRate: 0.275,
    genreMatchSensitivity: 0.1,
    outlierPlayThreshold: 20,
  },
};

export const USER_LIST = Object.values(USERS);
