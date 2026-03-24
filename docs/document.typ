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

#make-title(show-outline: false, show-author: true, justify: "left")

#show figure: set block(breakable: true)
#show table: set text(size: 0.95em)

= Exploratory Data Analysis

== Activity & Listening Volume

=== Summary Statistics

At the aggregate level, 2025 activity splits into two tiers: Alan and Koren are highest-volume listeners by event count (both about 53k and above), Anthony is close behind (53,263), and Alexandra is materially lower (30,725). Diversity breadth differs from raw volume. Koren has the broadest catalog footprint in 2025 (3,730 tracks, 1,396 artists, 365 genres), while Anthony attains high activity with a smaller genre basis (180 genres), indicating stronger concentration inside a narrower style manifold. Alan remains high-volume with moderate breadth (3,223 tracks, 477 artists, 267 genres), and Alexandra shows the lowest total volume but nontrivial breadth (2,137 tracks, 503 artists, 231 genres), consistent with selective but still varied rock-adjacent consumption.

Comparing 2024 to 2025, Alan and Alexandra contract in event count while Anthony and Koren expand, indicating that group-wide behavior in 2025 is not a uniform scale shift. All-time totals confirm a strong historical imbalance driven by Alan's long-run activity (1.91M events), but that dominance is attenuated in the 2025 slice where Koren and Anthony are much closer in scale.

#figure(
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 6, align: center)[*All-Time*],
    [*User*],[*Unique Tracks*],[*Unique Artists*],[*Unique Albums*],[*Unique Genres*],[*Total Listening Events*],
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
  ),
)

=== Total Listening Times

Play counts and listening minutes are jointly analyzed here to distinguish frequency from dwell time. This avoids overinterpreting high event counts that may arise from short plays and skip-heavy sessions.

For 2025, Alan has the highest play count, but not the highest listening minutes; Koren and Anthony generate substantially more minutes per play. Alexandra remains lowest in volume, yet her minutes-per-play is similar to Anthony and Koren and materially above Alan. This indicates that Alan's 2025 behavior is event-dense but shorter-duration, consistent with high skip prevalence observed later.

Year-over-year, Alan declines sharply from 2024 in both plays and minutes, while Anthony shows the largest gain in listening time with a smaller proportional gain in plays, implying longer average dwell per event in 2025. Koren also increases both metrics, though with a milder slope. Alexandra contracts in both dimensions but retains comparatively high time per play, suggesting reduced activity without a shift toward shorter interactions.

#figure(
  grid(
    columns: (1fr, 0.45fr),
    column-gutter: 0.5em,
    [
      #image("../data/total_listening/plots/total_listening_2025.png")
      *Total Listening Times vs. Play Counts for Each User (All-Time, 2024, 2025)*
    ],
    table(
      columns: 3,
      align: left,
      fill: (col, row) => {
        if row in (0, 6, 11) { gray.lighten(80%) }
      },
      table.cell(colspan: 3, align: center)[*All-Time*],
      [*User*],[*Play Count*],[*Minutes*],
      [Alan],[449171],[427018.26],
      [Anthony],[72459],[110963.31],
      [Alexandra],[139496],[292424.81],
      [Koren],[181373],[216588.57],
      table.cell(colspan: 3,align: center)[*2024*],
      [Alan],[56871],[74463.40],
      [Anthony],[11703],[18921.19],
      [Alexandra],[12366],[27250.65],
      [Koren],[14578],[36913.35],
      table.cell(colspan: 3,align: center)[*2025*],
      [Alan],[29312],[44018.27],
      [Anthony],[13703],[33214.73],
      [Alexandra],[8711],[20817.54],
      [Koren],[17125],[42420.55],
    )
  )
)

=== Listening Events Over Time

All-time trajectories are heterogeneous and nonstationary. Alan exhibits the largest historical spikes and the strongest long-run amplitude, with a pronounced peak period around 2019-2020 followed by lower but still elevated variability. Koren shows episodic bursts across multiple years without Alan's extreme peak magnitude. Anthony and Alexandra display lower absolute counts with intermittent surges rather than persistent high baselines.

#align(center, [
  #image("../data/events_over_time/plots/events_over_time_alltime.png", width: 95%)
])

Within 2025, Alan and Koren peak early (Q1) and then transition into lower but fluctuating mid/late-year levels. Anthony is highest in spring and then trends downward with a clear late-year low regime. Alexandra is comparatively stable throughout the year with smaller oscillations. This matters analytically because annual totals alone mask materially different intra-year paths: similar year-end totals can emerge from bursty versus steady processes.

#align(center, [
  #image("../data/events_over_time/plots/events_over_time_2025.png", width: 95%)
])

== Content Preferences

=== Top Tracks, Artists, Albums & Genres

#figure(
  // caption: "Top 10 tracks, artists, albums, and genres for Alan (2025)",
  grid(
    columns: 4,
    column-gutter: 0.5em,
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Alan - Top 10 Tracks (2025)*],
        [*Track*],[*Plays*],
        [Begin Again],[102],
        [In Your Eyes],[98],
        [Remember...Are],[86],
        [The Kill],[84],
        [either on...drugs],[82],
        [Soul Control],[78],
        [Weird Fishes],[76],
        [Endtroduction],[75],
        [HAZARD DUTY PAY!],[67],
        [PROTECT THE CROSS],[66],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Alan - Top 10 Artists (2025)*],
        [*Artist*],[*Plays*],
        [Kanye West],[1179],
        [JPEGMAFIA],[1086],
        [Kendrick Lamar],[922],
        [Jessie Ware],[794],
        [Denzel Curry],[756],
        [Danny Brown],[636],
        [Fiona Apple],[594],
        [Freddie Gibbs],[585],
        [JID],[584],
        [A Tribe...Quest],[475],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Alan - Top 10 Albums (2025)*],
        [*Album*],[*Plays*],
        [What's...Pleasure?],[673],
        [Melt My Eyez...Future],[453],
        [I LAY...FOR YOU],[367],
        [Wallsocket],[355],
        [I...DIRECTOR'S CUT],[353],
        [Lianne La Havas],[332],
        [Since I Left You],[331],
        [Black On Both Sides],[297],
        [4eva Is...Long Time],[297],
        [Atrocity Exhibition],[287],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Alan - Top 10 Genres (2025)*],
        [*Genre*],[*Plays*],
        [hip hop],[9677],
        [conscious hip hop],[4847],
        [trap],[4638],
        [alternative hip hop],[4451],
        [boom bap],[4413],
        [pop rap],[4245],
        [abstract hip hop],[3532],
        [jazz rap],[3491],
        [experimental hip...],[3405],
        [east coast hip hop],[3333],
      )
    ],
  )
)

