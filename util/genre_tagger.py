import os
import json
import time
import requests
import tkinter as tk
from tkinter import ttk, messagebox

SLEEP = 1
MB_BASE = "https://musicbrainz.org/ws/2"
HEADERS = {"User-Agent": "lastfm-ds-project/1.0 (your@email.com)"}
OUTPUT_FILE = "genres.json"
INPUT_FILE = "artists.csv"
MB_RESULTS = 5

LEAKER_GENRE_PRESETS = {
    "Playboi Carti": [
        "plugg",
        "trap",
        "punk rap",
        "rage",
    ],
    "Juice WRLD": [
        "trap",
        "emo rap",
        "soundcloud rap",
        "melodic trap",
    ],
    "Trippie Redd": [
        "trap",
        "emo rap",
        "hip hop",
        "melodic hip hop",
    ],
    "Travis Scott": [
        "trap",
        "hip hop",
        "psychedelic trap",
        "abstract hip hop",
        "pop rap",
        "melodic hip hop",
    ],
    "Kanye West": [
        "pop",
        "electronic",
        "soul",
        "hip hop",
        "chicago hip hop",
        "pop rap",
        "abstract hip hop",
    ],
    "Lil Uzi Vert": ["punk rap", "emo rap", "rage rap", "melodic hip hop", "trap"],
    "XXXTENTACION": [
        "emo rap",
        "trap",
        "indie rock",
        "hip hop",
        "rage rap",
        "alternative hip hop",
    ],
}


def fetch_all_artists() -> list[str]:
    import csv

    print(f"Loading artists from {INPUT_FILE}...")
    artists = []
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get("artist_name", "").strip()
            if name:
                artists.append(name)
    print(f"Loaded {len(artists)} artists.")
    return sorted(artists)


def load_existing() -> dict:
    if os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_genres(data: dict):
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def mb_search_artist(name: str) -> list[dict]:
    params = {
        "query": f'artist:"{name}"',
        "fmt": "json",
        "limit": MB_RESULTS,
        "inc": "tags",
    }
    try:
        resp = requests.get(
            f"{MB_BASE}/artist", params=params, headers=HEADERS, timeout=10
        )
        resp.raise_for_status()
        time.sleep(SLEEP)
        return resp.json().get("artists", [])
    except Exception as e:
        print(f"  [ERROR] MB search failed for '{name}': {e}")
        time.sleep(SLEEP)
        return []


def mb_get_artist_tags(mbid: str) -> list[dict]:
    params = {"inc": "tags", "fmt": "json"}
    try:
        resp = requests.get(
            f"{MB_BASE}/artist/{mbid}", params=params, headers=HEADERS, timeout=10
        )
        resp.raise_for_status()
        time.sleep(SLEEP)
        return resp.json().get("tags", [])
    except Exception as e:
        print(f"  [ERROR] MB tag fetch failed for {mbid}: {e}")
        time.sleep(SLEEP)
        return []


def filter_tags(tags: list[dict]) -> list[dict]:
    """Keep only tags with count >= 1, sorted descending."""
    return sorted(
        [t for t in tags if t.get("count", 0) >= 1],
        key=lambda t: t["count"],
        reverse=True,
    )


