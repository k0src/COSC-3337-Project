#import "@preview/typsidian:0.0.3": *
#import "@preview/frame-it:1.2.0": *
#import "@preview/mannot:0.3.0": *
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": chart, plot
#import calc: exp, ln, pow

#show: typsidian.with(
  title: "Music Data Project",
  author: "Koren Stalnaker",
  course: "COSC 3337",
  show-heading-colors: false,
)

#let artist-cols = (
  "KIDS SEE GHOSTS":           rgb("#ff9999").lighten(50%), 
  "Sufjan Stevens":            rgb("#ffb399").lighten(50%), 
  "Drake":                     rgb("#ffcc99").lighten(50%), 
  "Lonnie Liston Smith":       rgb("#ffe599").lighten(50%), 
  "ark762":                    rgb("#ffff99").lighten(50%), 
  "Playboi Carti":             rgb("#ccff99").lighten(50%), 
  "Lupe Fiasco":               rgb("#99ff99").lighten(50%), 
  "Denzel Curry":              rgb("#99ffb3").lighten(50%), 
  "Tee Grizzley":              rgb("#99ffcc").lighten(50%), 
  "J Dilla":                   rgb("#99ffe5").lighten(50%), 
  "Beartooth":                 rgb("#99ffff").lighten(50%), 
  "Cdot Honcho":               rgb("#99e5ff").lighten(50%), 
  "Anderson .Paak":            rgb("#99ccff").lighten(50%), 
  "Kendrick Lamar":            rgb("#99b3ff").lighten(50%), 
  "I Prevail":                 rgb("#9999ff").lighten(50%), 
  "Remarc":                    rgb("#b399ff").lighten(50%), 
  "A$AP Rocky":                rgb("#cc99ff").lighten(50%), 
  "Tay-K":                     rgb("#e599ff").lighten(50%), 
  "Hozier":                    rgb("#ff99ff").lighten(50%), 
  "JID":                       rgb("#ff99e5").lighten(50%), 
  "Panic! At The Disco":       rgb("#ff99cc").lighten(50%), 
  "Pi'erre Bourne":            rgb("#ff99b3").lighten(50%), 
  "Kanye West":                rgb("#ff8080").lighten(50%), 
  "Bring Me The Horizon":      rgb("#ff9966").lighten(50%), 
  "Alex Reese":                rgb("#ffb366").lighten(50%), 
  "Young Thug":                rgb("#ffcc66").lighten(50%), 
  "Travis Scott":              rgb("#ffff66").lighten(50%), 
  "LTJ Bukem":                 rgb("#b3ff66").lighten(50%), 
  "Palisades":                 rgb("#66ff66").lighten(50%), 
  "Big Bud":                   rgb("#66ff99").lighten(50%), 
  "Juice WRLD":                rgb("#66ffcc").lighten(50%), 
  "Chief Keef":                rgb("#66ffff").lighten(50%), 
  "Wage War":                  rgb("#66ccff").lighten(50%), 
  "toe":                       rgb("#6699ff").lighten(50%), 
  "Fall Out Boy":              rgb("#6666ff").lighten(50%), 
  "Future":                    rgb("#9966ff").lighten(50%), 
  "Gorillaz":                  rgb("#cc66ff").lighten(50%), 
  "21 Savage":                 rgb("#ff66ff").lighten(50%), 
  "Big K.R.I.T.":              rgb("#ff66b3").lighten(50%), 
  "Lil Baby":                  rgb("#ff6666").lighten(50%), 
  "A Boogie Wit da Hoodie":    rgb("#ff8833").lighten(50%), 
  "Luh Tyler":                 rgb("#ffaa33").lighten(50%), 
  "Neck Deep":                 rgb("#ffcc33").lighten(50%), 
  "Roni Size":                 rgb("#ffff33").lighten(50%), 
  "Don Toliver":               rgb("#99ff33").lighten(50%), 
  "Mint":                      rgb("#33ff33").lighten(50%), 
  "G Herbo":                   rgb("#33ff88").lighten(50%), 
  "Silverstein":               rgb("#33ffcc").lighten(50%), 
  "Roddy Ricch":               rgb("#33ffff").lighten(50%), 
  "My Chemical Romance":       rgb("#33aaff").lighten(50%), 
  "A Tribe Called Quest":      rgb("#3366ff").lighten(50%), 
  "Ashnikko":                  rgb("#3333ff").lighten(50%), 
  "mgk":                       rgb("#8833ff").lighten(50%), 
  "The Pharcyde":              rgb("#cc33ff").lighten(50%), 
  "The Roots":                 rgb("#ff33ff").lighten(50%), 
  "Danny Brown":               rgb("#ff3399").lighten(50%), 
  "The Avalanches":            rgb("#ffaacc").lighten(50%), 
  "Ken Carson":                rgb("#ffccaa").lighten(50%), 
  "Tom & Jerry":               rgb("#eeffaa").lighten(50%), 
  "Gunna":                     rgb("#aaffcc").lighten(50%), 
  "JAY-Z":                     rgb("#aaeeff").lighten(50%), 
  "Fountains Of Wayne":        rgb("#aaccff").lighten(50%), 
  "Kodak Black":               rgb("#ccaaff").lighten(50%), 
  "Black Star":                rgb("#ffaaee").lighten(50%), 
  "Wax Doctor":                rgb("#ffddaa").lighten(50%), 
  "Rivals":                    rgb("#ddffaa").lighten(50%), 
  "Nuito":                     rgb("#aaffdd").lighten(50%), 
  "State Champs":              rgb("#aaddff").lighten(50%), 
  "Nookie":                    rgb("#ddaaff").lighten(50%), 
  "Woe, Is Me":                rgb("#ffaadd").lighten(50%), 
  "Fiona Apple":               rgb("#ff7777").lighten(50%), 
  "Trippie Redd":              rgb("#ff9977").lighten(50%), 
  "Origin Unknown":            rgb("#ffbb77").lighten(50%), 
  "Sleep Theory":              rgb("#ffdd77").lighten(50%), 
  "PFM":                       rgb("#ffff77").lighten(50%), 
  "tenkay":                    rgb("#ddff77").lighten(50%), 
  "Neon Trees":                rgb("#bbff77").lighten(50%), 
  "Lianne La Havas":           rgb("#99ff77").lighten(50%), 
  "underscores":               rgb("#77ff77").lighten(50%), 
  "blink-182":                 rgb("#77ff99").lighten(50%), 
  "YoungBoy Never Broke Again":rgb("#77ffbb").lighten(50%), 
  "Pusha T":                   rgb("#77ffdd").lighten(50%), 
  "BigXthaPlug":               rgb("#77ffff").lighten(50%), 
  "Total Science":             rgb("#77ddff").lighten(50%), 
  "Hidden Agenda":             rgb("#77bbff").lighten(50%), 
  "¥$":                        rgb("#7799ff").lighten(50%), 
  "Earl Sweatshirt":           rgb("#7777ff").lighten(50%), 
  "OsamaSon":                  rgb("#9977ff").lighten(50%), 
  "Benji Blue Bills":          rgb("#bb77ff").lighten(50%), 
  "JPEGMAFIA":                 rgb("#dd77ff").lighten(50%), 
  "JMJ":                       rgb("#ff77ff").lighten(50%), 
  "Mos Def":                   rgb("#ff77dd").lighten(50%), 
  "Falling In Reverse":        rgb("#ff77bb").lighten(50%), 
  "MGMT":                      rgb("#ff7799").lighten(50%), 
  "Jessie Ware":               rgb("#dd7777").lighten(50%), 
  "Freddie Gibbs":             rgb("#dd9977").lighten(50%), 
  "Cutty Ranks":               rgb("#ddbb77").lighten(50%), 
  "Diamond Construct":         rgb("#dddd77").lighten(50%), 
  "Kim Dracula":               rgb("#bbdd77").lighten(50%), 
  "Duwap Kaine":               rgb("#77dd99").lighten(50%), 
  "SOB X RBE":                 rgb("#77dddd").lighten(50%), 
  "Fleet Foxes":               rgb("#7799dd").lighten(50%), 
  "WSTR":                      rgb("#9977dd").lighten(50%), 
  "Che":                       rgb("#dd77dd").lighten(50%), 
  "J Majik":                   rgb("#dd7799").lighten(50%), 
  "DANGERDOOM":                rgb("#ee9988").lighten(50%), 
  "Lil Uzi Vert":              rgb("#88ee99").lighten(50%), 
)

#make-title(show-outline: false, show-author: true, justify: "left")

#show figure: set block(breakable: true)

= Data Collection & Preprocessing

== Data Collection

For this project, we collected data from Spotify, which provides a comprehensive record of users' streaming history, from the first time they listened to music on the platform. The data can be downloaded from #link("https://www.spotify.com/us/account/privacy/", "Spotify's privacy settings page"), where users can request a copy of their data. This data comes in the form of a zip file containing multiple JSON files for each year of listening history. Each JSON file contains an array of listening events, with attributes such as timestamp, track name, artist name, album name, platform, country, and more.

For example, a single listening event in the JSON file looks like this:

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

where each attribute provides specific information about the listening event, such as the timestamp of when the track was played, the platform used, how long the track was played for in milliseconds, the country where it was played, and details about the track itself (name, artist, album). Additionally, there are attributes that indicate whether the user was shuffling their music, whether they skipped the track, and whether they were listening offline.

We collected data from four users over a span of 11 years (2015-2026), in the form of 58 total JSON files. Some users have more extensive listening histories than others, with varying numbers of unique tracks, artists, albums, platforms, and countries represented in their data. However, there is a full overlap in the time span of their listening history from 2020 to 2026.

== Data Preprocessing

To prepare the data for analysis, we performed several preprocessing steps. First, we extracted the relevant attributes from the JSON files and gave them more descriptive names. The data from Spotify contained some attributes that were not relevant to our analysis, such as IP address and audiobook-related fields, which we discarded. We focused on attributes that were relevant to understanding listening habits, such as track name, artist name, album name, platform, country, timestamp, ms played, reason for starting and ending the track, shuffle status, skip status, and offline status. We then imported the data into a central data store, using Supabase, which is a PostgreSQL database. This allowed us to easily query and manipulate the data for our analysis. 

The schema we used for the database is as follows:

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

We also pruned any null entries and duplicate songs (based on the primary key of username and timestamp) to ensure data quality. To make sure we had a clean dataset, we removed any songs that had both 1 play and less than 30 seconds played, as these were likely accidental plays or songs that were not fully listened to. After pruning, we were left with approximately 845,000 listening events. Additionally, we normalized the timestamp attribute to a datetime format for easier analysis. We also conducted redundancy and correlation analysis to check for any highly correlated attributes or redundant information, but found that there were no strong correlations or redundancies in the data. There were also no missing values in the dataset after preprocessing, which allowed us to proceed with our analysis without needing to handle missing data. Overall, the data preprocessing steps ensured that we had a clean and well-structured dataset to work with for our exploratory data analysis.

= Exploratory Data Analysis

== Unique Counts & Total Listening Events

// explain what is it, why did we collect it, etc

#figure(
  caption: "Summary Statistics for Each User (All-Time, 2024, 2025)",
  table(
    columns: 5,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 5, align: center)[*All-Time*],
    [*User*],[*Unique Tracks*],[*Unique Artists*],[*Unique Albums*],[*Total Listening Events*],
    [Alan],[10569],[1064],[3769],[450283],
    [Alexandra],[5249],[1064],[2349],[139541],
    [Anthony],[9066],[1296],[4252],[72483],
    [Koren],[15188],[4039],[7954],[181858],
    table.cell(colspan: 5, align: center)[*2024*],
    [Alan],[3926],[798],[1442],[57042],
    [Alexandra],[2177],[531],[1123],[12369],
    [Anthony],[2736],[551],[1442],[11713],
    [Koren],[3011],[1267],[1940],[14706],
    table.cell(colspan: 5, align: center)[*2025*],
    [Alan],[3227],[480],[976],[29418],
    [Alexandra],[2137],[503],[1064],[8712],
    [Anthony],[3510],[543],[1622],[13706],
    [Koren],[3740],[1405],[2313],[17160],
  )
)

=== Analysis

// analysis: per user and comparing across users

=== Methodology

// how (julia)

== Top Tracks, Artists, & Albums

=== Top Tracks

