#import "template/lib.typ": *
#import "@preview/frame-it:1.2.0": *
#import "@preview/mannot:0.3.0": *
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": chart, plot
#import "@preview/wrap-it:0.1.1": *
#import calc: exp, ln, pow

#show: typsidian.with(
  title: "Exploratory Data Analysis",
  author: "Koren Stalnaker, Alexandra Williams, Cesar Cervantes, Alan Zamora, Anthony Chen",
  footer-text: "K. Stalnaker, A. Williams, C. Cervantes, A. Zamora, A. Chen",
  course: "Spotify Data Project",
  // show-heading-colors: false,
  text-args: (headings: (numbering: none))
)

#let cap(body) = { 
  text(
    fill: rgb("#6a6a6a"), 
    style: "italic", 
    size: 0.9em,
    body
  ) 
}

#make-title(show-outline: false, show-author: true, justify: "left")

#show figure: set block(breakable: true)
#show table: set text(size: 0.9em)

== Data Preprocessing

Spotify provides a comprehensive record of a user's streaming history upon request via #link("https://www.spotify.com/us/account/privacy/", "Spotify's privacy settings page"), where a user can request a copy of their listening data, which includes entries for every "play event" from the first time the user plays a track on Spotify to the moment they request the data. We were able to collect listening data for 4 users: Koren, Alexandra, Alan, and Anthony over a total span of 11 years (2015-2026), in the form of 58 total JSON files.

#hr()

To prepare the data for analysis, we performed several preprocessing steps. First, we extracted the relevant attributes from the JSON files and gave them more descriptive names. The data from Spotify contained some attributes that were not relevant to our analysis, such as IP address and audiobook-related fields, which we discarded. We then imported the data into a PostgreSQL database using Supabase, to allow us to easily query and manipulate the data for preprocessing and analysis. The database schema is as follows:

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

=== Basic Data Cleaning

- *Timestamps.* Timestamps were normalized to a PostgreSQL `DATETIME` format to allow for easier querying and manipulation of time-based data. 
- *Duplicates.* Any duplicate events (based on the primary key) were removed from the database.
- *Null/Empty Entries.* Events that had empty values for any of the primary key attributes were pruned before being entered into the database.
- *Accidental Plays/Skips.* Any tracks that had a single play and less than 30 seconds played were removed from the database, since these were likely accidental plays or skips that do not reflect the user's true listening habits.
- *Erroneous Play Data.* A subset of Spotify listening events contained impossible play durations, likely due to logging errors, which would distort analysis if left uncorrected. These were identified by comparing reported playtime against timestamp gaps and verified track durations via external metadata, then removed or manually reviewed. 
- *Artist Genre Classification.* Since Spotify data lacks genre labels, genres were assigned to ~6,000 artists using a combination of manual tagging (via MusicBrainz data and a custom tagging tool) and AI-based classification, with filtering to ensure relevance and consistency.
- *Post-Processing and Normalization.* The resulting genre data was standardized through normalization of naming conventions, expansion of abbreviations, correction of inconsistencies and misspellings, and auditing of rare tags to ensure a clean, usable dataset for analysis.

After these data cleaning steps, we were left with approximately 845,000 rows of listening events.

== Activity & Listening Volume