#figure(
  // caption: "Top 10 tracks, artists, albums, and genres for Alexandra (2025)",
  grid(
    columns: 4,
    column-gutter: 0.5em,
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Alex - Top 10 Tracks (2025)*],
        [*Track*],[*Plays*],
        [Vendetta],[119],
        [Sunshine!],[25],
        [Riptide],[19],
        [Heartbreak...Century],[18],
        [Doomed],[15],
        [Static],[15],
        [Fed Up],[14],
        [I've Told You Once],[14],
        [Everybody but You],[13],
        [Nobody Loves Me],[13],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Alex - Top 10 Artists (2025)*],
        [*Artist*],[*Plays*],
        [Beartooth],[563],
        [Neck Deep],[444],
        [State Champs],[385],
        [Wage War],[306],
        [Bring...Horizon],[284],
        [Ashnikko],[233],
        [I Prevail],[228],
        [Panic! At The Disco],[209],
        [WSTR],[195],
        [mgk],[166],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Alex - Top 10 Albums (2025)*],
        [*Album*],[*Plays*],
        [The Surface],[160],
        [Erase The Pain],[119],
        [TRUE POWER],[116],
        [Below],[112],
        [Aggressive],[107],
        [Kings...New Age],[83],
        [Tickets...Downfall],[81],
        [POST HUMAN...GEn],[80],
        [Disease],[79],
        [Neck Deep],[75],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Alex - Top 10 Genres (2025)*],
        [*Genre*],[*Plays*],
        [pop punk],[3158],
        [metalcore],[2873],
        [alternative rock],[2725],
        [post hardcore],[2479],
        [punk rock],[1442],
        [pop rock],[1368],
        [hard rock],[1174],
        [alternative metal],[1006],
        [deathcore],[715],
        [hip hop],[708],
      )
    ],
  )
)

#figure(
  // caption: "Top 10 tracks, artists, albums, and genres for Anthony (2025)",
  grid(
    columns: 4,
    column-gutter: 0.5em,
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Anthony - Top 10 Tracks*],
        [*Track*],[*Plays*],
        [Yale],[51],
        [ss],[50],
        [No Pole],[48],
        [POWER],[46],
        [tv off],[44],
        [I Wonder],[40],
        [No Flockin'],[40],
        [FIELD TRIP],[38],
        [overseas],[38],
        [EVIL J0RDAN],[37],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Anthony - Top 10 Artists*],
        [*Artist*],[*Plays*],
        [Kanye West],[1199],
        [Playboi Carti],[639],
        [Drake],[556],
        [Young Thug],[511],
        [Future],[425],
        [Gunna],[342],
        [Kendrick Lamar],[321],
        [Lil Baby],[319],
        [Ken Carson],[317],
        [21 Savage],[313],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Anthony - Top 10 Albums*],
        [*Album*],[*Plays*],
        [MUSIC],[384],
        [Graduation],[266],
        [My Beautiful...Fantasy],[250],
        [Yeezus],[184],
        [Slime Season],[161],
        [The Life Of Pablo],[156],
        [A Great Chaos],[141],
        [GNX],[120],
        [Take Care],[113],
        [UY SCUTI],[112],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Anthony - Top 10 Genres*],
        [*Genre*],[*Plays*],
        [trap],[9622],
        [hip hop],[7419],
        [pop rap],[6038],
        [contemporary r&b],[2939],
        [pop],[2077],
        [gangsta rap],[1621],
        [southern hip hop],[1544],
        [abstract hip hop],[1520],
        [electronic],[1419],
        [rage],[1314],
      )
    ],
  )
)

#figure(
  // caption: "Top 10 tracks, artists, albums, and genres for Koren (2025)",
  grid(
    columns: 4,
    column-gutter: 0.5em,
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Koren - Top 10 Tracks*],
        [*Track*],[*Plays*],
        [Brown Paper Bag],[44],
        [Myron],[39],
        [Autobots],[38],
        [Off The Meter],[38],
        [On the Roof],[37],
        [Ice Cream & Syrup],[36],
        [Only You (Original Mix)],[35],
        [Maximum Style],[32],
        [Load Out],[32],
        [Gemini],[30],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Koren - Top 10 Artists*],
        [*Artist*],[*Plays*],
        [Playboi Carti],[1071],
        [Mint],[463],
        [LTJ Bukem],[299],
        [Che],[290],
        [Roni Size],[276],
        [tenkay],[255],
        [toe],[219],
        [Nookie],[202],
        [Lil Uzi Vert],[183],
        [OsamaSon],[181],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Koren - Top 10 Albums*],
        [*Album*],[*Plays*],
        [MUSIC...DA WAIT],[584],
        [MUSIC],[307],
        [Selected Jungle Works],[258],
        [New Forms],[208],
        [Atmospheric Intellige...],[177],
        [REST IN BASS],[160],
        [Producer 01],[108],
        [Selected Works 94-96],[93],
        [Unutella],[93],
        [Slow Motion],[90],
      )
    ],
    [
      #table(
        fill: (col, row) => {
          if row == 0 { gray.lighten(80%) }
        },
        columns: 2,
        align: left,
        table.cell(colspan: 2, align: center)[*Koren - Top 10 Genres*],
        [*Genre*],[*Plays*],
        [drum and bass],[5875],
        [trap],[5210],
        [liquid funk],[3847],
        [jungle],[3610],
        [underground trap],[2576],
        [hip hop],[2286],
        [plugg],[2241],
        [rage],[2181],
        [math rock],[1450],
        [cloud rap],[1432],
      )
    ],
  )
)

In 2025, all four users exhibit coherent but distinct stylistic cores. Alan's top artists and genres are heavily hip hop-centered, but his artist list spans adjacent substyles and eras, indicating breadth within one dominant macro-genre rather than single-artist lock-in. Anthony is the most canonically trap-centric profile: top artists, albums, and genre ranks align around mainstream trap/rap lineages with high repetition of central artists. Alexandra's profile is the most internally consistent rock pipeline (pop punk, metalcore, post-hardcore, alternative rock), with limited hip hop spillover relative to total volume. Koren is a hybrid cluster with strong drum and bass/jungle/liquid funk presence coexisting with trap/plugg/rage, yielding the widest cross-family genre mixture among the four despite high concentration at the artist level for a few key acts.

A notable cross-user pattern is that top-track counts are modest relative to top-artist counts, suggesting repeated cycling through artist catalogs rather than single-track looping as the dominant mode. Koren and Anthony show the strongest signs of artist-level reinforcement (high top-artist plays with genre consistency), while Alexandra and Alan show relatively more dispersion across artists within their core genre families.

=== Genre Profile