#figure(
  caption: "Alan's Top 10 Tracks (All-Time, 2024, 2025)", 
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("KIDS SEE GHOSTS") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("The Roots") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Jessie Ware") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Pusha T") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Jessie Ware") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Denzel Curry") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("Earl Sweatshirt") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("Jessie Ware") }
      else if (row == 5 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 5 and col in (2, 3)) { artist-cols.at("DANGERDOOM") }
      else if (row == 5 and col in (4, 5)) { artist-cols.at("JPEGMAFIA") }
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Pusha T") }
      else if (row == 6 and col in (2, 3)) { artist-cols.at("Fleet Foxes") }
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Jessie Ware") }
      else if (row == 7 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 7 and col in (2, 3)) { artist-cols.at("Denzel Curry") }
      else if (row == 7 and col in (4, 5)) { artist-cols.at("Jessie Ware") }
      else if (row == 8 and col in (0, 1)) { artist-cols.at("Travis Scott") }
      else if (row == 8 and col in (2, 3)) { artist-cols.at("MGMT") }
      else if (row == 8 and col in (4, 5)) { artist-cols.at("Lianne La Havas") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("Lupe Fiasco") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Denzel Curry") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("KIDS SEE GHOSTS") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("Anderson .Paak") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("JPEGMAFIA") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Juice WRLD") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("Black Star") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("underscores") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Track*],[*Plays*],
    [*Track*],[*Plays*],
    [*Track*],[*Plays*],
    [4th Dimension],[1371], // KIDS SEE GHOSTS
    [I Remember],[122], // The Roots
    [Begin Again],[102], // Jessie Ware
    [No More Parties In LA],[1237], // Kanye West
    [Nosetalgia],[117], // Pusha T
    [In Your Eyes],[98], // Jessie Ware
    [SIRENS],[1213], // Denzel Curry
    [Centurion],[111], // Earl Sweatshirt
    [Remember Where You Are],[87], // Jessie Ware
    [Gorgeous],[1151], // Kanye West
    [Crosshairs],[111], // DANGERDOOM
    [either on or off the drugs],[84], // JPEGMAFIA
    [The Games We Play],[1037], // Pusha T
    [Mykonos],[109], // Fleet Foxes
    [The Kill],[84], // Jessie Ware
    [Dark Fantasy],[1016], // Kanye West
    [Melt Session \#1],[107], // Denzel Curry
    [Soul Control],[78], // Jessie Ware
    [CAN'T SAY],[1008], // Travis Scott
    [Siberian Breaks],[106], // MGMT
    [Weird Fishes],[78], // Lianne La Havas
    [So Appalled],[988], // Kanye West
    [Mural],[102], // Lupe Fiasco
    [Endtroduction],[75], // Denzel Curry
    [Feel The Love],[967], // KIDS SEE GHOSTS
    [Jet Black],[101], // Anderson .Paak
    [HAZARD DUTY PAY!],[67], // JPEGMAFIA
    [Armed And Dangerous],[962], // Juice WRLD
    [Respiration],[100], // Black Star
    [Uncanny long arms],[67], // underscores
  )
)

#figure(
  caption: "Alexandra's Top 10 Tracks (All-Time, 2024, 2025)", 
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("Fall Out Boy") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("Beartooth") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Palisades") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Neck Deep") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Beartooth") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Beartooth") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Neck Deep") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("Beartooth") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("Beartooth") }
      else if (row == 5 and col in (0, 1)) { artist-cols.at("Neck Deep") }
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Falling In Reverse") }
      else if (row == 5 and col in (4, 5)) { artist-cols.at("Neck Deep") }
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Panic! At The Disco") }
      else if (row == 6 and col in (2, 3)) { artist-cols.at("Hozier") }
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Sleep Theory") }
      else if (row == 7 and col in (0, 1)) { artist-cols.at("Neon Trees") }
      else if (row == 7 and col in (2, 3)) { artist-cols.at("Beartooth") }
      else if (row == 7 and col in (4, 5)) { artist-cols.at("I Prevail") }
      else if (row == 8 and col in (0, 1)) { artist-cols.at("Panic! At The Disco") }
      else if (row == 8 and col in (2, 3)) { artist-cols.at("Falling In Reverse") }
      else if (row == 8 and col in (4, 5)) { artist-cols.at("Beartooth") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("Neck Deep") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("Falling In Reverse") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Woe, Is Me") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("Panic! At The Disco") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("Beartooth") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("State Champs") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Panic! At The Disco") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("Silverstein") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("Rivals") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Track*],[*Plays*],
    [*Track*],[*Plays*],
    [*Track*],[*Plays*],
    [Sugar, We're Goin Down],[237], // Fall Out Boy
    [Sunshine!],[49], // Beartooth
    [Vendetta],[119], // Palisades
    [Kali Ma],[194], // Neck Deep
    [Doubt Me],[45], // Beartooth
    [Sunshine!],[25], // Beartooth
    [Motion Sickness],[189], // Neck Deep
    [Might Love Myself],[41], // Beartooth
    [Riptide],[19], // Beartooth
    [Happy Judgement Day],[187], // Neck Deep
    [All My Life],[34], // Falling In Reverse
    [Heartbreak Of The Century],[18], // Neck Deep
    [This Is Gospel],[184], // Panic! At The Disco
    [Too Sweet],[31], // Hozier
    [Static],[16], // Sleep Theory
    [Everybody Talks],[181], // Neon Trees
    [Riptide],[30], // Beartooth
    [Doomed],[15], // I Prevail
    [LA Devotee],[174], // Panic! At The Disco
    [Ronald],[28], // Falling In Reverse
    [Fed Up],[14], // Beartooth
    [Can't Kick Up The Roots],[171], // Neck Deep
    [The Drug In Me Is You],[27], // Falling In Reverse
    [I've Told You Once],[14], // Woe, Is Me
    [Hallelujah],[170], // Panic! At The Disco
    [The Surface],[27], // Beartooth
    [Everybody but You],[13], // State Champs
    [Emperor's New Clothes],[168], // Panic! At The Disco
    [The Afterglow],[26], // Silverstein
    [Nobody Loves Me],[13], // Rivals
  )
)

#figure(
  caption: "Anthony's Top 10 Tracks (All-Time, 2024, 2025)", 
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("21 Savage") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Ken Carson") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Gunna") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Ken Carson") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("Playboi Carti") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("Don Toliver") }
      else if (row == 5 and col in (0, 1)) { artist-cols.at("Roddy Ricch") }
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Future") }
      else if (row == 5 and col in (4, 5)) { artist-cols.at("Kanye West") }
      else if (row == 6 and col in (0, 1)) { artist-cols.at("A$AP Rocky") }
      else if (row == 6 and col in (2, 3)) { artist-cols.at("Drake") }
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 7 and col in (0, 1)) { artist-cols.at("Lil Baby") }
      else if (row == 7 and col in (2, 3)) { artist-cols.at("Luh Tyler") }
      else if (row == 7 and col in (4, 5)) { artist-cols.at("Kodak Black") }
      else if (row == 8 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 8 and col in (2, 3)) { artist-cols.at("Playboi Carti") }
      else if (row == 8 and col in (4, 5)) { artist-cols.at("Kanye West") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("A Boogie Wit da Hoodie") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("¥$") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("¥$") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("Future") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("Playboi Carti") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Playboi Carti") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("Kanye West") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("Ken Carson") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Track*],[*Plays*],
    [*Track*],[*Plays*],
    [*Track*],[*Plays*],
    [ball w/o you],[234], // 21 Savage
    [Not Like Us],[59], // Kendrick Lamar
    [Yale],[51], // Ken Carson
    [Father Stretch My Hands Pt. 1],[226], // Kanye West
    [one of wun],[58], // GUNNA
    [ss],[50], // Ken Carson
    [I Wonder],[190], // Kanye West
    [ILoveUIHateU],[50], // Playboi Carti
    [No Pole],[48], // Don Toliver
    [Down Below],[184], // Roddy Ricch
    [Fried (She a Vibe)],[45], // Future
    [POWER],[46], // Kanye West
    [Praise The Lord (Da Shine)],[179], // A$AP Rocky
    [It's Up],[43], // Drake
    [tv off],[44], // Kendrick Lamar
    [Freestyle],[172], // Lil Baby
    [2 Slippery],[40], // Luh Tyler
    [No Flockin'],[40], // Kodak Black
    [POWER],[171], // Kanye West
    [ALL RED],[39], // Playboi Carti
    [I Wonder],[40], // Kanye West
    [Jungle],[164], // A Boogie Wit da Hoodie
    [CARNIVAL],[38], // ¥$
    [FIELD TRIP],[38], // ¥$
    [Flashing Lights],[160], // Kanye West
    [Cinderella],[36], // Future
    [EVIL J0RDAN],[38], // Playboi Carti
    [Shoota],[157], // Playboi Carti
    [Father Stretch My Hands Pt. 1],[36], // Kanye West
    [overseas],[38], // Ken Carson
  )
)

#figure(
  caption: "Koren's Top 10 Tracks (All-Time, 2024, 2025)", 
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("Cdot Honcho") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("Hidden Agenda") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Roni Size") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Trippie Redd") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Tom & Jerry") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Lil Uzi Vert") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Fountains Of Wayne") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("Origin Unknown") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("Ken Carson") }
      else if (row == 5 and col in (0, 1)) { artist-cols.at("Tee Grizzley") }
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Roni Size") }
      else if (row == 5 and col in (4, 5)) { artist-cols.at("ark762") }
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Lil Uzi Vert") }
      else if (row == 6 and col in (2, 3)) { artist-cols.at("Nookie") }
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Hidden Agenda") }
      else if (row == 7 and col in (0, 1)) { artist-cols.at("Tee Grizzley") }
      else if (row == 7 and col in (2, 3)) { artist-cols.at("Total Science") }
      else if (row == 7 and col in (4, 5)) { artist-cols.at("Remarc") }
      else if (row == 8 and col in (0, 1)) { artist-cols.at("SOB X RBE") }
      else if (row == 8 and col in (2, 3)) { artist-cols.at("Remarc") }
      else if (row == 8 and col in (4, 5)) { artist-cols.at("Nookie") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("A Tribe Called Quest") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("JMJ") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Tom & Jerry") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("SOB X RBE") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("Duwap Kaine") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("Benji Blue Bills") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Cdot Honcho") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("Cutty Ranks") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("J Majik") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Track*],[*Plays*],
    [*Track*],[*Plays*],
    [*Track*],[*Plays*],
    [Honcho Style 3],[297], // Cdot Honcho
    [On the Roof],[78], // Hidden Agenda
    [Brown Paper Bag],[44], // Roni Size
    [Poles 1469],[278], // Trippie Redd
    [Maximum Style (Lover To Lover)],[66], // Tom & Jerry
    [Myron],[39], // Lil Uzi Vert
    [Stacy's Mom],[276], // Fountains Of Wayne
    [Valley of the Shadows],[64], // Origin Unknown
    [Off The Meter],[38], // Ken Carson
    [From The D To The A],[272], // Tee Grizzley
    [Brown Paper Bag],[60], // Roni Size
    [Autobots],[38], // ark762
    [Money Longer],[263], // Lil Uzi Vert
    [Only You (Original Mix)],[59], // Nookie
    [On The Roof],[37], // Hidden Agenda
    [First Day Out],[262], // Tee Grizzley
    [Rotation],[54], // Total Science
    [Ice Cream & Syrup],[36], // Remarc
    [Lane Changing],[258], // SOB X RBE
    [Ice Cream & Syrup],[45], // Remarc
    [Only You (Original Mix)],[35], // Nookie
    [Award Tour],[242], // A Tribe Called Quest
    [In Too Deep - mixed],[44], // JMJ
    [Maximum Style (Lover To Lover)],[32], // Tom & Jerry
    [Anti],[235], // SOB X RBE
    [Pavement],[43], // Duwap Kaine
    [Load Out],[32], // Benji Blue Bills
    [Teflon Flow],[226], // Cdot Honcho
    [Limb By Limb - DJ SS Remix],[43], // Cutty Ranks 
    [Gemini],[30], // J Majik
  )
)

=== Top Artists

#figure(
  caption: "Alan's Top 10 Artists (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("Kanye West") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Kanye West") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Travis Scott") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("JPEGMAFIA") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("Danny Brown") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 5 and col in (0, 1)) { artist-cols.at("Denzel Curry") }
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Freddie Gibbs") }
      else if (row == 5 and col in (4, 5)) { artist-cols.at("Jessie Ware") }
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Juice WRLD") }
      else if (row == 6 and col in (2, 3)) { artist-cols.at("Denzel Curry") }
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Denzel Curry") }
      else if (row == 7 and col in (0, 1)) { artist-cols.at("Playboi Carti") }
      else if (row == 7 and col in (2, 3)) { artist-cols.at("The Roots") }
      else if (row == 7 and col in (4, 5)) { artist-cols.at("Danny Brown") }
      else if (row == 8 and col in (0, 1)) { artist-cols.at("Freddie Gibbs") }
      else if (row == 8 and col in (2, 3)) { artist-cols.at("A Tribe Called Quest") }
      else if (row == 8 and col in (4, 5)) { artist-cols.at("Fiona Apple") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("Lil Uzi Vert") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("Pusha T") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Freddie Gibbs") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("Drake") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("Sufjan Stevens") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("JID") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Future") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("Gorillaz") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("A Tribe Called Quest") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Artist*],[*Plays*],
    [*Artist*],[*Plays*],
    [*Artist*],[*Plays*],
    [Kanye West],[43739],
    [Kanye West],[2803],
    [Kanye West],[1184],
    [Travis Scott],[22269],
    [Kendrick Lamar],[2206],
    [JPEGMAFIA],[1094],
    [Kendrick Lamar],[15485],
    [Danny Brown],[1453],
    [Kendrick Lamar],[927],
    [Denzel Curry],[13157],
    [Freddie Gibbs],[1206],
    [Jessie Ware],[798],
    [Juice WRLD],[9580],
    [Denzel Curry],[1189],
    [Denzel Curry],[756],
    [Playboi Carti],[8932],
    [The Roots],[1185],
    [Danny Brown],[636],
    [Freddie Gibbs],[8815],
    [A Tribe Called Quest],[948],
    [Fiona Apple],[605],
    [Lil Uzi Vert],[8553],
    [Pusha T],[943],
    [Freddie Gibbs],[585],
    [Drake],[8538],
    [Sufjan Stevens],[922],
    [JID],[585],
    [Future],[8149],
    [Gorillaz],[875],
    [A Tribe Called Quest],[475],
  )
)