#grid(
  columns: (1fr, 0.55fr),
  gutter: 0.5em,
  [
    #align(center,
      [
        #table(
          columns: 6,
          align: left,
          fill: (col, row) => {
            if row in (0, 6, 11) { gray.lighten(80%) }
          },
          table.cell(colspan: 6, align: center)[*All-Time*],
          [*User*],[*Unique Tracks*],[*Unique Artists*],[*Unique Albums*],[*Unique Genres*],[*Total Events*],
          [Alan],[10,560],[1,687],[3,761],[407],[1,910,079],
          [Anthony],[9,061],[1,291],[4,247],[290],[283,029],
          [Alexandra],[5,246],[1,061],[2,347],[322],[467,926],
          [Koren],[15,074],[3,979],[7,864],[528],[618,654],
          table.cell(colspan: 6,align: center)[*2024*],
          [Alan],[3,923],[796],[1,439],[298],[231,266],
          [Anthony],[2,733],[549],[1,440],[207],[44,348],
          [Alexandra],[2,177],[531],[1,123],[233],[44,308],
          [Koren],[2,973],[1,255],[1,906],[351],[42,766],
          table.cell(colspan: 6,align: center)[*2025*],
          [Alan],[3,223],[477],[972],[267],[117,121],
          [Anthony],[3,509],[543],[1,622],[180],[53,263],
          [Alexandra],[2,137],[503],[1,064],[231],[30,725],
          [Koren],[3,730],[1,396],[2,304],[365],[53,353],
        )
      ]
    )
  ],
  [
    The summary statistics provide a quick look at the dataset and the listening patterns exhibited by all users. In terms of raw listening events, Alan leads by a large margin. He has \~2,000,000 total listening events --- more than 3 times the second-highest volume user: Koren, with \~620,000 events. This pattern is consistent throughout almost all periods in the dataset. Anthony has the lowest number of all-time plays, due to him joining Spotify in 2020, however, in 2024 and 2025, his total plays are on par with the other users. Alexandra consistently has the lowest total listening events among the users, with her total plays in 2025 decreasing by approximately 30% from 2024. The unique counts show that, despite having a large volume of total plays, Alan's catalog breadth is not much larger than the catalogs of the other users in the database. In comparison, Koren has the broadest catalog footprint in 2025. Compared to Alan's counts in 2025, Koren listened to about 3 times more unique artists. Anthony attains high activity with a smaller genre 
  ]
)
#v(-0.3em)
basis indicating stronger concentration inside a narrower genre manifold. Alan remains high-volume with moderate breadth, while Alexandra has the lowest total volume but a broad catalog with 503 unique artists, consistent with selective yet varied listening of rock-adjacent artists. From 2024 to 2025, Alan and Alexandra contract in event count, while Anthony and Koren expand. Breadth patterns diverge: Koren expands across all dimensions, while Anthony contracts in genres and artists. This suggests Anthony’s growth is more focused on a narrower set, while Koren’s reflects increased discovery. Alan’s 2025 shift is consistent with a general decrease in activity, though his breadth remains relatively stable, indicating continued engagement with a similar range of music. Alexandra’s decline in volume is paired with a slight decrease in breadth, but her catalog remains relatively broad compared to others.

=== Listening Events Over Time

#align(center, [
  #image("assets/events_over_time_alltime.png", width: 95%)
])

#align(center, [
  #image("assets/events_over_time_2025.png", width: 95%)
])

The all-time play trajectories are heterogeneous and vary between users and years. Alan exhibits the largest spikes and the strongest long-run amplitude, with a large peak period around 2019-2020 followed by lower but still elevated variability. Koren shows multiple spikes across multiple years, with the largest around 2017-2018, and a smaller peak in 2025. Anthony shows a moderate spike around 2021-2022. Alexandra is comparatively stable throughout the years. Within 2025, Alan and Koren peak early and then transition into lower but fluctuating mid/late-year levels. Anthony is highest in spring and then trends downward throughout the year. Alexandra maintains stability throughout the year with smaller oscillations.

=== Total Listening Time

#grid(
  columns: (0.75fr, 1fr),
  gutter: 1.5em,
  [
    Play counts and total listening time are key metrics for understanding user engagement with music. Play counts show how often a track is played, while total listening time reflects overall engagement. In 2025, Alan leads with about 44,000 minutes, followed by Koren at 42,000. Anthony and Alexandra are lower, at roughly 33,000 and 21,000 minutes. Although Alan has the highest play count, his listening time is not proportionally higher than Koren’s, suggesting shorter tracks or more skipping. Year over year, Alan shows a sharp decline in both metrics, though his listening time remains relatively high, indicating continued strong engagement. Anthony and Koren both increase in listening time, consistent with higher play counts, with Anthony’s rise more pronounced. Alexandra declines in both, but her listening time remains relatively high relative to her play counts, suggesting a shift toward longer tracks or albums in 2025.
  ],
  align(center, [
    #image("assets/total_listening_2025.png")
    #cap[Total Listening Times vs. Play Counts for Each User (All-Time, 2024, 2025)]
  ])
)

== Behavioral Profiles

=== Play & Session Distribution

