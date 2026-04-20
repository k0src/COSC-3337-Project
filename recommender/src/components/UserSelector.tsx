import styles from "./UserSelector.module.css";
import { UserInfo } from "../types";

interface Props {
  users: UserInfo[];
  activeUser: UserInfo | null;
  onChange: (user: UserInfo) => void;
}

const AVATARS: Record<string, string> = {
  alanjzamora: "A",
  alexxxxxrs: "Ax",
  dasucc: "An",
  korenns: "K",
};

export default function UserSelector({ users, activeUser, onChange }: Props) {
  return (
    <div className={styles.selector}>
      {users.map((user) => (
        <button
          key={user.username}
          className={`${styles.btn} ${activeUser?.username === user.username ? styles.active : ""}`}
          onClick={() => onChange(user)}
        >
          <span className={styles.avatar}>
            {AVATARS[user.username] ?? user.displayName[0]}
          </span>
          <span className={styles.name}>{user.displayName}</span>
        </button>
      ))}
    </div>
  );
}