#figure(
  grid(
    columns: 2,
    row-gutter: 1em,
    column-gutter: 0.5em,
    align: left,
    [
      *Alan*
      #v(-0.5em)
      #table(
        columns: 6,
        align: left,
        [*By Plays*],[*Plays*],[*Artists*],[*By Artists*],[*Artists*],[*Plays*],
        [hip hop],[9677],[113],[hip hop],[113],[9677],
        [consci...hop],[4847],[31],[trap],[63],[4638],
        [trap],[4638],[63],[alter...hip],[39],[4451],
        [alter...hip],[4451],[39],[electronic],[37],[2283],
        [boom bap],[4413],[28],[pop rap],[36],[4245],
        [pop rap],[4245],[36],[conte...r&b],[35],[2150],
        [abstr...hop],[3532],[23],[soul],[34],[2329],
        [jazz rap],[3491],[26],[alter...rock],[32],[2795],
        [exper...hop],[3405],[16],[consci...hop],[31],[4847],
        [east...hop],[3333],[28],[indie rock],[30],[1562],
      )

      - *Top by plays:* hip hop (9677 plays, 113 artists)
      - *Top by artists:* hip hop (113 artists, 9677 plays)
      - *Diverges:* #sym.crossmark
    ],
    [
      *Anthony*
      #v(-0.5em)
      #table(
        columns: 6,
        align: left,
        [*By Plays*],[*Plays*],[*Artists*],[*By Artists*],[*Artists*],[*Plays*],
        [trap],[9622],[270],[trap],[270],[9622],
        [hip hop],[7419],[263],[hip hop],[263],[7419],
        [pop rap],[6038],[97],[pop rap],[97],[6038],
        [conte...r&b],[2939],[75],[conte...r&b],[75],[2939],
        [pop],[2077],[40],[south...hop],[67],[1544],
        [gangsta rap],[1621],[53],[gangsta rap],[53],[1621],
        [south...hop],[1544],[67],[west...hop],[42],[598],
        [abstr...hop],[1520],[6],[pop],[40],[2077],
        [electronic],[1419],[25],[dance pop],[31],[623],
        [rage],[1314],[17],[alter...r&b],[31],[849],
      )

      - *Top by plays:* trap (9622 plays, 270 artists)
      - *Top by artists:* trap (270 artists, 9622 plays)
      - *Diverges:* #sym.crossmark
    ],
    [
      *Alexandra*
      #table(
        columns: 6,
        align: left,
        [*By Plays*],[*Plays*],[*Artists*],[*By Artists*],[*Artists*],[*Plays*],
        [pop punk],[3158],[121],[alter...rock],[141],[2725],
        [metalcore],[2873],[98],[pop punk],[121],[3158],
        [alter...rock],[2725],[141],[metalcore],[98],[2873],
        [post...core],[2479],[67],[post...core],[67],[2479],
        [punk rock],[1442],[42],[pop rock],[52],[1368],
        [pop rock],[1368],[52],[alter...met],[51],[1006],
        [hard rock],[1174],[49],[hard rock],[49],[1174],
        [alter...met],[1006],[51],[emo],[47],[625],
        [deathcore],[715],[32],[punk rock],[42],[1442],
        [hip hop],[708],[27],[pop],[41],[396],
      )

      - *Top by plays:* pop punk (3158 plays, 121 artists)
      - *Top by artists:* alternative rock (141 artists, 2725 plays)
      - *Diverges:* #sym.checkmark
    ],
    [
      *Koren*
      #table(
        columns: 6,
        align: left,
        [*By Plays*],[*Plays*],[*Artists*],[*By Artists*],[*Artists*],[*Plays*],
        [drum...bass],[5726],[201],[hip hop],[348],[2286],
        [trap],[5210],[324],[trap],[324],[5210],
        [liquid funk],[3698],[88],[drum...bass],[201],[5726],
        [jungle],[3487],[105],[under...trap],[114],[2576],
        [under...trap],[2576],[114],[jungle],[105],[3487],
        [hip hop],[2286],[348],[liquid funk],[88],[3698],
        [plugg],[2241],[65],[pop rap],[85],[1017],
        [rage],[2181],[35],[electronic],[82],[660],
        [math rock],[1450],[42],[plugg],[65],[2241],
        [cloud rap],[1432],[64],[cloud rap],[64],[1432],
      )

      - *Top by plays:* drum and bass (5726 plays, 201 artists)
      - *Top by artists:* hip hop (348 artists, 2286 plays)
      - *Diverges:* #sym.checkmark
    ],
  )
)

The divergence test cleanly splits users into two groups. Alan and Anthony are non-divergent: their top genres by volume and by artist count coincide, indicating that breadth and intensity are aligned around one dominant core (hip hop for Alan, trap for Anthony). Alexandra and Koren diverge: Alexandra covers more artists in alternative rock but allocates more total plays to pop punk; Koren covers far more artists in hip hop but allocates more plays to drum and bass. This matches earlier sections: Alexandra shows a stable rock ecosystem with subfamily weighting, while Koren shows schedule-dependent genre switching with a high-intensity drum-and-bass lane.

The magnitude of Koren's divergence is especially informative. A top-artist-count genre with much lower play total indicates exploratory perimeter behavior (many sampled artists) around hip hop, while drum and bass functions as a deeper-repeat channel. Anthony shows the opposite structure: very high artist counts and high plays both concentrated in trap, implying a large but internally coherent core rather than broad cross-family exploration.

=== Unique Genres Per Session

#align(center,
  table(
    columns: 8,
    align: left,
    [*User*],[*Number of Sessions*],[*Mean Genres*],[*Median Genres*],[*Range*],[*1 Genre*],[*5+ Genres*],[*10+ Genres*],
    [Alan],[1408],[20.38],[16.0],[$[1,104]$],[0.78%],[81.96%],[64.28%],
    [Anthony],[798],[14.80],[12.0],[$[1,75]$],[0.88%],[79.82%],[58.15%],
    [Alexandra],[1216],[13.64],[12.0],[$[1,63]$],[0.9%],[81.17%],[58.96%],
    [Koren],[1019],[13.30],[9.0],[$[1,154]$],[1.37%],[72.23%],[46.22%],
  )
)

Session-level genre breadth confirms that all users are generally multi-genre within sessions, but with distinct depth profiles. Alan has the highest mean and median genres per session (20.38 and 16), and the largest share of sessions with 10+ genres (64.28%), consistent with his broadening entropy trend and reduced long-run concentration. Anthony and Alexandra are similar in medians (12), but Anthony has slightly higher mean than Alexandra, implying occasional broader sessions layered on top of a concentrated core.

Koren is the most asymmetric profile, with the lowest median among the four (9) but the widest range (1-154). This indicates coexistence of narrow sessions and extremely broad sessions, matching his high temporal genre heterogeneity and mixed concentration signature. In practice, Koren's behavior is regime-switching rather than centered around one stable session archetype.

Taken together, Alan is high-volume and structurally broad in-session; Alexandra is lower-variance and style-coherent; Anthony is concentrated with strong core persistence; Koren alternates between concentrated and highly exploratory states, producing high entropy with moderate top-artist concentration.

=== Genre PCA

Principal component analysis is applied to per-user genre play-share vectors (each entry is the fraction of total plays attributed to that genre) to decompose inter-user variance into interpretable axes. Because genre shares sum to one, PCA here identifies the genre dimensions along which users diverge most, and the proportion of variance explained quantifies how well low-dimensional space captures that separation.

#align(center, [
  #image("../data/genre_pca_2025/genre_pca_biplot_2025.png", width: 90%)
])

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

The PCA solution is statistically strong for interpretation: PC1 and PC2 jointly explain 87.2% of variance, so the user separation seen in the biplot is not a projection artifact. Component structure is sharply anisotropic by genre family. Rock and punk load almost entirely on PC1 (family mean $|"PC1"| = 0.299$ vs $|"PC2"| = 0.017$), drum-and-bass lineage loads primarily on PC2 (family mean $|"PC2"| = 0.407$), and hip hop/trap carries mixed load on both axes (mean $|"PC1"| = 0.125$, $|"PC2"| = 0.154$). This quantifies the visual result: PC1 is the rock-versus-rap contrast, while PC2 isolates the DnB/jungle manifold from rap-centered profiles.

