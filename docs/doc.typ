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

```
Top Statistics (printing top 10)

Top Tracks (Group):

Track: 4th Dimension by KIDS SEE GHOSTS from KIDS SEE GHOSTS
  Play count: 1434
  Total minutes played: 1144.7477
Track: No More Parties In LA by Kanye West from The Life Of Pablo
  Play count: 1286
  Total minutes played: 1564.6639
Track: Gorgeous by Kanye West from My Beautiful Dark Twisted Fantasy
  Play count: 1277
  Total minutes played: 1122.6196
Track: SIRENS | Z1RENZ [FEAT. J.I.D | J.1.D] by Denzel Curry from TA13OO
  Play count: 1213
  Total minutes played: 812.7089
Track: Dark Fantasy by Kanye West from My Beautiful Dark Twisted Fantasy
  Play count: 1126
  Total minutes played: 1227.0258
Track: Father Stretch My Hands Pt. 1 by Kanye West from The Life Of Pablo
  Play count: 1105
  Total minutes played: 541.1573
Track: Devil In A New Dress by Kanye West from My Beautiful Dark Twisted Fantasy
  Play count: 1089
  Total minutes played: 1145.62
Track: POWER by Kanye West from My Beautiful Dark Twisted Fantasy
  Play count: 1080
  Total minutes played: 1557.984
Track: Alright by Kendrick Lamar from To Pimp A Butterfly
  Play count: 1064
  Total minutes played: 480.6513
Track: 90210 (feat. Kacy Hill) by Travis Scott from Rodeo
  Play count: 1055
  Total minutes played: 1278.3958

Top Artists (Group):

Artist: Kanye West
  Play count: 51490
  Total minutes played: 55710.6869
Artist: Travis Scott
  Play count: 25617
  Total minutes played: 27007.085
Artist: Kendrick Lamar
  Play count: 18005
  Total minutes played: 18389.5247
Artist: Lil Uzi Vert
  Play count: 15520
  Total minutes played: 12772.5825
Artist: Playboi Carti
  Play count: 14637
  Total minutes played: 10891.847
Artist: Drake
  Play count: 13818
  Total minutes played: 17113.379
Artist: Denzel Curry
  Play count: 13743
  Total minutes played: 12351.7533
Artist: Future
  Play count: 11924
  Total minutes played: 12610.3789
Artist: Juice WRLD
  Play count: 11261
  Total minutes played: 9878.9726
Artist: Neck Deep
  Play count: 9310
  Total minutes played: 20107.5606

Top Albums (Group):

Album: The Life Of Pablo by Kanye West
  Play count: 9899
  Total minutes played: 8538.1106
Album: My Beautiful Dark Twisted Fantasy by Kanye West
  Play count: 9393
  Total minutes played: 10773.2801
Album: Rodeo by Travis Scott
  Play count: 8591
  Total minutes played: 9829.896
Album: ASTROWORLD by Travis Scott
  Play count: 8537
  Total minutes played: 7754.1924
Album: Die Lit by Playboi Carti
  Play count: 8370
  Total minutes played: 5120.3001
Album: Goodbye & Good Riddance by Juice WRLD
  Play count: 6967
  Total minutes played: 5088.4066
Album: Late Registration by Kanye West
  Play count: 6482
  Total minutes played: 6043.2009
Album: good kid, m.A.A.d city by Kendrick Lamar
  Play count: 6255
  Total minutes played: 5781.3544
Album: The College Dropout by Kanye West
  Play count: 5445
  Total minutes played: 4654.7503
Album: NOT ALL HEROES WEAR CAPES by Metro Boomin
  Play count: 5376
  Total minutes played: 3675.6456

Top Tracks (per User):

User: Anthony
  Track: ball w/o you by 21 Savage from i am > i was
    Play count: 234
    Total minutes played: 516.4584
  Track: Father Stretch My Hands Pt. 1 by Kanye West from The Life Of Pablo
    Play count: 226
    Total minutes played: 231.3959
  Track: I Wonder by Kanye West from Graduation
    Play count: 190
    Total minutes played: 514.7784
  Track: Down Below by Roddy Ricch from Feed Tha Streets II
    Play count: 184
    Total minutes played: 418.1448
  Track: Praise The Lord (Da Shine) (feat. Skepta) by A$AP Rocky from TESTING
    Play count: 179
    Total minutes played: 341.2644
  Track: Freestyle by Lil Baby from Too Hard
    Play count: 172
    Total minutes played: 227.1322
  Track: POWER by Kanye West from My Beautiful Dark Twisted Fantasy
    Play count: 171
    Total minutes played: 446.7546
  Track: Jungle by A Boogie Wit da Hoodie from Artist
    Play count: 164
    Total minutes played: 365.6435
  Track: Flashing Lights by Kanye West from Graduation
    Play count: 160
    Total minutes played: 271.4192
  Track: No Flockin' by Kodak Black from No Flockin'
    Play count: 157
    Total minutes played: 164.8358

User: Alexandra
  Track: Sugar, We're Goin Down by Fall Out Boy from From Under The Cork Tree
    Play count: 237
    Total minutes played: 599.5486
  Track: Kali Ma by Neck Deep from Life's Not Out To Get You
    Play count: 194
    Total minutes played: 461.1912
  Track: Motion Sickness by Neck Deep from The Peace And The Panic
    Play count: 189
    Total minutes played: 545.4386
  Track: Happy Judgement Day by Neck Deep from The Peace And The Panic
    Play count: 187
    Total minutes played: 568.0204
  Track: This Is Gospel by Panic! At The Disco from Too Weird to Live, Too Rare to Die!
    Play count: 184
    Total minutes played: 461.0548
  Track: Everybody Talks by Neon Trees from Picture Show
    Play count: 181
    Total minutes played: 434.6248
  Track: LA Devotee by Panic! At The Disco from Death of a Bachelor
    Play count: 174
    Total minutes played: 458.92
  Track: I Write Sins Not Tragedies by Panic! At The Disco from A Fever You Can't Sweat Out
    Play count: 171
    Total minutes played: 352.3935
  Track: Can't Kick Up The Roots by Neck Deep from Life's Not Out To Get You
    Play count: 171
    Total minutes played: 404.8731
  Track: Hallelujah by Panic! At The Disco from Death of a Bachelor
    Play count: 170
    Total minutes played: 303.2938

User: Koren
  Track: Honcho Style 3 by Cdot Honcho from H3
    Play count: 297
    Total minutes played: 266.987
  Track: Poles 1469 by Trippie Redd from A Love Letter To You
    Play count: 278
    Total minutes played: 232.2848
  Track: Stacy's Mom by Fountains Of Wayne from Welcome Interstate Managers
    Play count: 276
    Total minutes played: 42.7488
  Track: From The D To The A (feat. Lil Yachty) by Tee Grizzley from From The D To The A (feat. Lil Yachty)
    Play count: 272
    Total minutes played: 283.3692
  Track: Money Longer by Lil Uzi Vert from Lil Uzi Vert vs. The World
    Play count: 263
    Total minutes played: 224.1773
  Track: First Day Out by Tee Grizzley from My Moment
    Play count: 262
    Total minutes played: 264.3956
  Track: Lane Changing by SOB X RBE from SOB X RBE
    Play count: 258
    Total minutes played: 290.2983
  Track: Award Tour (feat. Trugoy The Dove) by A Tribe Called Quest from Midnight Marauders
    Play count: 242
    Total minutes played: 172.7843
  Track: Anti by SOB X RBE from SOB X RBE
    Play count: 235
    Total minutes played: 233.7154
  Track: Teflon Flow by Cdot Honcho from H3
    Play count: 226
    Total minutes played: 162.4078

User: Alan
  Track: 4th Dimension by KIDS SEE GHOSTS from KIDS SEE GHOSTS
    Play count: 1371
    Total minutes played: 1058.7686
  Track: No More Parties In LA by Kanye West from The Life Of Pablo
    Play count: 1237
    Total minutes played: 1465.1925
  Track: SIRENS | Z1RENZ [FEAT. J.I.D | J.1.D] by Denzel Curry from TA13OO
    Play count: 1213
    Total minutes played: 812.7089
  Track: Gorgeous by Kanye West from My Beautiful Dark Twisted Fantasy
    Play count: 1151
    Total minutes played: 772.4116
  Track: The Games We Play by Pusha T from DAYTONA
    Play count: 1037
    Total minutes played: 590.9206
  Track: Dark Fantasy by Kanye West from My Beautiful Dark Twisted Fantasy
    Play count: 1016
    Total minutes played: 942.7341
  Track: CAN'T SAY by Travis Scott from ASTROWORLD
    Play count: 1008
    Total minutes played: 763.2827
  Track: So Appalled by Kanye West from My Beautiful Dark Twisted Fantasy
    Play count: 988
    Total minutes played: 1267.7344
  Track: Feel The Love by KIDS SEE GHOSTS from KIDS SEE GHOSTS
    Play count: 967
    Total minutes played: 562.2208
  Track: Armed And Dangerous by Juice WRLD from Goodbye & Good Riddance
    Play count: 962
    Total minutes played: 314.3084

Top Artists (per User):

User: Anthony
  Artist: Kanye West
    Play count: 6780
    Total minutes played: 14374.1085
  Artist: Drake
    Play count: 3829
    Total minutes played: 6950.29
  Artist: Future
    Play count: 2132
    Total minutes played: 4023.8215
  Artist: Young Thug
    Play count: 1959
    Total minutes played: 3475.9758
  Artist: Travis Scott
    Play count: 1457
    Total minutes played: 2865.4622
  Artist: YoungBoy Never Broke Again
    Play count: 1428
    Total minutes played: 1895.0885
  Artist: Kendrick Lamar
    Play count: 1418
    Total minutes played: 2843.7466
  Artist: Playboi Carti
    Play count: 1382
    Total minutes played: 2337.2979
  Artist: 21 Savage
    Play count: 1305
    Total minutes played: 2417.7279
  Artist: Juice WRLD
    Play count: 1234
    Total minutes played: 1849.3496

User: Alexandra
  Artist: Neck Deep
    Play count: 9308
    Total minutes played: 20104.9856
  Artist: State Champs
    Play count: 8301
    Total minutes played: 16673.2962
  Artist: Panic! At The Disco
    Play count: 7117
    Total minutes played: 13253.6459
  Artist: Beartooth
    Play count: 5603
    Total minutes played: 14609.6603
  Artist: Bring Me The Horizon
    Play count: 4320
    Total minutes played: 10041.7615
  Artist: Fall Out Boy
    Play count: 3133
    Total minutes played: 6402.6126
  Artist: blink-182
    Play count: 2697
    Total minutes played: 4216.0213
  Artist: My Chemical Romance
    Play count: 2484
    Total minutes played: 5037.6024
  Artist: mgk
    Play count: 2461
    Total minutes played: 4493.3567
  Artist: Wage War
    Play count: 2410
    Total minutes played: 6112.9877

User: Koren
  Artist: Lil Uzi Vert
    Play count: 5764
    Total minutes played: 5208.6507
  Artist: Playboi Carti
    Play count: 4323
    Total minutes played: 3762.8692
  Artist: Mint
    Play count: 4034
    Total minutes played: 6335.5558
  Artist: G Herbo
    Play count: 2820
    Total minutes played: 3026.6381
  Artist: Chief Keef
    Play count: 2732
    Total minutes played: 2310.6384
  Artist: Cdot Honcho
    Play count: 2654
    Total minutes played: 2355.9194
  Artist: Tee Grizzley
    Play count: 2000
    Total minutes played: 1763.6346
  Artist: Travis Scott
    Play count: 1807
    Total minutes played: 1387.8812
  Artist: Pi’erre Bourne
    Play count: 1789
    Total minutes played: 1826.0249
  Artist: Future
    Play count: 1642
    Total minutes played: 1494.3444

User: Alan
  Artist: Kanye West
    Play count: 43739
    Total minutes played: 40528.0545
  Artist: Travis Scott
    Play count: 22269
    Total minutes played: 22444.3132
  Artist: Kendrick Lamar
    Play count: 15485
    Total minutes played: 14646.8158
  Artist: Denzel Curry
    Play count: 13157
    Total minutes played: 11791.9312
  Artist: Juice WRLD
    Play count: 9580
    Total minutes played: 7584.6214
  Artist: Playboi Carti
    Play count: 8932
    Total minutes played: 4791.6799
  Artist: Freddie Gibbs
    Play count: 8815
    Total minutes played: 7735.7294
  Artist: Lil Uzi Vert
    Play count: 8553
    Total minutes played: 5820.1005
  Artist: Drake
    Play count: 8538
    Total minutes played: 8689.1678
  Artist: Future
    Play count: 8149
    Total minutes played: 7090.7513

Top Albums (per User):

User: Anthony
  Album: Graduation by Kanye West
    Play count: 1240
    Total minutes played: 2659.4108
  Album: My Beautiful Dark Twisted Fantasy by Kanye West
    Play count: 1051
    Total minutes played: 2975.4681
  Album: Donda by Kanye West
    Play count: 1022
    Total minutes played: 2798.1304
  Album: The Life Of Pablo by Kanye West
    Play count: 929
    Total minutes played: 1305.633
  Album: Take Care by Drake
    Play count: 638
    Total minutes played: 1309.7656
  Album: Yeezus by Kanye West
    Play count: 546
    Total minutes played: 1379.3193
  Album: Watch The Throne by JAY-Z
    Play count: 478
    Total minutes played: 557.515
  Album: The College Dropout by Kanye West
    Play count: 454
    Total minutes played: 668.7043
  Album: Death Race For Love by Juice WRLD
    Play count: 444
    Total minutes played: 737.618
  Album: i am > i was by 21 Savage
    Play count: 405
    Total minutes played: 763.0704

User: Alexandra
  Album: Life's Not Out To Get You by Neck Deep
    Play count: 1767
    Total minutes played: 4154.3688
  Album: Death of a Bachelor by Panic! At The Disco
    Play count: 1584
    Total minutes played: 3703.4185
  Album: Wishful Thinking by Neck Deep
    Play count: 1580
    Total minutes played: 2495.6433
  Album: Tickets To My Downfall by mgk
    Play count: 1533
    Total minutes played: 2834.7804
  Album: The Peace And The Panic by Neck Deep
    Play count: 1520
    Total minutes played: 3845.0621
  Album: Around the World and Back by State Champs
    Play count: 1488
    Total minutes played: 3419.7838
  Album: The Finer Things by State Champs
    Play count: 1454
    Total minutes played: 2870.9874
  Album: Around the World and Back (Deluxe) by State Champs
    Play count: 1305
    Total minutes played: 2748.7382
  Album: Too Weird to Live, Too Rare to Die! by Panic! At The Disco
    Play count: 1282
    Total minutes played: 2469.4714
  Album: Vices & Virtues by Panic! At The Disco
    Play count: 1254
    Total minutes played: 2311.7417

User: Koren
  Album: Playboi Carti by Playboi Carti
    Play count: 1491
    Total minutes played: 1196.3608
  Album: Die Lit by Playboi Carti
    Play count: 1346
    Total minutes played: 1086.015
  Album: #SantanaWorld (+) by Tay-K
    Play count: 1165
    Total minutes played: 907.9556
  Album: Luv Is Rage by Lil Uzi Vert
    Play count: 1155
    Total minutes played: 930.2193
  Album: Lil Uzi Vert vs. The World by Lil Uzi Vert
    Play count: 1064
    Total minutes played: 974.3214
  Album: H3 by Cdot Honcho
    Play count: 1020
    Total minutes played: 907.1934
  Album: Takeover by Cdot Honcho
    Play count: 1008
    Total minutes played: 698.4439
  Album: Luv Is Rage 2 by Lil Uzi Vert
    Play count: 965
    Total minutes played: 792.3553
  Album: Underdog by Duwap Kaine
    Play count: 961
    Total minutes played: 1008.9871
  Album: The Life Of Pi'erre 4 by Pi’erre Bourne
    Play count: 887
    Total minutes played: 941.7094

User: Alan
  Album: The Life Of Pablo by Kanye West
    Play count: 8732
    Total minutes played: 7083.7848
  Album: My Beautiful Dark Twisted Fantasy by Kanye West
    Play count: 8265
    Total minutes played: 7743.9478
  Album: Rodeo by Travis Scott
    Play count: 7932
    Total minutes played: 8642.6706
  Album: ASTROWORLD by Travis Scott
    Play count: 7676
    Total minutes played: 6941.9378
  Album: Die Lit by Playboi Carti
    Play count: 6645
    Total minutes played: 3482.85
  Album: Goodbye & Good Riddance by Juice WRLD
    Play count: 6565
    Total minutes played: 4607.4985
  Album: Late Registration by Kanye West
    Play count: 6071
    Total minutes played: 5365.4965
  Album: good kid, m.A.A.d city by Kendrick Lamar
    Play count: 5443
    Total minutes played: 4730.8037
  Album: KIDS SEE GHOSTS by KIDS SEE GHOSTS
    Play count: 5086
    Total minutes played: 3567.2617
  Album: The College Dropout by Kanye West
    Play count: 4976
    Total minutes played: 3984.039
```

- insights...

Univariate analysis - Per year


- explain all the functions & methodology

Bivariate analysis

Multivariate analysis

Temporal analysis

Behavioral pattern exploration

Group-level comparison analysis

Dimensional reduction and early unsupervised structure

Preliminary predictive framing

Story construction