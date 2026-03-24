import json
import os
import time
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()
sb = create_client(os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY"))

with open("a.json", "r", encoding="utf-8") as f:
    genres_data = json.load(f)

inserted = 0
skipped = 0

for artist_name, genres in genres_data.items():
    valid = [g for g in genres if g and g != "unknown"]
    if not valid:
        skipped += 1
        continue

    rows = [{"artist_name": artist_name, "genre": g} for g in valid]

    try:
        sb.table("artist_genres").upsert(rows).execute()
        inserted += len(rows)
        print(f"  ✓ {artist_name}: {valid}")
    except Exception as e:
        print(f"  [ERROR] {artist_name}: {e}")

    time.sleep(0.1)

print(f"\nDone. {inserted} rows inserted, {skipped} artists skipped.")