#grid(
  columns: 3,
  gutter: 1em,
  [
    #image("assets/boxplot_daily_play_count_2025.png")
    #table(
      columns: 5,
      align: left,
      [],[*Alan*],[*Alex*],[*Ant*],[*Koren*],
      [*Mean*],[85.708],[24.469],[45.372],[54.888],
      [*Med.*],[75.0],[19.5],[28.5],[35.0],
      [*Mode*],[2],[12],[6],[1],
      [*SD*],[71.418],[17.564],[51.829],[60.880],
      [*Skew.*],[1.922],[1.742],[2.430],[1.911],
      [*Min*],[1],[1],[1],[1],
      [*Max*],[597],[128],[315],[380],
      [$bold(Q_1)$],[31.0],[12.0],[11.0],[9.75],
      [$bold(Q_3)$],[123.0],[32.0],[59.75],[76.5],
      [*IQR*],[92.0],[20.0],[48.75],[66.75],
    )
    #cap[Distribution of Daily Play Counts for Each User (2025)]
  ],
  [
    #image("assets/boxplot_session_length_2025.png")
    #table(
      columns: 5,
      align: left,
      [],[*Alan*],[*Alex*],[*Ant*],[*Koren*],
      [*Mean*],[42.120],[21.752],[49.768],[50.454],
      [*Med.*],[27.197],[15.619],[24.182],[20.598],
      [*Mode*],[1],[7],[3],[2],
      [*SD*],[54.609],[24.863],[90.588],[82.280],
      [*Skew.*],[4.1745],[3.4265],[6.3074],[4.192],
      [*Min*],[0],[0],[0],[0],
      [*Max*],[678.582],[260.906],[1199.269],[877.882],
      [$bold(Q_1)$],[6.343],[6.873],[9.171],[4.081],
      [$bold(Q_3)$],[54.792],[27.848],[56.035],[65.587],
      [*IQR*],[48.449],[20.975],[46.84],[61.506],
    )
    #cap[Distribution of Session Length for Each User (2025)]
  ],
  [
    #image("assets/boxplot_plays_per_track_2025.png")
    #table(
      columns: 5,
      align: left,
      [],[*Alan*],[*Alex*],[*Ant*],[*Koren*],
      [*Mean*],[9.452],[4.456],[4.061],[4.706],
      [*Med.*],[4.0],[4.0],[2.0],[2.0],
      [*Mode*],[1],[3],[1],[1],
      [*SD*],[11.443],[3.635],[5.464],[5.729],
      [*Skew.*],[2.385],[16.481],[3.497],[2.227],
      [*Min*],[1],[1],[1],[1],
      [*Max*],[104],[119],[51],[45],
      [$bold(Q_1)$],[2.0],[3.0],[1.0],[1.0],
      [$bold(Q_3)$],[14.0],[6.0],[4.0],[6.0],
      [*IQR*],[12.0],[3.0],[3.0],[5.0],
    )
    #cap[Distribution of Plays Per Track for Each User (2025)]
  ],
  [
    #image("assets/boxplot_plays_per_artist_2025.png")
    #table(
      columns: 5,
      align: left,
      [],[*Alan*],[*Alex*],[*Ant*],[*Koren*],
      [*Mean*],[61.451],[17.318],[25.236],[12.267],
      [*Med.*],[8.0],[5.0],[4.0],[3.0],
      [*Mode*],[1],[3],[1],[1],
      [*SD*],[134.812],[47.732],[81.474],[40.365],
      [*Skew.*],[4.321],[6.927],[8.193],[15.467],
      [*Min*],[1],[1],[1],[1],
      [*Max*],[1179],[563],[1199],[1071],
      [$bold(Q_1)$],[2.0],[3.0],[2.0],[1.0],
      [$bold(Q_3)$],[49.0],[10.0],[15.0],[11.0],
      [*IQR*],[47.0],[7.0],[13.0],[10.0],
    )
    #cap[Distribution of Plays Per Artist for Each User (2025)]
  ],
  [
    #image("assets/boxplot_plays_per_album_2025.png")
    #table(
      columns: 5,
      align: left,
      [],[*Alan*],[*Alex*],[*Ant*],[*Koren*],
      [*Mean*],[29.668],[8.111],[8.300],[7.135],
      [*Med.*],[5.0],[5.0],[3.0],[2.0],
      [*Mode*],[1],[2],[1],[1],
      [*SD*],[58.485],[13.686],[19.994],[18.349],
      [*Skew.*],[3.982],[5.030],[8.674],[17.535],
      [*Min*],[1],[1],[1],[1],
      [*Max*],[673],[160],[384],[584],
      [$bold(Q_1)$],[2.0],[3.0],[1.0],[1.0],
      [$bold(Q_3)$],[29.0],[7.0],[7.0],[9.0],
      [*IQR*],[27.0],[4.0],[6.0],[8.0],
    )
    #cap[Distribution of Plays Per Album for Each User (2025)]
  ],
  [
    #image("assets/boxplot_plays_per_genre_2025.png")
    #table(
      columns: 5,
      align: left,
      [],[*Alan*],[*Alex*],[*Ant*],[*Koren*],
      [*Mean*],[438.655],[133.009],[295.906],[146.173],
      [*Med.*],[67.0],[10.0],[14.0],[11.0],
      [*Mode*],[2, 3],[2, 6],[1],[1],
      [*SD*],[1012.897],[413.022],[1063.802],[570.043],
      [*Skew.*],[4.657],[5.284],[6.488],[6.854],
      [*Min*],[1],[1],[1],[1],
      [*Max*],[9677],[3158],[9622],[5875],
      [$bold(Q_1)$],[14.5],[5.0],[3.0],[2.0],
      [$bold(Q_3)$],[336.0],[57.5],[110.75],[57.0],
      [*IQR*],[321.5],[52.5],[107.75],[55.0],
    )
    #cap[Distribution of Plays Per Genre for Each User (2025)]
  ],
)

