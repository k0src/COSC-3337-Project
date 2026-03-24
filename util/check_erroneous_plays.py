import os
import re
import json
import time
import requests
from collections import defaultdict
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

sb = create_client(SUPABASE_URL, SUPABASE_KEY)

SLEEP = 1.0
MB_BASE = "https://musicbrainz.org/ws/2"
HEADERS = {"User-Agent": "lastfm-ds-project/1.0 (your@email.com)"}
MB_THRESHOLD = 60000
OUTPUT_FILE = "suspicious_plays.json"

STRIP_PATTERN = re.compile(
    r"[\(\[]["
    r"feat\.|ft\.|featuring|with\s|"
    r"vip\s|original\s|radio\s|extended\s|"
    r"remix|remaster|mix|edit|version|live|acoustic|instrumental|explicit"
    r"][^\)\]]*[\)\]]",
    re.IGNORECASE,
)


def strip_title(s: str) -> str:
    s = STRIP_PATTERN.sub("", s)
    s = re.sub(r"\(\s*\)|\[\s*\]", "", s)
    return s.strip().lower()


def strip_artist(s: str) -> str:
    s = STRIP_PATTERN.sub("", s)
    s = re.sub(r"\s+(feat\.|ft\.|featuring|with)\s+.*$", "", s, flags=re.IGNORECASE)
    return s.strip().lower()


def artists_match(query_artist: str, result_artist: str) -> bool:
    base_query = strip_artist(query_artist)
    base_result = strip_artist(result_artist)
    return base_query in base_result or base_result in base_query


def mb_get_duration(track_name: str, artist_name: str) -> int | None:
    clean_title = strip_title(track_name)
    clean_artist = strip_artist(artist_name)

    params = {
        "query": f'recording:"{clean_title}" AND artist:"{clean_artist}"',
        "fmt": "json",
        "limit": 10,
    }
    try:
        resp = requests.get(
            f"{MB_BASE}/recording", params=params, headers=HEADERS, timeout=10
        )
        resp.raise_for_status()
        time.sleep(SLEEP)
        recordings = resp.json().get("recordings", [])
        if not recordings:
            return None

        lengths = []
        for rec in recordings:
            credits = rec.get("artist-credit", [])
            result_artist = "".join(
                c.get("artist", {}).get("name", "") if isinstance(c, dict) else c
                for c in credits
            ).strip()

            if not artists_match(artist_name, result_artist):
                continue

            if rec.get("length"):
                lengths.append(rec["length"])

        return max(lengths) if lengths else None

    except Exception as e:
        print(f"  [ERROR] {e}")
        time.sleep(SLEEP)
        return None


print("Fetching suspicious rows (ms_played > 600000)...")
rows = []
offset = 0
page = 1000
while True:
    resp = (
        sb.table("listening_history")
        .select("username, timestamp, track_name, artist_name, ms_played")
        .gt("ms_played", 600000)
        .order("timestamp")
        .range(offset, offset + page - 1)
        .execute()
    )
    rows.extend(resp.data)
    if len(resp.data) < page:
        break
    offset += page

print(f"Found {len(rows):,} rows.\n")

track_map = defaultdict(list)
for row in rows:
    key = (row["track_name"], row["artist_name"])
    track_map[key].append(
        {
            "timestamp": row["timestamp"],
            "ms_played": row["ms_played"],
            "username": row["username"],
        }
    )

print(f"Unique (track, artist) combinations: {len(track_map)}\n")

manual_review = {}
erroneous = {}

total = len(track_map)
for i, ((track_name, artist_name), instances) in enumerate(track_map.items()):
    max_ms = max(inst["ms_played"] for inst in instances)
    print(f"[{i+1}/{total}] {track_name} — {artist_name}  ({max_ms/1000/60:.1f} min)")
    print(f"  stripped → '{strip_title(track_name)}' by '{strip_artist(artist_name)}'")

    mb_duration = mb_get_duration(track_name, artist_name)
    key = f"{track_name} ||| {artist_name}"

    if mb_duration is None:
        print(f"  → No matching result — manual review")
        manual_review[key] = instances
        continue

    erroneous_instances = [
        inst for inst in instances if inst["ms_played"] > mb_duration + MB_THRESHOLD
    ]

    if erroneous_instances:
        print(
            f"  → MB max: {mb_duration/1000/60:.1f} min — {len(erroneous_instances)} erroneous instance(s)"
        )
        erroneous[key] = erroneous_instances
    else:
        print(f"  → MB max: {mb_duration/1000/60:.1f} min — OK")

output = {
    "manual_review": manual_review,
    "erroneous_songs": erroneous,
}

with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    json.dump(output, f, indent=2, default=str)

print(f"\nManual review : {len(manual_review)} unique tracks")
print(f"Erroneous     : {len(erroneous)} unique tracks")
print(f"Written to {OUTPUT_FILE}")
