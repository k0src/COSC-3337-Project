#import "template/lib.typ": *
#import "@preview/frame-it:1.2.0": *
#import "@preview/mannot:0.3.0": *
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": chart, plot
#import "@preview/wrap-it:0.1.1": *
#import calc: exp, ln, pow

#show: typsidian.with(
  title: "Spotify Data Project",
  author: "Koren Stalnaker, Alexandra Williams, Cesar Cervantes, Alan Zamora, Anthony Chen",
  footer-text: "K. Stalnaker, A. Williams, C. Cervantes, A. Zamora, A. Chen",
  course: "COSC 3337",
  show-heading-colors: false,
)

#make-title(show-outline: true, show-author: true, justify: "left", outline-depth: 2)

#pagebreak()

#show figure: set block(breakable: true)

= Data Collection

*Spotify Wrapped* is an end-of-year report of a user's Spotify listening habits, including top songs, artists, genres, and minutes listened. The goal of this project is to create something similar, by collecting the Spotify listening data from the group members, and then analyzing it to find insights and trends for each member and the group as a whole. 

Spotify provides a comprehensive record of a user's streaming history upon request via #link("https://www.spotify.com/us/account/privacy/", "Spotify's privacy settings page"), where a user can request a copy of their listening data, which includes entries for every "play event" from the first time the user plays a track on Spotify to the moment they request the data. The listening data comes in the form of a `.zip` file containing multiple JSON files for each year of listening history. Each JSON file contains an array of listening events, with attributes representing multiple aspects of that event, including the name of the track, the name of the album, the name of the artist, and the time it was played. For example, a single listening event in the JSON file looks like this:

```json
{
  "ts": "2026-02-02T01:15:20Z",
  "platform": "windows",
  "ms_played": 296413,
  "conn_country": "US",
  "master_metadata_track_name": "ラストナイト -album version-",
  "master_metadata_album_artist_name": "toe",
  "master_metadata_album_album_name": "For Long Tomorrow",
  "spotify_track_uri": "spotify:track:0Hi2e0tK8xefutVU3oE9JG",
  "episode_name": null,
  "episode_show_name": null,
  "spotify_episode_uri": null,
  "audiobook_title": null,
  "audiobook_uri": null,
  "audiobook_chapter_uri": null,
  "audiobook_chapter_title": null,
  "reason_start": "trackdone",
  "reason_end": "trackdone",
  "shuffle": true,
  "skipped": false,
  "offline": false,
  "offline_timestamp": 1769994623,
  "incognito_mode": false
},
```

Each attribute provides specific information about a single listening event:
- `ts`: A timestamp indicating when the track stopped playing in UTC (Coordinated Universal Time). 
- `platform`: The platform used when streaming the track (e.g., Windows, Android, IOS)
- `ms_played`: The number of milliseconds the stream was played for.
- `conn_country`: The country code of the country the stream was played.
- `master_metadata_track_name`: The name of the track.
- `master_metadata_album_artist_name`: The name of the artist.
- `master_metadata_album_album_name`: The name of the album.
- `spotify_track_uri`: The Spotify URI for the track; a resource identifier used by Spotify to identify the track.
- `reason_start`: The reason the track started playing (e.g., `trackdone`).
- `reason_end`: The reason the track stopped playing (e.g. `endplay`).
- `shuffle`: A boolean indicating whether the track was played in shuffle mode.
- `skipped`: A boolean indicating whether the track was skipped.
- `offline`: A boolean indicating whether the track was played while the user was offline.
- `offline_timestamp`: A timestamp indicating when the track was played while the user was offline, in Unix time.
- `incognito_mode`: A boolean indicating whether the track was played while the user was in incognito mode.

The fields `episode_name` through `audiobook_chapter_title` deal with podcasts and audiobooks, respectively. Since our project focuses on music listening habits, we will not be using these fields in our analysis.

#hr()

We were able to collect listening data for 4 users: Koren, Alexandra, Alan, and Anthony over a total span of 11 years (2025-2026), in the form of 58 total JSON files. Since Spotify provides each user's entire listening history, we can analyze each user's 2025 activity, as well as their activity during prior years, and their all-time activity, to compare trends across different time periods. Some users have more extensive listening histories than others, however, there is a full overlap in the time span of our listening history from 2020 to 2026.

= Data Preprocessing