User geometry reinforces earlier sections. Alexandra is the only strong negative-PC1 point (rock pole), Koren is strongly positive on PC2 (DnB/jungle pole), and Alan/Anthony occupy the rap side with negative PC2. The closest pair in PCA space is Anthony-Alan (distance $0.0977$), far below Anthony-Koren ($0.2734$) or Alexandra-Koren ($0.3940$). This is consistent with pre-PCA evidence: Alan and Anthony were already the non-divergent group in genre ranking (plays and artist-count leaders coincide), while Koren and Alexandra were divergence-heavy in different directions.

The loadings also explain why Alan and Anthony are near each other but not identical. Both are pulled by trap/hip hop/pop-rap vectors, yet Anthony is farther toward high trap intensity (higher PC1), while Alan sits less extreme and slightly closer to cross-family vectors. Koren's high PC2 arises from alignment with drum and bass, liquid funk, and jungle arrows, matching the schedule-dependent genre switching identified in the temporal section. Alexandra's near-zero PC2 and strongly negative PC1 indicate that her separation is driven by stable rock-family preference rather than time-varying migration into the DnB axis.

== Behavioral Profile

=== Play & Session Distributions

#figure(
  grid(
    columns: 2,
    column-gutter: 0.5em,
    [#image("../data/distributions/plots/boxplot_daily_play_count_2025.png")],
    [
      *Distribution of Daily Play Counts for Each User (2025)*
      #v(-0.5em)
      #table(
        columns: 5,
        align: left,
        [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
        [*Mean*],[85.7076],[24.4691],[45.3742],[54.8878],
        [*Median*],[75.0],[19.5],[28.5],[35.0],
        [*Mode*],[2],[12],[6],[1],
        [*Std. Dev.*],[71.4182],[17.5635],[51.8286],[60.8802],
        [*Skew.*],[1.9217],[1.7419],[2.4302],[1.9107],
        [*Min*],[1],[1],[1],[1],
        [*Max*],[597],[128],[315],[380],
        [$bold(Q_1)$],[31.0],[12.0],[11.0],[9.75],
        [$bold(Q_3)$],[123.0],[32.0],[59.75],[76.5],
        [*IQR*],[92.0],[20.0],[48.75],[66.75],
      )
    ]
  )
)

#figure(
  grid(
    columns: 2,
    column-gutter: 0.5em,
    [#image("../data/distributions/plots/boxplot_session_length_2025.png")],
    [
      *Distribution of Session Length for Each User (2025)*
      #v(-0.5em)
      #table(
        columns: 5,
        align: left,
        [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
        [*Mean*],[42.1197],[21.7521],[49.7679],[50.4538],
        [*Median*],[27.1972],[15.6186],[24.1821],[20.5975],
        [*Mode*],[1],[7],[3],[2],
        [*Std.*],[54.6085],[24.8627],[90.5875],[82.2804],
        [*Skew.*],[4.1745],[3.4265],[6.3074],[4.192],
        [*Min*],[0],[0],[0],[0],
        [*Max*],[678.5822],[260.9058],[1199.2688],[877.882],
        [$bold(Q_1)$],[6.3432],[6.873],[9.171],[4.0809],
        [$bold(Q_3)$],[54.7924],[27.8482],[56.0345],[65.5868],
        [*IQR*],[48.4492],[20.9752],[46.8636],[61.5059],
      )
    ]
  )
)

#figure(
  grid(
    columns: 2,
    column-gutter: 0.5em,
    [#image("../data/distributions/plots/boxplot_plays_per_track_2025.png")],
    [
      *Distribution of Plays per Track for Each User (2025)*
      #v(-0.5em)
      #table(
        columns: 5,
        align: left,
        [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
        [*Mean*],[9.4524],[4.4558],[4.0614],[4.706],
        [*Median*],[4.0],[4.0],[2.0],[2.0],
        [*Mode*],[1],[3],[1],[1],
        [*Std.*],[11.4427],[3.6347],[5.4638],[5.7288],
        [*Skew.*],[2.3847],[16.481],[3.4971],[2.2271],
        [*Min*],[1],[1],[1],[1],
        [*Max*],[104],[119],[51],[45],
        [$bold(Q_1)$],[2.0],[3.0],[1.0],[1.0],
        [$bold(Q_3)$],[14.0],[6.0],[4.0],[6.0],
        [*IQR*],[12.0],[3.0],[3.0],[5.0],
      )
    ]
  )
)

#figure(
  grid(
    columns: 2,
    column-gutter: 0.5em,
    [#image("../data/distributions/plots/boxplot_plays_per_artist_2025.png")],
    [
      *Distribution of Plays per Artist for Each User (2025)*
      #v(-0.5em)
      #table(
        columns: 5,
        align: left,
        [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
        [*Mean*],[61.4507],[17.3181],[25.2357],[12.2672],
        [*Median*],[8.0],[5.0],[4.0],[3.0],
        [*Mode*],[1],[3],[1],[1],
        [*Std.*],[134.8121],[47.7319],[81.4738],[40.3652],
        [*Skew.*],[4.3211],[6.9268],[8.1925],[15.4665],
        [*Min*],[1],[1],[1],[1],
        [*Max*],[1179],[563],[1199],[1071],
        [$bold(Q_1)$],[2.0],[3.0],[2.0],[1.0],
        [$bold(Q_3)$],[49.0],[10.0],[15.0],[11.0],
        [*IQR*],[47.0],[7.0],[13.0],[10.0],
      )
    ]
  )
)

#figure(
  grid(
    columns: 2,
    column-gutter: 0.5em,
    [#image("../data/distributions/plots/boxplot_plays_per_album_2025.png")],
    [
      *Distribution of Plays per Album for Each User (2025)*
      #v(-0.5em)
      #table(
        columns: 5,
        align: left,
        [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
        [*Mean*],[29.668],[8.1108],[8.2998],[7.1354],
        [*Median*],[5.0],[5.0],[3.0],[2.0],
        [*Mode*],[1],[2],[1],[1],
        [*Std.*],[58.4846],[13.6859],[19.9943],[18.3486],
        [*Skew.*],[3.9819],[5.0295],[8.6743],[17.5351],
        [*Min*],[1],[1],[1],[1],
        [*Max*],[673],[160],[384],[584],
        [$bold(Q_1)$],[2.0],[3.0],[1.0],[1.0],
        [$bold(Q_3)$],[29.0],[7.0],[7.0],[9.0],
        [*IQR*],[27.0],[4.0],[6.0],[8.0],
      )
    ]
  )
)

#figure(
  grid(
    columns: 2,
    column-gutter: 0.5em,
    [#image("../data/distributions/plots/boxplot_plays_per_genre_2025.png")],
    [
      *Distribution of Plays per Genre for Each User (2025)*
      #v(-0.5em)
      #table(
        columns: 5,
        align: left,
        [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
        [*Mean*],[438.6554],[133.0087],[295.9056],[146.1726],
        [*Median*],[67.0],[10.0],[14.0],[11.0],
        [*Mode*],[2, 3],[2, 6],[1],[1],
        [*Std.*],[1012.8973],[413.022],[1063.8019],[570.0426],
        [*Skew.*],[4.6574],[5.2842],[6.488],[6.8537],
        [*Min*],[1],[1],[1],[1],
        [*Max*],[9677],[3158],[9622],[5875],
        [$bold(Q_1)$],[14.5],[5.0],[3.0],[2.0],
        [$bold(Q_3)$],[336.0],[57.5],[110.75],[57.0],
        [*IQR*],[321.5],[52.5],[107.75],[55.0],
      )
    ]
  )
)

