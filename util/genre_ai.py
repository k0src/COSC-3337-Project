import os
import json
import csv
import time
from dotenv import load_dotenv
from supabase import create_client
import anthropic

load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
ANTHROPIC_KEY = os.getenv("ANTHROPIC_API_KEY")

claude = anthropic.Anthropic(api_key=ANTHROPIC_KEY)

sb = create_client(SUPABASE_URL, SUPABASE_KEY)

OUTPUT_FILE = "genres.json"
ARTISTS_FILE = "artists_2024_2025.csv"
SLEEP = 0.5

SYSTEM_PROMPT = """You are a music genre expert. Given an artist name and one of their songs, return a JSON array of genre tags for that artist.

Rules:
- Return ONLY a raw JSON array of strings, no explanation, no markdown, no backticks
- Include specific subgenres rather than broad parent genres where possible, espacailly for rock songs (e.g., metalcore, easycore, midwest emo, indie rock, post-punk revival, etc.)
  - Good: ["midwest emo", "math rock", "indie rock"] for American Football
  - Bad: ["rock"] for American Football
  - Good: ["hard rock", "rock", "blues rock"] for AC/DC - here "rock" is appropriate because it IS their primary genre
- Include location-based genres ONLY when the location is part of the genre name itself
  - Good: "midwest emo", "uk drill", "memphis rap", "chicago blues", "southern hip hop"
  - Bad: "american", "british", "from illinois"
- Do NOT include: era tags (90s, 80s), mood tags (happy, sad), instrument tags (guitar), nationality tags, or spam
- Aim for 3-6 genres. More is fine if the artist genuinely spans many genres
- Don't feel forced to come up with 3 genres though. Sometimes, it's just a generic rapper. Then just hip hop and/or trap is fine. No need to invent anything else. This goes for all other kinds of artists too.
- If you truly cannot determine the genres, return an empty array []
- Use lowercase, spaces instead of dashes (e.g. "post hardcore" not "post-hardcore")
- Sepearte genre names consistently (e.g., "electro pop" not "electropop")
- If the artist is very obscure and you cannot find reliable genre information, return []
- Never guess wildly - an empty array is better than wrong genres
- Note: Be careful how you use the song name. It should be fine, but remember, the _artists_ are being classified, not songs. For example, if the artist is "Drake" and the song is "Jumpman", make sure you include "contemporary r&b", "pop rap", and "pop", for example, even though this particular _song_ would be classified as "hip hop", "rap". 

Some specific notes for genre names:
- Rap is not a genre (for this project). "hip hop", "trap", "rage", "jerk", etc, are good genres, but "rap" isn't unless it's included in the name of a specific genre, e.g., "rap rock", "comedy rap".
- "drill" refers to Chicago Drill (Chief Keef, G Herbo, etc.) Other drill genres shuld specify the location (e.g., "new york drill", "uk drill", etc.)
- Just don't add "liquid drum and bass", do "drum and bass" and "liquid funk" if it comes up. Same for "atmospheric drum and bass".
- Underground trap artists should be classifed as "underground trap". Note that "underground hip hop" is separate, underground trap includes artists like Summrs, Yeat, Duwap Kaine (all modern, from the 2010s to 2020s), and underground hip hop includes artists like Aceyalone (from the 90s), MF DOOM (90s, 2000s), and Aesop Rock (2000s to 2020s). Some of these artists probably also fall under alternative or abstract hip hop. Use your best judgement. Also remember to include their subgenres. For the underground trap examples, they would be "pluggnb", "jerk", "rage", respectively (note that those are only one and they could have more).
- Use "contemporary r&b" for modern R&B artists, r&b should be for older R&B artists, or artists whoe emulate that sound. H.E.R. = "contemporary R&B", Mint Condition = "r&b" for example.
- If it's a film score, soundtrack, video game music, etc., use "soundtrack" as the genre.
- Don't use "hardcore" as a genre (because this refers to rock and breakbeat). "post hardcore" or "happy hardcore" for example are fine though."""


def load_existing() -> dict:
    if os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_genres(data: dict):
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def load_artists() -> list[str]:
    artists = []
    with open(ARTISTS_FILE, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get("artist_name", "").strip()
            if name:
                artists.append(name)
    return artists


def get_sample_song(artist_name: str) -> str | None:
    try:
        resp = (
            sb.table("listening_history")
            .select("track_name")
            .eq("artist_name", artist_name)
            .limit(1)
            .execute()
        )
        if resp.data:
            return resp.data[0]["track_name"]
    except Exception as e:
        print(f"  [DB ERROR] {e}")
    return None


def get_genres(artist_name: str, song_title: str) -> list[str]:
    user_msg = f'Artist: "{artist_name}"\nSong: "{song_title}"\n\nReturn the genre tags for this artist as a JSON array.'

    try:
        resp = claude.messages.create(
            model="claude-haiku-4-5",
            max_tokens=256,
            system=SYSTEM_PROMPT,
            tools=[
                {"type": "web_search_20250305", "name": "web_search", "max_uses": 1}
            ],
            messages=[{"role": "user", "content": user_msg}],
            timeout=10,
        )

        text = ""
        for block in resp.content:
            if hasattr(block, "text"):
                text += block.text

        text = text.strip()
        start = text.find("[")
        end = text.rfind("]") + 1
        if start == -1 or end == 0:
            return []
        return json.loads(text[start:end])

    except Exception as e:
        print(f"  [API ERROR] {e}")
        return None


def normalize(genre: str) -> str:
    import re

    return re.sub(r"-", " ", genre).strip().lower()


if __name__ == "__main__":
    genres_data = load_existing()
    all_artists = load_artists()
    pending = [a for a in all_artists if a not in genres_data]

    print(
        f"{len(all_artists)} total artists, {len(genres_data)} already done, {len(pending)} remaining\n"
    )

    errors = []

    for i, artist_name in enumerate(pending):
        print(f"[{i+1}/{len(pending)}] {artist_name}")

        song = get_sample_song(artist_name)
        if not song:
            print(f"  No song found in DB. Skipping")
            genres_data[artist_name] = []
            save_genres(genres_data)
            continue

        print(f"  Song: {song}")
        genres = get_genres(artist_name, song)

        def save_errors():
            with open("genre_errors.json", "w", encoding="utf-8") as f:
                json.dump({"not_found": errors}, f, indent=2, ensure_ascii=False)

        if genres is None:
            print(f"  API error — adding to manual review")
            errors.append(artist_name)
            save_errors()
            time.sleep(2)
            continue

        normalized = list({normalize(g) for g in genres if g})

        if not normalized:
            print(f"  No genres found — adding to manual review")
            errors.append(artist_name)
            save_errors()
            continue

        print(f"  Genres: {normalized}")
        genres_data[artist_name] = normalized
        save_genres(genres_data)
        time.sleep(SLEEP)

    no_genres = [a for a, g in genres_data.items() if g == []]

    with open("genre_errors.json", "w", encoding="utf-8") as f:
        json.dump(
            {
                "api_errors": errors,
            },
            f,
            indent=2,
            ensure_ascii=False,
        )

    print(f"\nDone. {len(genres_data)} artists tagged.")
    print(f"API errors: {len(errors)} - not in genres.json, will retry on next run")
    print(f"No genres found: {len(no_genres)} - written to errors.json")