Across all six metrics, medians are far below means and upper tails are long, indicating heavy-tailed listening behavior. For daily play counts, Alan has the highest center and spread; Anthony and Koren have lower medians but longer tails, which could mean they endgage in more sporadic high-intensity days. Alexandra's distribution is tighter with fewer extreme days. Session length is especially skewed for Anthony and Koren, where rare very long sessions inflate means well above medians. Plays per track shows Alan's higher repeat intensity (median 4 versus 2 for Anthony/Koren), while Alexandra is bimodally selective: lower overall volume with occasional strong track-level repeats. Artist- and album-level distributions confirm concentration effects for Alan and Anthony via extreme upper outliers, but Koren's genre-level spread reveals broader movement across genre buckets despite low per-artist medians. Genre plays are heavy-tailed for all users; Alan and Anthony have the largest maxima, while Koren maintains a relatively broad middle range plus high-end spikes.

== Content Preferences

=== Top Tracks, Artists, Albums & Genres

In 2025, all four users have distinct musical preferences. Alan's top artists and genres are predominately hip hop-centered, but his top artists span multiple subgenres and eras, indicating breadth within one dominant genre rather than concentration around a single artist or exploration of multiple distinct genres. Anthony's top artists and genres are also hip hop-centered, but his top artists are more concentrated around a smaller set of subgenres, particularly trap and pop rap, indicating a stronger concentration around a narrower set of artists and genres. Alexandra's top artists and genres are centered around rock-adjacent genres, particularly pop punk and metalcore, with a limited interest in hip hop. Koren's top artists and genres are centered around drum and bass, with a strong interest in trap as well, but with a smaller presence of hip hop compared to the other users. Overall, while there is some overlap in the top artists and genres among the users, particularly between Alan and Anthony, each user has a distinct musical profile that reflects their individual preferences and listening habits.

=== Unique Genres Per Session

#grid(
  columns: (1fr, 0.75fr),
  gutter: 0.5em,
  table(
    columns: 8,
    align: left,
    [*User*],[*Sessions*],[*Mean*],[*Median*],[*Range*],[*1 Genre*],[*5+*],[*10+ Genres*],
    [Alan],[1408],[20.38],[16.0],[$[1,104]$],[0.78%],[81.96%],[64.28%],
    [Anthony],[798],[14.80],[12.0],[$[1,75]$],[0.88%],[79.82%],[58.15%],
    [Alexandra],[1216],[13.64],[12.0],[$[1,63]$],[0.9%],[81.17%],[58.96%],
    [Koren],[1019],[13.30],[9.0],[$[1,154]$],[1.37%],[72.23%],[46.22%],
  ),
  [
    From the session-level genre data, we can see that all users generally listen to multiple genres within sessions, but each user has a distinct genre profile. Alan has the highest mean and median genres per session (20.38 and 16), and the largest share of sessions with 10+ genres (64.28%). Anthony and Alexandra are similar in medians (12), but Anthony has slightly higher mean than Alexandra, suggesting he has occasional 
  ]
)
#v(-0.3em)
broader sessions, with a concentrated core taste. Koren is the most asymmetric profile, with the lowest median among the four but the widest range. The suggests both narrow sessions and extremely broad sessions, implying he listens to music in both an exploratory fashion and engaging with a core set of familiar artists. Overall, Alan is high-volume and structurally broad in-session; Alexandra is lower-variance and style-coherent; Anthony is concentrated with strong core persistence; Koren alternates between concentrated and highly exploratory states.

=== Interaction Flags & Skip Rate by Shuffle

#align(center, 
  grid(
    columns: 2,
    gutter: 0.5em,
    image("assets/bool_flags_users_2025.png"),
    image("assets/skip_by_shuffle_users_2025.png"),
  )
)

In 2025, Alexandra has high shuffle usage with low skip, consistent with a trusted catalog. Alan is the contrast case: lowest shuffle and the highest skip rate (about 80%), indicating active selection and rejection rather than passive listening. Koren combines high shuffle with high skip, suggesting exploratory sampling with frequent filtering. Anthony sits between these patterns with moderate shuffle and skip. From 2024 to 2025, Alan’s high skip persists, while Alexandra and Anthony both reduce skip. Offline rates are low across users, except Alexandra’s all-time baseline, so they are secondary to shuffle and skip.

