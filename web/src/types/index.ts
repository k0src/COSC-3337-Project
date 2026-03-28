export type Username = "alanjzamora" | "dasucc" | "alexxxxxrs" | "korenns";

export type DisplayName = "Alan" | "Anthony" | "Alexandra" | "Koren";

export interface UserConfig {
  username: Username;
  displayName: DisplayName;
  color: string;
}

export const USERS: UserConfig[] = [
  {
    username: "alanjzamora",
    displayName: "Alan",
    color: "var(--color-user-alan)",
  },
  {
    username: "dasucc",
    displayName: "Anthony",
    color: "var(--color-user-anthony)",
  },
  {
    username: "alexxxxxrs",
    displayName: "Alexandra",
    color: "var(--color-user-alexandra)",
  },
  {
    username: "korenns",
    displayName: "Koren",
    color: "var(--color-user-koren)",
  },
];

export const DISPLAY_NAME_TO_USERNAME: Record<DisplayName, Username> = {
  Alan: "alanjzamora",
  Anthony: "dasucc",
  Alexandra: "alexxxxxrs",
  Koren: "korenns",
};

export const USERNAME_TO_DISPLAY: Record<Username, DisplayName> = {
  alanjzamora: "Alan",
  dasucc: "Anthony",
  alexxxxxrs: "Alexandra",
  korenns: "Koren",
};

export type TimePeriod = "alltime" | "2024" | "2025";