Across all six metrics, medians are far below means and upper tails are long, confirming heavy-tailed listening behavior as the dominant statistical regime. For daily play counts, Alan has the highest center and spread; Anthony and Koren have lower medians but longer tails, indicating sporadic high-intensity days. Alexandra's distribution is tighter with fewer extreme days.

Session length is especially skewed for Anthony and Koren, where rare very long sessions inflate means well above medians. Plays per track shows Alan's higher repeat intensity (median 4 versus 2 for Anthony/Koren), while Alexandra is bimodally selective: lower overall volume with occasional strong track-level repeats. Artist- and album-level distributions confirm concentration effects for Alan and Anthony via extreme upper outliers, but Koren's genre-level spread reveals broader movement across genre buckets despite low per-artist medians. Genre plays are heavy-tailed for all users; Alan and Anthony have the largest maxima, while Koren maintains a relatively broad middle range plus high-end spikes.

Methodological note: because these variables are non-Gaussian with extreme skew, mean-based comparisons alone are insufficient; conclusions are based on joint reading of median, IQR, skew, and outlier density.

=== Outliers

#grid(
  columns: (1fr, 0.8fr),
  column-gutter: 1em,
  [
    #grid(
      columns: 3,
      column-gutter: 0.5em,
      row-gutter: 1em,
      [
        #table(
          fill: (col, row) => {
            if row == 0 { gray.lighten(80%) }
          },
          columns: 2,
          align: left,
          table.cell(colspan: 2, align: center)[*Daily Play Count*],
          [*User*],[*Outliers*],
          [Alan],[5],
          [Anthony],[20],
          [Alexandra],[15],
          [Koren],[17],
        )
      ],
      [
        #table(
          fill: (col, row) => {
            if row == 0 { gray.lighten(80%) }
          },
          columns: 2,
          align: left,
          table.cell(colspan: 2, align: center)[*Session Length*],
          [*User*],[*Outliers*],
          [Alan],[88],
          [Anthony],[65],
          [Alexandra],[70],
          [Koren],[65],
        )
      ],
      [
        #table(
          fill: (col, row) => {
            if row == 0 { gray.lighten(80%) }
          },
          columns: 2,
          align: left,
          table.cell(colspan: 2, align: center)[*Plays per Track*],
          [*User*],[*Outliers*],
          [Alan],[145],
          [Anthony],[404],
          [Alexandra],[51],
          [Koren],[342],
        )
      ],
      [
        #table(
          fill: (col, row) => {
            if row == 0 { gray.lighten(80%) }
          },
          columns: 2,
          align: left,
          table.cell(colspan: 2, align: center)[*Plays per Artist*],
          [*User*],[*Outliers*],
          [Alan],[70],
          [Anthony],[71],
          [Alexandra],[78],
          [Koren],[128],
        )
      ],
      [
        #table(
          fill: (col, row) => {
            if row == 0 { gray.lighten(80%) }
          },
          columns: 2,
          align: left,
          table.cell(colspan: 2, align: center)[*Plays per Album*],
          [*User*],[*Outliers*],
          [Alan],[142],
          [Anthony],[180],
          [Alexandra],[108],
          [Koren],[138],
        )
      ],
      [
        #table(
          fill: (col, row) => {
            if row == 0 { gray.lighten(80%) }
          },
          columns: 2,
          align: left,
          table.cell(colspan: 2, align: center)[*Plays per Genre*],
          [*User*],[*Outliers*],
          [Alan],[39],
          [Anthony],[32],
          [Alexandra],[33],
          [Koren],[52],
        )
      ],
    )
  ],
  [
    Outliers are identified with the $1.5 times "IQR"$ rule within each user-metric distribution.

    Outlier incidence depends strongly on metric. Session-length outliers are high for all users, confirming that unusually long sessions are a routine feature rather than rare artifacts. Track-level outliers are especially high for Anthony and Koren, consistent with bursty replays of selected tracks during specific periods. Album-level outliers are also elevated for Alan and Anthony, indicating recurrent deep-catalog sessions. Genre-level outlier counts are lower than track/album outliers, implying that extreme behavior more often manifests as intensity within favored entities than abrupt jumps in genre allocation.
  ],
)

Daily-play outliers are relatively sparse compared with entity-level outliers, which suggests that many extremes occur through composition (what is played and how repeatedly) rather than purely through very high daily totals.

=== Interaction Flags & Skip Rate by Shuffle

#figure(
  grid(
    columns: 2,
    column-gutter: 0.5em,
    [
      #image("../data/bool_flags/plots/bool_flags_users_2025.png")
      *Rate of Shuffle, Skipped, and Offline Plays for Each User (All-Time, 2024, 2025)*
    ],
    table(
      columns: 4,
      align: left,
      fill: (col, row) => {
        if row in (0, 6, 11) { gray.lighten(80%) } else { white }
      },
      table.cell(colspan: 4, align: center)[*All-Time*],
      [*User*],[*Shuffle*],[*Skip*],[*Offline*],
      [Alan],[63.3%],[26.0%],[0.1%],
      [Alexandra],[93.3%],[11.7%],[5.0%],
      [Anthony],[53.8%],[34.1%],[0.4%],
      [Koren],[65.1%],[27.5%],[0.9%],
      table.cell(colspan: 4,align: center)[*2024*],
      [Alan],[72.8%],[80.6%],[0.1%],
      [Alexandra],[89.5%],[37.1%],[0.0%],
      [Anthony],[68.3%],[55.6%],[0.0%],
      [Koren],[76.1%],[58.8%],[1.7%],
      table.cell(colspan: 4,align: center)[*2025*],
      [Alan],[49.7%],[80.3%],[0.1%],
      [Alexandra],[95.8%],[26.4%],[1.4%],
      [Anthony],[61.5%],[31.9%],[0.5%],
      [Koren],[76.6%],[55.1%],[0.8%],
    ),
  ),
)

In 2025, Alexandra has a high shuffle usage with comparatively low skip consistent with a trusted catalog of songs. Alan is the strongest contrast case: lowest shuffle among the four in 2025 and the highest skip rate (about 80%), indicating an active selection-and-rejection regime rather than passive stream continuation. Koren combines high shuffle with high skip, suggesting exploratory sampling with frequent filtering. Anthony sits between these patterns with moderate shuffle and moderate skip.

Cross-period comparison shows that elevated skip in Alan is persistent from 2024 to 2025, whereas Alexandra and Anthony both reduce skip meaningfully from 2024. Offline rates remain low for most users and years, except Alexandra's all-time baseline, so offline behavior is secondary to shuffle/skip as a driver of inter-user separation.