#figure(
  caption: "Alexandra's Top 10 Artists (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("Neck Deep") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("Beartooth") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Beartooth") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("State Champs") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Neck Deep") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Neck Deep") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Panic! At The Disco") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("Bring Me The Horizon") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("State Champs") }
      else if (row == 5 and col in (0, 1)) { artist-cols.at("Beartooth") }
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Wage War") }
      else if (row == 5 and col in (4, 5)) { artist-cols.at("Wage War") }
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Bring Me The Horizon") }
      else if (row == 6 and col in (2, 3)) { artist-cols.at("State Champs") }
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Bring Me The Horizon") }
      else if (row == 7 and col in (0, 1)) { artist-cols.at("Fall Out Boy") }
      else if (row == 7 and col in (2, 3)) { artist-cols.at("Falling In Reverse") }
      else if (row == 7 and col in (4, 5)) { artist-cols.at("Ashnikko") }
      else if (row == 8 and col in (0, 1)) { artist-cols.at("blink-182") }
      else if (row == 8 and col in (2, 3)) { artist-cols.at("Ashnikko") }
      else if (row == 8 and col in (4, 5)) { artist-cols.at("I Prevail") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("My Chemical Romance") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("Panic! At The Disco") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Panic! At The Disco") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("mgk") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("Kim Dracula") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("WSTR") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Wage War") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("mgk") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("mgk") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Artist*],[*Plays*],
    [*Artist*],[*Plays*],
    [*Artist*],[*Plays*],
    [Neck Deep],[9308],
    [Beartooth],[988],
    [Beartooth],[563],
    [State Champs],[8301],
    [Neck Deep],[656],
    [Neck Deep],[444],
    [Panic! At The Disco],[7117],
    [Bring Me The Horizon],[501],
    [State Champs],[385],
    [Beartooth],[5603],
    [Wage War],[442],
    [Wage War],[306],
    [Bring Me The Horizon],[4320],
    [State Champs],[408],
    [Bring Me The Horizon],[284],
    [Fall Out Boy],[3133],
    [Falling In Reverse],[339],
    [Ashnikko],[233],
    [blink-182],[2697],
    [Ashnikko],[316],
    [I Prevail],[228],
    [My Chemical Romance],[2484],
    [Panic! At The Disco],[276],
    [Panic! At The Disco],[209],
    [mgk],[2461],
    [Kim Dracula],[265],
    [WSTR],[195],
    [Wage War],[2410],
    [mgk],[258],
    [mgk],[166],
  )
)

#figure(
  caption: "Anthony's Top 10 Artists (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("Kanye West") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Kanye West") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Drake") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Future") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Playboi Carti") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Future") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("Drake") }
      else if (row == 5 and col in (0, 1)) { artist-cols.at("Young Thug") }
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Drake") }
      else if (row == 5 and col in (4, 5)) { artist-cols.at("Young Thug") }
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Travis Scott") }
      else if (row == 6 and col in (2, 3)) { artist-cols.at("¥$") }
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Future") }
      else if (row == 7 and col in (0, 1)) { artist-cols.at("YoungBoy Never Broke Again") }
      else if (row == 7 and col in (2, 3)) { artist-cols.at("Gunna") }
      else if (row == 7 and col in (4, 5)) { artist-cols.at("Gunna") }
      else if (row == 8 and col in (0, 1)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 8 and col in (2, 3)) { artist-cols.at("21 Savage") }
      else if (row == 8 and col in (4, 5)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("Playboi Carti") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("Young Thug") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Lil Baby") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("21 Savage") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("YoungBoy Never Broke Again") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("Ken Carson") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Juice WRLD") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("BigXthaPlug") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("21 Savage") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Artist*],[*Plays*],
    [*Artist*],[*Plays*],
    [*Artist*],[*Plays*],
    [Kanye West],[6780],
    [Kanye West],[858],
    [Kanye West],[1199],
    [Drake],[3829],
    [Future],[648],
    [Playboi Carti],[640],
    [Future],[2132],
    [Kendrick Lamar],[428],
    [Drake],[557],
    [Young Thug],[1959],
    [Drake],[426],
    [Young Thug],[511],
    [Travis Scott],[1457],
    [¥\$],[335],
    [Future],[425],
    [YoungBoy Never Broke Again],[1428],
    [Gunna],[313],
    [Gunna],[342],
    [Kendrick Lamar],[1418],
    [21 Savage],[301],
    [Kendrick Lamar],[321],
    [Playboi Carti],[1382],
    [Young Thug],[296],
    [Lil Baby],[319],
    [21 Savage],[1305],
    [YoungBoy Never Broke Again],[292],
    [Ken Carson],[317],
    [Juice WRLD],[1234],
    [BigXthaPlug],[280],
    [21 Savage],[313],
  )
)

#figure(
  caption: "Koren's Top 10 Artists (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("Lil Uzi Vert") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("Mint") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Playboi Carti") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Playboi Carti") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("LTJ Bukem") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Mint") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Mint") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("Lonnie Liston Smith") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("LTJ Bukem") }
      else if (row == 5 and col in (0, 1)) { artist-cols.at("G Herbo") }
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Nookie") }
      else if (row == 5 and col in (4, 5)) { artist-cols.at("Che") }
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Chief Keef") }
      else if (row == 6 and col in (2, 3)) { artist-cols.at("toe") }
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Roni Size") }
      else if (row == 7 and col in (0, 1)) { artist-cols.at("Cdot Honcho") }
      else if (row == 7 and col in (2, 3)) { artist-cols.at("Alex Reese") }
      else if (row == 7 and col in (4, 5)) { artist-cols.at("tenkay") }
      else if (row == 8 and col in (0, 1)) { artist-cols.at("Tee Grizzley") }
      else if (row == 8 and col in (2, 3)) { artist-cols.at("Wax Doctor") }
      else if (row == 8 and col in (4, 5)) { artist-cols.at("toe") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("Travis Scott") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("Roni Size") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Nookie") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("Pi'erre Bourne") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("Big Bud") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("Lil Uzi Vert") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Future") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("Hidden Agenda") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("OsamaSon") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Artist*],[*Plays*],
    [*Artist*],[*Plays*],
    [*Artist*],[*Plays*],
    [Lil Uzi Vert],[5764],
    [Mint],[764],
    [Playboi Carti],[1071],
    [Playboi Carti],[4323],
    [LTJ Bukem],[523],
    [Mint],[463],
    [Mint],[4034],
    [Lonnie Liston Smith],[325],
    [LTJ Bukem],[300],
    [G Herbo],[2820],
    [Nookie],[267],
    [Che],[290],
    [Chief Keef],[2732],
    [toe],[241],
    [Roni Size],[279],
    [Cdot Honcho],[2654],
    [Alex Reece],[231],
    [tenkay],[255],
    [Tee Grizzley],[2000],
    [Wax Doctor],[187],
    [toe],[219],
    [Travis Scott],[1807],
    [Roni Size],[186],
    [Nookie],[203],
    [Pi'erre Bourne],[1789],
    [Big Bud],[165],
    [Lil Uzi Vert],[183],
    [Future],[1642],
    [Hidden Agenda],[162],
    [OsamaSon],[181],
  )
)

=== Top Albums

#figure(
  caption: "Alan's Top 10 Albums (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("The Roots") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Jessie Ware") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Freddie Gibbs") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Denzel Curry") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Travis Scott") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("J Dilla") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("JPEGMAFIA") }
      else if (row == 5 and col in (0, 1)) { artist-cols.at("Travis Scott") }
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Kanye West") }
      else if (row == 5 and col in (4, 5)) { artist-cols.at("underscores") }
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Playboi Carti") }
      else if (row == 6 and col in (2, 3)) { artist-cols.at("Denzel Curry") }
      else if (row == 6 and col in (4, 5)) { artist-cols.at("JPEGMAFIA") }
      else if (row == 7 and col in (0, 1)) { artist-cols.at("Juice WRLD") }
      else if (row == 7 and col in (2, 3)) { artist-cols.at("Danny Brown") }
      else if (row == 7 and col in (4, 5)) { artist-cols.at("Lianne La Havas") }
      else if (row == 8 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 8 and col in (2, 3)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 8 and col in (4, 5)) { artist-cols.at("The Avalanches") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("Black Star") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Mos Def") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("KIDS SEE GHOSTS") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("Danny Brown") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("Big K.R.I.T.") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("The Pharcyde") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("Danny Brown") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Album*],[*Plays*],
    [*Album*],[*Plays*],
    [*Album*],[*Plays*],
    [The Life Of Pablo],[8732],
    [Undun],[687],
    [What's Your Pleasure?],[677],
    [My Beautiful...Fantasy],[8265],
    [Piñata],[677],
    [Melt My Eyez See Your Future],[453],
    [Rodeo],[7932],
    [Donuts],[669],
    [I LAY DOWN MY LIFE FOR YOU],[372],
    [ASTROWORLD],[7676],
    [Late Registration],[665],
    [Wallsocket],[359],
    [Die Lit],[6645],
    [Melt My Eyez See Your Future],[652],
    [I LAY DOWN MY LIFE FOR YOU],[356],
    [Goodbye & Good Riddance],[6565],
    [Atrocity Exhibition],[639],
    [Lianne La Havas],[334],
    [Late Registration],[6071],
    [To Pimp A Butterfly],[589],
    [Since I Left You],[331],
    [good kid, m.A.A.d city],[5443],
    [Mos Def...Black Star],[567],
    [Black On Both Sides],[299],
    [KIDS SEE GHOSTS],[5086],
    [XXX (Deluxe Version)],[550],
    [4eva Is A Mighty Long Time],[298],
    [The College Dropout],[4976],
    [Bizarre Ride II The Pharcyde],[528],
    [Atrocity Exhibition],[287],
  )
)

#figure(
  caption: "Alexandra's Top 10 Albums (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("Neck Deep") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("Beartooth") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Beartooth") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Panic! At The Disco") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Bring Me The Horizon") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Palisades") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Neck Deep") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("Neck Deep") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("I Prevail") } 
      else if (row == 5 and col in (0, 1)) { artist-cols.at("mgk") } 
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Beartooth") }  
      else if (row == 5 and col in (4, 5)) { artist-cols.at("Beartooth") } 
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Neck Deep") } 
      else if (row == 6 and col in (2, 3)) { artist-cols.at("Kim Dracula") } 
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Beartooth") } 
      else if (row == 7 and col in (0, 1)) { artist-cols.at("State Champs") } 
      else if (row == 7 and col in (2, 3)) { artist-cols.at("Beartooth") } 
      else if (row == 7 and col in (4, 5)) { artist-cols.at("State Champs") } 
      else if (row == 8 and col in (0, 1)) { artist-cols.at("State Champs") } 
      else if (row == 8 and col in (2, 3)) { artist-cols.at("I Prevail") } 
      else if (row == 8 and col in (4, 5)) { artist-cols.at("mgk") } 
      else if (row == 9 and col in (0, 1)) { artist-cols.at("State Champs") } 
      else if (row == 9 and col in (2, 3)) { artist-cols.at("mgk") } 
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Bring Me The Horizon") } 
      else if (row == 10 and col in (0, 1)) { artist-cols.at("Panic! At The Disco") } 
      else if (row == 10 and col in (2, 3)) { artist-cols.at("Beartooth") } 
      else if (row == 10 and col in (4, 5)) { artist-cols.at("Beartooth") } 
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Panic! At The Disco") } 
      else if (row == 11 and col in (2, 3)) { artist-cols.at("Diamond Construct") } 
      else if (row == 11 and col in (4, 5)) { artist-cols.at("Neck Deep") } 
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Album*],[*Plays*],
    [*Album*],[*Plays*],
    [*Album*],[*Plays*],
    [Life's Not Out To Get You],[1767],
    [The Surface],[322],
    [The Surface],[160],
    [Death of a Bachelor],[1584],
    [POST HUMAN: NeX GEn],[195],
    [Erase The Pain],[119],
    [Wishful Thinking],[1580],
    [Neck Deep],[169],
    [TRUE POWER],[116],
    [Tickets To My Downfall],[1533],
    [Below],[166],
    [Below],[112],
    [The Peace And The Panic],[1520],
    [A Gradual Decline In Morale],[166],
    [Aggressive],[107],
    [Around the World and Back],[1488],
    [Aggressive],[152],
    [Kings of the New Age],[83],
    [The Finer Things],[1454],
    [TRUE POWER],[135],
    [Tickets To My Downfall],[81],
    [Around the World and Back],[1305],
    [Tickets To My Downfall],[129],
    [POST HUMAN: NeX GEn],[80],
    [Too Weird to Live, Too Rare to Die!],[1282],
    [Disease (Deluxe Edition)],[125],
    [Disease (Deluxe Edition)],[79],
    [Vices & Virtues],[1254],
    [Angel Killer Zero],[119],
    [Neck Deep],[75],
  )
)

