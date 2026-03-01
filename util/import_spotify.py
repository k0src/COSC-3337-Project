import json
import glob
import os
from supabase import create_client
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
USERNAME = "alanjzamora"

sb = create_client(SUPABASE_URL, SUPABASE_KEY)

pattern = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "spotify", USERNAME, "*.json"
)
files = sorted(glob.glob(pattern))

if not files:
    print("No JSON files found")
    exit(1)

rows = []

for filepath in files:
    with open(filepath, "r", encoding="utf-8") as f:
        entries = json.load(f)

    for entry in entries:
        if not entry.get("spotify_track_uri"):
            continue

        rows.append(
            {
                "timestamp": entry.get("ts"),
                "username": USERNAME,
                "platform": entry.get("platform"),
                "ms_played": entry.get("ms_played"),
                "conn_country": entry.get("conn_country"),
                "spotify_track_uri": entry.get("spotify_track_uri"),
                "track_name": entry.get("master_metadata_track_name"),
                "artist_name": entry.get("master_metadata_album_artist_name"),
                "album_name": entry.get("master_metadata_album_album_name"),
                "reason_start": entry.get("reason_start"),
                "reason_end": entry.get("reason_end"),
                "shuffle": entry.get("shuffle"),
                "skipped": entry.get("skipped"),
                "offline": entry.get("offline"),
                "offline_timestamp": entry.get("offline_timestamp"),
            }
        )

print(f"Parsed {len(rows):,} tracks")

seen = {}
for row in rows:
    key = (row["spotify_track_uri"], row["timestamp"], row["username"])
    seen[key] = row
rows = list(seen.values())
print(f"After dedup: {len(rows):,} unique rows")

BATCH = 500
inserted = 0

for i in range(0, len(rows), BATCH):
    batch = rows[i : i + BATCH]
    sb.table("spotify_data").upsert(batch).execute()
    inserted += len(batch)

print(f"\nDone. {inserted:,} rows inserted.")