To prepare the data for analysis, we performed several preprocessing steps. First, we extracted the relevant attributes from the JSON files and gave them more descriptive names. The data from Spotify contained some attributes that were not relevant to our analysis, such as IP address and audiobook-related fields, which we discarded. We focused on attributes that were relevant to understanding listening habits, such as track name, artist name, album name, platform, country, timestamp, ms played, reason for starting and ending the track, shuffle status, skip status, and offline status. We then imported the data into a PostgreSQL database using Supabase, to allow us to easily query and manipulate the data for preprocessing and analysis.

The database schema is as follows:

```sql
create table public.listening_history (
  track_id text not null,
  timestamp timestamp without time zone not null,
  username text not null,
  track_name text not null,
  artist_name text not null,
  album_name text null,
  platform text null,
  ms_played bigint null,
  conn_country text null,
  reason_start text null,
  reason_end text null,
  shuffle boolean null,
  skipped boolean null,
  offline boolean null,
  offline_timestamp text null,
  constraint spotify_data_pkey primary key (track_id, "timestamp", username)
);
```

The primary key is a combination of `track_id`, `timestamp`, and `username`, which ensures that each listening event is uniquely identified. This also allows us to easily compare data from multiple users while maintaining the integrity of the data.

== Basic Data Cleaning

The raw Spotify listening data totals around 890,000 rows. Using queries based on timestamps, time played, and other attributes, we can select the data we want to work with on an individual-query basis. However, there was still some noisy and erroneous data which we took steps to clean. We also formatted some attributes to be easier to work with.

*Timestamps.* Timestamps were normalized to a PostgreSQL `DATETIME` format to allow for easier querying and manipulation of time-based data. This also allows us to perform time-based calculations such as finding the total listening time for a given period.

*Duplicates.* Any duplicate events (based on the primary key combination of `track_id`, `timestamp`, and `username`) were removed from the database, to ensure that each listening event is only counted once in our analysis.

*Null/Empty Entries.* Events that had a null or empty value for any of the primary key attributes were pruned before being entered into the database. This is because these events would not be identifiable or usable in our analysis, since they would not have a unique identifier.

*Accidental Plays/Skips.* To ensure we had a clean dataset, any tracks that had a single play and less than 30 seconds played were removed from the database, since these were likely accidental plays or skips that do not reflect the user's true listening habits.

After these data cleaning steps, we were left with approximately 850,000 rows of listening events.

== Erroneous Play Data

The Spotify streaming history data export includes a `ms_played` field representing how many milliseconds of a track were played during a given listening event. In most cases this value is accurate, but a subset of records contained physically impossible values --- `ms_played` far exceeding the actual duration of the track, with no corresponding gap in the timestamp sequence to explain the discrepancy. 

Some events from the raw data imported into the database showed 1-2 hours played of a single track, which in many cases is incorrect. To ensure our data is correct, these records need to be removed. However, it is not as simple as removing the events with extremely high `ms_played` values --- some tracks are legitimately over an hour long, and if the user listened to it fully, then an `ms_played` value of 3,600,000 or more is accurate. 

For example, the song #link("https://open.spotify.com/track/5VkncTHIkxFzQyvCaHyceS", "\"Sleepygirls (Full Album) - Continuous Mix\"") appears multiple times in Koren's listening history. This track is a continuous mix of an album that is over an hour long, so an `ms_played` value of 3,600,000 or more is accurate. However, #link("https://open.spotify.com/track/1iP5UMdOsGz6EdltGbbcb7", "\"The Fire\"") appears multiple times in Alan's listening history. This song is 3 minutes and 41 seconds, but an event from the raw data for this song has a `ms_played` value of 6,083,003 (about 101 minutes), which is clearly erroneous. Note that the Spotify URI is included for each event; in this case, the URI leads to the 3:41 version of this track, meaning it is not possible that some kind of 101 minute "special edition" once existed on Spotify. Additionally, the timestamps of the surrounding events confirm that only around 4 minutes passed between the start of this track and the next track. The root cause is likely a Spotify logging bug where `ms_played` was written incorrectly for certain events, possibly during app crashes, background playback interruptions, or offline sync conflicts.

