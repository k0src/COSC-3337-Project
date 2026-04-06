import { Routes, Route } from "react-router-dom";
import { Sidebar } from "@components";
import { Dashboard, UserDashboard } from "@pages";
import styles from "./App.module.css";

export default function App() {
  return (
    <div className={styles.layout}>
      <Sidebar />
      <main className={styles.main}>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/user/:username" element={<UserDashboard />} />
        </Routes>
      </main>
    </div>
  );
}