#figure(
  caption: "Anthony's Top 10 Albums (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("Kanye West") } 
      else if (row == 2 and col in (2, 3)) { artist-cols.at("Kendrick Lamar") } 
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Playboi Carti") } 
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Kanye West") } 
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Future") } 
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Kanye West") } 
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("¥$") } 
      else if (row == 4 and col in (4, 5)) { artist-cols.at("Kanye West") } 
      else if (row == 5 and col in (0, 1)) { artist-cols.at("Kanye West") } 
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Kanye West") } 
      else if (row == 5 and col in (4, 5)) { artist-cols.at("Kanye West") } 
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Drake") } 
      else if (row == 6 and col in (2, 3)) { artist-cols.at("21 Savage") } 
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Young Thug") } 
      else if (row == 7 and col in (0, 1)) { artist-cols.at("Kanye West") } 
      else if (row == 7 and col in (2, 3)) { artist-cols.at("Future") } 
      else if (row == 7 and col in (4, 5)) { artist-cols.at("Kanye West") } 
      else if (row == 8 and col in (0, 1)) { artist-cols.at("JAY-Z") } 
      else if (row == 8 and col in (2, 3)) { artist-cols.at("Kanye West") } 
      else if (row == 8 and col in (4, 5)) { artist-cols.at("Ken Carson") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("Kanye West") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("Gunna") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Kendrick Lamar") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("Juice WRLD") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("Kanye West") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("Drake") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("21 Savage") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("BigXthaPlug") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("Young Thug") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Album*],[*Plays*],
    [*Album*],[*Plays*],
    [*Album*],[*Plays*],
    [Graduation],[1240], 
    [GNX],[274], 
    [MUSIC],[385], 
    [My Beautiful...Fantasy],[1051], 
    [WE DON'T TRUST YOU],[256], 
    [Graduation],[266], 
    [Donda],[1022], 
    [VULTURES 1],[219], 
    [My Beautiful...Fantasy],[250], 
    [The Life Of Pablo],[929], 
    [Graduation],[209], 
    [Yeezus],[184], 
    [Take Care],[638], 
    [american dream],[146],
    [Slime Season],[161], 
    [Yeezus],[546], 
    [MIXTAPE PLUTO],[131], 
    [The Life Of Pablo],[156], 
    [Watch The Throne],[478], 
    [My Beautiful...Fantasy],[121], 
    [A Great Chaos],[141], 
    [The College Dropout],[454],
    [One of Wun],[107],
    [GNX],[120],
    [Death Race For Love],[444],
    [The Life Of Pablo],[104],
    [Take Care],[113],
    [i am > i was],[405],
    [TAKE CARE],[103],
    [UY SCUTI],[112],
  )
)

#figure(
  caption: "Koren's Top 10 Albums (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) }
      else if (row == 2 and col in (0, 1)) { artist-cols.at("Playboi Carti") }
      else if (row == 2 and col in (2, 3)) { artist-cols.at("Mint") }
      else if (row == 2 and col in (4, 5)) { artist-cols.at("Playboi Carti") }
      else if (row == 3 and col in (0, 1)) { artist-cols.at("Playboi Carti") }
      else if (row == 3 and col in (2, 3)) { artist-cols.at("Mint") }
      else if (row == 3 and col in (4, 5)) { artist-cols.at("Playboi Carti") }
      else if (row == 4 and col in (0, 1)) { artist-cols.at("Tay-K") }
      else if (row == 4 and col in (2, 3)) { artist-cols.at("LTJ Bukem") }
      else if (row == 4 and col in (4, 5)) { artist-cols.at("Mint") }
      else if (row == 5 and col in (0, 1)) { artist-cols.at("Lil Uzi Vert") }
      else if (row == 5 and col in (2, 3)) { artist-cols.at("Wax Doctor") }
      else if (row == 5 and col in (4, 5)) { artist-cols.at("Roni Size") }
      else if (row == 6 and col in (0, 1)) { artist-cols.at("Lil Uzi Vert") }
      else if (row == 6 and col in (2, 3)) { artist-cols.at("LTJ Bukem") }
      else if (row == 6 and col in (4, 5)) { artist-cols.at("Mint") }
      else if (row == 7 and col in (0, 1)) { artist-cols.at("Cdot Honcho") }
      else if (row == 7 and col in (2, 3)) { artist-cols.at("toe") }
      else if (row == 7 and col in (4, 5)) { artist-cols.at("Che") }
      else if (row == 8 and col in (0, 1)) { artist-cols.at("Cdot Honcho") }
      else if (row == 8 and col in (2, 3)) { artist-cols.at("Lonnie Liston Smith") }
      else if (row == 8 and col in (4, 5)) { artist-cols.at("LTJ Bukem") }
      else if (row == 9 and col in (0, 1)) { artist-cols.at("Lil Uzi Vert") }
      else if (row == 9 and col in (2, 3)) { artist-cols.at("Hidden Agenda") }
      else if (row == 9 and col in (4, 5)) { artist-cols.at("Wax Doctor") }
      else if (row == 10 and col in (0, 1)) { artist-cols.at("Duwap Kaine") }
      else if (row == 10 and col in (2, 3)) { artist-cols.at("PFM") }
      else if (row == 10 and col in (4, 5)) { artist-cols.at("Nuito") }
      else if (row == 11 and col in (0, 1)) { artist-cols.at("Pi'erre Bourne") }
      else if (row == 11 and col in (2, 3)) { artist-cols.at("Roni Size") }
      else if (row == 11 and col in (4, 5)) { artist-cols.at("J Majik") }
      else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Album*],[*Plays*],
    [*Album*],[*Plays*],
    [*Album*],[*Plays*],
    [Playboi Carti],[1491],
    [Selected Jungle Works],[419],
    [MUSIC - SORRY 4 DA WAIT],[584],
    [Die Lit],[1346],
    [Atmospheric Intelligence],[215],
    [MUSIC],[307],
    [\#SantanaWorld (+)],[1165],
    [Producer 01],[188],
    [Selected Jungle Works],[258],
    [Luv Is Rage],[1155],
    [Selected Works 94-96],[187],
    [New Forms],[211],
    [Lil Uzi Vert vs. The World],[1064],
    [Producer 05],[161],
    [Atmospheric Intelligence],[177],
    [H3],[1020],
    [the book about my...vague anxiety],[126],
    [REST IN BASS],[160],
    [Takeover],[1008],
    [Visions of a New World],[105],
    [Producer 01],[109],
    [Luv Is Rage 2],[965],
    [On the Roof / The Flute Tune],[101],
    [Selected Works 94-96],[93],
    [Underdog],[961],
    [Producer 02],[88],
    [Unutella],[93],
    [The Life Of Pi'erre 4],[887],
    [New Forms],[86],
    [Slow Motion],[90],
  )
)

#let col-swatch = (name) => { rect(fill: artist-cols.at(name), height: 0.8em, width: 2.8em) }

