data collection + preprocessing

- todo: make sys image

```
schema:
- track_id: spotify uri
- timestamp: listened at
- ms_played: how long the song was played for in ms
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

Total listening events: 844165
Unique tracks: 30717
Unique artists: 5929
Unique albums: 13533
Unique platforms: 275
Unique countries: 19

Individual Statistics

Alan:
  Total events: 450283
  Unique tracks: 10569
  Unique artists: 1695
  Unique albums: 3769
  Unique platforms: 48
  Unique countries: 16
Alexandra:
  Total events: 139541
  Unique tracks: 5249
  Unique artists: 1064
  Unique albums: 2349
  Unique platforms: 75
  Unique countries: 4
Anthony:
  Total events: 72483
  Unique tracks: 9066
  Unique artists: 1296
  Unique albums: 4252
  Unique platforms: 24
  Unique countries: 2
Koren:
  Total events: 181858
  Unique tracks: 15188
  Unique artists: 4039
  Unique albums: 7954
  Unique platforms: 143
  Unique countries: 5
```

- summary_statistics.jl
- simple sql queries
- count rows
- insights:
  - lot of events - 11 years of data
  - lots of unique tracks, artists, albums, platforms, countries
  - platforms? - they are mostly different versions of ios (iphone, ipad, diff updates) & android (diff updates, phones, tablets) - possible to see exactly what device was used to listen and when
    - cast, home, web player, smart tv, win 10, 11, macos, linux
  - countries:
    - koren - us, ca (correct, mostly us) - also gb and switzerland - prob vpn
    - alan - many - either travel or vpn
  - users have different listening habits - some listen to more unique tracks, artists, albums, platforms, countries than others
  - top listener by raw numbers: alan - 450k events
  - top listener by unique tracks: koren - 15k unique tracks
  - top listener by unique artists: koren - 4k unique artists
  - top listener by unique albums: koren - 7k unique albums
  - top listener by unique platforms: koren - 143 unique platforms
  - include runners up here and do comparisons
  - insights about listening habits - alan listens to a lot of music but not as much variety as me
  - i listen to a lot of music with a lot of variety
    - 181k events but 15k unique tracks, 4k unique artists, 7k unique albums, 143 unique platforms, 5 unique countries
  - alan - has fav artists and albums - listens to them a lot - less variety - but still wins by raw numbers 
    - 450k events but only 10k unique tracks, 1.7k unique artists, 3.7k unique albums, 48 unique platforms, 16 unique countries
  - others:
    - anthony - 72k events but only 9k unique tracks, 1.3k unique artists, 4.2k unique albums, 24 unique platforms, 2 unique countries
    - alexandra - 139k events but only 5k unique tracks, 1k unique artists, 2.3k unique albums, 75 unique platforms, 4 unique countries
  - lowest listener by raw numbers: anthony - 72k events
  - lowest listener by unique tracks: alexandra - 5k unique tracks
  - lowest listener by unique artists: alexandra - 1k unique artists - also anthony - 1.3k unique artists - they have fav artists they listen to a lot but not as much variety
  - lowest listener by unique albums: alexandra - 2.3k unique albums
  - lowest listener by unique platforms: anthony - 24 unique platforms
  - lowest listener by unique countries: anthony - 2 unique countries - only a few devices, and doesnt use vpn or travel much
  - overall - lot of variety in listening habits - some people listen to a lot of music but not as much variety, while others listen to a lot of music with a lot of variety - keep in mind tho 11 years

  follow up:

  - more detailed analysis of listening habits - what artists, albums, platforms, countries do they listen to the most? - top 10 artists, albums, platforms, countries for each user - compare and contrast
  - also look at temporal patterns - when do they listen to music? - time of day, day of week, month, year - do they have different listening habits at different times? - do they listen to more music on weekends or weekdays? - do they listen to more music in certain months or years? - do they have different listening habits at different times of day? - do they listen to more music in the morning, afternoon, evening, night?
  - also look at behavioral patterns - do they skip songs a lot? - do they listen to a lot of music offline? - do they shuffle a lot? - do they have different listening habits when they are offline vs online? - do they have different listening habits when they are shuffling vs not shuffling? - do they have different listening habits when they are skipping vs not skipping?
  - also look at group-level comparisons - do they have similar listening habits? - do they listen to the same artists, albums, platforms, countries? - do they have similar temporal patterns? - do they have similar behavioral patterns? - do they have similar listening habits overall?
  - also look at dimensional reduction and early unsupervised structure - can we find any patterns in the data? - can we cluster users based on their listening habits? - can we find any latent factors that explain their listening habits? - can we find any interesting patterns in the data that we didnt expect?
  - also look at preliminary predictive framing - can we predict how much music they will listen to in the future? - can we predict what artists, albums, platforms, countries they will listen to in the future? - can we predict when they will listen to music in the future? - can we predict their behavioral patterns in the future? - can we predict their group-level comparisons in the future? - can we predict their dimensional reduction and early unsupervised structure in the future?
  - also story telling - over time

