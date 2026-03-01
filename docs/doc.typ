data collection + preprocessing

```
schema:
- track_id: spotify uri
- timestamp: listened at
- username: listener
- track_name
- artist_name
- album_name (nullable)
- platform: app, desktop, tv, etc
- conn_country: what country the song was played in
- reason_end: skipped, trackdone, etc
- reason_start: trackdone, autoplay, etc
- shuffle: bool
- skipped: bool
- offline: bool
```

+ download data from spotify https://www.spotify.com/us/account/privacy/
  - this gives you a zip file with a bunch of json files
  - extract
  - keep only music stuff
  - json array with:
    ```json
    {
      "ts": "2026-02-02T01:15:20Z",
      "platform": "windows",
      "ms_played": 296413,
      "conn_country": "US",
      "ip_addr": "129.7.0.128",
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
+ decide which attributes to keep (get rid of nulls)
+ give them better names
+ central data store
  - i used supabase - postgresql db
+ import data to supabase
  - schema here - pk
  - username column to distinguish 
  - show import_spotify.py
+ prune: songs with 1 play and less than 30s played
  - show prune.py
  - after pruning X songs left 
+ no missing vals
+ no integration besides combining multiple peoples data
+ data normalizing: 
  - timestamp to datetime
+ redundancy & correlation analysis:
  - correlation matrix - ms_played and skipped are correlated, but not strongly
  - redundancy: none - spotify uri is unique but we have 871k entries - spotify will time you out after like 5 api calls - no
- other data preprocessing steps for Spotify play data:
  - get rid of duplicates in terms of pk - (username, timestamp) - who know how that even happens

Exploratory Data Analysis

+ outliers
  - extreme values (for any/all attributes)
  - irregular data points
  - visualize them
  - z-score?
  - iqr
+ univariate analysis
  - distributions
  - skewness
  - outliers
  - histograms
  - boxplots
  - q-q plots
  - counts, unique counts
  - ranges, sd, mean, median, mode
  - 5 num
+ bivariate analysis &/or
+ multivariate analysis
  - scatterplots - numeric pairs
  - bar plots - categorical
  - correlations - matrix
  - group comparisons - differences across categories - pivot tables
  - distributions
  - bubble chart
  - heat map 
  - run/line chart
  - pair plots
  - pca?
  - time series analysis
+ K-means clustering
+ transformation?
  - scaling?
  - encoding?
+ simple predictive models
  - linear/multiple linear regression
+ visualizing insights
+ patterns
+ anomalies

dataset info
- approx 872k listening events
- 4 people
- time span: 2015-2026 (full overlap from 2020-2026) 
- no missing values

Exploratory Data Analysis

Structural overview

Summary stats:

```
Summary Statistics

Group Statistics

Total number of listening events: 844165
Number of unique tracks: 30717
Number of unique artists: 5929
Number of unique albums: 13533
Number of unique platforms: 275
Number of unique countries: 19

Individual Statistics

Total Listening Events per User:
Anthony: 72483 total listening events
Alexandra: 139541 total listening events
Koren: 181858 total listening events
Alan: 450283 total listening events

Unique Tracks per User:
Anthony: 9066 unique tracks
Alexandra: 5249 unique tracks
Koren: 15188 unique tracks
Alan: 10569 unique tracks

Unique Artists per User:
Anthony: 1296 unique artists
Alexandra: 1064 unique artists
Koren: 4039 unique artists
Alan: 1695 unique artists

Unique Albums per User:
Anthony: 4252 unique albums
Alexandra: 2349 unique albums
Koren: 7954 unique albums
Alan: 3769 unique albums

Unique Platforms per User:
Anthony: 24 unique platforms
Alexandra: 75 unique platforms
Koren: 143 unique platforms
Alan: 48 unique platforms

Unique Countries per User:
Anthony: 2 unique countries
Alexandra: 4 unique countries
Koren: 5 unique countries
Alan: 16 unique countries
```

- summary_statistics.jl
- simple sql queries
- count rows
  
Univariate analysis

Bivariate analysis

Multivariate analysis

Temporal analysis

Behavioral pattern exploration

Group-level comparison analysis

Dimensional reduction and early unsupervised structure

Preliminary predictive framing

Story construction