#box(breakable: true, title: "Artist Colors Key", [
  #align(center,
    table(
      columns: 6,
      align: left,
      [*Artist*],[*Color*],[*Artist*],[*Color*],[*Artist*],[*Color*],
      [Kanye West],[#col-swatch("Kanye West")],
      [Beartooth],[#col-swatch("Beartooth")],
      [Playboi Carti],[#col-swatch("Playboi Carti")],
      [Neck Deep],[#col-swatch("Neck Deep")],
      [Kendrick Lamar],[#col-swatch("Kendrick Lamar")],
      [Panic! At The Disco],[#col-swatch("Panic! At The Disco")],
      [Future],[#col-swatch("Future")],
      [Denzel Curry],[#col-swatch("Denzel Curry")],
      [State Champs],[#col-swatch("State Champs")],
      [Lil Uzi Vert],[#col-swatch("Lil Uzi Vert")],
      [Jessie Ware],[#col-swatch("Jessie Ware")],
      [Drake],[#col-swatch("Drake")],
      [Mint],[#col-swatch("Mint")],
      [Travis Scott],[#col-swatch("Travis Scott")],
      [21 Savage],[#col-swatch("21 Savage")],
      [Ken Carson],[#col-swatch("Ken Carson")],
      [Roni Size],[#col-swatch("Roni Size")],
      [mgk],[#col-swatch("mgk")],
      [JPEGMAFIA],[#col-swatch("JPEGMAFIA")],
      [Juice WRLD],[#col-swatch("Juice WRLD")],
      [Cdot Honcho],[#col-swatch("Cdot Honcho")],
      [Danny Brown],[#col-swatch("Danny Brown")],
      [Bring Me The Horizon],[#col-swatch("Bring Me The Horizon")],
      [Young Thug],[#col-swatch("Young Thug")],
      [LTJ Bukem],[#col-swatch("LTJ Bukem")],
      [Falling In Reverse],[#col-swatch("Falling In Reverse")],
      [I Prevail],[#col-swatch("I Prevail")],
      [Gunna],[#col-swatch("Gunna")],
      [¥\$],[#col-swatch("¥$")],
      [Hidden Agenda],[#col-swatch("Hidden Agenda")],
      [Nookie],[#col-swatch("Nookie")],
      [Freddie Gibbs],[#col-swatch("Freddie Gibbs")],
      [KIDS SEE GHOSTS],[#col-swatch("KIDS SEE GHOSTS")],
      [The Roots],[#col-swatch("The Roots")],
      [Pusha T],[#col-swatch("Pusha T")],
      [Tee Grizzley],[#col-swatch("Tee Grizzley")],
      [A Tribe Called Quest],[#col-swatch("A Tribe Called Quest")],
      [Wage War],[#col-swatch("Wage War")],
      [toe],[#col-swatch("toe")],
      [Wax Doctor],[#col-swatch("Wax Doctor")],
      [Lianne La Havas],[#col-swatch("Lianne La Havas")],
      [Black Star],[#col-swatch("Black Star")],
      [underscores],[#col-swatch("underscores")],
      [Fall Out Boy],[#col-swatch("Fall Out Boy")],
      [Palisades],[#col-swatch("Palisades")],
      [Lil Baby],[#col-swatch("Lil Baby")],
      [Tom & Jerry],[#col-swatch("Tom & Jerry")],
      [Remarc],[#col-swatch("Remarc")],
      [SOB X RBE],[#col-swatch("SOB X RBE")],
      [Duwap Kaine],[#col-swatch("Duwap Kaine")],
      [J Majik],[#col-swatch("J Majik")],
      [Ashnikko],[#col-swatch("Ashnikko")],
      [Kim Dracula],[#col-swatch("Kim Dracula")],
      [YoungBoy Never Broke Again],[#col-swatch("YoungBoy Never Broke Again")],
      [BigXthaPlug],[#col-swatch("BigXthaPlug")],
      [Lonnie Liston Smith],[#col-swatch("Lonnie Liston Smith")],
      [Che],[#col-swatch("Che")],
      [Pi'erre Bourne],[#col-swatch("Pi'erre Bourne")],
      [Earl Sweatshirt],[#col-swatch("Earl Sweatshirt")],
      [DANGERDOOM],[#col-swatch("DANGERDOOM")],
      [Fleet Foxes],[#col-swatch("Fleet Foxes")],
      [MGMT],[#col-swatch("MGMT")],
      [Lupe Fiasco],[#col-swatch("Lupe Fiasco")],
      [Anderson .Paak],[#col-swatch("Anderson .Paak")],
      [Hozier],[#col-swatch("Hozier")],
      [Sleep Theory],[#col-swatch("Sleep Theory")],
      [Neon Trees],[#col-swatch("Neon Trees")],
      [Woe, Is Me],[#col-swatch("Woe, Is Me")],
      [Silverstein],[#col-swatch("Silverstein")],
      [Rivals],[#col-swatch("Rivals")],
      [Don Toliver],[#col-swatch("Don Toliver")],
      [Roddy Ricch],[#col-swatch("Roddy Ricch")],
      [A\$AP Rocky],[#col-swatch("A$AP Rocky")],
      [Luh Tyler],[#col-swatch("Luh Tyler")],
      [Kodak Black],[#col-swatch("Kodak Black")],
      [A Boogie Wit da Hoodie],[#col-swatch("A Boogie Wit da Hoodie")],
      [Trippie Redd],[#col-swatch("Trippie Redd")],
      [Fountains Of Wayne],[#col-swatch("Fountains Of Wayne")],
      [Origin Unknown],[#col-swatch("Origin Unknown")],
      [ark762],[#col-swatch("ark762")],
      [Total Science],[#col-swatch("Total Science")],
      [JMJ],[#col-swatch("JMJ")],
      [Benji Blue Bills],[#col-swatch("Benji Blue Bills")],
      [Cutty Ranks],[#col-swatch("Cutty Ranks")],
      [Fiona Apple],[#col-swatch("Fiona Apple")],
      [Sufjan Stevens],[#col-swatch("Sufjan Stevens")],
      [JID],[#col-swatch("JID")],
      [Gorillaz],[#col-swatch("Gorillaz")],
      [blink-182],[#col-swatch("blink-182")],
      [My Chemical Romance],[#col-swatch("My Chemical Romance")],
      [WSTR],[#col-swatch("WSTR")],
      [G Herbo],[#col-swatch("G Herbo")],
      [Chief Keef],[#col-swatch("Chief Keef")],
      [Alex Reese],[#col-swatch("Alex Reese")],
      [tenkay],[#col-swatch("tenkay")],
      [Big Bud],[#col-swatch("Big Bud")],
      [OsamaSon],[#col-swatch("OsamaSon")],
      [J Dilla],[#col-swatch("J Dilla")],
      [The Avalanches],[#col-swatch("The Avalanches")],
      [Mos Def],[#col-swatch("Mos Def")],
      [Big K.R.I.T.],[#col-swatch("Big K.R.I.T.")],
      [The Pharcyde],[#col-swatch("The Pharcyde")],
      [Diamond Construct],[#col-swatch("Diamond Construct")],
      [JAY-Z],[#col-swatch("JAY-Z")],
      [Tay-K],[#col-swatch("Tay-K")],
      [PFM],[#col-swatch("PFM")],
      [Nuito],[#col-swatch("Nuito")],
    )
  )
])

=== Analysis

=== Methodology

== Total Listening Times vs. Play Counts

#figure(
  caption: "Total Listening Times vs. Play Counts for Each User (All-Time, 2024, 2025)",
  grid(
    image("../data/total_listening/plots/total_listening_alltime.png"),
    image("../data/total_listening/plots/total_listening_2024.png"),
    image("../data/total_listening/plots/total_listening_2025.png")
  )
)

#figure(
  caption: "Total Listening Times vs. Play Counts for Each User (All-Time, 2024, 2025)",
  table(
    columns: 4,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 4, align: center)[*All-Time*],
    [],[*Play Count*],[*Minutes*],[*Hours*],
    [*Alan*],[450283],[443300.79],[7388.35],
    [*Alexandra*],[139541],[292826.91],[4880.45],
    [*Anthony*],[72483],[111125.20],[1852.09],
    [*Koren*],[181858],[218405.78],[3640.10],
    table.cell(colspan: 4, align: center)[*2024*],
    [*Alan*],[57042],[77082.03],[1284.70],
    [*Alexandra*],[12369],[27288.73],[454.81],
    [*Anthony*],[11713],[18974.18],[316.24],
    [*Koren*],[14706],[37464.72],[624.41],
    table.cell(colspan: 4, align: center)[*2025*],
    [*Alan*],[29418],[45544.53],[759.08],
    [*Alexandra*],[8712],[20827.66],[347.13],
    [*Anthony*],[13706],[33247.98],[554.13],
    [*Koren*],[17160],[42747.47],[712.46],
  )
)

=== Analysis

=== Methodology

== Events Over Time

=== Daily Listening Events

#figure(
  caption: "Daily Listening Events Over Time for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    row-gutter: 1em,
    image("../data/events_over_time/plots/events_over_time_alltime.png", width: 100%),
    image("../data/events_over_time/plots/events_over_time_2024.png", width: 100%),
    image("../data/events_over_time/plots/events_over_time_2025.png", width: 100%),
  )
)

=== Monthly Plays

#figure(
  caption: "Monthly Plays for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    row-gutter: 1em,
    image("../data/monthly_plays/plots/monthly_plays_alltime.png", width: 100%),
    image("../data/monthly_plays/plots/monthly_plays_2024.png", width: 100%),
    image("../data/monthly_plays/plots/monthly_plays_2025.png", width: 100%),
  )
)

=== Analysis

=== Methodology

== Distributions

=== Daily Play Count

#figure(
  caption: "Distribution of Daily Play Counts for Each User (All-Time, 2024, 2025)",
  table(
    columns: 8,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 8, align: center)[*All-Time*],
    [],[*Mean*],[*Median*],[*Mode*],[*Range*],[*Standard Deviation*],[*Variance*],[*Skewness*],
    [*Alan*],[156.57],[123.00],[1.00],[1276.00],[144.12],[20771.13],[1.87],
    [*Alexandra*],[39.78],[29.00],[12.00],[235.00],[34.62],[1198.52],[1.71],
    [*Anthony*],[58.08],[33.00],[1.00],[848.00],[73.25],[5365.18],[3.17],
    [*Koren*],[63.92],[40.00],[1.00],[1084.00],[74.14],[5496.12],[2.91],
    table.cell(colspan: 8, align: center)[*2024*],
    [*Alan*],[160.68],[148.00],[165.00],[676.00],[105.76],[11184.63],[1.02],
    [*Alexandra*],[34.26],[29.00],[9.00],[224.00],[27.36],[748.46],[2.49],
    [*Anthony*],[42.13],[27.00],[1.00],[263.00],[43.09],[1856.87],[1.89],
    [*Koren*],[43.38],[32.00],[1.00],[277.00],[41.99],[1763.30],[2.10],
    table.cell(colspan: 8, align: center)[*2025*],
    [*Alan*],[54.82],[75.50],[2.00],[596.00],[71.52],[5115.28],[1.91],
    [*Alexandra*],[24.47],[19.50],[12.00],[127.00],[17.56],[308.41],[1.74],
    [*Anthony*],[45.38],[28.50],[6.00],[314.00],[51.83],[2686.58],[2.43],
    [*Koren*],[54.82],[34.00],[1.00],[379.00],[60.89],[3707.91],[1.91],
  )
)

#figure(
  caption: "Box Plots of Daily Play Counts for Each User (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_daily_play_count_alltime.png"),
      image("../data/distributions/plots/boxplot_daily_play_count_alltime_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[48],[222.25],[1277],[174.25],[-213.375],[483.625],
        [Alexandra],[1],[15],[53],[236],[38],[-42],[110],
        [Anthony],[1],[12],[75],[849],[63],[-82.5],[169.5],
        [Koren],[1],[14],[88],[1085],[74],[-97],[199],
      )
    )
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_daily_play_count_2024.png"),
      image("../data/distributions/plots/boxplot_daily_play_count_2024_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[81],[220],[677],[139],[-127.5],[428.5],
        [Alexandra],[1],[16],[44],[225],[28],[-26],[86],
        [Anthony],[1],[11.25],[57.75],[264],[46.5],[-58.5],[127.5],
        [Koren],[1],[13],[60.5],[278],[47.5],[-58.25],[131.75],
      )
    )
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_daily_play_count_2025.png"),
      image("../data/distributions/plots/boxplot_daily_play_count_2025_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[31],[123.75],[597],[92.75],[-108.125],[262.875],
        [Alexandra],[1],[12],[32],[128],[20],[-18],[62],
        [Anthony],[1],[11],[59.75],[315],[48.75],[-62.125],[132.875],
        [Koren],[1],[9],[76],[380],[67],[-91.5],[176.5],
      )
    )
  ]
)

#figure(
  caption: "Histograms of Daily Play Counts for Each User (All-Time, 2024, 2025)",
  [
    *Alan*
    #grid(
      columns: 2,
      image("../data/distributions/plots/daily_play_count_hist_alanjzamora_alltime.png"),
      image("../data/distributions/plots/daily_play_count_hist_alanjzamora_2024.png"),
      image("../data/distributions/plots/daily_play_count_hist_alanjzamora_2025.png"),
    )
    *Alexandra*
    #grid(
      columns: 2,
      image("../data/distributions/plots/daily_play_count_hist_alexxxxxrs_alltime.png"),
      image("../data/distributions/plots/daily_play_count_hist_alexxxxxrs_2024.png"),
      image("../data/distributions/plots/daily_play_count_hist_alexxxxxrs_2025.png"),
    )
    *Anthony*
    #grid(
      columns: 2,
      image("../data/distributions/plots/daily_play_count_hist_dasucc_alltime.png"),
      image("../data/distributions/plots/daily_play_count_hist_dasucc_2024.png"),
      image("../data/distributions/plots/daily_play_count_hist_dasucc_2025.png"),
    )
    *Koren*
    #grid(
      columns: 2,
      image("../data/distributions/plots/daily_play_count_hist_korenns_alltime.png"),
      image("../data/distributions/plots/daily_play_count_hist_korenns_2024.png"),
      image("../data/distributions/plots/daily_play_count_hist_korenns_2025.png"),
    )
  ]
)

=== Plays Per Track

#figure(
  caption: "Distribution of Plays per Track for Each User (All-Time, 2024, 2025)",
  table(
    columns: 8,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 8, align: center)[*All-Time*],
    [],[*Mean*],[*Median*],[*Mode*],[*Range*],[*Standard Deviation*],[*Variance*],[*Skewness*],
    [*Alan*],[47.52],[5.00],[2.00],[1370.00],[119.01],[14164.13],[4.16],
    [*Alexandra*],[32.20],[20.00],[2.00],[262.00],[37.28],[1389.89],[1.75],
    [*Anthony*],[8.78],[3.00],[2.00],[233.00],[16.41],[269.32],[5.03],
    [*Koren*],[13.18],[4.00],[2.00],[305.00],[23.60],[557.08],[4.22],
    table.cell(colspan: 8, align: center)[*2024*],
    [*Alan*],[15.01],[4.00],[1.00],[121.00],[20.35],[414.10],[1.63],
    [*Alexandra*],[6.06],[5.00],[4.00],[51.00],[4.60],[21.15],[2.85],
    [*Anthony*],[4.42],[2.00],[1.00],[58.00],[6.14],[37.76],[3.41],
    [*Koren*],[5.00],[2.00],[1.00],[77.00],[7.49],[56.13],[3.30],
    table.cell(colspan: 8, align: center)[*2025*],
    [*Alan*],[9.47],[4.00],[1.00],[103.00],[11.51],[132.40],[2.39],
    [*Alexandra*],[4.47],[4.00],[3.00],[118.00],[3.64],[13.23],[16.46],
    [*Anthony*],[4.06],[2.00],[1.00],[50.00],[5.47],[29.87],[3.50],
    [*Koren*],[4.70],[2.00],[1.00],[44.00],[5.73],[32.84],[2.23],
  )
)

#figure(
  caption: "Box Plots of Plays per Track for Each User (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_track_alltime.png"),
      image("../data/distributions/plots/boxplot_plays_per_track_alltime_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[2],[21],[1371],[19],[-26.5],[49.5],
        [Alexandra],[1],[4],[44],[263],[40],[-56],[104],
        [Anthony],[1],[2],[8],[234],[6],[-7],[17],
        [Koren],[1],[2],[14],[306],[12],[-16],[32], 
      )
    )
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_track_2024.png"),
      image("../data/distributions/plots/boxplot_plays_per_track_2024_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[2],[25],[122],[23],[-32.5],[59.5],
        [Alexandra],[1],[3],[8],[52],[5],[-4.5],[15.5],
        [Anthony],[1],[1],[5],[59],[4],[-5],[11],
        [Koren],[1],[1],[5],[78],[4],[-5],[11],
      )
    )
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_track_2025.png"),
      image("../data/distributions/plots/boxplot_plays_per_track_2025_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[2],[14],[104],[12],[-16],[32],
        [Alexandra],[1],[3],[6],[119],[3],[-1.5],[10.5],
        [Anthony],[1],[1],[4],[51],[3],[-3.5],[8.5],
        [Koren],[1],[1],[6],[45],[5],[-6.5],[13.5],   
      )
    )
  ]
)

=== Plays Per Artist

#figure(
  caption: "Distribution of Plays per Artist for Each User (All-Time, 2024, 2025)",
  table(
    columns: 8,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 8, align: center)[*All-Time*],
    [],[*Mean*],[*Median*],[*Mode*],[*Range*],[*Standard Deviation*],[*Variance*],[*Skewness*],
    [*Alan*],[265.65],[5.00],[2.00],[43738.00],[1547.60],[2395064.73],[16.81],
    [*Alexandra*],[131.15],[22.00],[2.00],[9307.00],[557.96],[311323.54],[11.00],
    [*Anthony*],[55.93],[4.00],[2.00],[6779.00],[273.06],[74559.34],[15.17],
    [*Koren*],[45.03],[6.00],[2.00],[5763.00],[198.37],[39350.67],[14.55],
    table.cell(colspan: 8, align: center)[*2024*],
    [*Alan*],[71.48],[5.00],[2.00],[2802.00],[211.32],[44655.85],[6.09],
    [*Alexandra*],[23.29],[7.00],[1.00],[987.00],[70.99],[5039.69],[8.07],
    [*Anthony*],[21.26],[3.00],[1.00],[857.00],[65.88],[4340.80],[7.26],
    [*Koren*],[11.61],[3.00],[1.00],[763.00],[35.68],[1272.94],[11.74],
    table.cell(colspan: 8, align: center)[*2025*],
    [*Alan*],[61.29],[8.00],[1.00],[1183.00],[135.04],[18235.16],[4.34],
    [*Alexandra*],[17.32],[5.00],[3.00],[562.00],[47.73],[2278.42],[6.93],
    [*Anthony*],[25.24],[4.00],[1.00],[1198.00],[81.50],[6642.28],[8.19],
    [*Koren*],[12.21],[3.00],[1.00],[1070.00],[40.27],[1621.82],[15.49],
  )
)

#figure(
  caption: "Box Plots of Plays per Artist for Each User (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_artist_alltime.png"),
      image("../data/distributions/plots/boxplot_plays_per_artist_alltime_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[2],[24],[43739],[22],[-31],[57],
        [Alexandra],[1],[3],[75],[9308],[72],[-105],[183],
        [Anthony],[1],[2],[18],[6780],[16],[-22],[42],
        [Koren],[1],[2],[24],[5764],[22],[-31],[57],
      )
    )
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_artist_2024.png"),
      image("../data/distributions/plots/boxplot_plays_per_artist_2024_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[2],[26.75],[2803],[24.75],[-35.125],[63.875],
        [Alexandra],[1],[4],[13],[988],[9],[-9.5],[26.5],
        [Anthony],[1],[1],[11],[858],[10],[-14],[26],
        [Koren],[1],[1],[8],[764],[7],[-9.5],[18.5],
      )
    )
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_artist_2025.png"),
      image("../data/distributions/plots/boxplot_plays_per_artist_2025_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[2],[49.25],[1184],[47.25],[-68.875],[120.125],
        [Alexandra],[1],[3],[10],[563],[7],[-7.5],[20.5],
        [Anthony],[1],[2],[15],[1199],[13],[-17.5],[34.5],
        [Koren],[1],[1],[11],[1071],[10],[-14],[26],
      )
    )
  ]
)

=== Plays Per Album

#figure(
  caption: "Distribution of Plays per Album for Each User (All-Time, 2024, 2025)",
  table(
    columns: 8,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 8, align: center)[*All-Time*],
    [],[*Mean*],[*Median*],[*Mode*],[*Range*],[*Standard Deviation*],[*Variance*],[*Skewness*],
    [*Alan*],[114.75],[4.00],[2.00],[8731.00],[503.24],[253250.73],[9.14],
    [*Alexandra*],[57.97],[18.00],[2.00],[1766.00],[150.36],[22609.62],[6.19],
    [*Anthony*],[16.64],[4.00],[2.00],[1239.00],[52.37],[2742.38],[10.64],
    [*Koren*],[21.64],[5.00],[2.00],[1490.00],[61.03],[3724.59],[10.40],
    table.cell(colspan: 8, align: center)[*2024*],
    [*Alan*],[38.28],[4.00],[2.00],[686.00],[92.17],[8494.98],[3.78],
    [*Alexandra*],[10.91],[6.00],[1.00],[321.00],[20.73],[429.59],[6.63],
    [*Anthony*],[8.07],[3.00],[1.00],[273.00],[18.28],[334.03],[7.64],
    [*Koren*],[7.21],[2.00],[1.00],[418.00],[16.57],[274.53],[11.38],
    table.cell(colspan: 8, align: center)[*2025*],
    [*Alan*],[29.66],[5.00],[1.00],[676.00],[58.62],[3436.35],[4.00],
    [*Alexandra*],[8.11],[5.00],[2.00],[159.00],[13.69],[187.32],[5.03],
    [*Anthony*],[8.30],[3.00],[1.00],[384.00],[20.01],[400.26],[8.69],
    [*Koren*],[7.12],[2.00],[1.00],[583.00],[18.34],[336.26],[17.53],
  )
)

#figure(
  caption: "Box Plots of Plays per Album for Each User (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_album_alltime.png"),
      image("../data/distributions/plots/boxplot_plays_per_album_alltime_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[2],[17],[8732],[15],[-20.5],[39.5],
        [Alexandra],[1],[3],[49],[1767],[46],[-66],[118],
        [Anthony],[1],[2],[10],[1240],[8],[-10],[22],
        [Koren],[1],[2],[18],[1491],[16],[-22],[42],
      )
    )
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_album_2024.png"),
      image("../data/distributions/plots/boxplot_plays_per_album_2024_log.png"),
    )
    #align(center,  
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[2],[20],[687],[18],[-25],[47],
        [Alexandra],[1],[3],[10],[322],[7],[-7.5],[20.5],
        [Anthony],[1],[1],[7],[274],[6],[-8],[16],
        [Koren],[1],[1],[6],[419],[5],[-6.5],[13.5],
      )
    )
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_album_2025.png"),
      image("../data/distributions/plots/boxplot_plays_per_album_2025_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[1],[2],[29],[677],[27],[-38.5],[69.5],
        [Alexandra],[1],[3],[7],[160],[4],[-3],[13],
        [Anthony],[1],[1],[7],[385],[6],[-8],[16],
        [Koren],[1],[1],[9],[584],[8],[-11],[21],
      )
    )
  ]
)

=== Session Length

#figure(
  caption: "Distribution of Session Lengths for Each User (All-Time, 2024, 2025)",
  table(
    columns: 8,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 8, align: center)[*All-Time*],
    [],[*Mean*],[*Median*],[*Mode*],[*Range*],[*Standard Deviation*],[*Variance*],[*Skewness*],
    [*Alan*],[41.36],[26.50],[1.00],[1158.65],[51.30],[2631.50],[4.09],
    [*Alexandra*],[30.54],[19.06],[1.00],[494.45],[39.98],[1598.04],[3.78],
    [*Anthony*],[44.01],[21.21],[2.00],[1199.27],[67.80],[4596.43],[5.25],
    [*Koren*],[30.46],[13.01],[1.00],[1085.80],[52.12],[2716.85],[5.97],
    table.cell(colspan: 8, align: center)[*2024*],
    [*Alan*],[58.19],[36.44],[1.00],[1158.64],[81.48],[6638.73],[5.12],
    [*Alexandra*],[28.37],[17.27],[3.00],[494.45],[41.44],[1717.48],[4.36],
    [*Anthony*],[39.27],[19.95],[1.00],[435.77],[53.36],[2846.83],[3.26],
    [*Koren*],[42.02],[19.35],[1.00],[711.71],[64.38],[4145.35],[3.56],
    table.cell(colspan: 8, align: center)[*2025*],
    [*Alan*],[42.87],[27.97],[1.00],[678.58],[55.24],[3050.96],[4.08],
    [*Alexandra*],[21.77],[15.70],[7.00],[260.91],[24.86],[617.96],[3.43],
    [*Anthony*],[49.83],[24.18],[3.00],[1199.27],[90.70],[8226.07],[6.29],
    [*Koren*],[50.69],[20.59],[1.00],[877.88],[82.47],[6800.97],[4.18],
  )
)

#figure(
  caption: "Box Plots of Session Length for Each User (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_session_length_alltime.png"),
      image("../data/distributions/plots/boxplot_session_length_alltime_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[0],[6.668],[57.329],[1158.650],[50.661],[-69.323],[133.320],
        [Alexandra],[0],[8.981],[35.642],[494.446],[26.660],[-30.009],[74.632],
        [Anthony],[0],[5.048],[59.096],[1199.269],[54.047],[-76.022],[140.166],
        [Koren],[0],[2.511],[38.261],[1085.802],[35.751],[-51.126],[91.898],
      )
    )
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_session_length_2024.png"),
      image("../data/distributions/plots/boxplot_session_length_2024_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[0.008],[11.509],[74.306],[1158.650],[62.797],[-82.687],[168.502],
        [Alexandra],[0],[6.387],[34.533],[494.446],[28.146],[-35.832],[76.752],
        [Anthony],[0.028],[6.346],[57.505],[435.802],[51.159],[-70.393],[134.244],
        [Koren],[0],[4.718],[50.605],[711.707],[45.887],[-63.112],[118.435],
      )
    )
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_session_length_2025.png"),
      image("../data/distributions/plots/boxplot_session_length_2025_log.png"),
    )
    #align(center,
      table(
        columns: 8,
        align: left,
        [*User*],[*Min*],[$bold(Q_1)$],[$bold(Q_3)$],[*Max*],[*IQR*],[*Lower Fence*],[*Upper Fence*],
        [Alan],[0],[6.582],[55.796],[678.582],[49.213],[-67.337],[129.715],
        [Alexandra],[0],[6.879],[27.848],[260.906],[20.969],[-24.575],[59.302],
        [Anthony],[0],[9.171],[56.035],[1199.269],[46.864],[-61.124],[126.330],
        [Koren],[0],[4.044],[66.133],[877.882],[62.089],[-89.090],[159.267],
      )
    )
  ]
)

=== Analysis

=== Methodology

== Outliers

=== Daily Play Count

#figure(
  caption: "Distribution of Daily Play Counts for Each User with Outliers Removed (All-Time, 2024, 2025)",
  table(
    columns: 9,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 9, align: center)[*All-Time*],
    [],[*Outliers*],[*Mean*],[*Median*],[*Mode*],[*Range*],[*Standard Deviation*],[*Variance*],[*Skewness*],
    [*Alan*],[94],[140.48],[118.00],[1.00],[479.00],[112.43],[12640.24],[0.82],
    [*Alexandra*],[191],[34.01],[28.00],[12.00],[109.00],[24.83],[616.58],[0.97],
    [*Anthony*],[89],[42.61],[30.00],[1.00],[168.00],[40.15],[1611.64],[1.15],
    [*Koren*],[158],[50.92],[37.00],[1.00],[198.00],[47.00],[2208.74],[1.08],
    table.cell(colspan: 9, align: center)[*2024*],
    [*Alan*],[5],[155.13],[146.50],[165.00],[427.00],[95.29],[9079.38],[0.52],
    [*Alexandra*],[17],[30.21],[28.00],[9.00],[83.00],[18.83],[354.56],[0.67],
    [*Anthony*],[14],[35.28],[25.00],[1.00],[125.00],[30.72],[943.94],[1.08],
    [*Koren*],[17],[36.70],[30.00],[1.00],[130.00],[29.10],[846.94],[0.85],
    table.cell(colspan: 9, align: center)[*2025*],
    [*Alan*],[5],[81.58],[72.00],[2.00],[249.00],[60.15],[3618.18],[0.63],
    [*Alexandra*],[15],[22.07],[18.00],[12.00],[58.00],[13.19],[173.89],[0.79],
    [*Anthony*],[20],[34.59],[26.50],[6.00],[130.00],[29.84],[890.66],[1.08],
    [*Koren*],[17],[44.61],[31.00],[1.00],[166.00],[42.62],[1816.50],[1.04],
  )
)

=== Plays Per Track

#figure(
  caption: "Distribution of Plays per Track for Each User with Outliers Removed (All-Time, 2024, 2025)",
  table(
    columns: 9,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 9, align: center)[*All-Time*],
    [],[*Outliers*],[*Mean*],[*Median*],[*Mode*],[*Range*],[*Standard Deviation*],[*Variance*],[*Skewness*],
    [*Alan*],[1736],[7.12],[3.00],[2.00],[48.00],[9.29],[86.22],[2.46],
    [*Alexandra*],[281],[25.13],[17.00],[2.00],[103.00],[25.82],[666.52],[1.20],
    [*Anthony*],[1004],[4.19],[3.00],[2.00],[16.00],[3.71],[13.75],[1.62],
    [*Koren*],[1523],[6.58],[3.00],[2.00],[31.00],[7.14],[51.05],[1.70],
    table.cell(colspan: 9, align: center)[*2024*],
    [*Alan*],[146],[12.62],[3.00],[1.00],[58.00],[16.54],[273.70],[1.37],
    [*Alexandra*],[68],[5.51],[5.00],[4.00],[14.00],[3.26],[10.62],[0.69],
    [*Anthony*],[231],[2.84],[2.00],[1.00],[10.00],[2.38],[5.66],[1.64],
    [*Koren*],[345],[2.65],[2.00],[1.00],[10.00],[2.28],[5.22],[1.79],
    table.cell(colspan: 9, align: center)[*2025*],
    [*Alan*],[148],[7.65],[4.00],[1.00],[31.00],[7.77],[60.34],[1.13],
    [*Alexandra*],[51],[4.18],[4.00],[3.00],[9.00],[2.14],[4.58],[0.53],
    [*Anthony*],[404],[2.43],[2.00],[1.00],[7.00],[1.76],[3.09],[1.41],
    [*Koren*],[344],[3.26],[2.00],[1.00],[12.00],[3.30],[10.92],[1.63],
  )
)

=== Plays Per Artist

#figure(
  caption: "Distribution of Plays per Artist for Each User with Outliers Removed (All-Time, 2024, 2025)",
  table(
    columns: 9,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 9, align: center)[*All-Time*],
    [],[*Outliers*],[*Mean*],[*Median*],[*Mode*],[*Range*],[*Standard Deviation*],[*Variance*],[*Skewness*],
    [*Alan*],[320],[7.51],[3.00],[2.00],[55.00],[10.28],[105.59],[2.59],
    [*Alexandra*],[121],[33.02],[17.00],[2.00],[180.00],[39.93],[1594.69],[1.57],
    [*Anthony*],[207],[6.87],[3.00],[2.00],[41.00],[8.51],[72.40],[2.09],
    [*Koren*],[521],[10.46],[4.50],[2.00],[56.00],[12.82],[164.38],[1.86],
    table.cell(colspan: 9, align: center)[*2024*],
    [*Alan*],[138],[8.12],[3.00],[2.00],[61.00],[11.83],[139.93],[2.47],
    [*Alexandra*],[74],[7.19],[6.00],[1.00],[25.00],[5.23],[27.38],[1.16],
    [*Anthony*],[76],[5.08],[3.00],[1.00],[25.00],[5.72],[32.76],[1.88],
    [*Koren*],[184],[3.70],[2.00],[1.00],[17.00],[3.63],[13.15],[1.83],
    table.cell(colspan: 9, align: center)[*2025*],
    [*Alan*],[70],[18.67],[5.00],[1.00],[113.00],[27.09],[733.92],[1.88],
    [*Alexandra*],[78],[5.50],[5.00],[3.00],[18.00],[3.61],[13.03],[1.33],
    [*Anthony*],[71],[6.52],[3.00],[1.00],[33.00],[7.52],[56.54],[1.72],
    [*Koren*],[128],[5.08],[2.00],[1.00],[25.00],[5.78],[33.39],[1.68],
  )
)

=== Plays Per Album

#figure(
  caption: "Distribution of Plays per Album for Each User with Outliers Removed (All-Time, 2024, 2025)",
  table(
    columns: 9,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 9, align: center)[*All-Time*],
    [],[*Outliers*],[*Mean*],[*Median*],[*Mode*],[*Range*],[*Standard Deviation*],[*Variance*],[*Skewness*],
    [*Alan*],[753],[5.76],[3.00],[2.00],[38.00],[6.84],[46.79],[2.41],
    [*Alexandra*],[217],[24.90],[15.00],[2.00],[117.00],[27.78],[771.71],[1.41],
    [*Anthony*],[618],[4.78],[3.00],[2.00],[21.00],[4.57],[20.88],[1.75],
    [*Koren*],[1002],[8.33],[4.00],[2.00],[41.00],[9.55],[91.27],[1.71],
    table.cell(colspan: 9, align: center)[*2024*],
    [*Alan*],[255],[6.76],[3.00],[2.00],[46.00],[9.71],[94.36],[2.43],
    [*Alexandra*],[103],[6.10],[5.00],[1.00],[19.00],[4.05],[16.42],[0.90],
    [*Anthony*],[170],[3.68],[2.00],[1.00],[15.00],[3.58],[12.80],[1.69],
    [*Koren*],[292],[3.06],[2.00],[1.00],[12.00],[2.73],[7.43],[1.74],
    table.cell(colspan: 9, align: center)[*2025*],
    [*Alan*],[142],[10.56],[3.00],[1.00],[67.00],[14.63],[214.01],[1.97],
    [*Alexandra*],[108],[4.63],[4.00],[2.00],[12.00],[2.66],[7.10],[0.86],
    [*Anthony*],[180],[3.64],[2.00],[1.00],[15.00],[3.42],[11.70],[1.71],
    [*Koren*],[138],[4.66],[2.00],[1.00],[20.00],[5.04],[25.42],[1.43],
  )
)

=== Session Length

#figure(
  caption: "Distribution of Session Lengths for Each User with Outliers Removed (All-Time, 2024, 2025)",
  table(
    columns: 9,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 9, align: center)[*All-Time*],
    [],[*Outliers*],[*Mean*],[*Median*],[*Mode*],[*Range*],[*Standard Deviation*],[*Variance*],[*Skewness*],
    [*Alan*],[798],[32.95],[24.14],[1.00],[133.23],[31.60],[998.39],[1.06],
    [*Alexandra*],[922],[21.04],[17.27],[1.00],[75.61],[16.85],[283.85],[0.97],
    [*Anthony*],[178],[31.43],[18.48],[2.00],[140.12],[32.92],[1083.91],[1.18],
    [*Koren*],[796],[19.58],[10.81],[1.00],[91.81],[21.93],[480.72],[1.30],
    table.cell(colspan: 9, align: center)[*2024*],
    [*Alan*],[103],[43.47],[33.20],[1.00],[168.25],[40.73],[1658.75],[1.07],
    [*Alexandra*],[77],[20.05],[15.20],[3.00],[76.48],[17.63],[310.72],[1.02],
    [*Anthony*],[31],[29.84],[18.07],[1.00],[132.36],[29.94],[896.46],[1.09],
    [*Koren*],[100],[25.98],[15.65],[1.00],[118.22],[27.52],[757.41],[1.27],
    table.cell(colspan: 9, align: center)[*2025*],
    [*Alan*],[90],[32.44],[24.89],[1.00],[128.02],[30.39],[923.71],[1.02],
    [*Alexandra*],[70],[17.15],[14.26],[7.00],[59.03],[13.59],[184.57],[0.90],
    [*Anthony*],[65],[30.70],[20.88],[3.00],[125.17],[29.44],[866.96],[1.27],
    [*Koren*],[65],[34.33],[16.78],[1.00],[157.38],[39.37],[1549.89],[1.28],
  )
)

=== Analysis

=== Methodology

== Temporal Analysis

=== Listening Times

#figure(
  caption: "Distribution of Listening Times for Alan (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alanjzamora_alltime.png", width: 80%),
      [*Most Active Hour*: 6:00 PM \ *Least Active Hour*: 9:00 AM]
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alanjzamora_2024.png", width: 80%),
      [*Most Active Hour*: 6:00 PM \ *Least Active Hour*: 9:00 AM]
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alanjzamora_2025.png", width: 80%),
      [*Most Active Hour*: 4:00 PM \ *Least Active Hour*: 9:00 AM]
    )
  ]
)

#figure(
  caption: "Distribution of Listening Times for Alexandra (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alexxxxxrs_alltime.png", width: 80%),
      [*Most Active Hour*: 11:00 PM \ *Least Active Hour*: 10:00 AM]
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alexxxxxrs_2024.png", width: 80%),
      [*Most Active Hour*: 8:00 PM \ *Least Active Hour*: 11:00 AM]
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alexxxxxrs_2025.png", width: 80%),
      [*Most Active Hour*: 9:00 PM \ *Least Active Hour*: 10:00 AM]
    )
  ]
)

#figure(
  caption: "Distribution of Listening Times for Anthony (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_dasucc_alltime.png", width: 80%),
      [*Most Active Hour*: 12:00 AM \ *Least Active Hour*: 12:00 PM]
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_dasucc_2024.png", width: 80%),
      [*Most Active Hour*: 1:00 AM \ *Least Active Hour*: 12:00 PM]
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_dasucc_2025.png", width: 80%),
      [*Most Active Hour*: 5:00 PM \ *Least Active Hour*: 12:00 PM]
    )
  ]
)

#figure(
  caption: "Distribution of Listening Times for Koren (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_korenns_alltime.png", width: 80%),
      [*Most Active Hour*: 11:00 PM \ *Least Active Hour*: 10:00 AM]
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_korenns_2024.png", width: 80%),
      [*Most Active Hour*: 10:00 PM \ *Least Active Hour*: 11:00 AM]
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_korenns_2025.png", width: 80%),
      [*Most Active Hour*: 2:00 PM \ *Least Active Hour*: 11:00 AM]
    )
  ]
)

#figure(
  caption: "Listening Times Heatmap for Alan (All-Time, 2024, 2025)",
  [
    #grid(
      image("../data/heatmap/plots/heatmap_dow_hour_alanjzamora_alltime.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_alanjzamora_2024.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_alanjzamora_2025.png"),
    )
  ]
)

#figure(
  caption: "Listening Times Heatmap for Alexandra (All-Time, 2024, 2025)",
  [
    #grid(
      image("../data/heatmap/plots/heatmap_dow_hour_alexxxxxrs_alltime.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_alexxxxxrs_2024.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_alexxxxxrs_2025.png"),
    )
  ]
)

#figure(
  caption: "Listening Times Heatmap for Anthony (All-Time, 2024, 2025)",
  [
    #grid(
      image("../data/heatmap/plots/heatmap_dow_hour_dasucc_alltime.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_dasucc_2024.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_dasucc_2025.png"),
    )
  ]
)

#figure(
  caption: "Listening Times Heatmap for Koren (All-Time, 2024, 2025)",
  [
    #grid(
      image("../data/heatmap/plots/heatmap_dow_hour_korenns_alltime.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_korenns_2024.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_korenns_2025.png"),
    )
  ]
)

=== Analysis

=== Methodology

== Bool Flags

=== Shuffle, Skipped, Offline

#figure(
  caption: "Rate of Shuffle, Skipped, and Offline Plays for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    image("../data/bool_flags/plots/bool_flags_users_alltime.png"),
    image("../data/bool_flags/plots/bool_flags_users_2024.png"),
    image("../data/bool_flags/plots/bool_flags_users_2025.png")
  )
)

#figure(
  caption: "Rate of Shuffle, Skipped, and Offline Plays for Each User (All-Time, 2024, 2025)",
  table(
    columns: 4,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 4, align: center)[*All-Time*],
    [*User*],[*Shuffle Rate*],[*Skip Rate*],[*Offline Rate*],
    [Alan],[0.633 (63.3%)],[0.260 (26.0%)],[0.001 (0.1%)],
    [Alexandra],[0.933 (93.3%)],[0.117 (11.7%)],[0.050 (5.0%)],
    [Anthony],[0.538 (53.8%)],[0.341 (34.1%)],[0.004 (0.4%)],
    [Koren],[0.651 (65.1%)],[0.275 (27.5%)],[0.009 (0.9%)],
    table.cell(colspan: 4, align: center)[*2024*],
    [Alan],[0.728 (72.8%)],[0.806 (80.6%)],[0.001 (0.1%)],
    [Alexandra],[0.895 (89.5%)],[0.371 (37.1%)],[0 (0.0%)],
    [Anthony],[0.683 (68.3%)],[0.556 (55.6%)],[0 (0.0%)],
    [Koren],[0.761 (76.1%)],[0.588 (58.8%)],[0.017 (1.7%)],
    table.cell(colspan: 4, align: center)[*2025*],
    [Alan],[0.496 (49.6%)],[0.802 (80.2%)],[0.001 (0.1%)],
    [Alexandra],[0.958 (95.8%)],[0.264 (26.4%)],[0.014 (1.4%)],
    [Anthony],[0.615 (61.5%)],[0.319 (31.9%)],[0.005 (0.5%)],
    [Koren],[0.766 (76.6%)],[0.551 (55.1%)],[0.080 (8.0%)],
  )
)

=== Skip Rate by Shuffle

#figure(
  caption: "Skip Rate by Shuffle for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    image("../data/skip_by_shuffle/plots/skip_by_shuffle_users_alltime.png"),
    image("../data/skip_by_shuffle/plots/skip_by_shuffle_users_2024.png"),
    image("../data/skip_by_shuffle/plots/skip_by_shuffle_users_2025.png")
  )
)

#figure(
  caption: "Skip Rate by Shuffle for Each User (All-Time, 2024, 2025)",
  table(
    columns: 3,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 3, align: center)[*All-Time*],
    [*User*],[*Skip Rate (Shuffle On)*],[*Skip Rate (Shuffle Off)*],
    [Alan],[0.239 (23.9%)],[0.297 (29.7%)],
    [Alexandra],[0.114 (11.4%)],[0.164 (16.4%)],
    [Anthony],[0.464 (46.4%)],[0.197 (19.7%)],
    [Koren],[0.294 (29.4%)],[0.240 (24.0%)],
    table.cell(colspan: 3, align: center)[*2024*],
    [Alan],[0.814 (81.4%)],[0.784 (78.4%)],
    [Alexandra],[0.372 (37.2%)],[0.359 (35.9%)],
    [Anthony],[0.655 (65.5%)],[0.343 (34.3%)],
    [Koren],[0.541 (54.1%)],[0.740 (74.0%)],
    table.cell(colspan: 3, align: center)[*2025*],
    [Alan],[0.830 (83.0%)],[0.774 (77.4%)],
    [Alexandra],[0.260 (26.0%)],[0.337 (33.7%)],
    [Anthony],[0.389 (38.9%)],[0.207 (20.7%)],
    [Koren],[0.478 (47.8%)],[0.789 (78.9%)],
  )
)

=== Start & End Reasons

#figure(
  caption: "Start Reasons Proportions for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    image("../data/reason_start_end/plots/reason_start_users_alltime.png"),
    image("../data/reason_start_end/plots/reason_start_users_2024.png"),
    image("../data/reason_start_end/plots/reason_start_users_2025.png")
  )
)

#figure(
  caption: "Start Reasons Proportions for Each User (All-Time, 2024, 2025)",
  table(
    columns: 5,
    align: left,
    fill: (col, row) => {
      if row in (0, 11, 22) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 5, align: center)[*All-Time*],
    [*Reason*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
    [`fwdbtn`],[0.555 (55.5%)],[0.349 (34.9%)],[0.527 (52.7%)],[0.515 (51.5%)],
    [`trackdone`],[0.101 (10.1%)],[0.540 (54.0%)],[0.357 (35.7%)],[0.199 (19.9%)],
    [`clickrow`],[0.226 (22.6%)],[0.036 (3.6%)],[0.052 (5.2%)],[0.155 (15.5%)],
    [`playbtn`],[0.036 (3.6%)],[0.024 (2.4%)],[0.030 (3.0%)],[0.058 (5.8%)],
    [`backbtn`],[0.070 (7.0%)],[0.028 (2.8%)],[0.018 (1.8%)],[0.043 (4.3%)],
    [`appload`],[0.010 (1.0%)],[0.019 (1.9%)],[0.008 (0.8%)],[0.014 (1.4%)],
    [`remote`],[0.002 (0.2%)],[0.002 (0.2%)],[0.008 (0.8%)],[0.007 (0.7%)],
    [`trackerror`],[0.000 (0.0%)],[0.001 (0.1%)],[0.000 (0.0%)],[0.006 (0.6%)],
    [`unknown`],[0 (0%)],[0.001 (0.1%)],[0.001 (0.1%)],[0.001 (0.1%)],
    table.cell(colspan: 5, align: center)[*2024*],
    [*Reason*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
    [`fwdbtn`],[0.555 (55.5%)],[0.331 (33.1%)],[0.461 (46.1%)],[0.416 (41.6%)],
    [`trackdone`],[0.174 (17.4%)],[0.576 (57.6%)],[0.410 (41.0%)],[0.368 (36.8%)],
    [`clickrow`],[0.210 (21.0%)],[0.029 (2.9%)],[0.076 (7.6%)],[0.118 (11.8%)],
    [`playbtn`],[0.021 (2.1%)],[0.016 (1.6%)],[0.013 (1.3%)],[0.031 (3.1%)],
    [`backbtn`],[0.025 (2.5%)],[0.033 (3.3%)],[0.018 (1.8%)],[0.043 (4.3%)],
    [`appload`],[0.012 (1.2%)],[0.012 (1.2%)],[0.009 (0.9%)],[0.010 (1.0%)],
    [`remote`],[0.003 (0.3%)],[0.003 (0.3%)],[0.013 (1.3%)],[0.008 (0.8%)],
    [`trackerror`],[0.000 (0.0%)],[0.001 (0.1%)],[0.000 (0.0%)],[0.004 (0.4%)],
    [`unknown`],[0 (0%)],[0.000 (0.0%)],[0.000 (0.0%)],[0.001 (0.1%)],
    table.cell(colspan: 5, align: center)[*2025*],
    [*Reason*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
    [`fwdbtn`],[0.405 (40.5%)],[0.258 (25.8%)],[0.247 (24.7%)],[0.418 (41.8%)],
    [`trackdone`],[0.178 (17.8%)],[0.634 (63.4%)],[0.646 (64.6%)],[0.416 (41.6%)],
    [`clickrow`],[0.353 (35.3%)],[0.033 (3.3%)],[0.062 (6.2%)],[0.095 (9.5%)],
    [`playbtn`],[0.021 (2.1%)],[0.011 (1.1%)],[0.008 (0.8%)],[0.026 (2.6%)],
    [`backbtn`],[0.026 (2.6%)],[0.019 (1.9%)],[0.010 (1.0%)],[0.025 (2.5%)],
    [`appload`],[0.012 (1.2%)],[0.027 (2.7%)],[0.011 (1.1%)],[0.005 (0.5%)],
    [`remote`],[0.003 (0.3%)],[0.000 (0.0%)],[0.014 (1.4%)],[0.005 (0.5%)],
    [`trackerror`],[0.001 (0.1%)],[0.001 (0.1%)],[0.001 (0.1%)],[0.009 (0.9%)],
    [`unknown`],[0.001 (0.1%)],[0.016 (1.6%)],[0.001 (0.1%)],[0.001 (0.1%)],
  )
)

#figure(
  caption: "End Reasons Proportions for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    image("../data/reason_start_end/plots/reason_end_users_alltime.png"),
    image("../data/reason_start_end/plots/reason_end_users_2024.png"),
    image("../data/reason_start_end/plots/reason_end_users_2025.png")
  )
)

#figure(
  caption: "End Reasons Proportions for Each User (All-Time, 2024, 2025)",
  table(
    columns: 5,
    align: left,
    fill: (col, row) => {
      if row in (0, 12, 23) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 5, align: center)[*All-Time*],
    [*Reason*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
    [`fwdbtn`],[0.552 (55.2%)],[0.342 (34.2%)],[0.525 (52.5%)],[0.519 (51.9%)],
    [`trackdone`],[0.100 (10%)],[0.543 (54.3%)],[0.363 (36.3%)],[0.203 (20.3%)],
    [`endplay`],[0.258 (25.8%)],[0.033 (3.3%)],[0.066 (6.6%)],[0.187 (18.7%)],
    [`backbtn`],[0.069 (6.9%)],[0.028 (2.8%)],[0.018 (1.8%)],[0.043 (4.3%)],
    [`unexpected-exit-while-paused`],[0.015 (1.5%)],[0.032 (3.2%)],[0.016 (1.6%)],[0.020 (2.0%)],
    [`logout`],[0.002 (0.2%)],[0.018 (1.8%)],[0.007 (0.7%)],[0.013 (1.3%)],
    [`remote`],[0.001 (0.1%)],[0.001 (0.1%)],[0.002 (0.2%)],[0.006 (0.6%)],
    [`unexpected-exit`],[0.001 (0.1%)],[0.001 (0.1%)],[0.001 (0.1%)],[0.004 (0.4%)],
    [`trackerror`],[0.001 (0.1%)],[0.001 (0.1%)],[0.000 (0.0%)],[0.002 (0.2%)],
    [`unknown`],[0 (0%)],[0.001 (0.1%)],[0.003 (0.3%)],[0.003 (0.3%)],
    table.cell(colspan: 5, align: center)[*2024*],
    [`fwdbtn`],[0.545 (54.5%)],[0.308 (30.8%)],[0.456 (45.6%)],[0.417 (41.7%)],
    [`trackdone`],[0.170 (17.0%)],[0.577 (57.7%)],[0.402 (40.2%)],[0.370 (37.0%)],
    [`endplay`],[0.236 (23.6%)],[0.031 (3.1%)],[0.083 (8.3%)],[0.130 (13.0%)],
    [`backbtn`],[0.025 (2.5%)],[0.032 (3.2%)],[0.018 (1.8%)],[0.042 (4.2%)],
    [`unexpected-exit-while-paused`],[0.019 (1.9%)],[0.033 (3.3%)],[0.021 (2.1%)],[0.015 (1.5%)],
    [`logout`],[0.001 (0.1%)],[0.017 (1.7%)],[0.010 (1.0%)],[0.012 (1.2%)],
    [`remote`],[0.004 (0.4%)],[0.002 (0.2%)],[0.003 (0.3%)],[0.011 (1.1%)],
    [`unexpected-exit`],[0.000 (0.0%)],[0.001 (0.1%)],[0.001 (0.1%)],[0.000 (0.0%)],
    [`trackerror`],[0.000 (0.0%)],[0.000 (0.0%)],[0.000 (0.0%)],[0.003 (0.3%)],
    [`unknown`],[0 (0%)],[0 (0%)],[0.007 (0.7%)],[0 (0%)],
    table.cell(colspan: 5, align: center)[*2025*],
    [`fwdbtn`],[0.398 (39.8%)],[0.222 (22.2%)],[0.244 (24.4%)],[0.423 (42.3%)],
    [`trackdone`],[0.173 (17.3%)],[0.646 (64.6%)],[0.640 (64.0%)],[0.416 (41.6%)],
    [`endplay`],[0.379 (37.9%)],[0.024 (2.4%)],[0.066 (6.6%)],[0.103 (10.3%)],
    [`backbtn`],[0.025 (2.5%)],[0.018 (1.8%)],[0.010 (1.0%)],[0.025 (2.5%)],
    [`unexpected-exit-while-paused`],[0.015 (1.5%)],[0.083 (8.3%)],[0.023 (2.3%)],[0.015 (1.5%)],
    [`logout`],[0.005 (0.5%)],[0.006 (0.6%)],[0.014 (1.4%)],[0.007 (0.7%)],
    [`remote`],[0.004 (0.4%)],[0.000 (0.0%)],[0.003 (0.3%)],[0.009 (0.9%)],
    [`unexpected-exit`],[0.001 (0.1%)],[0.000 (0.0%)],[0.001 (0.1%)],[0.001 (0.1%)],
    [`trackerror`],[0.001 (0.1%)],[0.001 (0.1%)],[0.001 (0.1%)],[0.001 (0.1%)],
    [`unknown`],[0 (0%],[0 (0%)],[0 (0%)],[0 (0%)],
  )
)

=== Analysis

=== Methodology

== Top Artist Concentration

#figure(
  caption: "Concentration of Top Artist in Listening History for Each User (All-Time, 2024, 2025)",
  grid(
    image("../data/artist_concentration/plots/artist_concentration_alltime.png"),
    image("../data/artist_concentration/plots/artist_concentration_2024.png"),
    image("../data/artist_concentration/plots/artist_concentration_2025.png"),
  )
)

#figure(
  caption: "Concentration of Top Artist in Listening History for Each User (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) }
      else { white }
    },
    table.cell(colspan: 6, align: center)[*All-Time*],
    [*User*],[*Top 1 Share*],[*Top 5 Share*],[*Top 10 Share*],[*Entropy*],[*Gini*],
    [Alan],[0.097 (9.7%)],[0.231 (23.1%)],[0.327 (32.7%)],[6.922],[0.933],
    [Alexandra],[0.067 (6.7%)],[0.248 (24.8%)],[0.343 (34.3%)],[7.391],[0.833],
    [Anthony],[0.094 (9.4%)],[0.223 (22.3%)],[0.316 (31.6%)],[7.297],[0.874],
    [Koren],[0.032 (3.2%)],[0.108 (10.8%)],[0.163 (16.3%)],[9.338],[0.829],
    table.cell(colspan: 6, align: center)[*2024*],
    [Alan],[0.049 (4.9%)],[0.155 (15.5%)],[0.241 (24.1%)],[7.188],[0.854],
    [Alexandra],[0.080 (8.0%)],[0.242 (24.2%)],[0.360 (36.0%)],[7.118],[0.737],
    [Anthony],[0.073 (7.3%)],[0.230 (23.0%)],[0.357 (35.7%)],[6.897],[0.803],
    [Koren],[0.052 (5.2%)],[0.144 (14.4%)],[0.207 (20.7%)],[8.450],[0.740],
    table.cell(colspan: 6, align: center)[*2025*],
    [Alan],[0.040 (4.0%)],[0.162 (16.2%)],[0.260 (26.0%)],[7.113],[0.778],
    [Alexandra],[0.065 (6.5%)],[0.228 (22.8%)],[0.346 (34.6%)],[7.215],[0.711],
    [Anthony],[0.087 (8.7%)],[0.243 (24.3%)],[0.361 (36.1%)],[6.845],[0.804],
    [Koren],[0.062 (6.2%)],[0.140 (14.0%)],[0.201 (20.1%)],[8.564],[0.743],
  )
)

=== Analysis

=== Methodology

== Artist Diversity Over Time

#figure(
  caption: "Artist Entropy Over Time for Each User (All-Time, 2024, 2025)",
  image("../data/artist_diversity/artist_entropy_over_time.png"),
)

#figure(
  caption: "Artist Gini Coefficient Over Time for Each User (All-Time, 2024, 2025)",
  image("../data/artist_diversity/artist_gini_over_time.png"),
)