In any case, these rows need to be removed, as evaluating them as real events will lead to inflated listening times and skewed insights. Given the extremely large number of unique tracks, it is impossible to write an SQL query to remove songs with high `ms_played` values, since we do not know which songs _actually have_ long durations. For the "The Fire" example, it may seem possible to compare each same-track event instance to each other, and remove the outlier (e.g., remove all instances of "The Fire" where the time played is greater than 4 minutes). However, this fails in multiple ways. First, if a track was played once, and the `ms_played` value was erroneously reported by Spotify, we have no reference for the what the correct value is in the database alone, and this would still result in incorrect play times. Second, for tracks like "Sleepygirls", we have no idea what the actual duration of the track is from the data alone. If, for example, this song was played twice fully (at one hour play time) and then 20 times for a few minutes, we would not want to remove all events with `ms_played` less than 3,600,000, since some of those are accurate (and could also provide interesting metrics, e.g., "Koren listens to lots of long songs, but tends not to finish them"). 

=== Detection Methodology

Spotify's `timestamp` field records when a track _stopped playing_, in UTC time. This means the gap between two consecutive timestamps for the same user should roughly equal the `ms_played` of the later event. If ms_played is 101 minutes but only 4 minutes elapsed between timestamps, the value is erroneous. However, this strategy is not foolproof. For example, if in reality, "The Fire" was played for 4 minutes, and the next listening session started over an hour later, the gap between timestamps would be over an hour, which would match the erroneous `ms_played` value, and we would not be able to detect the error. So, we can handle this by checking the actual duration of the track using the #link("https://musicbrainz.org/doc/MusicBrainz_API", "MusicBrainz API"). This is a community-sourced database of songs, albums, artists, etc., containing metadata for around #link("https://musicbrainz.org/statistics", "55 million different songs"). Note that due to the high volume of data, it is not possible to use the official Spotify API. This would be a lot simpler, however the Spotify API has strict rate limits (which MusicBrainz does not have) which makes it infeasible for our use case.

A detection script which flags erroneous events functions as follows:
+ Query all rows in the database where `ms_played > 1000000` (about 16 minutes). This threshold was chosen because legitimate plays above this are rare and worth reviewing. This cuts down the number of rows that need to be checked, and thus the time the script takes to run significantly. Checking all 850k rows in this fashion would take approximately 240 hours; this cutoff reduces the time to around 4 (since an API call takes approximately one second, and we left with around 15,000 rows after the threshold). Rows are grouped by `(track_name, artist_name)` to avoid redundant API calls. For example, if "The Fire" by The Roots appears 5 times with inflated `ms_played`, only one MusicBrainz lookup is needed.
+ For each unique `(track_name, artist_name)` combination:
  + Strip parenthetical suffixes from the title, such as (feat. X), (VIP Mix), (Radio Edit), (Remaster), etc. using regex before querying MusicBrainz, since these variants often return no results without stripping due to differences in metadata encoding across the two platforms. For example, the song #link("https://open.spotify.com/track/0Y3VMlkIVyqG7Xkvdskdcz", "\"Only You (Original Mix) [2011 Remaster]\"") by Nookie does not exist in the MusicBrainz database with this exact title. However, it #link("https://musicbrainz.org/recording/1ff5772e-7cca-4db4-9c21-b118e898a643", "does exist") on MusicBrainz with the same duration and same album without the two parenthetical suffixes.
  + Query the MusicBrainz recordings endpoint for the cleaned title and artist.
  + Filter results to those whose credited artist roughly matched the query artist, using substring matching with the base artist name to handle featured artists and alternate credit formats. Only the main artist is included in the listening history export, so this allows for "RAF" by A\$AP Mob to be matched with "RAF"	by A\$AP Mob feat. A\$AP Rocky, Playboi Carti, Quavo, Lil Uzi Vert & Frank Ocean on MusicBrainz.
  + Save the _maximum_ duration across the matching recording versions; this is generous by design to avoid false positives on extended versions or remasters. For example, if the track has a radio edit version that is 3 minutes and an extended mix version that is 7 minutes, we save 7 minutes as the duration.
  + Compare each instance's `ms_played` against `mb_duration + 60,000 ms` (one minute tolerance).
  + Flag instances where `ms_played` exceeds this threshold as erroneous.
+ The results are written to a JSON file to be removed from the main `listening_history` table. Instances where MusicBrainz returned no matching result were saved to a separate `manual_review` set.

#hr()

After running the script, around 2,000 erroneous rows were detected and removed from `listening_history`, and moved to an `erroneous_plays` table with identical schema to `listening_history`. The `manual_review` songs were reviewed on a case-by-case basis by looking up the track on Spotify to compare the duration, and then either marked as valid or erroneous, and kept or removed accordingly.