class GenreTagger:
    def __init__(self, root: tk.Tk):
        self.ui_font = "Helvetica"
        self.root = root
        self.root.title("Genre Tagger")
        self.root.geometry("600x700")
        self.root.resizable(False, True)

        self.genres_data = load_existing()
        self.all_artists = fetch_all_artists()

        self.pending = [a for a in self.all_artists if a not in self.genres_data]
        self.total = len(self.all_artists)
        print(
            f"{len(self.pending)} artists remaining, {self.total - len(self.pending)} already done."
        )

        self.current_idx = 0
        self.mb_candidates = []
        self.mb_candidate_idx = 0
        self.tag_vars = {}
        self.manual_mode = False

        self._build_ui()

        if self.pending:
            self._load_artist(0)
        else:
            messagebox.showinfo("Done", "All artists already tagged.")
            self.root.quit()

    def _build_ui(self):
        pad = {"padx": 12, "pady": 6}

        self.progress_var = tk.StringVar()
        tk.Label(
            self.root,
            textvariable=self.progress_var,
            font=(self.ui_font, 10),
            fg="gray",
        ).pack(anchor="w", **pad)

        self.name_var = tk.StringVar()
        name_row = tk.Frame(self.root)
        name_row.pack(anchor="w", padx=12, pady=(6, 0), fill="x")
        self.name_label = tk.Label(
            name_row, textvariable=self.name_var, font=(self.ui_font, 18, "bold")
        )
        self.name_label.pack(side="left")
        tk.Button(
            name_row,
            text="📋",
            font=(self.ui_font, 12),
            bd=0,
            cursor="hand2",
            padx=2,
            command=self._copy_artist,
        ).pack(side="left", padx=(4, 0))
        tk.Button(
            name_row,
            text="🎵",
            font=(self.ui_font, 12),
            bd=0,
            cursor="hand2",
            padx=2,
            command=self._open_spotify,
        ).pack(side="left", padx=(4, 0))

        tk.Button(
            name_row,
            text="🔍",
            font=(self.ui_font, 12),
            bd=0,
            cursor="hand2",
            padx=2,
            command=self._open_google,
        ).pack(side="left", padx=(4, 0))

        self.info_var = tk.StringVar()
        tk.Label(
            self.root,
            textvariable=self.info_var,
            font=(self.ui_font, 11),
            fg="#555555",
            wraplength=560,
            justify="left",
        ).pack(anchor="w", padx=12, pady=(0, 6))

        self.wrong_btn = tk.Button(
            self.root,
            text="Wrong artist?",
            command=self._next_candidate,
            font=(self.ui_font, 10),
            fg="#cc6600",
        )
        self.wrong_btn.pack(anchor="w", padx=12)

        ttk.Separator(self.root, orient="horizontal").pack(fill="x", padx=12, pady=8)

        tk.Label(self.root, text="Tags:", font=(self.ui_font, 12, "bold")).pack(
            anchor="w", padx=12
        )

        tag_outer = tk.Frame(self.root)
        tag_outer.pack(fill="both", expand=True, padx=12, pady=4)

        self.tag_canvas = tk.Canvas(tag_outer, height=320, highlightthickness=0)
        scrollbar = ttk.Scrollbar(
            tag_outer, orient="vertical", command=self.tag_canvas.yview
        )
        self.tag_canvas.configure(yscrollcommand=scrollbar.set)
        scrollbar.pack(side="right", fill="y")
        self.tag_canvas.pack(side="left", fill="both", expand=True)

        self.tag_frame = tk.Frame(self.tag_canvas)
        self.tag_canvas_window = self.tag_canvas.create_window(
            (0, 0), window=self.tag_frame, anchor="nw"
        )
        self.tag_frame.bind(
            "<Configure>",
            lambda e: self.tag_canvas.configure(
                scrollregion=self.tag_canvas.bbox("all")
            ),
        )
        self.tag_canvas.bind(
            "<Configure>",
            lambda e: self.tag_canvas.itemconfig(self.tag_canvas_window, width=e.width),
        )

        self.tag_canvas.bind_all(
            "<MouseWheel>",
            lambda e: self.tag_canvas.yview_scroll(int(-1 * (e.delta / 120)), "units"),
        )

        add_frame = tk.Frame(self.root)
        add_frame.pack(fill="x", padx=12, pady=6)
        tk.Label(add_frame, text="Add genre:", font=(self.ui_font, 11)).pack(
            side="left"
        )
        self.add_entry = tk.Entry(add_frame, font=(self.ui_font, 11))
        self.add_entry.pack(side="left", padx=6, fill="x", expand=True)
        self.add_entry.bind("<Return>", lambda e: self._add_custom_tag())
        tk.Button(
            add_frame,
            text="+",
            font=(self.ui_font, 13, "bold"),
            command=self._add_custom_tag,
        ).pack(side="left", fill="y")

        btn_frame = tk.Frame(self.root)
        btn_frame.pack(fill="x", padx=12, pady=10)
        tk.Button(
            btn_frame,
            text="Skip (unknown)",
            font=(self.ui_font, 12),
            fg="gray",
            command=self._skip,
            width=20,
        ).pack(side="left", fill="x", expand=True, padx=(0, 6))

        self.leaker_btn = tk.Menubutton(
            btn_frame,
            text="Leaker",
            font=(self.ui_font, 12),
            width=20,
            relief="raised",
            direction="below",
        )
        self.leaker_menu = tk.Menu(self.leaker_btn, tearoff=False)
        for artist_name in LEAKER_GENRE_PRESETS:
            self.leaker_menu.add_command(
                label=artist_name,
                command=lambda name=artist_name: self._assign_leaker(name),
            )
        self.leaker_btn.configure(menu=self.leaker_menu)
        self.leaker_btn.pack(side="left", fill="x", expand=True, padx=(0, 6))

        tk.Button(
            btn_frame,
            text="Accept",
            font=(self.ui_font, 13, "bold"),
            fg="black",
            command=self._accept,
            width=20,
        ).pack(side="right", fill="x", expand=True)

        self.root.bind("<F5>", lambda e: self._accept())

    def _open_spotify(self):
        import urllib.parse
        import subprocess
        import sys

        name = (
            self.pending[self.current_idx]
            if self.current_idx < len(self.pending)
            else ""
        )
        query = urllib.parse.quote(name)
        uri = f"spotify:search:{query}"
        if sys.platform == "darwin":
            subprocess.run(["open", uri])
        elif sys.platform == "win32":
            subprocess.run(["start", uri], shell=True)
        else:
            subprocess.run(["xdg-open", uri])

    def _copy_artist(self):
        name = (
            self.pending[self.current_idx]
            if self.current_idx < len(self.pending)
            else ""
        )
        self.root.clipboard_clear()
        self.root.clipboard_append(name)

    def _open_google(self):
        import urllib.parse
        import subprocess
        import sys

        name = (
            self.pending[self.current_idx]
            if self.current_idx < len(self.pending)
            else ""
        )
        query = urllib.parse.quote(f"{name} genre")
        url = f"https://www.google.com/search?q={query}"
        if sys.platform == "darwin":
            subprocess.run(["open", url])
        elif sys.platform == "win32":
            subprocess.run(["start", url], shell=True)
        else:
            subprocess.run(["xdg-open", url])

    def _load_artist(self, idx: int):
        if idx >= len(self.pending):
            messagebox.showinfo("Done", f"All {self.total} artists tagged!")
            self.root.quit()
            return

        self.current_idx = idx
        self.mb_candidates = []
        self.mb_candidate_idx = 0
        self.manual_mode = False

        artist_name = self.pending[idx]
        done_count = (self.total - len(self.pending)) + idx
        self.progress_var.set(
            f"{done_count + 1} / {self.total} - {len(self.genres_data)} saved"
        )
        self.name_var.set(artist_name)

        print(f"\n[{done_count+1}/{self.total}] Searching: {artist_name}")
        self.mb_candidates = mb_search_artist(artist_name)

        if self.mb_candidates:
            self._show_candidate(0)
        else:
            self._enter_manual_mode()

    def _show_candidate(self, idx: int):
        if idx >= len(self.mb_candidates):
            self._enter_manual_mode()
            return

        self.mb_candidate_idx = idx
        artist = self.mb_candidates[idx]

        parts = []
        if artist.get("type"):
            parts.append(artist["type"])
        if artist.get("country"):
            parts.append(artist["country"])
        if artist.get("disambiguation"):
            parts.append(artist["disambiguation"])
        self.info_var.set("  ·  ".join(parts) if parts else "")

        self.wrong_btn.config(state="normal")

        tags = artist.get("tags", [])
        if not tags and artist.get("id"):
            tags = mb_get_artist_tags(artist["id"])

        filtered = filter_tags(tags)
        self._render_tags(filtered, auto_select=3)

    def _enter_manual_mode(self):
        self.manual_mode = True
        self.info_var.set("Artist not found on MusicBrainz")
        self.wrong_btn.config(state="disabled")
        self._render_tags([], auto_select=0)

    def _next_candidate(self):
        self._show_candidate(self.mb_candidate_idx + 1)

    def _render_tags(self, tags: list[dict], auto_select: int):
        for widget in self.tag_frame.winfo_children():
            widget.destroy()
        self.tag_vars = {}

        for i, tag in enumerate(tags):
            name = tag["name"]
            count = tag["count"]
            var = tk.BooleanVar(value=(i < auto_select))
            self.tag_vars[name] = var

            row = tk.Frame(self.tag_frame)
            row.pack(anchor="w", pady=1)

            cb = tk.Checkbutton(row, variable=var, font=(self.ui_font, 11))
            cb.pack(side="left")

            label_text = f"{name} ({count})"
            tk.Label(row, text=label_text, font=(self.ui_font, 11)).pack(side="left")

        self.tag_canvas.yview_moveto(0)

    def _add_custom_tag(self):
        text = self.add_entry.get().strip().lower()
        if not text:
            return
        if text in self.tag_vars:
            self.tag_vars[text].set(True)
            self.add_entry.delete(0, tk.END)
            return

        var = tk.BooleanVar(value=True)
        self.tag_vars[text] = var

        row = tk.Frame(self.tag_frame)
        row.pack(anchor="w", pady=1)
        cb = tk.Checkbutton(row, variable=var, font=(self.ui_font, 11))
        cb.pack(side="left")
        tk.Label(
            row, text=f"{text}  (manual)", font=(self.ui_font, 11), fg="#1565c0"
        ).pack(side="left")

        self.add_entry.delete(0, tk.END)
        self.tag_frame.update_idletasks()
        self.tag_canvas.yview_moveto(1.0)

    def _accept(self):
        selected = [name for name, var in self.tag_vars.items() if var.get()]
        artist_name = self.pending[self.current_idx]
        self.genres_data[artist_name] = selected
        save_genres(self.genres_data)
        print(f"  Saved: {artist_name} → {selected}")
        self._load_artist(self.current_idx + 1)

    def _skip(self):
        artist_name = self.pending[self.current_idx]
        self.genres_data[artist_name] = ["unknown"]
        save_genres(self.genres_data)
        print(f"  Skipped: {artist_name}")
        self._load_artist(self.current_idx + 1)

    def _assign_leaker(self, preset_artist: str):
        artist_name = self.pending[self.current_idx]
        self.genres_data[artist_name] = list(LEAKER_GENRE_PRESETS[preset_artist])
        save_genres(self.genres_data)
        print(f"  Leaker mapped: {artist_name} -> {preset_artist}")
        self._load_artist(self.current_idx + 1)


if __name__ == "__main__":
    root = tk.Tk()
    app = GenreTagger(root)
    root.mainloop()