=== Analysis

=== Methodology

== Discovered/Rediscovered Items

=== Analysis

=== Methodology

== Repeat vs. New Artists

#figure(
  caption: "Proportion of Repeat vs. New Artists for Each User (All-Time, 2024, 2025)",
  grid(
    image("../data/repeat_vs_new/plots/repeat_vs_new_alltime.png"),
    image("../data/repeat_vs_new/plots/repeat_vs_new_2024.png"),
    image("../data/repeat_vs_new/plots/repeat_vs_new_2025.png"),
  )
)

=== Analysis

=== Methodology

== Artist Plays per Month

#figure(
  caption: "Monthly Plays of Top Artist for Alan (2024, 2025)",
  grid(
    image("../data/monthly_top_artist/plots/monthly_top_artist_alan_2024.png"),
    image("../data/monthly_top_artist/plots/monthly_top_artist_alan_2025.png")
  )
)

#figure(
  caption: "Monthly Plays of Top Artist for Alexandra (2024, 2025)",
  grid(
    image("../data/monthly_top_artist/plots/monthly_top_artist_alexandra_2024.png"),
    image("../data/monthly_top_artist/plots/monthly_top_artist_alexandra_2025.png")
  )
)

#figure(
  caption: "Monthly Plays of Top Artist for Anthony (2024, 2025)",
  grid(
    image("../data/monthly_top_artist/plots/monthly_top_artist_anthony_2024.png"),
    image("../data/monthly_top_artist/plots/monthly_top_artist_anthony_2025.png")
  )
)