#figure(
  grid(
    columns: 2,
    column-gutter: 0.5em,
    [
      #image("../data/skip_by_shuffle/plots/skip_by_shuffle_users_2025.png")
      *Skip Rate by Shuffle for Each User (All-Time, 2024, 2025)*
    ],
    table(
      columns: 3,
      align: left,
      fill: (col, row) => {
        if row in (0, 6, 11) { gray.lighten(80%) } else { white }
      },
      table.cell(colspan: 3, align: center)[*All-Time*],
      [*User*],[*On*],[*Off*],
      [Alan],[23.9%],[29.7%],
      [Alexandra],[11.4%],[16.4%],
      [Anthony],[46.4%],[19.7%],
      [Koren],[29.4%],[24.0%],
      table.cell(colspan: 3,align: center)[*2024*],
      [Alan],[81.4%],[78.4%],
      [Alexandra],[37.2%],[35.9%],
      [Anthony],[65.5%],[34.3%],
      [Koren],[54.1%],[74.0%],
      table.cell(colspan: 3,align: center)[*2025*],
      [Alan],[83.0%],[77.4%],
      [Alexandra],[26.0%],[33.7%],
      [Anthony],[38.9%],[20.7%],
      [Koren],[47.8%],[78.9%],
    )
  ),
)

The shuffle-conditioned skip rates reveal user-specific mechanics rather than a universal shuffle effect. For Alan, skip is high regardless of shuffle state, indicating that high skipping is a stable behavioral trait, not a shuffle artifact. For Anthony, skip is substantially higher when shuffle is on, implying shuffle increases mismatch probability in his catalog context. Alexandra shows the opposite direction (higher skip with shuffle off), consistent with deliberate non-shuffle curation of lower-confidence content or albums. Koren exhibits the strongest asymmetry: skip is much higher with shuffle off in 2025, suggesting non-shuffle sessions are often targeted evaluation or rapid filtering passes.

These conditional results explain why aggregate skip rates can mislead: identical overall skip can emerge from different decision processes depending on shuffle dependence.

=== Playback Start & End Reasons

Playback start/end reasons are behavioral fingerprints of control flow: completion-dominant listening versus forward-seeking and manual intervention. Spotify exports six primary reason codes: `trackdone` — natural track completion; `fwdbtn` — forward/skip button press; `clickrow` — user manually selected a track from the queue; `endplay` — playback ended by session or app closure; `backbtn` — backward navigation; and `appload` — playback resumed on app launch. Higher `fwdbtn` and `endplay` shares indicate active, filtering-oriented behavior; `trackdone` dominance signals passive, completion-oriented listening.

#figure(
  caption: "Start Reasons & End Reasons Proportions for Each User (2025)",
  grid(
    columns: 2,
    column-gutter: 0.5em,
    image("../data/reason_start_end/plots/reason_start_users_2025.png"),
    image("../data/reason_start_end/plots/reason_end_users_2025.png"),
  )
)

In 2025, Alexandra and Anthony are track-completion dominant (`trackdone` is the largest start and end category), while Alan and Koren remain forward-button dominant (`fwdbtn`), with Alan additionally showing a very large `endplay` share. This aligns with the skip metrics: high forward/endplay proportions co-occur with high skip profiles, especially for Alan and Koren.

Relative to all-time and 2024, Anthony shifts toward much higher `trackdone`, consistent with longer average minutes per play and a more completion-oriented 2025 mode. Alexandra remains consistently completion-oriented across periods, though 2025 shows a modest increase in interruption-related end reasons (`unexpected...paused`). Alan's 2025 profile shifts from historically `fwdbtn`-heavy toward more `clickrow` starts and `endplay` ends, indicating more explicit manual navigation and session termination. Koren retains high `fwdbtn` with moderate `trackdone`, preserving a mixed exploration-plus-filtering pattern.

== Temporal Patterns

=== Calendar Heatmap

#image("../data/calendar_heatmap/plots/calendar_heatmap_alan_2025.png")
#image("../data/calendar_heatmap/plots/calendar_heatmap_anthony_2025.png")
#image("../data/calendar_heatmap/plots/calendar_heatmap_alexandra_2025.png")
#image("../data/calendar_heatmap/plots/calendar_heatmap_koren_2025.png")

Daily heatmaps show that each user has essentially continuous platform presence across observed 2025 days (active-day rate ~100% in exported slices), but intensity variance differs materially. Alan has the highest mean daily volume (85.71), highest tail ($"p95" = 205$, $max = 597$), and high but not maximal volatility (coefficient of variation, $"CV" = sigma\/mu = 0.832$), matching earlier findings of heavy right tails in daily-play distributions. Anthony and Koren are more bursty than Alan by normalized variance ($"CV" = 1.140$ and $1.107$), with lower central tendency but frequent spikes (Anthony max 315, Koren max 380). Alexandra is the most stable profile ($"CV" = 0.717$, $"p95" = 56$, $max = 128$), consistent with tighter IQR and lower outlier mass in earlier distribution diagnostics.

=== Listening Times

#figure(
  caption: "Distribution of Listening Times for Each User (2025)",
  grid(
    columns: 2,
    gutter: 1.5em,
    image("../data/listening_times/plots/listening_times_alanjzamora_2025.png"),
    image("../data/listening_times/plots/listening_times_dasucc_2025.png"),
    image("../data/listening_times/plots/listening_times_alexxxxxrs_2025.png"),
    image("../data/listening_times/plots/listening_times_korenns_2025.png"),
  )
)

Hourly profiles are sharply non-uniform for all users. Alan peaks at midnight (2,085 events) with a deep morning trough at 9 AM (88), and 43.8% of his annual plays occur in late-night hours (10 PM-5 AM). This aligns with his high skip/high manual-control profile from Bool Flags and Reasons: a late, high-frequency, high-turnover listening regime.

Anthony peaks at 5 PM (994) and bottoms at noon (119), but still allocates 46.3% of activity to the late-night band, indicating a split chronotype (late-night baseline with an evening commute/after-work apex). Alexandra is the most evening-centered profile: peak at 9 PM (1,398), trough at 10 AM (13), and the highest evening share (34.0%), consistent with lower overall volume but concentrated high-engagement windows. Koren is distinct: peak at 2 PM (1,655), near-zero mid-morning (11 AM = 18), only 3.4% morning share, and the highest afternoon share (35.9%), indicating a daytime-heavy core with secondary late-night activity.

The key cross-user result is that high 2025 totals arise from different temporal mechanisms. Alan's and Anthony's scale includes strong nocturnal mass; Koren's scale is driven more by afternoon intensity; Alexandra's lower total is partially offset by tightly concentrated evening peaks.

== Artist Analysis

Artist-level analysis covers concentration, long-run diversity trajectories, sequential transition behavior, and track-level preference asymmetry — together distinguishing genuine exploratory breadth from high-volume repetition.

=== Top Artist Concentration

In 2025, Anthony is the most concentrated listener at the top end (Top-1 = 8.7%, Top-10 = 36.1%), followed closely by Alexandra (Top-10 = 34.6%). Alan is moderate (Top-10 = 26.0%), and Koren remains the least top-heavy (Top-10 = 20.1%). This ranking is consistent with earlier entity-level distribution tails: Anthony's large track/album outlier counts emerge from repeated play concentration around a narrower artist frontier.

Cross-period comparisons show different trajectories. Alan's concentration has relaxed substantially versus all-time (Top-1 from 9.7% to 4.0%), indicating broadening of artist allocation despite high volume. Alexandra remains persistently concentrated across all periods with modest easing in 2025. Anthony's top concentration rises from 2024 to 2025, aligning with his post-spring narrowing in monthly top-artist dynamics. Koren's concentration rises relative to all-time (Top-1 from 3.2% to 6.2%) while still staying below peers on Top-10 share, implying selective focal loops embedded inside a wider artist universe.