Shuffle-conditioned skip rates show user-specific behavior rather than a uniform shuffle effect. Alan’s skip is high regardless of shuffle, indicating a stable trait. Anthony’s skip increases with shuffle, implying more mismatch under shuffle. Alexandra shows higher skip with shuffle off, consistent with more selective non-shuffle listening. Koren shows the strongest asymmetry, with much higher skip when shuffle is off in 2025, suggesting targeted evaluation or filtering. These patterns show that similar overall skip rates can arise from different underlying behaviors.

=== Genre PCA

Principal component analysis is applied to per-user genre play-share vectors (each entry is the fraction of total plays attributed to that genre) to decompose inter-user variance into interpretable axes. Because genre shares sum to one, PCA here identifies the genre dimensions along which users diverge most, and the proportion of variance explained quantifies how well low-dimensional space captures that separation.

#align(center, grid(
  columns: 2,
  gutter: 2em,
  align: left,
  [
    *Top Genre Loadings by Magnitude*
      #v(-0.5em)
      #table(
        columns: 4,
        align: left,
        [*Genre*],[*PC1*],[*PC2*],[*Absolute Loading*],
        [drum and bass],[0.1562],[0.5349],[0.5572],
        [pop punk],[-0.4348],[0.0216],[0.4353],
        [metalcore],[-0.3996],[0.0260],[0.4005],
        [hip hop],[0.2114],[-0.3314],[0.3931],
        [liquid funk],[0.1038],[0.3532],[0.3681],
        [alternative rock],[-0.3659],[-0.0216],[0.3666],
        [trap],[0.3450],[-0.0716],[0.3523],
        [jungle],[0.0968],[0.3338],[0.3475],
        [post hardcore],[-0.3444],[0.0255],[0.3453],
        [pop rap],[0.1433],[-0.2779],[0.3126],
      )
  ],
  [
    *Variance Explained by Principal Components*
    #v(-0.5em)
    #table(
      columns: 3,
      align: left,
      [*PC1 Variance*],[*PC2 Variance*],[*Total*],
      [58.8%],[28.4%],[87.2%],
    )

    #v(2em)

    *User Scores*
    #v(-0.5em)
    #table(
      columns: 3,
      align: left,
      [*User*],[*PC1*],[*PC2*],
      [Alan],[0.0310],[-0.0747],
      [Alexandra],[-0.2575],[0.0083],
      [Anthony],[0.1245],[-0.1030],
      [Koren],[0.1020],[0.1694],
    )
  ]
))

#align(center, [
  #image("assets/genre_pca_biplot_2025.png", width: 90%)
])

The PCA solution is statistically strong for interpretation: PC1 and PC2 jointly explain 87.2% of variance, so the user separation seen in the biplot is not a projection artifact. Component structure is sharply anisotropic by genre family. Rock and punk load almost entirely on PC1 (family mean $|"PC1"| = 0.299$ vs $|"PC2"| = 0.017$), drum-and-bass lineage loads primarily on PC2 (family mean $|"PC2"| = 0.407$), and hip hop/trap carries mixed load on both axes (mean $|"PC1"| = 0.125$, $|"PC2"| = 0.154$). This quantifies the visual result: PC1 is the rock-versus-rap contrast, while PC2 isolates the DnB/jungle manifold from rap-centered profiles. 

User geometry reinforces earlier sections. Alexandra is the only strong negative-PC1 point (rock pole), Koren is strongly positive on PC2 (DnB/jungle pole), and Alan/Anthony occupy the rap side with negative PC2. The closest pair in PCA space is Anthony-Alan (distance $0.0977$), far below Anthony-Koren ($0.2734$) or Alexandra-Koren ($0.3940$). This is consistent with pre-PCA evidence: Alan and Anthony were already the non-divergent group in genre ranking (plays and artist-count leaders coincide), while Koren and Alexandra were divergence-heavy in different directions.

The loadings also explain why Alan and Anthony are near each other but not identical. Both are pulled by trap/hip hop/pop-rap vectors, yet Anthony is farther toward high trap intensity (higher PC1), while Alan sits less extreme and slightly closer to cross-family vectors. Koren's high PC2 arises from alignment with drum and bass, liquid funk, and jungle arrows, matching the schedule-dependent genre switching identified in the temporal section. Alexandra's near-zero PC2 and strongly negative PC1 indicate that her separation is driven by stable rock-family preference rather than time-varying migration into the DnB axis.

== Temporal Patterns

Hourly profiles are non-uniform for all users. Alan peaks at midnight with a trough at 9 AM, and 43.8% of his plays occur late night (10 PM-5 AM), matching his high skip, manual-control pattern. Anthony peaks at 5 PM and bottoms at noon, but still allocates 46.3% of activity to late night, indicating a split between late-night baseline and evening peak. Alexandra is the most evening-centered: peak at 9 PM, trough at 10 AM, and the highest evening share (34.0%), with lower volume but concentrated usage. Koren peaks at 2 PM, with minimal mid-morning activity, only 3.4% morning share, and the highest afternoon share (35.9%), indicating a daytime-heavy pattern. 