== Artist Genre Classification

The Spotify listening data export does not include genres for individual songs or artists. However, in order to gain more insight on the listening habits of the users in the dataset, we wanted to determine the genre associated with each distinct artist in the listening history dataset. After cleaning the data, there are around 6,000 unique artists. The goal was to assign one or more genre tags to each one of these artists, and store them in a separate database table for later analysis, such as genre-based listening breakdowns, similarity measures, clustering, etc.

The challenge was scale and data quality. Unlike empirical metadata like the song name, duration, or album name, genres are subjective --- there is no objective listing of genres for a particular artist. However, this also means that there are many different sources that have already attempted to classify artists by genre, and a "misclassification" (e.g., assigning "electronic" to an artist instead of "house") is not as problematic as an incorrect duration value, since both tags are still informative of the artist's style. Using the MusicBrainz API (since again, the Spotify API has strict rate limits, and their genre data is #link("https://developer.spotify.com/documentation/web-api/reference/get-an-artist", "deprecated")), we can use the user tags for each artist in the database to extract genre information from. 

However, the use of MusicBrainz user tags leads to two problems. First, tags only exist for artists that both exist in the MusicBrainz database (which is the majority of artists in the listening data), and that have tags contributed by users (a much smaller fraction of the artists in the listening data). Second, the quality of the tags is consistent. For example, the following are a few of the user tags for the band Nirvana:

```json
"tags": [
  {
    "count": 20,
    "name": "rock"
  },
  {
    "count": 30,
    "name": "alternative rock"
  },
  {
    "count": 3,
    "name": "90s"
  },
  {
    "count": 8,
    "name": "american"
  },
  {
    "count": 62,
    "name": "grunge"
  },
  {
    "count": 0,
    "name": "legendary"
  },
  {
    "count": 0,
    "name": "rock and indie"
  },
  {
    "count": 0,
    "name": "kurt cobain"
  }
]
```

Some tags are actual genres we want to record (e.g., "grunge", "alternative rock", "rock"), some tags are additional information, such as locations, time periods, or band members (e.g., "90s", "american", "kurt cobain"), some tags are spam or subjective measures of taste (e.g., "legendary"), and some tags are inconsistent with the format we want for our database (e.g., "rock and indie" --- we would rather have "indie rock", or something more specific like "grunge"). 

Due to these issues, there was no clean, programmatic source that covered all 6,000 artists reliably. It is not feasible to create regex patterns to filter out the relevant tags, since the "relevance" of a tag is not determined by the tag itself, but rather by the context of the artist. For example, "rock" is a relevant tag for Nirvana, but not for Kendrick Lamar.

=== Classification Methodology

==== GUI Genre Tagger (MusicBrainz)

The first method we used was creating a manual "genre tagger" tool to tag each artist in the database, using pre-filled genre tags from the MusicBrainz database (ranked by `count`), including information on the artist from the MusicBrainz disambiguation, and methods for manually adding genre tags and searching for the artist on Spotify, or searching their genres on Google. @genre-tagger shows a screenshot of the tool, which is built using Python and the Tkinter library for the GUI. 

#figure(
  caption: "Screenshot of the GUI genre tagger tool used classify artists by genre.",
  image("assets/genre_tagger.png", width: 50%)
) <genre-tagger>

*Process.* For each unique artist from the database, the tool:
+ Queries the MusicBrainz API for the top 5 matching artist results.
+ Fetches the full tag list for the top result.
+ Filters tags to those with `count >= 1`, sorted descending by `count`.
+ Displays the artist name, type (e.g., "Person", "Group"), country, and disambiguation field for context.
+ Pre-selects the top three tags as a default accept shortcut.
+ Allows cycling through alternative MusicBrainz candidate artists via the "Wrong artist?".
+ Provides a manual text entry field for artists not found on MusicBrainz or where tags were insufficient.
+ Includes a Spotify search button and a Google search button for quick external lookup.
+ Saves artist-genre combinations to a `genres.json` file immediately on every "Accept" press.
+ Includes a "Skip" button for unknown artists. These artists are saved with `["unknown"]` as their genre tag.