#figure(
  grid(
    columns: 2,
    column-gutter: 0.5em,
    [
      #image("../data/artist_concentration/plots/artist_concentration_2025.png")
      *Concentration of Listening Events for Top Artists for Each User (All-Time, 2024, 2025)*
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

=== Artist Diversity Over Time

#figure(
  caption: "Artist Entropy & Gini Coefficient Over Time for Each User (2020-2025)",
  grid(
    columns: 2,
    gutter: 0.5em,
    image("../data/artist_diversity/artist_entropy_over_time.png"),
    image("../data/artist_diversity/artist_gini_over_time.png")
  )
)

Shannon entropy ($H = -sum_i p_i log_2 p_i$; higher values indicate a more uniform distribution of plays across artists) and the Gini coefficient (0 = perfectly equal allocation, 1 = all plays on a single artist) jointly measure breadth and inequality of artist allocation. Koren remains the highest-entropy listener in every year (2025 entropy = 8.564), confirming structurally broad artist exposure despite periodic concentration bursts. Alexandra and Alan converge in 2025 entropy (7.215 and 7.113), but arrive there differently: Alexandra through relatively stable medium concentration, Alan through major long-run diversification (entropy +1.555 from 2020 to 2025).

Gini trends sharpen the interpretation. Alan's Gini falls markedly from 0.911 to 0.778 across 2020-2025, indicating reduced inequality in artist play allocation. Koren also declines slightly (0.768 to 0.743), consistent with sustained breadth. Alexandra increases modestly (0.679 to 0.711), suggesting greater emphasis on a core subset inside a rock-focused space. Anthony shows the largest Gini increase (0.436 to 0.804), indicating substantial consolidation since 2020; this supports his 2025 pattern of high concentration metrics and strong top-genre dominance.

Relative to the outlier section, these diversity trends explain why high outlier counts do not imply low diversity by default: Koren exhibits high burstiness with high entropy, while Anthony exhibits high burstiness with higher allocation inequality.

=== Artist Transition Matrix

The row-normalized transition matrix $P_(i j)$ gives the empirical probability that artist $j$ immediately follows artist $i$ in consecutive plays within a session. High diagonal entries indicate self-loops (repeated plays of the same artist), while dominant off-diagonal entries indicate stable directional flows between artists. Mean self-transition probability and per-row transition entropy (higher = more varied outgoing behavior per artist) summarize the overall structure.

#align(center, grid(
  columns: 2,
  gutter: 0.5em,
  image("../data/artist_transition_matrix_2025/plots/artist_transition_matrix_alanjzamora.png"),
  image("../data/artist_transition_matrix_2025/plots/artist_transition_matrix_dasucc.png"),
  image("../data/artist_transition_matrix_2025/plots/artist_transition_matrix_alexxxxxrs.png"),
  image("../data/artist_transition_matrix_2025/plots/artist_transition_matrix_korenns.png")
))

#align(center, grid(
  columns: 2,
  align: left,
  column-gutter: 1em,
  row-gutter: 1em,
  [
    *Alan*
    #v(-0.5em)
    #table(
      columns: 3,
      align: left,
      [*From Artist*],[*To Artist*],[*Probability*],
      [Jessie Ware],[Jessie Ware],[0.919],
      [Fiona Apple],[Fiona Apple],[0.917],
      [JPEGMAFIA],[JPEGMAFIA],[0.846],
      [Danny Brown],[Danny Brown],[0.677],
      [Denzel Curry],[Denzel Curry],[0.525],
      [Kanye West],[Kanye West],[0.521],
      [JID],[JID],[0.502],
      [A Tribe Called Quest],[A Tribe Called Quest],[0.441],
      [Kendrick Lamar],[Kendrick Lamar],[0.328],
      [Freddie Gibbs],[Freddie Gibbs],[0.287],
    )
  ],
  [
    *Anthony*
    #v(-0.5em)
    #table(
      columns: 3,
      align: left,
      [*From Artist*],[*To Artist*],[*Probability*],
      [Kanye West],[Kanye West],[0.883],
      [Ken Carson],[Ken Carson],[0.819],
      [Playboi Carti],[Playboi Carti],[0.785],
      [Young Thug],[Young Thug],[0.780],
      [21 Savage],[21 Savage],[0.504],
      [Drake],[Drake],[0.432],
      [Kendrick Lamar],[Kendrick Lamar],[0.408],
      [Gunna],[Gunna],[0.340],
      [Future],[Future],[0.203],
      [Lil Baby],[Future],[0.168],
    )
  ],
  [
    *Alexandra*
    #v(-0.5em)
    #table(
      columns: 3,
      align: left,
      [*From Artist*],[*To Artist*],[*Probability*],
      [Wage War],[Wage War],[0.384],
      [I Prevail],[I Prevail],[0.325],
      [Neck Deep],[Neck Deep],[0.291],
      [State Champs],[State Champs],[0.283],
      [WSTR],[WSTR],[0.258],
      [Bring Me The Horizon],[Beartooth],[0.254],
      [Beartooth],[Beartooth],[0.248],
      [mgk],[State Champs],[0.245],
      [State Champs],[Beartooth],[0.228],
      [Panic! At The Disco],[Panic! At The Disco],[0.224],
    )
  ],
  [
    *Koren*
    #v(-0.5em)
    #table(
      columns: 3,
      align: left,
      [*From Artist*],[*To Artist*],[*Probability*],
      [Playboi Carti],[Playboi Carti],[0.981],
      [toe],[toe],[0.952],
      [Lil Uzi Vert],[Lil Uzi Vert],[0.915],
      [Che],[Che],[0.896],
      [Mint],[Mint],[0.752],
      [tenkay],[tenkay],[0.735],
      [OsamaSon],[OsamaSon],[0.585],
      [Roni Size],[Roni Size],[0.529],
      [Nookie],[LTJ Bukem],[0.318],
      [LTJ Bukem],[Roni Size],[0.258],
    )
  ],
))

Transition matrices clarify whether concentration comes from self-loops or rotational flows. Koren has the strongest persistence (mean self-transition $0.674$) and the lowest transition entropy ($0.365$), meaning sequence behavior is highly sticky once a focal artist lane is entered. Alan is also persistence-heavy (mean self-transition $0.596$), but with higher row entropy ($0.582$), indicating more between-artist movement than Koren despite strong loops for selected rows (for example Jessie Ware and Fiona Apple above $0.91$). Anthony is intermediate (mean self-transition $0.530$, entropy $0.662$): several dominant self-loops coexist with directional bridges such as Lil Baby #sym.arrow.r Future and Future #sym.arrow.r Gunna.

Alexandra is structurally different from the other three. Her diagonal mass is lowest (mean self-transition $0.242$) and transition entropy is highest ($0.896$), so listening proceeds as a network traversal inside a coherent rock ecosystem rather than repeated artist lock-in. At the transition level, this matches her earlier profile: lower volatility, high completion behavior, and subfamily-coherent breadth. Koren and Alan, by contrast, express concentration through sequential persistence, while Alexandra expresses consistency through stable *clustered movement*.

