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

export interface RecommendationsResponse {
  tracks: ScoredTrack[];
  total: number;
}

export interface UserInfo {
  username: string;
  displayName: string;
  dominantFamilies: string[];
}