*The "Leaker" button.* A non-insignificant number of listening events for multiple users come from "leaked" songs, that is, unreleased or unofficial songs uploaded by a third-party "artist" onto Spotify without the permission of the actual artist. Instead of removing these rows from the database, since these artists never break into even the top 200 artists for any user, we decided to classify the genres of these "leaker" artists as the same as the actual artist. For example, if a user listened to a leaked song by Playboi Carti, we classify the genre of the "leaker" artist as the same as Playboi Carti, since the leaked song is still informative of the user's listening habits and preferences, even if it is not an official release. 

So, the "Leaker" button opens a dropdown menu when pressed, with a few of the most common artists that have leaks in our dataset (e.g., Playboi Carti, Lil Uzi Vert, Juice WRLD). When one is selected, the genre tags for the corresponding "leaker" artist are set to be the same as the selected artist.

#hr()

Using this tool, we were able to classify around 3,000 artists. The remaining artists were classified using a semi-automated AI approach described in the next section.

==== AI Genre Tagger (Claude API)

For the remainder of the artists, we used the Claude API to classify genres based on the artist name, and one of their songs as disambiguation context, using the `claude-haiku-4-5` model.

*Process.* For each artist, the genre tagger script:
+ Queried the database for one sample track by that artist.
+ Called the Claude API with a pre-written system prompt and the artist name and track title as the user message. The Claude API searches the web for the artist and track, and then generates genre tags (formatted as a JSON object with an array of tags) based on the search results.
+ Parsed the returned JSON array of genre tags.
+ Normalized and saved to `genres.json` immediately.

*Prompt Design.* The system prompt was structured in order to produce clean, specific genre tags, in a consistent format based on the existing genre tag patterns:
- Prefer specific subgenres over broader ones, for example `["midwest emo", "indie rock"]` not `["rock"]` for American Football, but `["hard rock", "rock", "arena rock"]` for AC/DC where rock is the primary genre.
- Include location-based genres only when the location is part of the genre name itself, for example `"midwest emo"`, `"new york drill"`, is acceptable, but not `"american"`, `"german"`, `"brazilian"`, etc.
- Exclude era tags, mood tags, instrument tags, nationality tags, and spam.
- Return `[]` for truly unknown obscure artists rather than guessing.

#hr()

Using this method, we were able to classify the majority of the remaining artists, with a small number of artists manually reviewed and classified when the returned tags were clearly incorrect (e.g., if the returned tags did not match the genre of the sample track, or if the tags were too broad to be informative, e.g., `"rock"`).

=== Post-Processing & Normalization

After both methods were complete, the genre tags from the `genres.json` file were inserted into a new table in the database, `artist_genres`, with columns `artist_name` and `genre`, where the two columns serve as a compound primary key. Each artist can have multiple rows in this table, one for each genre tag.

Next, a series of post-processing and normalization scripts were run, in order to make sure tags were consistent, formatted correctly, and artists were classified accurately.

*Dash and compound normalization.* All unique genre names were queried from the table, and the tags were manually inspected to find instances of hyphenated or compound genre names, such as `hiphop`, `hip-hop`, `electropop`, `synth-pop`, etc. Using a canonical mapping table, these were normalized to a consistent format without dashes or compound names (e.g., `hip hop`, `electro pop`), and updated in the database accordingly.

*Abbreviation expansion.* Abbreviations like `"alt"` (as in `"alt rock"`) were expanded to their full form (e.g., `"alternative"`), and updated in the database accordingly.

*Alternate name normalization.* Genres with alternate names (e.g., `"rhythm and blues"`, `"r and b"`, `"dnb"`, `"drum n bass"`) were normalized to a consistent format (e.g., `"r&b"`, `"drum and bass"`), and updated in the database.

*Misspelling detection.* `difflib.get_close_matches` with a threshold of `0.8` was used to flag near-duplicate genre tags for manual review, catching names like `"undergroud trap"`, which was corrected to `"underground trap"`.

*Frequency audit.* Genres appearing only once or twice were audited for accuracy, since they may be overly specific or erroneous. In most cases, these were either removed or changed to a genre that appears more often in the dataset. However, legitimate genres were kept, such as `"amapiano"`, which only appears for one artist in the dataset.

#hr()

After preprocessing, the cleaned and normalized `artist_genres` table contains around 6,000 unique artists, and 600 unique genres. This table can now be joined with the `listening_history` table to perform genre-based analysis of listening habits, such as genre popularity over time, genre-based user similarity, and genre co-occurrence patterns.

#pagebreak()