=== Track Anomalies

Track-level anomalies are identified by comparing each track's actual play count against a uniform baseline expectation derived from the artist's catalog: $"expected"_t = "total plays for artist" \/ "distinct tracks by artist"$. Tracks with $"actual"\/"expected" > 2 times$ are classified as *obsessions* — the user returns to them far more than the artist's catalog average would predict. Tracks with $"actual"\/"expected" < 0.5 times$ are *avoidances* — persistent suppression within an otherwise favored artist. This isolates within-artist preference asymmetry that is invisible in aggregate play counts.

#align(center, grid(
  columns: 2,
  gutter: 1em,
  image("../data/track_anomaly_2025/plots/track_anomaly_alanjzamora.png"),
  image("../data/track_anomaly_2025/plots/track_anomaly_dasucc.png"),
  image("../data/track_anomaly_2025/plots/track_anomaly_alexxxxxrs.png"),
  image("../data/track_anomaly_2025/plots/track_anomaly_korenns.png"),
))

Anomaly structure distinguishes intensity bias from catalog suppression. Koren has the strongest positive deviation tail (top obsession ratio $14.70 times$, median top-12 obsession ratio $5.82 times$), indicating extreme short-horizon fixation events. Anthony is next (max $10.25 times$, median $8.30 times$), consistent with concentrated trap-core replay behavior already visible in top-artist concentration and transition persistence.

Avoidance concentration is equally diagnostic. Alan's top avoidances are highly concentrated in a single catalog pocket (11 of top-12 avoidances from JPEGMAFIA, median avoidance ratio $0.058 times$), showing active within-artist filtering rather than global artist rejection. Anthony exhibits a similar but weaker structure (9 of top-12 avoidances from Kanye West, median $0.113 times$). Koren's avoidances are centered on Playboi Carti subsets (6 of top-12), while Alexandra's avoidances are milder in magnitude (median $0.187 times$) and less extreme overall, matching her lower-volatility, completion-oriented profile.

Taken together, the anomaly model does not contradict the transition and PCA results; it sharpens them. High concentration users are not simply "repeating favorites" uniformly. They also exhibit selective suppression inside otherwise favored artist catalogs, producing simultaneous obsession and avoidance signatures that explain the high skip and manual-navigation patterns documented earlier.

== Cross-User Comparison

User-level behavioral similarity is evaluated using composite distance metrics and raw feature overlap, providing convergent evidence that pairwise profiles are structurally distinct.

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
+ *late-night fraction (22:00-05:00):* proportion of plays in late-night hours; captures chronotype and listening context

*Categorical Feature ($bold(delta)$):*
+ *$bold(delta_"top" (a,b) = 0)$ if top genre matches, else 1:* ensures genre-separated users are penalized despite numeric feature proximity

#align(center, grid(
  columns: (1fr, 0.8fr),
  gutter: 0.5em,
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
  image("../data/composite_user_distance/plots/composite_user_distance_alltime.png")
))

The composite distance matrix provides a behavioral similarity check across mixed numeric and categorical features. The closest pair is Alan--Anthony ($0.4660$), consistent with their shared hip-hop/trap orientation and similar artist concentration levels. The farthest pair is Alexandra--Anthony ($0.7224$), driven primarily by opposing shuffle habits (93% vs. 54%), a 22-minute gap in mean session length, and a nearly five-fold difference in mean plays per track (33.6 vs. 9.1). The global pairwise spread is $0.7224 - 0.4660 = 0.2564$, confirming that users occupy meaningfully distinct regions of the feature space rather than clustering around a single listener archetype.

Average distance-to-others shows Alexandra as the most isolated profile (mean $0.6379$), reflecting her extreme shuffle dependence and pop-punk top genre relative to the trap-adjacent cluster formed by the other three. Anthony is the second-most isolated ($0.5680$) despite sharing genre space with Alan and Koren, because his low mean plays per track ($9.10$ vs.\ $14$--$49$ for the others) and high skip rate pull him away in those dimensions. Koren is the most central ($0.5289$) and Alan sits slightly higher ($0.5552$); both have intermediate entropy and concentration values that place them in the moderate-similarity zone relative to the full group.

==== Temporal Self-Drift (2024 → 2025)

Self-drift applies the same composite distance function between each user's 2024 and 2025 feature vectors, measuring how much their behavioral profile shifted year-over-year.

#align(center, grid(
  columns: (1fr, 0.9fr),
  gutter: 1em,
  align: left,
  image("../data/user_self_drift/plots/user_self_drift_2024_2025.png"),
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

Self-drift from 2024 to 2025 is heterogeneous (spread $0.1671$): Alexandra drifts most ($0.2872$), Koren least ($0.1201$), with Alan ($0.2348$) and Anthony ($0.2138$) in between. The drift ranking aligns with section-level narrative. Alexandra changes top genre label (metalcore #sym.arrow.r pop punk) and shortens sessions materially, even while retaining rock-family identity. Koren preserves top genre and most feature directions, producing the smallest drift despite sizable volume and timing fluctuations.

Anthony's drift is dominated by stronger engagement efficiency: mean play duration and session length rise while skip rate falls, yet top-genre identity remains trap. Alan's drift is different in mechanism: shuffle rate drops sharply and session length falls, but high-skip, manual-control behavior remains, so drift reflects mode shift within a stable macro-genre identity rather than genre replacement.

=== Cross-User Similarity Robustness

This section validates whether cross-user conclusions are stable across multiple similarity definitions. Cosine similarity emphasizes allocation shape (intensity-weighted profiles), while Jaccard emphasizes set overlap (shared support regardless of weights). Agreement between them increases confidence that similarities are structural, not metric-specific artifacts.

#align(center,
  grid(
    columns: 2,
    column-gutter: 0.5em,
    image("../data/genre_cosine_similarity/genre_cosine_2025.png"),
    image("../data/genre_jaccard_similarity/genre_jaccard_2025.png"),
    image("../data/artist_cosine_similarity/plots/artist_cosine_2025.png"),
    image("../data/artist_jaccard_similarity/plots/artist_jaccard_2025.png"),
  )
)

Genre-level similarity is highly non-uniform in 2025. By cosine, Alan-Anthony is the strongest pair (0.242), followed by Anthony-Koren (0.190), while any pair with Alexandra is near zero. Jaccard confirms the same broad ordering but adds a complementary view: Anthony-Koren has the highest shared genre support (0.352), then Alan-Koren (0.244) and Alan-Anthony (0.232). The combined reading is that Alan and Anthony are most similar in weighted allocation geometry, whereas Anthony and Koren share a wider common genre footprint even when their weights differ.

Artist-level overlap is much sparser than genre-level overlap. Artist cosine similarities in 2025 are all small (max 0.095 for Anthony-Koren; 0.084 for Alan-Anthony), and artist Jaccard is near zero for most pairs, including zero overlap between Alexandra and each other user in top artist sets for the selected window. This formally supports the earlier qualitative claim: users may occupy related genre manifolds while expressing them through distinct artist catalogs.

Temporal context further strengthens the interpretation. All-time similarities are materially higher than 2025 for several pairs (for example Alan-Anthony in genre cosine), indicating that the 2025 slice represents a sharper behavioral differentiation regime rather than a permanent absence of shared listening structure.