#figure(
  caption: "Monthly Plays of Top Artist for Koren (2024, 2025)",
  grid(
    image("../data/monthly_top_artist/plots/monthly_top_artist_koren_2024.png"),
    image("../data/monthly_top_artist/plots/monthly_top_artist_koren_2025.png")
  )
)

=== Analysis

=== Methodology

== Daily Play Count

#figure(
  caption: "Daily Play Count Heatmap for Each User (2025)",
  grid(
    image("../data/calendar_heatmap/plots/calendar_heatmap_alan_2025.png"),
    image("../data/calendar_heatmap/plots/calendar_heatmap_alexandra_2025.png"),
    image("../data/calendar_heatmap/plots/calendar_heatmap_anthony_2025.png"),
    image("../data/calendar_heatmap/plots/calendar_heatmap_koren_2025.png"),
  )
)

=== Analysis

=== Methodology

- more on outliers
- q-q plot
- quantile plot

// dont touch anything after here- its random notes 
/* =================================== --- ================================== */

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

/* =================================== --- ================================== */

Exploratory Data Analysis

Summary stats - done

dataset info
- approx 872k listening events
- 4 people
- time span: 2015-2026 (full overlap from 2020-2026) 
- no missing values

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

Univariate analysis - done

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

OUTLIERS