summary stats: visualizations

- bar chart per user for:
  - total listening events - total_listening_events_per_user.png
  - unique tracks - unique_tracks_per_user.png
  - unique artists - unique_artists_per_user.png
  - unique albums - unique_albums_per_user.png
- ratio plots for:
  - unique tracks / total listening events
- for timestamp vs listening events:
  - line chart for each user over time - events_over_time.png
- listening clock - listening_times_name.png - clock plot for each user showing when they listen to music
- explain all the functions & methodology 

Univariate analysis

- averages - group and per user:

```
Group Averages

Average ms_played: 75742.9187
Average skip rate: 0.2466
Average shuffle rate: 0.6784
Average offline rate: 0.0112
Average daily plays: 370.6499
Average daily unique tracks: 256.3604
Average daily unique artists: 111.6732
Average monthly plays: 9245.0903
Average yearly plays: 103819.4117

User Averages

User: Alan
  Average ms_played: 59069.6243
  Average skip rate: 0.2598
  Average shuffle rate: 0.6332
  Average offline rate: 0.0013
  Average daily plays: 289.1867
  Average daily unique tracks: 170.2235
  Average daily unique artists: 51.7361
  Average monthly plays: 6738.8346
  Average yearly plays: 73728.5447

User: Alexandra
  Average ms_played: 125910.0511
  Average skip rate: 0.1175
  Average shuffle rate: 0.9329
  Average offline rate: 0.0498
  Average daily plays: 69.8994
  Average daily unique tracks: 62.4683
  Average daily unique artists: 36.378
  Average monthly plays: 1285.7449
  Average yearly plays: 14565.6158

User: Anthony
  Average ms_played: 91987.2519
  Average skip rate: 0.3411
  Average shuffle rate: 0.5382
  Average offline rate: 0.004
  Average daily plays: 150.382
  Average daily unique tracks: 129.8723
  Average daily unique artists: 55.8233
  Average monthly plays: 2042.6474
  Average yearly plays: 16638.1659

User: Koren
  Average ms_played: 72058.1274
  Average skip rate: 0.2753
  Average shuffle rate: 0.6512
  Average offline rate: 0.0088
  Average daily plays: 149.8734
  Average daily unique tracks: 107.9461
  Average daily unique artists: 63.8412
  Average monthly plays: 2329.4371
  Average yearly plays: 20646.4081
```

- average session rate - group and per user

```
Average session length (minutes): 35.6912

Average session length per user (minutes)

User: Alan
  Average session length: 41.358
User: Alexandra
  Average session length: 30.5397
User: Anthony
  Average session length: 44.0051
User: Koren
  Average session length: 30.4578
```

- methodology:
  - session length - 30 mins
  - if gap between two consecutive tracks > 30 mins - new session
  - assign session boundaries based on this - time diff between each track and prev one, per user
  - lag() - previous track's timestamp - mark as new session start
  - use cumulative sum of those session-start flags - assign "session id"
  - aggregate sessions to get their duration (max(timestamp) - min(timestamp)) per session
  - average those durations

derived attributes

- plays per artist (top 100) + per user
- plays per track (top 100) + per user
- plays per album (top 100) + per user

- insights...

Univariate analysis - Per year

- plays per artist (top 100) + per user
- plays per track (top 100) + per user
- plays per album (top 100) + per user

- insights...


- explain all the functions & methodology

Bivariate analysis

Multivariate analysis

Temporal analysis

Behavioral pattern exploration

Group-level comparison analysis

Dimensional reduction and early unsupervised structure

Preliminary predictive framing

Story construction