#align(center, 
  grid(
    columns: 2,
    gutter: 2em,
    image("assets/listening_times_alanjzamora_2025_c.png", width: 90%),
    image("assets/listening_times_dasucc_2025_c.png", width: 90%),
    image("assets/listening_times_alexxxxxrs_2025_c.png", width: 90%),
    image("assets/listening_times_korenns_2025_c.png", width: 90%),
  )
)

=== Artist Diversity Over Time

#grid(
  columns: 2,
  gutter: 0.5em,
  image("assets/artist_entropy_over_time.png"),
  image("assets/artist_gini_over_time.png")
)

Shannon entropy ($H = -sum_i p_i log_2 p_i$) measures how evenly plays are distributed across artists, while the Gini coefficient measures inequality (0 = uniform, 1 = fully concentrated). Together, they separate breadth from concentration. Koren has the highest entropy in every year (2025 = 8.564), indicating consistently broad artist coverage. His slightly declining Gini (0.768 to 0.743) supports this, showing stable distribution without heavy concentration. Short-term concentration does not reduce overall diversity. Alexandra and Alan converge in 2025 entropy (7.215 and 7.113), but differ in path. Alan’s entropy rises substantially from 2020 (+1.555), while his Gini drops from 0.911 to 0.778, indicating a clear shift toward a more even distribution. Alexandra’s entropy is stable, while her Gini increases slightly (0.679 to 0.711), indicating more weight on a core subset without major expansio. Anthony shows the largest shift. His Gini rises from 0.436 to 0.804, indicating strong consolidation, while entropy growth is limited. This implies a move from broad allocation to concentration on a smaller set of artists.

== Artist Analysis

=== Top Artist Concentration

In 2025, Anthony is the most concentrated at the top end (Top-1 = 8.7%, Top-10 = 36.1%), followed by Alexandra (Top-10 = 34.6%). Alan is moderate (Top-10 = 26.0%), and Koren is the least top-heavy (Top-10 = 20.1%). This matches earlier distribution patterns, with Anthony’s outliers driven by repeated plays around a smaller set of artists. Cross-period comparisons show different shifts. Alan’s concentration drops from all-time (Top-1 from 9.7% to 4.0%), indicating broader artist allocation. Alexandra remains consistently concentrated with slight easing in 2025. Anthony’s concentration rises from 2024 to 2025, aligning with his post-spring narrowing. Koren’s concentration increases relative to all-time (Top-1 from 3.2% to 6.2%) but stays below others on Top-10 share, indicating focal repetition within a broader set of artists.

#figure(
  grid(
    columns: 2,
    column-gutter: 0.5em,
    [
      #image("assets/artist_concentration_2025.png")
      #cap[Concentration of Listening Events for Top Artists for Each User (All-Time, 2024, 2025)]
    ],
    [
      #table(
        columns: 4,
        align: left,
        fill: (col, row) => {
          if row in (0, 6, 11) { gray.lighten(80%) } else { white }
        },
        table.cell(colspan: 4, align: center)[*All-Time*],
        [*User*],[*Top 1*],[*Top 5*],[*Top 10*],
        [Alan],[9.7%],[23.1%],[32.7%],
        [Alexandra],[6.7%],[24.8%],[34.3%],
        [Anthony],[9.4%],[22.3%],[31.6%],
        [Koren],[3.2%],[10.8%],[16.3%],
        table.cell(colspan: 4,align: center)[*2024*],
        [Alan],[4.9%],[15.5%],[24.1%],
        [Alexandra],[8.0%],[24.2%],[36.0%],
        [Anthony],[7.3%],[23.0%],[35.7%],
        [Koren],[5.2%],[14.4%],[20.7%],
        table.cell(colspan: 4,align: center)[*2025*],
        [Alan],[4.0%],[16.2%],[26.0%],
        [Alexandra],[6.5%],[22.8%],[34.6%],
        [Anthony],[8.7%],[24.3%],[36.1%],
        [Koren],[6.2%],[14.0%],[20.1%],
      )
    ]
  )
)

=== Artist Transition Matrix

The row-normalized transition matrix $P_(i j)$ gives the probability that artist $j$ immediately follows artist $i$ in consecutive plays within a session. High diagonal entries indicate self-loops (repeated plays of the same artist), while off-diagonal entries indicate changes between artists. Mean self-transition probability and per-row transition entropy (higher = more varied outgoing behavior per artist) summarize the overall structure. 