- for each user and each day (all time + yearly to compare):
  - daily play count
- mean & sd of daily play count for a user
- First apply log transformation
  - log_play_count = log(1 + track_play_count)
- z = (val - mean) / sd
- outlier -> |z| > 3
- if symmetric - both high and low outliers
- 1.5iqr - prob better
- iqr = q3 - q1 of DPC
- q1 - 1.5 x iqr and q3 + 1.5 x iqr = bounds
- outside = outlier
- can use boxplot to show this too
- Rank-frequency plot - Zipf style
- Pareto chart
- lorenz curve
- histogram of log counts
  
- same thing for
  - plays per track
  - plays per artist
  - session length

DISTRIBUTIONS
- Daily Listening Counts
  - symmetric?
  - right-skewed?
  - long tail?
  - typical daily listening volume
- daily plot count per user
- plot histogram ~50 bins
- overlay density curve
- compute mean, median, sd, skewness, kurtosis
- boxplot
- log scale histogram
- median diff from mean?
- one user has higher variance?
- multiple modes?
  
- and do this for
  - plays per track
  - plays per artist
  - session length

Bivariate analysis

Multivariate analysis

Temporal analysis

Behavioral pattern exploration

Group-level comparison analysis

Dimensional reduction and early unsupervised structure

Preliminary predictive framing

Story construction