Koren has the strongest persistence (mean self-transition $0.674$) and the lowest transition entropy ($0.365$), meaning sequences tend to stay on the same artist once selected. Alan is also high in persistence (mean self-transition $0.596$), but with higher row entropy ($0.582$), indicating more switching between artists despite strong loops for specific cases (for example Jessie Ware and Fiona Apple above $0.91$). Anthony is intermediate (mean self-transition $0.530$, entropy $0.662$), with dominant self-loops.

Alexandra differs from the others. Her diagonal mass is lowest (mean self-transition $0.242$) and transition entropy is highest ($0.896$), so listening more often moves between related artists rather than staying on one. This matches her earlier pattern of steady listening with high completion rates across a consistent set of genres. Koren and Alan show concentration through repeated plays of the same artist, while Alexandra shows consistency through frequent but structured switching.

#align(center, grid(
  columns: 2,
  gutter: 0.5em,
  image("assets/artist_transition_matrix_alanjzamora.png", width: 100%),
  image("assets/artist_transition_matrix_dasucc.png", width: 100%),
  image("assets/artist_transition_matrix_alexxxxxrs.png", width: 100%),
  image("assets/artist_transition_matrix_korenns.png", width: 100%)
))

== Cross-User Comparison

=== User Distance Function

*Composite Distance $bold(d(x, y) in [0,1])$:*

$
  d(x,y) = (1/12) dot lr([
    sum_(i=1)^(11) |hat(x)_i - hat(y)_i|
    + delta_"top" ("Top Genre"_x, "Top Genre"_y)
  ])
$

$
  hat(x)_i = (x_i - min) / (max - min) space "(min-max over the 4 users)"
$

*Numeric Features ($bold(i = 1 dots 11)$, all min-max normalized):*
+ *mean play duration (min):* engagement depth; lower values signal skip-heavy, short-dwell listening
+ *skip rate:* the primary selectivity axis; strongest single behavioral differentiator across users
+ *shuffle rate:* exploratory vs. intentionally curated listening mode
+ *artist entropy (bits):* breadth of artist distribution; higher = more uniform spread across artists
+ *artist Gini coefficient:* inequality of artist plays; complements entropy by capturing tail concentration
+ *top-1 artist share:* peak artist concentration; fraction of all plays on the single most-played artist
+ *genre Gini coefficient:* style concentration; captures how tightly plays cluster around a few genres
+ *top-1 track share:* track-level peak concentration; distinguishes catalog cycling from single-track fixation
+ *mean session length (min):* engagement duration per session; reflects how long a user sustains a listening block
+ *mean plays per track:* repeat-listening intensity; distinguishes deep-catalog cycling from one-and-done exploration
+ *late-night fraction (22:00-05:00):* proportion of plays in late-night hours; captures listening context

*Categorical Feature ($bold(delta)$):*
+ *$bold(delta_"top" (a,b) = 0)$ if top genre matches, else 1:* ensures genre-separated users are penalized despite numeric feature proximity

#align(center, grid(
  columns: 2,
  gutter: 3em,
  align: left,
  [
    *Per-User Feature Values*
    #v(-0.5em)
    #table(
      columns: 5,
      align: left,
      [*Feature*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
      [Mean Play Duration (Min)],[0.95],[2.10],[1.53],[1.19],
      [Skip Rate],[26.0%],[11.7%],[34.1%],[27.5%],
      [Shuffle Rate],[63.4%],[93.3%],[53.8%],[65.1%],
      [Artist Entropy],[6.920],[7.390],[7.296],[9.326],
      [Artist Gini],[0.933],[0.833],[0.874],[0.829],
      [Top-1 Artist Share],[9.7%],[6.7%],[9.4%],[3.2%],
      [Genre Gini],[0.910],[0.880],[0.925],[0.909],
      [Top-1 Track Share],[0.3%],[0.2%],[0.3%],[0.2%],
      [Mean Session Length (Min)],[36.46],[26.59],[39.98],[26.96],
      [Mean Plays per Track],[49.22],[33.55],[9.10],[13.97],
      [Late-Night Fraction],[38.7%],[41.3%],[49.3%],[38.4%],
      [Top Genre],[hip hop],[pop punk],[trap],[trap],
    )
  ],
  image("assets/composite_user_distance_alltime.png")
))

The composite distance matrix provides a behavioral similarity check across mixed numeric and categorical features. The closest pair is Alan-Anthony ($0.4660$), consistent with their shared hip-hop/trap orientation and similar artist concentration levels. The farthest pair is Alexandra-Anthony ($0.7224$), driven primarily by opposing shuffle habits (93% vs. 54%), a 22-minute gap in mean session length, and a nearly five-fold difference in mean plays per track (33.6 vs. 9.1).

Average distance-to-others shows Alexandra as the most isolated profile (mean $0.6379$), reflecting her extreme shuffle dependence and pop-punk top genre relative to the trap-adjacent cluster formed by the other three. Anthony is the second-most isolated ($0.5680$) despite sharing genre space with Alan and Koren, because his low mean plays per track (9.10 vs. 14-49 for the others) and high skip rate pull him away in those dimensions. Koren is the most central ($0.5289$) and Alan sits slightly higher ($0.5552$); both have intermediate entropy and concentration values that place them in the moderate-similarity zone relative to the full group.

==== User Self-Drift (2024 to 2025)

Self-drift applies the same composite distance function between each user's 2024 and 2025 feature vectors, measuring how much their behavioral profile shifted year-over-year. From 2024 to 2025, it is heterogeneous (spread $0.1671$): Alexandra drifts most ($0.2872$), Koren least ($0.1201$), with Alan ($0.2348$) and Anthony ($0.2138$) in between. The drift ranking aligns with section-level narrative. Alexandra changes top genre label (metalcore #sym.arrow.r pop punk) and shortens sessions materially, even while retaining rock-family identity. Koren preserves top genre and most feature directions, producing the smallest drift despite sizable volume and timing fluctuations.

#align(center, grid(
  columns: (1fr, 0.9fr),
  gutter: 1em,
  align: left,
  image("assets/user_self_drift_2024_2025.png"),
  [
    #table(
      columns: 4,
      align: left,
      [*User*],[*Drift*],[*Top Genre (2024)*],[*Top Genre (2025)*],
      [Alan],[0.2348],[hip hop],[hip hop],
      [Alexandra],[0.2872],[metalcore],[pop punk],
      [Anthony],[0.2138],[trap],[trap],
      [Koren],[0.1201],[drum and bass],[drum and bass],
    )

    - *Mean Self-Drift:* 0.2140
    - *Max Self-Drift:* 0.2872 (Alexandra)
    - *Min Self-Drift:* 0.1201 (Koren)
  ]
))

== Final Findings & Conclusions

#grid(
  columns: 2,
  gutter: 1em,
  [#box(theme: "important", title: "Little Genre Overlap Between Users", [
    Anthony, Alan, and Koren share some rap artists (Kanye, Travis Scott, Drake), but Alexandra's pop-punk/rock catalog has essentially zero overlap with the others. Koren's drum and bass component is unique to him entirely. Overall, each person has carved out mostly distinct musical territory.
  ])],
  [#box(theme: "important", title: "Four Clearly Different Listening Styles", [
    + *Passive* (Alexandra: high shuffle, low skip)
    + *Active* (Alan: high clickrow, high repeat count) 
    + *Curatorial* (Anthony: high skip rate, skips more than completes) 
    + *Exploratory* (Koren: most unique artists/tracks, short sessions, genre-shifting)
  ])],
  [#box(theme: "important", title: "Alan's Kanye Obsession is Statistically Extreme", [
    43,739 Kanye plays = ~9.7% of Alan's entire listening history devoted to one artist. His artist Gini coefficient of 0.933 means the bulk of his plays is concentrated in fewer than 20 artists, which indicates Alan listens to a select few of his favorites almost exclusively.
  ])],
  [#box(theme: "important", title: "Alan's Kanye Obsession is Statistically Extreme", [
    43,739 Kanye plays = ~9.7% of Alan's entire listening history devoted to one artist. His artist Gini coefficient of 0.933 means the bulk of his plays is concentrated in fewer than 20 artists, which indicates Alan listens to a select few of his favorites almost exclusively.
  ])],
  [#box(theme: "important", title: "Koren's Drum & Bass Pivot is a Genuine Behavioral Shift", [
    LTJ Bukem, Roni Size, Alex Reece (classic 90s drum and bass artists) suddenly appeared in Koren's top artists in 2024 and stayed in 2025. This is an abrupt addition of an entirely new genre rather than a gradual increase in plays.
  ])],
  [#box(theme: "important", title: "Group Listening Volume Has Been Declining Since 2021", [
    Group-wide events went from ~44k in 2018 to ~140k in 2019, peaked at ~130k in 2020-2021, and have declined to ~70k in 2025. This is largely Alan's trajectory, as his listening dropped post-2020, and no other user increased enough to compensate.
  ])],
)

#hr()

#box(title: "AI Disclosure", [
  The group collected and downloaded their personal Spotify Extended Streaming History data, wrote the data processing and import pipeline, structured all JSON outputs, and built the summary tables and visualizations used throughout this report. Claude was used to assist in writing the written analysis and drawing insights from the already-prepared data. Prompts provided to Claude included requests to identify trends, behavioral patterns, and cross-user comparisons based on the structured data files. All AI-generated analysis was reviewed and verified by group members against the underlying data.
])
