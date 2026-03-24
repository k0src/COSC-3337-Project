#import "@preview/typsidian:0.0.3": *
#import "@preview/frame-it:1.2.0": *
#import "@preview/mannot:0.3.0": *
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": chart, plot
#import calc: exp, ln, pow

#show: typsidian.with(
  title: "Spotify Data Project",
  author: "Koren Stalnaker",
  course: "COSC 3337",
  show-heading-colors: false,
)

#let artist-cols = (
  "KIDS SEE GHOSTS": rgb("#ff9999").lighten(50%),
  "Sufjan Stevens": rgb("#ffb399").lighten(50%),
  "Drake": rgb("#ffcc99").lighten(50%),
  "Lonnie Liston Smith": rgb("#ffe599").lighten(50%),
  "ark762": rgb("#ffff99").lighten(50%),
  "Playboi Carti": rgb("#ccff99").lighten(50%),
  "Lupe Fiasco": rgb("#99ff99").lighten(50%),
  "Denzel Curry": rgb("#99ffb3").lighten(50%),
  "Tee Grizzley": rgb("#99ffcc").lighten(50%),
  "J Dilla": rgb("#99ffe5").lighten(50%),
  "Beartooth": rgb("#99ffff").lighten(50%),
  "Cdot Honcho": rgb("#99e5ff").lighten(50%),
  "Anderson .Paak": rgb("#99ccff").lighten(50%),
  "Kendrick Lamar": rgb("#99b3ff").lighten(50%),
  "I Prevail": rgb("#9999ff").lighten(50%),
  "Remarc": rgb("#b399ff").lighten(50%),
  "A$AP Rocky": rgb("#cc99ff").lighten(50%),
  "Tay-K": rgb("#e599ff").lighten(50%),
  "Hozier": rgb("#ff99ff").lighten(50%),
  "JID": rgb("#ff99e5").lighten(50%),
  "Panic! At The Disco": rgb("#ff99cc").lighten(50%),
  "Pi'erre Bourne": rgb("#ff99b3").lighten(50%),
  "Kanye West": rgb("#ff8080").lighten(50%),
  "Bring Me The Horizon": rgb("#ff9966").lighten(50%),
  "Alex Reese": rgb("#ffb366").lighten(50%),
  "Young Thug": rgb("#ffcc66").lighten(50%),
  "Travis Scott": rgb("#ffff66").lighten(50%),
  "LTJ Bukem": rgb("#b3ff66").lighten(50%),
  "Palisades": rgb("#66ff66").lighten(50%),
  "Big Bud": rgb("#66ff99").lighten(50%),
  "Juice WRLD": rgb("#66ffcc").lighten(50%),
  "Chief Keef": rgb("#66ffff").lighten(50%),
  "Wage War": rgb("#66ccff").lighten(50%),
  "toe": rgb("#6699ff").lighten(50%),
  "Fall Out Boy": rgb("#6666ff").lighten(50%),
  "Future": rgb("#9966ff").lighten(50%),
  "Gorillaz": rgb("#cc66ff").lighten(50%),
  "21 Savage": rgb("#ff66ff").lighten(50%),
  "Big K.R.I.T.": rgb("#ff66b3").lighten(50%),
  "Lil Baby": rgb("#ff6666").lighten(50%),
  "A Boogie Wit da Hoodie": rgb("#ff8833").lighten(50%),
  "Luh Tyler": rgb("#ffaa33").lighten(50%),
  "Neck Deep": rgb("#ffcc33").lighten(50%),
  "Roni Size": rgb("#ffff33").lighten(50%),
  "Don Toliver": rgb("#99ff33").lighten(50%),
  "Mint": rgb("#33ff33").lighten(50%),
  "G Herbo": rgb("#33ff88").lighten(50%),
  "Silverstein": rgb("#33ffcc").lighten(50%),
  "Roddy Ricch": rgb("#33ffff").lighten(50%),
  "My Chemical Romance": rgb("#33aaff").lighten(50%),
  "A Tribe Called Quest": rgb("#3366ff").lighten(50%),
  "Ashnikko": rgb("#3333ff").lighten(50%),
  "mgk": rgb("#8833ff").lighten(50%),
  "The Pharcyde": rgb("#cc33ff").lighten(50%),
  "The Roots": rgb("#ff33ff").lighten(50%),
  "Danny Brown": rgb("#ff3399").lighten(50%),
  "The Avalanches": rgb("#ffaacc").lighten(50%),
  "Ken Carson": rgb("#ffccaa").lighten(50%),
  "Tom & Jerry": rgb("#eeffaa").lighten(50%),
  "Gunna": rgb("#aaffcc").lighten(50%),
  "JAY-Z": rgb("#aaeeff").lighten(50%),
  "Fountains Of Wayne": rgb("#aaccff").lighten(50%),
  "Kodak Black": rgb("#ccaaff").lighten(50%),
  "Black Star": rgb("#ffaaee").lighten(50%),
  "Wax Doctor": rgb("#ffddaa").lighten(50%),
  "Rivals": rgb("#ddffaa").lighten(50%),
  "Nuito": rgb("#aaffdd").lighten(50%),
  "State Champs": rgb("#aaddff").lighten(50%),
  "Nookie": rgb("#ddaaff").lighten(50%),
  "Woe, Is Me": rgb("#ffaadd").lighten(50%),
  "Fiona Apple": rgb("#ff7777").lighten(50%),
  "Trippie Redd": rgb("#ff9977").lighten(50%),
  "Origin Unknown": rgb("#ffbb77").lighten(50%),
  "Sleep Theory": rgb("#ffdd77").lighten(50%),
  "PFM": rgb("#ffff77").lighten(50%),
  "tenkay": rgb("#ddff77").lighten(50%),
  "Neon Trees": rgb("#bbff77").lighten(50%),
  "Lianne La Havas": rgb("#99ff77").lighten(50%),
  "underscores": rgb("#77ff77").lighten(50%),
  "blink-182": rgb("#77ff99").lighten(50%),
  "YoungBoy Never Broke Again": rgb("#77ffbb").lighten(50%),
  "Pusha T": rgb("#77ffdd").lighten(50%),
  "BigXthaPlug": rgb("#77ffff").lighten(50%),
  "Total Science": rgb("#77ddff").lighten(50%),
  "Hidden Agenda": rgb("#77bbff").lighten(50%),
  "¥$": rgb("#7799ff").lighten(50%),
  "Earl Sweatshirt": rgb("#7777ff").lighten(50%),
  "OsamaSon": rgb("#9977ff").lighten(50%),
  "Benji Blue Bills": rgb("#bb77ff").lighten(50%),
  "JPEGMAFIA": rgb("#dd77ff").lighten(50%),
  "JMJ": rgb("#ff77ff").lighten(50%),
  "Mos Def": rgb("#ff77dd").lighten(50%),
  "Falling In Reverse": rgb("#ff77bb").lighten(50%),
  "MGMT": rgb("#ff7799").lighten(50%),
  "Jessie Ware": rgb("#dd7777").lighten(50%),
  "Freddie Gibbs": rgb("#dd9977").lighten(50%),
  "Cutty Ranks": rgb("#ddbb77").lighten(50%),
  "Diamond Construct": rgb("#dddd77").lighten(50%),
  "Kim Dracula": rgb("#bbdd77").lighten(50%),
  "Duwap Kaine": rgb("#77dd99").lighten(50%),
  "SOB X RBE": rgb("#77dddd").lighten(50%),
  "Fleet Foxes": rgb("#7799dd").lighten(50%),
  "WSTR": rgb("#9977dd").lighten(50%),
  "Che": rgb("#dd77dd").lighten(50%),
  "J Majik": rgb("#dd7799").lighten(50%),
  "DANGERDOOM": rgb("#ee9988").lighten(50%),
  "Lil Uzi Vert": rgb("#88ee99").lighten(50%),
)

#make-title(show-outline: false, show-author: true, justify: "left")

#show figure: set block(breakable: true)

= Exploratory Data Analysis

== Unique Counts & Total Listening Events

Unique item counts and total event volume establish the scale and scope of each user's listening history. Understanding how many distinct tracks, artists, and albums each user has encountered tells us whether their listening habits are broad or focused on repeat favorites, a key baseline before any deeper analysis.

#figure(
  caption: "Summary Statistics for Each User (All-Time, 2024, 2025)",
  table(
    columns: 5,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 5, align: center)[*All-Time*],
    [*User*], [*Unique Tracks*], [*Unique Artists*], [*Unique Albums*], [*Total Listening Events*],
    [Alan], [10569], [1064], [3769], [450283],
    [Alexandra], [5249], [1064], [2349], [139541],
    [Anthony], [9066], [1296], [4252], [72483],
    [Koren], [15188], [4039], [7954], [181858],
    table.cell(colspan: 5, align: center)[*2024*],
    [Alan], [3926], [798], [1442], [57042],
    [Alexandra], [2177], [531], [1123], [12369],
    [Anthony], [2736], [551], [1442], [11713],
    [Koren], [3011], [1267], [1940], [14706],
    table.cell(colspan: 5, align: center)[*2025*],
    [Alan], [3227], [480], [976], [29418],
    [Alexandra], [2137], [503], [1064], [8712],
    [Anthony], [3510], [543], [1622], [13706],
    [Koren], [3740], [1405], [2313], [17160],
  ),
)

=== Analysis

The four users vary substantially in both volume and catalog breadth. Alan leads in raw event count with 450,283 all-time plays, more than double Koren's 181,858 and nearly 2.5x Alexandra's 139,541. Anthony has the fewest plays (72,483), which is notable given his dataset starts in 2020 while the others have data going back further. However, raw play count alone is misleading about listening habits. Alan's 10,569 unique tracks and 1,064 unique artists against 450,283 plays implies a very high repeat-listen rate. This is confirmed later in the plays-per-artist distributions: Kanye West alone accounts for roughly 9.7% of his entire all-time catalog. Koren's profile is the most distinct: 15,188 unique tracks and 4,039 unique artists all-time, by far the most of any user, despite having fewer total plays than Alan. Koren encounters the most new material but returns to each artist less. Alexandra has the fewest unique tracks (5,249) and fewest unique artists, yet her per-play duration is the highest (approximately 2.1 minutes per play vs Alan's 0.98; see the Listening Times section), meaning she cycles through the same narrow catalog repeatedly and listens through full songs.

In 2025, catalog breadth shifts notably. Anthony has the most unique tracks (3,510) and Koren the most unique artists (1,405), while Alan's unique track count falls to 3,227, below both Anthony and Koren despite nearly twice the play count. This reinforces a consistent cross-time pattern: Alan's volume is high but his exploration is low. Alexandra remains the most constrained listener in 2025 with 2,137 unique tracks and 503 unique artists across only 8,712 total plays.

From 2024 to 2025, Anthony shows the most notable catalog expansion: unique tracks grew from 2,736 to 3,510 (a 28% increase) while his total plays grew by only 17%. Koren's unique artist count grows from 1,267 to 1,405 and album count from 1,940 to 2,313, both substantial jumps relative to play count growth, suggesting active broadening of repertoire in 2025.

== Top Tracks, Artists, & Albums

Top N rankings expose the most dominant items in each user's catalog and give a direct snapshot of their strongest listening preferences. Combined across three time windows (all-time, 2024, and 2025), these tables reveal both stable long-term obsessions and emerging trends.

=== Top Tracks

#figure(
  caption: "Alan's Top 10 Tracks (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) {
        artist-cols.at("KIDS SEE GHOSTS")
      } else if (row == 2 and col in (2, 3)) { artist-cols.at("The Roots") } else if (row == 2 and col in (4, 5)) {
        artist-cols.at("Jessie Ware")
      } else if (row == 3 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("Pusha T")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("Jessie Ware") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Denzel Curry")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("Earl Sweatshirt") } else if (
        row == 4 and col in (4, 5)
      ) { artist-cols.at("Jessie Ware") } else if (row == 5 and col in (0, 1)) {
        artist-cols.at("Kanye West")
      } else if (row == 5 and col in (2, 3)) { artist-cols.at("DANGERDOOM") } else if (row == 5 and col in (4, 5)) {
        artist-cols.at("JPEGMAFIA")
      } else if (row == 6 and col in (0, 1)) { artist-cols.at("Pusha T") } else if (row == 6 and col in (2, 3)) {
        artist-cols.at("Fleet Foxes")
      } else if (row == 6 and col in (4, 5)) { artist-cols.at("Jessie Ware") } else if (row == 7 and col in (0, 1)) {
        artist-cols.at("Kanye West")
      } else if (row == 7 and col in (2, 3)) { artist-cols.at("Denzel Curry") } else if (row == 7 and col in (4, 5)) {
        artist-cols.at("Jessie Ware")
      } else if (row == 8 and col in (0, 1)) { artist-cols.at("Travis Scott") } else if (row == 8 and col in (2, 3)) {
        artist-cols.at("MGMT")
      } else if (row == 8 and col in (4, 5)) { artist-cols.at("Lianne La Havas") } else if (
        row == 9 and col in (0, 1)
      ) { artist-cols.at("Kanye West") } else if (row == 9 and col in (2, 3)) {
        artist-cols.at("Lupe Fiasco")
      } else if (row == 9 and col in (4, 5)) { artist-cols.at("Denzel Curry") } else if (row == 10 and col in (0, 1)) {
        artist-cols.at("KIDS SEE GHOSTS")
      } else if (row == 10 and col in (2, 3)) { artist-cols.at("Anderson .Paak") } else if (
        row == 10 and col in (4, 5)
      ) { artist-cols.at("JPEGMAFIA") } else if (row == 11 and col in (0, 1)) { artist-cols.at("Juice WRLD") } else if (
        row == 11 and col in (2, 3)
      ) { artist-cols.at("Black Star") } else if (row == 11 and col in (4, 5)) { artist-cols.at("underscores") } else {
        white
      }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Track*], [*Plays*],
    [*Track*], [*Plays*],
    [*Track*], [*Plays*],
    [4th Dimension], [1371],
    [I Remember], [122],
    [Begin Again], [102],
    [No More Parties In LA], [1237],
    [Nosetalgia], [117],
    [In Your Eyes], [98],
    [SIRENS], [1213],
    [Centurion], [111],
    [Remember Where You Are], [87],
    [Gorgeous], [1151],
    [Crosshairs], [111],
    [either on or off the drugs], [84],
    [The Games We Play], [1037],
    [Mykonos], [109],
    [The Kill], [84],
    [Dark Fantasy], [1016],
    [Melt Session \#1], [107],
    [Soul Control], [78],
    [CAN'T SAY], [1008],
    [Siberian Breaks], [106],
    [Weird Fishes], [78],
    [So Appalled], [988],
    [Mural], [102],
    [Endtroduction], [75],
    [Feel The Love], [967],
    [Jet Black], [101],
    [HAZARD DUTY PAY!], [67],
    [Armed And Dangerous], [962],
    [Respiration], [100],
    [Uncanny long arms], [67],
  ),
)

#figure(
  caption: "Alexandra's Top 10 Tracks (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) {
        artist-cols.at("Fall Out Boy")
      } else if (row == 2 and col in (2, 3)) { artist-cols.at("Beartooth") } else if (row == 2 and col in (4, 5)) {
        artist-cols.at("Palisades")
      } else if (row == 3 and col in (0, 1)) { artist-cols.at("Neck Deep") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("Beartooth")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("Beartooth") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Neck Deep")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("Beartooth") } else if (row == 4 and col in (4, 5)) {
        artist-cols.at("Beartooth")
      } else if (row == 5 and col in (0, 1)) { artist-cols.at("Neck Deep") } else if (row == 5 and col in (2, 3)) {
        artist-cols.at("Falling In Reverse")
      } else if (row == 5 and col in (4, 5)) { artist-cols.at("Neck Deep") } else if (row == 6 and col in (0, 1)) {
        artist-cols.at("Panic! At The Disco")
      } else if (row == 6 and col in (2, 3)) { artist-cols.at("Hozier") } else if (row == 6 and col in (4, 5)) {
        artist-cols.at("Sleep Theory")
      } else if (row == 7 and col in (0, 1)) { artist-cols.at("Neon Trees") } else if (row == 7 and col in (2, 3)) {
        artist-cols.at("Beartooth")
      } else if (row == 7 and col in (4, 5)) { artist-cols.at("I Prevail") } else if (row == 8 and col in (0, 1)) {
        artist-cols.at("Panic! At The Disco")
      } else if (row == 8 and col in (2, 3)) { artist-cols.at("Falling In Reverse") } else if (
        row == 8 and col in (4, 5)
      ) { artist-cols.at("Beartooth") } else if (row == 9 and col in (0, 1)) { artist-cols.at("Neck Deep") } else if (
        row == 9 and col in (2, 3)
      ) { artist-cols.at("Falling In Reverse") } else if (row == 9 and col in (4, 5)) {
        artist-cols.at("Woe, Is Me")
      } else if (row == 10 and col in (0, 1)) { artist-cols.at("Panic! At The Disco") } else if (
        row == 10 and col in (2, 3)
      ) { artist-cols.at("Beartooth") } else if (row == 10 and col in (4, 5)) {
        artist-cols.at("State Champs")
      } else if (row == 11 and col in (0, 1)) { artist-cols.at("Panic! At The Disco") } else if (
        row == 11 and col in (2, 3)
      ) { artist-cols.at("Silverstein") } else if (row == 11 and col in (4, 5)) { artist-cols.at("Rivals") } else {
        white
      }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Track*], [*Plays*],
    [*Track*], [*Plays*],
    [*Track*], [*Plays*],
    [Sugar, We're Goin Down], [237],
    [Sunshine!], [49],
    [Vendetta], [119],
    [Kali Ma], [194],
    [Doubt Me], [45],
    [Sunshine!], [25],
    [Motion Sickness], [189],
    [Might Love Myself], [41],
    [Riptide], [19],
    [Happy Judgement Day], [187],
    [All My Life], [34],
    [Heartbreak Of The Century], [18],
    [This Is Gospel], [184],
    [Too Sweet], [31],
    [Static], [16],
    [Everybody Talks], [181],
    [Riptide], [30],
    [Doomed], [15],
    [LA Devotee], [174],
    [Ronald], [28],
    [Fed Up], [14],
    [Can't Kick Up The Roots], [171],
    [The Drug In Me Is You], [27],
    [I've Told You Once], [14],
    [Hallelujah], [170],
    [The Surface], [27],
    [Everybody but You], [13],
    [Emperor's New Clothes], [168],
    [The Afterglow], [26],
    [Nobody Loves Me], [13],
  ),
)

#figure(
  caption: "Anthony's Top 10 Tracks (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) { artist-cols.at("21 Savage") } else if (
        row == 2 and col in (2, 3)
      ) { artist-cols.at("Kendrick Lamar") } else if (row == 2 and col in (4, 5)) {
        artist-cols.at("Ken Carson")
      } else if (row == 3 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("Gunna")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("Ken Carson") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Kanye West")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("Playboi Carti") } else if (row == 4 and col in (4, 5)) {
        artist-cols.at("Don Toliver")
      } else if (row == 5 and col in (0, 1)) { artist-cols.at("Roddy Ricch") } else if (row == 5 and col in (2, 3)) {
        artist-cols.at("Future")
      } else if (row == 5 and col in (4, 5)) { artist-cols.at("Kanye West") } else if (row == 6 and col in (0, 1)) {
        artist-cols.at("A$AP Rocky")
      } else if (row == 6 and col in (2, 3)) { artist-cols.at("Drake") } else if (row == 6 and col in (4, 5)) {
        artist-cols.at("Kendrick Lamar")
      } else if (row == 7 and col in (0, 1)) { artist-cols.at("Lil Baby") } else if (row == 7 and col in (2, 3)) {
        artist-cols.at("Luh Tyler")
      } else if (row == 7 and col in (4, 5)) { artist-cols.at("Kodak Black") } else if (row == 8 and col in (0, 1)) {
        artist-cols.at("Kanye West")
      } else if (row == 8 and col in (2, 3)) { artist-cols.at("Playboi Carti") } else if (row == 8 and col in (4, 5)) {
        artist-cols.at("Kanye West")
      } else if (row == 9 and col in (0, 1)) { artist-cols.at("A Boogie Wit da Hoodie") } else if (
        row == 9 and col in (2, 3)
      ) { artist-cols.at("¥$") } else if (row == 9 and col in (4, 5)) { artist-cols.at("¥$") } else if (
        row == 10 and col in (0, 1)
      ) { artist-cols.at("Kanye West") } else if (row == 10 and col in (2, 3)) { artist-cols.at("Future") } else if (
        row == 10 and col in (4, 5)
      ) { artist-cols.at("Playboi Carti") } else if (row == 11 and col in (0, 1)) {
        artist-cols.at("Playboi Carti")
      } else if (row == 11 and col in (2, 3)) { artist-cols.at("Kanye West") } else if (row == 11 and col in (4, 5)) {
        artist-cols.at("Ken Carson")
      } else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Track*], [*Plays*],
    [*Track*], [*Plays*],
    [*Track*], [*Plays*],
    [ball w/o you], [234],
    [Not Like Us], [59],
    [Yale], [51],
    [Father Stretch My Hands Pt. 1], [226],
    [one of wun], [58],
    [ss], [50],
    [I Wonder], [190],
    [ILoveUIHateU], [50],
    [No Pole], [48],
    [Down Below], [184],
    [Fried (She a Vibe)], [45],
    [POWER], [46],
    [Praise The Lord (Da Shine)], [179],
    [It's Up], [43],
    [tv off], [44],
    [Freestyle], [172],
    [2 Slippery], [40],
    [No Flockin'], [40],
    [POWER], [171],
    [ALL RED], [39],
    [I Wonder], [40],
    [Jungle], [164],
    [CARNIVAL], [38],
    [FIELD TRIP], [38],
    [Flashing Lights], [160],
    [Cinderella], [36],
    [EVIL J0RDAN], [38],
    [Shoota], [157],
    [Father Stretch My Hands Pt. 1], [36],
    [overseas], [38],
  ),
)

#figure(
  caption: "Koren's Top 10 Tracks (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) { artist-cols.at("Cdot Honcho") } else if (
        row == 2 and col in (2, 3)
      ) { artist-cols.at("Hidden Agenda") } else if (row == 2 and col in (4, 5)) {
        artist-cols.at("Roni Size")
      } else if (row == 3 and col in (0, 1)) { artist-cols.at("Trippie Redd") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("Tom & Jerry")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("Lil Uzi Vert") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Fountains Of Wayne")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("Origin Unknown") } else if (row == 4 and col in (4, 5)) {
        artist-cols.at("Ken Carson")
      } else if (row == 5 and col in (0, 1)) { artist-cols.at("Tee Grizzley") } else if (row == 5 and col in (2, 3)) {
        artist-cols.at("Roni Size")
      } else if (row == 5 and col in (4, 5)) { artist-cols.at("ark762") } else if (row == 6 and col in (0, 1)) {
        artist-cols.at("Lil Uzi Vert")
      } else if (row == 6 and col in (2, 3)) { artist-cols.at("Nookie") } else if (row == 6 and col in (4, 5)) {
        artist-cols.at("Hidden Agenda")
      } else if (row == 7 and col in (0, 1)) { artist-cols.at("Tee Grizzley") } else if (row == 7 and col in (2, 3)) {
        artist-cols.at("Total Science")
      } else if (row == 7 and col in (4, 5)) { artist-cols.at("Remarc") } else if (row == 8 and col in (0, 1)) {
        artist-cols.at("SOB X RBE")
      } else if (row == 8 and col in (2, 3)) { artist-cols.at("Remarc") } else if (row == 8 and col in (4, 5)) {
        artist-cols.at("Nookie")
      } else if (row == 9 and col in (0, 1)) { artist-cols.at("A Tribe Called Quest") } else if (
        row == 9 and col in (2, 3)
      ) { artist-cols.at("JMJ") } else if (row == 9 and col in (4, 5)) { artist-cols.at("Tom & Jerry") } else if (
        row == 10 and col in (0, 1)
      ) { artist-cols.at("SOB X RBE") } else if (row == 10 and col in (2, 3)) {
        artist-cols.at("Duwap Kaine")
      } else if (row == 10 and col in (4, 5)) { artist-cols.at("Benji Blue Bills") } else if (
        row == 11 and col in (0, 1)
      ) { artist-cols.at("Cdot Honcho") } else if (row == 11 and col in (2, 3)) {
        artist-cols.at("Cutty Ranks")
      } else if (row == 11 and col in (4, 5)) { artist-cols.at("J Majik") } else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Track*], [*Plays*],
    [*Track*], [*Plays*],
    [*Track*], [*Plays*],
    [Honcho Style 3], [297],
    [On the Roof], [78],
    [Brown Paper Bag], [44],
    [Poles 1469], [278],
    [Maximum Style (Lover To Lover)], [66],
    [Myron], [39],
    [Stacy's Mom], [276],
    [Valley of the Shadows], [64],
    [Off The Meter], [38],
    [From The D To The A], [272],
    [Brown Paper Bag], [60],
    [Autobots], [38],
    [Money Longer], [263],
    [Only You (Original Mix)], [59],
    [On The Roof], [37],
    [First Day Out], [262],
    [Rotation], [54],
    [Ice Cream & Syrup], [36],
    [Lane Changing], [258],
    [Ice Cream & Syrup], [45],
    [Only You (Original Mix)], [35],
    [Award Tour], [242],
    [In Too Deep - mixed], [44],
    [Maximum Style (Lover To Lover)], [32],
    [Anti], [235],
    [Pavement], [43],
    [Load Out], [32],
    [Teflon Flow], [226],
    [Limb By Limb - DJ SS Remix], [43],
    [Gemini], [30],
  ),
)

=== Top Artists

Play counts per artist, ranked by total plays, give the clearest single-variable view of listening concentration and genre loyalty across time windows.

#figure(
  caption: "Alan's Top 10 Artists (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (
        row == 2 and col in (2, 3)
      ) { artist-cols.at("Kanye West") } else if (row == 2 and col in (4, 5)) { artist-cols.at("Kanye West") } else if (
        row == 3 and col in (0, 1)
      ) { artist-cols.at("Travis Scott") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("Kendrick Lamar")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("JPEGMAFIA") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Kendrick Lamar")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("Danny Brown") } else if (row == 4 and col in (4, 5)) {
        artist-cols.at("Kendrick Lamar")
      } else if (row == 5 and col in (0, 1)) { artist-cols.at("Denzel Curry") } else if (row == 5 and col in (2, 3)) {
        artist-cols.at("Freddie Gibbs")
      } else if (row == 5 and col in (4, 5)) { artist-cols.at("Jessie Ware") } else if (row == 6 and col in (0, 1)) {
        artist-cols.at("Juice WRLD")
      } else if (row == 6 and col in (2, 3)) { artist-cols.at("Denzel Curry") } else if (row == 6 and col in (4, 5)) {
        artist-cols.at("Denzel Curry")
      } else if (row == 7 and col in (0, 1)) { artist-cols.at("Playboi Carti") } else if (row == 7 and col in (2, 3)) {
        artist-cols.at("The Roots")
      } else if (row == 7 and col in (4, 5)) { artist-cols.at("Danny Brown") } else if (row == 8 and col in (0, 1)) {
        artist-cols.at("Freddie Gibbs")
      } else if (row == 8 and col in (2, 3)) { artist-cols.at("A Tribe Called Quest") } else if (
        row == 8 and col in (4, 5)
      ) { artist-cols.at("Fiona Apple") } else if (row == 9 and col in (0, 1)) {
        artist-cols.at("Lil Uzi Vert")
      } else if (row == 9 and col in (2, 3)) { artist-cols.at("Pusha T") } else if (row == 9 and col in (4, 5)) {
        artist-cols.at("Freddie Gibbs")
      } else if (row == 10 and col in (0, 1)) { artist-cols.at("Drake") } else if (row == 10 and col in (2, 3)) {
        artist-cols.at("Sufjan Stevens")
      } else if (row == 10 and col in (4, 5)) { artist-cols.at("JID") } else if (row == 11 and col in (0, 1)) {
        artist-cols.at("Future")
      } else if (row == 11 and col in (2, 3)) { artist-cols.at("Gorillaz") } else if (row == 11 and col in (4, 5)) {
        artist-cols.at("A Tribe Called Quest")
      } else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Artist*], [*Plays*],
    [*Artist*], [*Plays*],
    [*Artist*], [*Plays*],
    [Kanye West], [43739],
    [Kanye West], [2803],
    [Kanye West], [1184],
    [Travis Scott], [22269],
    [Kendrick Lamar], [2206],
    [JPEGMAFIA], [1094],
    [Kendrick Lamar], [15485],
    [Danny Brown], [1453],
    [Kendrick Lamar], [927],
    [Denzel Curry], [13157],
    [Freddie Gibbs], [1206],
    [Jessie Ware], [798],
    [Juice WRLD], [9580],
    [Denzel Curry], [1189],
    [Denzel Curry], [756],
    [Playboi Carti], [8932],
    [The Roots], [1185],
    [Danny Brown], [636],
    [Freddie Gibbs], [8815],
    [A Tribe Called Quest], [948],
    [Fiona Apple], [605],
    [Lil Uzi Vert], [8553],
    [Pusha T], [943],
    [Freddie Gibbs], [585],
    [Drake], [8538],
    [Sufjan Stevens], [922],
    [JID], [585],
    [Future], [8149],
    [Gorillaz], [875],
    [A Tribe Called Quest], [475],
  ),
)

#figure(
  caption: "Alexandra's Top 10 Artists (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) { artist-cols.at("Neck Deep") } else if (
        row == 2 and col in (2, 3)
      ) { artist-cols.at("Beartooth") } else if (row == 2 and col in (4, 5)) { artist-cols.at("Beartooth") } else if (
        row == 3 and col in (0, 1)
      ) { artist-cols.at("State Champs") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("Neck Deep")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("Neck Deep") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Panic! At The Disco")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("Bring Me The Horizon") } else if (
        row == 4 and col in (4, 5)
      ) { artist-cols.at("State Champs") } else if (row == 5 and col in (0, 1)) {
        artist-cols.at("Beartooth")
      } else if (row == 5 and col in (2, 3)) { artist-cols.at("Wage War") } else if (row == 5 and col in (4, 5)) {
        artist-cols.at("Wage War")
      } else if (row == 6 and col in (0, 1)) { artist-cols.at("Bring Me The Horizon") } else if (
        row == 6 and col in (2, 3)
      ) { artist-cols.at("State Champs") } else if (row == 6 and col in (4, 5)) {
        artist-cols.at("Bring Me The Horizon")
      } else if (row == 7 and col in (0, 1)) { artist-cols.at("Fall Out Boy") } else if (row == 7 and col in (2, 3)) {
        artist-cols.at("Falling In Reverse")
      } else if (row == 7 and col in (4, 5)) { artist-cols.at("Ashnikko") } else if (row == 8 and col in (0, 1)) {
        artist-cols.at("blink-182")
      } else if (row == 8 and col in (2, 3)) { artist-cols.at("Ashnikko") } else if (row == 8 and col in (4, 5)) {
        artist-cols.at("I Prevail")
      } else if (row == 9 and col in (0, 1)) { artist-cols.at("My Chemical Romance") } else if (
        row == 9 and col in (2, 3)
      ) { artist-cols.at("Panic! At The Disco") } else if (row == 9 and col in (4, 5)) {
        artist-cols.at("Panic! At The Disco")
      } else if (row == 10 and col in (0, 1)) { artist-cols.at("mgk") } else if (row == 10 and col in (2, 3)) {
        artist-cols.at("Kim Dracula")
      } else if (row == 10 and col in (4, 5)) { artist-cols.at("WSTR") } else if (row == 11 and col in (0, 1)) {
        artist-cols.at("Wage War")
      } else if (row == 11 and col in (2, 3)) { artist-cols.at("mgk") } else if (row == 11 and col in (4, 5)) {
        artist-cols.at("mgk")
      } else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Artist*], [*Plays*],
    [*Artist*], [*Plays*],
    [*Artist*], [*Plays*],
    [Neck Deep], [9308],
    [Beartooth], [988],
    [Beartooth], [563],
    [State Champs], [8301],
    [Neck Deep], [656],
    [Neck Deep], [444],
    [Panic! At The Disco], [7117],
    [Bring Me The Horizon], [501],
    [State Champs], [385],
    [Beartooth], [5603],
    [Wage War], [442],
    [Wage War], [306],
    [Bring Me The Horizon], [4320],
    [State Champs], [408],
    [Bring Me The Horizon], [284],
    [Fall Out Boy], [3133],
    [Falling In Reverse], [339],
    [Ashnikko], [233],
    [blink-182], [2697],
    [Ashnikko], [316],
    [I Prevail], [228],
    [My Chemical Romance], [2484],
    [Panic! At The Disco], [276],
    [Panic! At The Disco], [209],
    [mgk], [2461],
    [Kim Dracula], [265],
    [WSTR], [195],
    [Wage War], [2410],
    [mgk], [258],
    [mgk], [166],
  ),
)

#figure(
  caption: "Anthony's Top 10 Artists (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (
        row == 2 and col in (2, 3)
      ) { artist-cols.at("Kanye West") } else if (row == 2 and col in (4, 5)) { artist-cols.at("Kanye West") } else if (
        row == 3 and col in (0, 1)
      ) { artist-cols.at("Drake") } else if (row == 3 and col in (2, 3)) { artist-cols.at("Future") } else if (
        row == 3 and col in (4, 5)
      ) { artist-cols.at("Playboi Carti") } else if (row == 4 and col in (0, 1)) { artist-cols.at("Future") } else if (
        row == 4 and col in (2, 3)
      ) { artist-cols.at("Kendrick Lamar") } else if (row == 4 and col in (4, 5)) { artist-cols.at("Drake") } else if (
        row == 5 and col in (0, 1)
      ) { artist-cols.at("Young Thug") } else if (row == 5 and col in (2, 3)) { artist-cols.at("Drake") } else if (
        row == 5 and col in (4, 5)
      ) { artist-cols.at("Young Thug") } else if (row == 6 and col in (0, 1)) {
        artist-cols.at("Travis Scott")
      } else if (row == 6 and col in (2, 3)) { artist-cols.at("¥$") } else if (row == 6 and col in (4, 5)) {
        artist-cols.at("Future")
      } else if (row == 7 and col in (0, 1)) { artist-cols.at("YoungBoy Never Broke Again") } else if (
        row == 7 and col in (2, 3)
      ) { artist-cols.at("Gunna") } else if (row == 7 and col in (4, 5)) { artist-cols.at("Gunna") } else if (
        row == 8 and col in (0, 1)
      ) { artist-cols.at("Kendrick Lamar") } else if (row == 8 and col in (2, 3)) {
        artist-cols.at("21 Savage")
      } else if (row == 8 and col in (4, 5)) { artist-cols.at("Kendrick Lamar") } else if (row == 9 and col in (0, 1)) {
        artist-cols.at("Playboi Carti")
      } else if (row == 9 and col in (2, 3)) { artist-cols.at("Young Thug") } else if (row == 9 and col in (4, 5)) {
        artist-cols.at("Lil Baby")
      } else if (row == 10 and col in (0, 1)) { artist-cols.at("21 Savage") } else if (row == 10 and col in (2, 3)) {
        artist-cols.at("YoungBoy Never Broke Again")
      } else if (row == 10 and col in (4, 5)) { artist-cols.at("Ken Carson") } else if (row == 11 and col in (0, 1)) {
        artist-cols.at("Juice WRLD")
      } else if (row == 11 and col in (2, 3)) { artist-cols.at("BigXthaPlug") } else if (row == 11 and col in (4, 5)) {
        artist-cols.at("21 Savage")
      } else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Artist*], [*Plays*],
    [*Artist*], [*Plays*],
    [*Artist*], [*Plays*],
    [Kanye West], [6780],
    [Kanye West], [858],
    [Kanye West], [1199],
    [Drake], [3829],
    [Future], [648],
    [Playboi Carti], [640],
    [Future], [2132],
    [Kendrick Lamar], [428],
    [Drake], [557],
    [Young Thug], [1959],
    [Drake], [426],
    [Young Thug], [511],
    [Travis Scott], [1457],
    [¥\$], [335],
    [Future], [425],
    [YoungBoy Never Broke Again], [1428],
    [Gunna], [313],
    [Gunna], [342],
    [Kendrick Lamar], [1418],
    [21 Savage], [301],
    [Kendrick Lamar], [321],
    [Playboi Carti], [1382],
    [Young Thug], [296],
    [Lil Baby], [319],
    [21 Savage], [1305],
    [YoungBoy Never Broke Again], [292],
    [Ken Carson], [317],
    [Juice WRLD], [1234],
    [BigXthaPlug], [280],
    [21 Savage], [313],
  ),
)

#figure(
  caption: "Koren's Top 10 Artists (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) {
        artist-cols.at("Lil Uzi Vert")
      } else if (row == 2 and col in (2, 3)) { artist-cols.at("Mint") } else if (row == 2 and col in (4, 5)) {
        artist-cols.at("Playboi Carti")
      } else if (row == 3 and col in (0, 1)) { artist-cols.at("Playboi Carti") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("LTJ Bukem")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("Mint") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Mint")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("Lonnie Liston Smith") } else if (
        row == 4 and col in (4, 5)
      ) { artist-cols.at("LTJ Bukem") } else if (row == 5 and col in (0, 1)) { artist-cols.at("G Herbo") } else if (
        row == 5 and col in (2, 3)
      ) { artist-cols.at("Nookie") } else if (row == 5 and col in (4, 5)) { artist-cols.at("Che") } else if (
        row == 6 and col in (0, 1)
      ) { artist-cols.at("Chief Keef") } else if (row == 6 and col in (2, 3)) { artist-cols.at("toe") } else if (
        row == 6 and col in (4, 5)
      ) { artist-cols.at("Roni Size") } else if (row == 7 and col in (0, 1)) { artist-cols.at("Cdot Honcho") } else if (
        row == 7 and col in (2, 3)
      ) { artist-cols.at("Alex Reese") } else if (row == 7 and col in (4, 5)) { artist-cols.at("tenkay") } else if (
        row == 8 and col in (0, 1)
      ) { artist-cols.at("Tee Grizzley") } else if (row == 8 and col in (2, 3)) {
        artist-cols.at("Wax Doctor")
      } else if (row == 8 and col in (4, 5)) { artist-cols.at("toe") } else if (row == 9 and col in (0, 1)) {
        artist-cols.at("Travis Scott")
      } else if (row == 9 and col in (2, 3)) { artist-cols.at("Roni Size") } else if (row == 9 and col in (4, 5)) {
        artist-cols.at("Nookie")
      } else if (row == 10 and col in (0, 1)) { artist-cols.at("Pi'erre Bourne") } else if (
        row == 10 and col in (2, 3)
      ) { artist-cols.at("Big Bud") } else if (row == 10 and col in (4, 5)) { artist-cols.at("Lil Uzi Vert") } else if (
        row == 11 and col in (0, 1)
      ) { artist-cols.at("Future") } else if (row == 11 and col in (2, 3)) { artist-cols.at("Hidden Agenda") } else if (
        row == 11 and col in (4, 5)
      ) { artist-cols.at("OsamaSon") } else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Artist*], [*Plays*],
    [*Artist*], [*Plays*],
    [*Artist*], [*Plays*],
    [Lil Uzi Vert], [5764],
    [Mint], [764],
    [Playboi Carti], [1071],
    [Playboi Carti], [4323],
    [LTJ Bukem], [523],
    [Mint], [463],
    [Mint], [4034],
    [Lonnie Liston Smith], [325],
    [LTJ Bukem], [300],
    [G Herbo], [2820],
    [Nookie], [267],
    [Che], [290],
    [Chief Keef], [2732],
    [toe], [241],
    [Roni Size], [279],
    [Cdot Honcho], [2654],
    [Alex Reece], [231],
    [tenkay], [255],
    [Tee Grizzley], [2000],
    [Wax Doctor], [187],
    [toe], [219],
    [Travis Scott], [1807],
    [Roni Size], [186],
    [Nookie], [203],
    [Pi'erre Bourne], [1789],
    [Big Bud], [165],
    [Lil Uzi Vert], [183],
    [Future], [1642],
    [Hidden Agenda], [162],
    [OsamaSon], [181],
  ),
)

=== Top Albums

Album-level rankings surface how listening volume is distributed across a user's full discography, and whether their top tracks cluster within a handful of records or spread across a wide catalog.

#figure(
  caption: "Alan's Top 10 Albums (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (
        row == 2 and col in (2, 3)
      ) { artist-cols.at("The Roots") } else if (row == 2 and col in (4, 5)) { artist-cols.at("Jessie Ware") } else if (
        row == 3 and col in (0, 1)
      ) { artist-cols.at("Kanye West") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("Freddie Gibbs")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("Denzel Curry") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Travis Scott")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("J Dilla") } else if (row == 4 and col in (4, 5)) {
        artist-cols.at("JPEGMAFIA")
      } else if (row == 5 and col in (0, 1)) { artist-cols.at("Travis Scott") } else if (row == 5 and col in (2, 3)) {
        artist-cols.at("Kanye West")
      } else if (row == 5 and col in (4, 5)) { artist-cols.at("underscores") } else if (row == 6 and col in (0, 1)) {
        artist-cols.at("Playboi Carti")
      } else if (row == 6 and col in (2, 3)) { artist-cols.at("Denzel Curry") } else if (row == 6 and col in (4, 5)) {
        artist-cols.at("JPEGMAFIA")
      } else if (row == 7 and col in (0, 1)) { artist-cols.at("Juice WRLD") } else if (row == 7 and col in (2, 3)) {
        artist-cols.at("Danny Brown")
      } else if (row == 7 and col in (4, 5)) { artist-cols.at("Lianne La Havas") } else if (
        row == 8 and col in (0, 1)
      ) { artist-cols.at("Kanye West") } else if (row == 8 and col in (2, 3)) {
        artist-cols.at("Kendrick Lamar")
      } else if (row == 8 and col in (4, 5)) { artist-cols.at("The Avalanches") } else if (row == 9 and col in (0, 1)) {
        artist-cols.at("Kendrick Lamar")
      } else if (row == 9 and col in (2, 3)) { artist-cols.at("Black Star") } else if (row == 9 and col in (4, 5)) {
        artist-cols.at("Mos Def")
      } else if (row == 10 and col in (0, 1)) { artist-cols.at("KIDS SEE GHOSTS") } else if (
        row == 10 and col in (2, 3)
      ) { artist-cols.at("Danny Brown") } else if (row == 10 and col in (4, 5)) {
        artist-cols.at("Big K.R.I.T.")
      } else if (row == 11 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (row == 11 and col in (2, 3)) {
        artist-cols.at("The Pharcyde")
      } else if (row == 11 and col in (4, 5)) { artist-cols.at("Danny Brown") } else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Album*], [*Plays*],
    [*Album*], [*Plays*],
    [*Album*], [*Plays*],
    [The Life Of Pablo], [8732],
    [Undun], [687],
    [What's Your Pleasure?], [677],
    [My Beautiful...Fantasy], [8265],
    [Piñata], [677],
    [Melt My Eyez See Your Future], [453],
    [Rodeo], [7932],
    [Donuts], [669],
    [I LAY DOWN MY LIFE FOR YOU], [372],
    [ASTROWORLD], [7676],
    [Late Registration], [665],
    [Wallsocket], [359],
    [Die Lit], [6645],
    [Melt My Eyez See Your Future], [652],
    [I LAY DOWN MY LIFE FOR YOU], [356],
    [Goodbye & Good Riddance], [6565],
    [Atrocity Exhibition], [639],
    [Lianne La Havas], [334],
    [Late Registration], [6071],
    [To Pimp A Butterfly], [589],
    [Since I Left You], [331],
    [good kid, m.A.A.d city], [5443],
    [Mos Def...Black Star], [567],
    [Black On Both Sides], [299],
    [KIDS SEE GHOSTS], [5086],
    [XXX (Deluxe Version)], [550],
    [4eva Is A Mighty Long Time], [298],
    [The College Dropout], [4976],
    [Bizarre Ride II The Pharcyde], [528],
    [Atrocity Exhibition], [287],
  ),
)

#figure(
  caption: "Alexandra's Top 10 Albums (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) { artist-cols.at("Neck Deep") } else if (
        row == 2 and col in (2, 3)
      ) { artist-cols.at("Beartooth") } else if (row == 2 and col in (4, 5)) { artist-cols.at("Beartooth") } else if (
        row == 3 and col in (0, 1)
      ) { artist-cols.at("Panic! At The Disco") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("Bring Me The Horizon")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("Palisades") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Neck Deep")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("Neck Deep") } else if (row == 4 and col in (4, 5)) {
        artist-cols.at("I Prevail")
      } else if (row == 5 and col in (0, 1)) { artist-cols.at("mgk") } else if (row == 5 and col in (2, 3)) {
        artist-cols.at("Beartooth")
      } else if (row == 5 and col in (4, 5)) { artist-cols.at("Beartooth") } else if (row == 6 and col in (0, 1)) {
        artist-cols.at("Neck Deep")
      } else if (row == 6 and col in (2, 3)) { artist-cols.at("Kim Dracula") } else if (row == 6 and col in (4, 5)) {
        artist-cols.at("Beartooth")
      } else if (row == 7 and col in (0, 1)) { artist-cols.at("State Champs") } else if (row == 7 and col in (2, 3)) {
        artist-cols.at("Beartooth")
      } else if (row == 7 and col in (4, 5)) { artist-cols.at("State Champs") } else if (row == 8 and col in (0, 1)) {
        artist-cols.at("State Champs")
      } else if (row == 8 and col in (2, 3)) { artist-cols.at("I Prevail") } else if (row == 8 and col in (4, 5)) {
        artist-cols.at("mgk")
      } else if (row == 9 and col in (0, 1)) { artist-cols.at("State Champs") } else if (row == 9 and col in (2, 3)) {
        artist-cols.at("mgk")
      } else if (row == 9 and col in (4, 5)) { artist-cols.at("Bring Me The Horizon") } else if (
        row == 10 and col in (0, 1)
      ) { artist-cols.at("Panic! At The Disco") } else if (row == 10 and col in (2, 3)) {
        artist-cols.at("Beartooth")
      } else if (row == 10 and col in (4, 5)) { artist-cols.at("Beartooth") } else if (row == 11 and col in (0, 1)) {
        artist-cols.at("Panic! At The Disco")
      } else if (row == 11 and col in (2, 3)) { artist-cols.at("Diamond Construct") } else if (
        row == 11 and col in (4, 5)
      ) { artist-cols.at("Neck Deep") } else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Album*], [*Plays*],
    [*Album*], [*Plays*],
    [*Album*], [*Plays*],
    [Life's Not Out To Get You], [1767],
    [The Surface], [322],
    [The Surface], [160],
    [Death of a Bachelor], [1584],
    [POST HUMAN: NeX GEn], [195],
    [Erase The Pain], [119],
    [Wishful Thinking], [1580],
    [Neck Deep], [169],
    [TRUE POWER], [116],
    [Tickets To My Downfall], [1533],
    [Below], [166],
    [Below], [112],
    [The Peace And The Panic], [1520],
    [A Gradual Decline In Morale], [166],
    [Aggressive], [107],
    [Around the World and Back], [1488],
    [Aggressive], [152],
    [Kings of the New Age], [83],
    [The Finer Things], [1454],
    [TRUE POWER], [135],
    [Tickets To My Downfall], [81],
    [Around the World and Back], [1305],
    [Tickets To My Downfall], [129],
    [POST HUMAN: NeX GEn], [80],
    [Too Weird to Live, Too Rare to Die!], [1282],
    [Disease (Deluxe Edition)], [125],
    [Disease (Deluxe Edition)], [79],
    [Vices & Virtues], [1254],
    [Angel Killer Zero], [119],
    [Neck Deep], [75],
  ),
)

#figure(
  caption: "Anthony's Top 10 Albums (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (
        row == 2 and col in (2, 3)
      ) { artist-cols.at("Kendrick Lamar") } else if (row == 2 and col in (4, 5)) {
        artist-cols.at("Playboi Carti")
      } else if (row == 3 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("Future")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("Kanye West") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Kanye West")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("¥$") } else if (row == 4 and col in (4, 5)) {
        artist-cols.at("Kanye West")
      } else if (row == 5 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (row == 5 and col in (2, 3)) {
        artist-cols.at("Kanye West")
      } else if (row == 5 and col in (4, 5)) { artist-cols.at("Kanye West") } else if (row == 6 and col in (0, 1)) {
        artist-cols.at("Drake")
      } else if (row == 6 and col in (2, 3)) { artist-cols.at("21 Savage") } else if (row == 6 and col in (4, 5)) {
        artist-cols.at("Young Thug")
      } else if (row == 7 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (row == 7 and col in (2, 3)) {
        artist-cols.at("Future")
      } else if (row == 7 and col in (4, 5)) { artist-cols.at("Kanye West") } else if (row == 8 and col in (0, 1)) {
        artist-cols.at("JAY-Z")
      } else if (row == 8 and col in (2, 3)) { artist-cols.at("Kanye West") } else if (row == 8 and col in (4, 5)) {
        artist-cols.at("Ken Carson")
      } else if (row == 9 and col in (0, 1)) { artist-cols.at("Kanye West") } else if (row == 9 and col in (2, 3)) {
        artist-cols.at("Gunna")
      } else if (row == 9 and col in (4, 5)) { artist-cols.at("Kendrick Lamar") } else if (
        row == 10 and col in (0, 1)
      ) { artist-cols.at("Juice WRLD") } else if (row == 10 and col in (2, 3)) {
        artist-cols.at("Kanye West")
      } else if (row == 10 and col in (4, 5)) { artist-cols.at("Drake") } else if (row == 11 and col in (0, 1)) {
        artist-cols.at("21 Savage")
      } else if (row == 11 and col in (2, 3)) { artist-cols.at("BigXthaPlug") } else if (row == 11 and col in (4, 5)) {
        artist-cols.at("Young Thug")
      } else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Album*], [*Plays*],
    [*Album*], [*Plays*],
    [*Album*], [*Plays*],
    [Graduation], [1240],
    [GNX], [274],
    [MUSIC], [385],
    [My Beautiful...Fantasy], [1051],
    [WE DON'T TRUST YOU], [256],
    [Graduation], [266],
    [Donda], [1022],
    [VULTURES 1], [219],
    [My Beautiful...Fantasy], [250],
    [The Life Of Pablo], [929],
    [Graduation], [209],
    [Yeezus], [184],
    [Take Care], [638],
    [american dream], [146],
    [Slime Season], [161],
    [Yeezus], [546],
    [MIXTAPE PLUTO], [131],
    [The Life Of Pablo], [156],
    [Watch The Throne], [478],
    [My Beautiful...Fantasy], [121],
    [A Great Chaos], [141],
    [The College Dropout], [454],
    [One of Wun], [107],
    [GNX], [120],
    [Death Race For Love], [444],
    [The Life Of Pablo], [104],
    [Take Care], [113],
    [i am > i was], [405],
    [TAKE CARE], [103],
    [UY SCUTI], [112],
  ),
)

#figure(
  caption: "Koren's Top 10 Albums (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row == 0 { gray.lighten(80%) } else if (row == 2 and col in (0, 1)) {
        artist-cols.at("Playboi Carti")
      } else if (row == 2 and col in (2, 3)) { artist-cols.at("Mint") } else if (row == 2 and col in (4, 5)) {
        artist-cols.at("Playboi Carti")
      } else if (row == 3 and col in (0, 1)) { artist-cols.at("Playboi Carti") } else if (row == 3 and col in (2, 3)) {
        artist-cols.at("Mint")
      } else if (row == 3 and col in (4, 5)) { artist-cols.at("Playboi Carti") } else if (row == 4 and col in (0, 1)) {
        artist-cols.at("Tay-K")
      } else if (row == 4 and col in (2, 3)) { artist-cols.at("LTJ Bukem") } else if (row == 4 and col in (4, 5)) {
        artist-cols.at("Mint")
      } else if (row == 5 and col in (0, 1)) { artist-cols.at("Lil Uzi Vert") } else if (row == 5 and col in (2, 3)) {
        artist-cols.at("Wax Doctor")
      } else if (row == 5 and col in (4, 5)) { artist-cols.at("Roni Size") } else if (row == 6 and col in (0, 1)) {
        artist-cols.at("Lil Uzi Vert")
      } else if (row == 6 and col in (2, 3)) { artist-cols.at("LTJ Bukem") } else if (row == 6 and col in (4, 5)) {
        artist-cols.at("Mint")
      } else if (row == 7 and col in (0, 1)) { artist-cols.at("Cdot Honcho") } else if (row == 7 and col in (2, 3)) {
        artist-cols.at("toe")
      } else if (row == 7 and col in (4, 5)) { artist-cols.at("Che") } else if (row == 8 and col in (0, 1)) {
        artist-cols.at("Cdot Honcho")
      } else if (row == 8 and col in (2, 3)) { artist-cols.at("Lonnie Liston Smith") } else if (
        row == 8 and col in (4, 5)
      ) { artist-cols.at("LTJ Bukem") } else if (row == 9 and col in (0, 1)) {
        artist-cols.at("Lil Uzi Vert")
      } else if (row == 9 and col in (2, 3)) { artist-cols.at("Hidden Agenda") } else if (row == 9 and col in (4, 5)) {
        artist-cols.at("Wax Doctor")
      } else if (row == 10 and col in (0, 1)) { artist-cols.at("Duwap Kaine") } else if (row == 10 and col in (2, 3)) {
        artist-cols.at("PFM")
      } else if (row == 10 and col in (4, 5)) { artist-cols.at("Nuito") } else if (row == 11 and col in (0, 1)) {
        artist-cols.at("Pi'erre Bourne")
      } else if (row == 11 and col in (2, 3)) { artist-cols.at("Roni Size") } else if (row == 11 and col in (4, 5)) {
        artist-cols.at("J Majik")
      } else { white }
    },
    table.cell(colspan: 2, align: center)[*All-Time*],
    table.cell(colspan: 2, align: center)[*2024*],
    table.cell(colspan: 2, align: center)[*2025*],
    [*Album*], [*Plays*],
    [*Album*], [*Plays*],
    [*Album*], [*Plays*],
    [Playboi Carti], [1491],
    [Selected Jungle Works], [419],
    [MUSIC - SORRY 4 DA WAIT], [584],
    [Die Lit], [1346],
    [Atmospheric Intelligence], [215],
    [MUSIC], [307],
    [\#SantanaWorld (+)], [1165],
    [Producer 01], [188],
    [Selected Jungle Works], [258],
    [Luv Is Rage], [1155],
    [Selected Works 94-96], [187],
    [New Forms], [211],
    [Lil Uzi Vert vs. The World], [1064],
    [Producer 05], [161],
    [Atmospheric Intelligence], [177],
    [H3], [1020],
    [the book about my...vague anxiety], [126],
    [REST IN BASS], [160],
    [Takeover], [1008],
    [Visions of a New World], [105],
    [Producer 01], [109],
    [Luv Is Rage 2], [965],
    [On the Roof / The Flute Tune], [101],
    [Selected Works 94-96], [93],
    [Underdog], [961],
    [Producer 02], [88],
    [Unutella], [93],
    [The Life Of Pi'erre 4], [887],
    [New Forms], [86],
    [Slow Motion], [90],
  ),
)

#let col-swatch = name => { rect(fill: artist-cols.at(name), height: 0.8em, width: 2.8em) }

#box(breakable: true, title: "Artist Colors Key", [
  #align(center, table(
    columns: 6,
    align: left,
    [*Artist*], [*Color*], [*Artist*], [*Color*], [*Artist*], [*Color*],
    [Kanye West],
    [#col-swatch("Kanye West")],
    [Beartooth],
    [#col-swatch("Beartooth")],
    [Playboi Carti],
    [#col-swatch("Playboi Carti")],

    [Neck Deep],
    [#col-swatch("Neck Deep")],
    [Kendrick Lamar],
    [#col-swatch("Kendrick Lamar")],
    [Panic! At The Disco],
    [#col-swatch("Panic! At The Disco")],

    [Future],
    [#col-swatch("Future")],
    [Denzel Curry],
    [#col-swatch("Denzel Curry")],
    [State Champs],
    [#col-swatch("State Champs")],

    [Lil Uzi Vert],
    [#col-swatch("Lil Uzi Vert")],
    [Jessie Ware],
    [#col-swatch("Jessie Ware")],
    [Drake],
    [#col-swatch("Drake")],

    [Mint],
    [#col-swatch("Mint")],
    [Travis Scott],
    [#col-swatch("Travis Scott")],
    [21 Savage],
    [#col-swatch("21 Savage")],

    [Ken Carson], [#col-swatch("Ken Carson")], [Roni Size], [#col-swatch("Roni Size")], [mgk], [#col-swatch("mgk")],
    [JPEGMAFIA],
    [#col-swatch("JPEGMAFIA")],
    [Juice WRLD],
    [#col-swatch("Juice WRLD")],
    [Cdot Honcho],
    [#col-swatch("Cdot Honcho")],

    [Danny Brown],
    [#col-swatch("Danny Brown")],
    [Bring Me The Horizon],
    [#col-swatch("Bring Me The Horizon")],
    [Young Thug],
    [#col-swatch("Young Thug")],

    [LTJ Bukem],
    [#col-swatch("LTJ Bukem")],
    [Falling In Reverse],
    [#col-swatch("Falling In Reverse")],
    [I Prevail],
    [#col-swatch("I Prevail")],

    [Gunna], [#col-swatch("Gunna")], [¥\$], [#col-swatch("¥$")], [Hidden Agenda], [#col-swatch("Hidden Agenda")],
    [Nookie],
    [#col-swatch("Nookie")],
    [Freddie Gibbs],
    [#col-swatch("Freddie Gibbs")],
    [KIDS SEE GHOSTS],
    [#col-swatch("KIDS SEE GHOSTS")],

    [The Roots],
    [#col-swatch("The Roots")],
    [Pusha T],
    [#col-swatch("Pusha T")],
    [Tee Grizzley],
    [#col-swatch("Tee Grizzley")],

    [A Tribe Called Quest],
    [#col-swatch("A Tribe Called Quest")],
    [Wage War],
    [#col-swatch("Wage War")],
    [toe],
    [#col-swatch("toe")],

    [Wax Doctor],
    [#col-swatch("Wax Doctor")],
    [Lianne La Havas],
    [#col-swatch("Lianne La Havas")],
    [Black Star],
    [#col-swatch("Black Star")],

    [underscores],
    [#col-swatch("underscores")],
    [Fall Out Boy],
    [#col-swatch("Fall Out Boy")],
    [Palisades],
    [#col-swatch("Palisades")],

    [Lil Baby],
    [#col-swatch("Lil Baby")],
    [Tom & Jerry],
    [#col-swatch("Tom & Jerry")],
    [Remarc],
    [#col-swatch("Remarc")],

    [SOB X RBE],
    [#col-swatch("SOB X RBE")],
    [Duwap Kaine],
    [#col-swatch("Duwap Kaine")],
    [J Majik],
    [#col-swatch("J Majik")],

    [Ashnikko],
    [#col-swatch("Ashnikko")],
    [Kim Dracula],
    [#col-swatch("Kim Dracula")],
    [YoungBoy Never Broke Again],
    [#col-swatch("YoungBoy Never Broke Again")],

    [BigXthaPlug],
    [#col-swatch("BigXthaPlug")],
    [Lonnie Liston Smith],
    [#col-swatch("Lonnie Liston Smith")],
    [Che],
    [#col-swatch("Che")],

    [Pi'erre Bourne],
    [#col-swatch("Pi'erre Bourne")],
    [Earl Sweatshirt],
    [#col-swatch("Earl Sweatshirt")],
    [DANGERDOOM],
    [#col-swatch("DANGERDOOM")],

    [Fleet Foxes],
    [#col-swatch("Fleet Foxes")],
    [MGMT],
    [#col-swatch("MGMT")],
    [Lupe Fiasco],
    [#col-swatch("Lupe Fiasco")],

    [Anderson .Paak],
    [#col-swatch("Anderson .Paak")],
    [Hozier],
    [#col-swatch("Hozier")],
    [Sleep Theory],
    [#col-swatch("Sleep Theory")],

    [Neon Trees],
    [#col-swatch("Neon Trees")],
    [Woe, Is Me],
    [#col-swatch("Woe, Is Me")],
    [Silverstein],
    [#col-swatch("Silverstein")],

    [Rivals],
    [#col-swatch("Rivals")],
    [Don Toliver],
    [#col-swatch("Don Toliver")],
    [Roddy Ricch],
    [#col-swatch("Roddy Ricch")],

    [A\$AP Rocky],
    [#col-swatch("A$AP Rocky")],
    [Luh Tyler],
    [#col-swatch("Luh Tyler")],
    [Kodak Black],
    [#col-swatch("Kodak Black")],

    [A Boogie Wit da Hoodie],
    [#col-swatch("A Boogie Wit da Hoodie")],
    [Trippie Redd],
    [#col-swatch("Trippie Redd")],
    [Fountains Of Wayne],
    [#col-swatch("Fountains Of Wayne")],

    [Origin Unknown],
    [#col-swatch("Origin Unknown")],
    [ark762],
    [#col-swatch("ark762")],
    [Total Science],
    [#col-swatch("Total Science")],

    [JMJ],
    [#col-swatch("JMJ")],
    [Benji Blue Bills],
    [#col-swatch("Benji Blue Bills")],
    [Cutty Ranks],
    [#col-swatch("Cutty Ranks")],

    [Fiona Apple],
    [#col-swatch("Fiona Apple")],
    [Sufjan Stevens],
    [#col-swatch("Sufjan Stevens")],
    [JID],
    [#col-swatch("JID")],

    [Gorillaz],
    [#col-swatch("Gorillaz")],
    [blink-182],
    [#col-swatch("blink-182")],
    [My Chemical Romance],
    [#col-swatch("My Chemical Romance")],

    [WSTR], [#col-swatch("WSTR")], [G Herbo], [#col-swatch("G Herbo")], [Chief Keef], [#col-swatch("Chief Keef")],
    [Alex Reese], [#col-swatch("Alex Reese")], [tenkay], [#col-swatch("tenkay")], [Big Bud], [#col-swatch("Big Bud")],
    [OsamaSon],
    [#col-swatch("OsamaSon")],
    [J Dilla],
    [#col-swatch("J Dilla")],
    [The Avalanches],
    [#col-swatch("The Avalanches")],

    [Mos Def],
    [#col-swatch("Mos Def")],
    [Big K.R.I.T.],
    [#col-swatch("Big K.R.I.T.")],
    [The Pharcyde],
    [#col-swatch("The Pharcyde")],

    [Diamond Construct],
    [#col-swatch("Diamond Construct")],
    [JAY-Z],
    [#col-swatch("JAY-Z")],
    [Tay-K],
    [#col-swatch("Tay-K")],

    [PFM], [#col-swatch("PFM")], [Nuito], [#col-swatch("Nuito")],
  ))
])

=== Analysis

The most striking feature across all users is the sheer magnitude of repeat plays at the top. Alan's all-time #1 track, "4th Dimension" by KIDS SEE GHOSTS, has 1,371 plays, over 22 hours of a single track. His top 10 all-time tracks are almost entirely Kanye West and Kanye-adjacent: KIDS SEE GHOSTS is a Kanye/Kid Cudi collab, and six of the ten are direct Kanye records. This extreme concentration mirrors his all-time #1 artist: Kanye West at 43,739 plays, roughly 9.7% of his entire listening history. In 2024, Alan's top track is "I Remember" by The Roots (122 plays), a completely different artist than his all-time #1, indicating his 2024 listening already showed diversification from the Kanye core. By 2025, his entire top 10 is Jessie Ware-dominated: she holds 6 of the 10 spots, which ties directly to the monthly top artist chart showing Jessie Ware as his January and May 2025 leader.

Alexandra's listening profile is similarly concentrated but within a different genre. Her all-time #1 track "Sugar, We're Goin Down" (237 plays) and the surrounding top 10 (Neck Deep, Panic! at the Disco, Neon Trees) represent a tight pop-punk/alt-rock catalog she has maintained for years. Her top artist list is correspondingly stable: Neck Deep (9,308), State Champs (8,301), Panic! at the Disco (7,117) hold the top three all-time, and Beartooth is her #1 in both 2024 and 2025. The shift between 2024 and 2025 is minimal: she's not discovering new genres, just redistributing plays within the same artists.

Anthony's all-time list spans more artists (21 Savage, Kanye West, A\$AP Rocky, Lil Baby), but rap dominates entirely. His top track ("ball w/o you" by 21 Savage, 234 plays) is far below Alan's peak counts, consistent with his lower total volume. What's notable in Anthony's 2025 top 10 tracks is the emergence of Ken Carson: three of his top 10 tracks are from Ken Carson, who appears nowhere in his all-time top 10. This is direct evidence of new artist discovery in 2025, consistent with his high new-play rate (13%) from the Repeat vs. New analysis. His Kanye plays actually increased from 2024 to 2025 (858 to 1,199) while his total play count grew only modestly, meaning his Kanye listening became more concentrated, not less.

Koren's lists are the most eclectic across all three windows. His all-time #1 track is "Honcho Style 3" by Cdot Honcho (297 plays), and the list spans drill rap, jungle/drum and bass, and classic hip-hop. His 2024 top artist is Mint (764 plays), a drum and bass artist that none of the other three users have in their charts at all. By 2025, Playboi Carti jumps to #1 (1,071 plays), a significant increase relative to 2024 where Carti doesn't appear in Koren's top 10. This shift suggests Koren's 2025 listening moved toward mainstream trap while retaining his DnB secondary catalog (LTJ Bukem, Roni Size, and Nookie still appear across all three windows).

=== Methodology

Queries against `listening_history` used `COUNT(*) GROUP BY track_name, artist_name ORDER BY COUNT(*) DESC LIMIT 10` for tracks, and equivalent queries for artists and albums, filtered by `username` and optionally by year via `EXTRACT(year FROM timestamp)`. Artist name color assignments are fixed globally across all tables, allowing visual cross-referencing between track, artist, and album tables across time periods.

== Total Listening Times vs. Play Counts

Total listening time and raw play count are complementary but distinct metrics: a user with fewer plays could still accumulate more hours if they consistently finish their tracks. The ratio of minutes-per-play directly reflects skip behavior and listening intent, making it a useful complement to the Bool Flags analysis.

#figure(
  caption: "Total Listening Times vs. Play Counts for Each User (All-Time, 2024, 2025)",
  grid(
    image("../data/total_listening/plots/total_listening_alltime.png"),
    image("../data/total_listening/plots/total_listening_2024.png"),
    image("../data/total_listening/plots/total_listening_2025.png"),
  ),
)

#figure(
  caption: "Total Listening Times vs. Play Counts for Each User (All-Time, 2024, 2025)",
  table(
    columns: 4,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 4, align: center)[*All-Time*],
    [], [*Play Count*], [*Minutes*], [*Hours*],
    [*Alan*], [450283], [443300.79], [7388.35],
    [*Alexandra*], [139541], [292826.91], [4880.45],
    [*Anthony*], [72483], [111125.20], [1852.09],
    [*Koren*], [181858], [218405.78], [3640.10],
    table.cell(colspan: 4, align: center)[*2024*],
    [*Alan*], [57042], [77082.03], [1284.70],
    [*Alexandra*], [12369], [27288.73], [454.81],
    [*Anthony*], [11713], [18974.18], [316.24],
    [*Koren*], [14706], [37464.72], [624.41],
    table.cell(colspan: 4, align: center)[*2025*],
    [*Alan*], [29418], [45544.53], [759.08],
    [*Alexandra*], [8712], [20827.66], [347.13],
    [*Anthony*], [13706], [33247.98], [554.13],
    [*Koren*], [17160], [42747.47], [712.46],
  ),
)

=== Analysis

Alan has by far the most plays all-time (450,283) and the most total hours (7,388). But his minutes-per-play ratio is approximately 0.98 minutes, less than a full minute per play event on average and the lowest of any user. Alexandra, by contrast, accumulates 4,880 hours from only 139,541 plays, giving a ratio of roughly 2.10 minutes per play. Anthony (\~1.53 min/play all-time) and Koren (\~1.20 min/play) fall between these extremes.

Alexandra's high ratio directly reflects her listening style. Her 54% `trackdone` rate (tracks that play to completion) means she regularly finishes songs rather than skipping. Alan's `trackdone` rate is just 10%, dominated instead by `fwdbtn` (55.5%). Many of his 450,000 play events are partial listens, which is why his hours-per-play is so low despite leading in raw volume. This makes Alan's total play count somewhat inflated as a measure of actual music consumed relative to Alexandra or Koren.

In 2025, the ratios shift noticeably. Anthony's minutes-per-play goes from roughly 1.62 in 2024 to 2.43 in 2025, while his play count grew only 17% (11,713 to 13,706). His total hours jumped 75% (316 to 554). This is a substantial behavioral shift: Anthony in 2025 listens through far more of each track, corroborated by his `trackdone` rate rising to 64.6% in 2025 from 41.0% in 2024. Koren shows a similar effect (712 hours from 17,160 plays, \~2.49 min/play in 2025). Alan's 2025 play count (29,418) is nearly half his 2024 count (57,042), but his ratio also improved (\~1.55 vs \~1.35 min/play), consistent with his shift from `fwdbtn`-dominant to more `clickrow` and `trackdone` behavior visible in the start reason data.

=== Methodology

Total minutes were computed by summing `ms_played` per user (and year), converted from milliseconds using `SUM(ms_played) / 60000.0`. Hours are minutes divided by 60. The `ms_played` field reflects actual audio duration consumed per event (not full track length), so partial plays correctly contribute shorter values. The bar chart renders both play count and total minutes on the same y-axis, making the ratio difference between users visually apparent.

== Events Over Time

Tracking listening events over time reveals macro-level trends, seasonal patterns, and major life events (such as COVID-19 lockdowns) that shaped each user's relationship with music. Daily resolution captures short-term bursts; monthly aggregation reveals sustained shifts.

=== Daily Listening Events

#figure(
  caption: "Daily Listening Events Over Time for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    row-gutter: 1em,
    image("../data/events_over_time/plots/events_over_time_alltime.png", width: 100%),
    image("../data/events_over_time/plots/events_over_time_2024.png", width: 100%),
    image("../data/events_over_time/plots/events_over_time_2025.png", width: 100%),
  ),
)

=== Monthly Plays

Monthly aggregation smooths day-to-day noise and makes seasonal trends easier to identify, particularly for comparing users whose peak days occur at different times.

#figure(
  caption: "Monthly Plays for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    row-gutter: 1em,
    image("../data/monthly_plays/plots/monthly_plays_alltime.png", width: 100%),
    image("../data/monthly_plays/plots/monthly_plays_2024.png", width: 100%),
    image("../data/monthly_plays/plots/monthly_plays_2025.png", width: 100%),
  ),
)

=== Analysis

The all-time plot is dominated by Alan's listening, which shows a massive spike in early 2020 through mid-2021. His peak reaches approximately 15,000+ daily events in a single month (around March-April 2021), almost certainly driven by the COVID-19 lockdown. At that peak, Alan's listening volume is at a level he has never replicated since: post-2021 monthly values consistently fall below 5,000. This suggests lockdown produced an extraordinary amount of passive background listening. After 2021, all users show a general declining trend through 2022-2023 followed by a partial recovery.

In 2025, all four users share a sharp peak in March. Alan hits roughly 4,300 events in March, Koren peaks at approximately 4,100, the highest month for both users all year. Both drop sharply in April: Alan falls to around 1,100, Koren to roughly 2,050. The synchronization across users is notable and suggests either an external event (a major album release, the start of a semester) or a consistent seasonal behavior. Anthony peaks slightly later (around 2,300 in March-April combined) before hitting his clear trough in September (\~300 events), the lowest single-month for any user in 2025. Alexandra is consistently the most stable and lowest, staying in the 600-1,000 range most of the year.

By late 2025, Alan recovers to \~3,200 in November before dipping in December. The convergence of all four users to a narrower range in Q3-Q4 (roughly 500-2,000 events/month) contrasts with the wide divergence in Q1, where Alan and Koren were 4-6x higher than Alexandra.

=== Methodology

Daily play counts were computed using `COUNT(*) GROUP BY DATE(timestamp), username`. For the all-time and 2024 views, these were further aggregated monthly with `DATE_TRUNC('month', timestamp)`. The 2025 plot uses monthly resolution directly. Time series for each user are plotted as lines with points, using consistent user-color assignments across all views.

== Distributions

Distribution analysis characterizes the shape, spread, and central tendency of five key variables: daily play counts, plays per track, plays per artist, plays per album, and session length. For each, we examine histograms, log-scale box plots, and summary statistics to assess skewness, outlier extent, and the degree to which extreme values dominate over typical behavior.

=== Daily Play Count

Daily play count measures how many tracks each user listened to on a given day, capturing engagement intensity over time.

#figure(
  caption: "Distribution of Daily Play Counts for Each User (All-Time, 2024, 2025)",
  table(
    columns: 8,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 8, align: center)[*All-Time*],
    [], [*Mean*], [*Median*], [*Mode*], [*Range*], [*Standard Deviation*], [*Variance*], [*Skewness*],
    [*Alan*], [156.57], [123.00], [1.00], [1276.00], [144.12], [20771.13], [1.87],
    [*Alexandra*], [39.78], [29.00], [12.00], [235.00], [34.62], [1198.52], [1.71],
    [*Anthony*], [58.08], [33.00], [1.00], [848.00], [73.25], [5365.18], [3.17],
    [*Koren*], [63.92], [40.00], [1.00], [1084.00], [74.14], [5496.12], [2.91],
    table.cell(colspan: 8, align: center)[*2024*],
    [*Alan*], [160.68], [148.00], [165.00], [676.00], [105.76], [11184.63], [1.02],
    [*Alexandra*], [34.26], [29.00], [9.00], [224.00], [27.36], [748.46], [2.49],
    [*Anthony*], [42.13], [27.00], [1.00], [263.00], [43.09], [1856.87], [1.89],
    [*Koren*], [43.38], [32.00], [1.00], [277.00], [41.99], [1763.30], [2.10],
    table.cell(colspan: 8, align: center)[*2025*],
    [*Alan*], [54.82], [75.50], [2.00], [596.00], [71.52], [5115.28], [1.91],
    [*Alexandra*], [24.47], [19.50], [12.00], [127.00], [17.56], [308.41], [1.74],
    [*Anthony*], [45.38], [28.50], [6.00], [314.00], [51.83], [2686.58], [2.43],
    [*Koren*], [54.82], [34.00], [1.00], [379.00], [60.89], [3707.91], [1.91],
  ),
)

#figure(
  caption: "Box Plots of Daily Play Counts for Each User (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_daily_play_count_alltime.png"),
      image("../data/distributions/plots/boxplot_daily_play_count_alltime_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [48], [222.25], [1277], [174.25], [-213.375], [483.625],
      [Alexandra], [1], [15], [53], [236], [38], [-42], [110],
      [Anthony], [1], [12], [75], [849], [63], [-82.5], [169.5],
      [Koren], [1], [14], [88], [1085], [74], [-97], [199],
    ))
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_daily_play_count_2024.png"),
      image("../data/distributions/plots/boxplot_daily_play_count_2024_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [81], [220], [677], [139], [-127.5], [428.5],
      [Alexandra], [1], [16], [44], [225], [28], [-26], [86],
      [Anthony], [1], [11.25], [57.75], [264], [46.5], [-58.5], [127.5],
      [Koren], [1], [13], [60.5], [278], [47.5], [-58.25], [131.75],
    ))
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_daily_play_count_2025.png"),
      image("../data/distributions/plots/boxplot_daily_play_count_2025_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [31], [123.75], [597], [92.75], [-108.125], [262.875],
      [Alexandra], [1], [12], [32], [128], [20], [-18], [62],
      [Anthony], [1], [11], [59.75], [315], [48.75], [-62.125], [132.875],
      [Koren], [1], [9], [76], [380], [67], [-91.5], [176.5],
    ))
  ],
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
  ],
)

=== Plays Per Track

Plays per track measures how many total plays each unique track accumulates over the analysis window. High skewness here means a small number of tracks are played obsessively while most are played once or twice.

#figure(
  caption: "Distribution of Plays per Track for Each User (All-Time, 2024, 2025)",
  table(
    columns: 8,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 8, align: center)[*All-Time*],
    [], [*Mean*], [*Median*], [*Mode*], [*Range*], [*Standard Deviation*], [*Variance*], [*Skewness*],
    [*Alan*], [47.52], [5.00], [2.00], [1370.00], [119.01], [14164.13], [4.16],
    [*Alexandra*], [32.20], [20.00], [2.00], [262.00], [37.28], [1389.89], [1.75],
    [*Anthony*], [8.78], [3.00], [2.00], [233.00], [16.41], [269.32], [5.03],
    [*Koren*], [13.18], [4.00], [2.00], [305.00], [23.60], [557.08], [4.22],
    table.cell(colspan: 8, align: center)[*2024*],
    [*Alan*], [15.01], [4.00], [1.00], [121.00], [20.35], [414.10], [1.63],
    [*Alexandra*], [6.06], [5.00], [4.00], [51.00], [4.60], [21.15], [2.85],
    [*Anthony*], [4.42], [2.00], [1.00], [58.00], [6.14], [37.76], [3.41],
    [*Koren*], [5.00], [2.00], [1.00], [77.00], [7.49], [56.13], [3.30],
    table.cell(colspan: 8, align: center)[*2025*],
    [*Alan*], [9.47], [4.00], [1.00], [103.00], [11.51], [132.40], [2.39],
    [*Alexandra*], [4.47], [4.00], [3.00], [118.00], [3.64], [13.23], [16.46],
    [*Anthony*], [4.06], [2.00], [1.00], [50.00], [5.47], [29.87], [3.50],
    [*Koren*], [4.70], [2.00], [1.00], [44.00], [5.73], [32.84], [2.23],
  ),
)

#figure(
  caption: "Box Plots of Plays per Track for Each User (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_track_alltime.png"),
      image("../data/distributions/plots/boxplot_plays_per_track_alltime_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [2], [21], [1371], [19], [-26.5], [49.5],
      [Alexandra], [1], [4], [44], [263], [40], [-56], [104],
      [Anthony], [1], [2], [8], [234], [6], [-7], [17],
      [Koren], [1], [2], [14], [306], [12], [-16], [32],
    ))
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_track_2024.png"),
      image("../data/distributions/plots/boxplot_plays_per_track_2024_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [2], [25], [122], [23], [-32.5], [59.5],
      [Alexandra], [1], [3], [8], [52], [5], [-4.5], [15.5],
      [Anthony], [1], [1], [5], [59], [4], [-5], [11],
      [Koren], [1], [1], [5], [78], [4], [-5], [11],
    ))
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_track_2025.png"),
      image("../data/distributions/plots/boxplot_plays_per_track_2025_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [2], [14], [104], [12], [-16], [32],
      [Alexandra], [1], [3], [6], [119], [3], [-1.5], [10.5],
      [Anthony], [1], [1], [4], [51], [3], [-3.5], [8.5],
      [Koren], [1], [1], [6], [45], [5], [-6.5], [13.5],
    ))
  ],
)

=== Plays Per Artist

Plays per artist aggregates all listening events per unique artist name, revealing how unevenly listening volume is distributed across an artist catalog. Extreme skewness here is expected given the top artist data; the question is how extreme.

#figure(
  caption: "Distribution of Plays per Artist for Each User (All-Time, 2024, 2025)",
  table(
    columns: 8,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 8, align: center)[*All-Time*],
    [], [*Mean*], [*Median*], [*Mode*], [*Range*], [*Standard Deviation*], [*Variance*], [*Skewness*],
    [*Alan*], [265.65], [5.00], [2.00], [43738.00], [1547.60], [2395064.73], [16.81],
    [*Alexandra*], [131.15], [22.00], [2.00], [9307.00], [557.96], [311323.54], [11.00],
    [*Anthony*], [55.93], [4.00], [2.00], [6779.00], [273.06], [74559.34], [15.17],
    [*Koren*], [45.03], [6.00], [2.00], [5763.00], [198.37], [39350.67], [14.55],
    table.cell(colspan: 8, align: center)[*2024*],
    [*Alan*], [71.48], [5.00], [2.00], [2802.00], [211.32], [44655.85], [6.09],
    [*Alexandra*], [23.29], [7.00], [1.00], [987.00], [70.99], [5039.69], [8.07],
    [*Anthony*], [21.26], [3.00], [1.00], [857.00], [65.88], [4340.80], [7.26],
    [*Koren*], [11.61], [3.00], [1.00], [763.00], [35.68], [1272.94], [11.74],
    table.cell(colspan: 8, align: center)[*2025*],
    [*Alan*], [61.29], [8.00], [1.00], [1183.00], [135.04], [18235.16], [4.34],
    [*Alexandra*], [17.32], [5.00], [3.00], [562.00], [47.73], [2278.42], [6.93],
    [*Anthony*], [25.24], [4.00], [1.00], [1198.00], [81.50], [6642.28], [8.19],
    [*Koren*], [12.21], [3.00], [1.00], [1070.00], [40.27], [1621.82], [15.49],
  ),
)

#figure(
  caption: "Box Plots of Plays per Artist for Each User (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_artist_alltime.png"),
      image("../data/distributions/plots/boxplot_plays_per_artist_alltime_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [2], [24], [43739], [22], [-31], [57],
      [Alexandra], [1], [3], [75], [9308], [72], [-105], [183],
      [Anthony], [1], [2], [18], [6780], [16], [-22], [42],
      [Koren], [1], [2], [24], [5764], [22], [-31], [57],
    ))
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_artist_2024.png"),
      image("../data/distributions/plots/boxplot_plays_per_artist_2024_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [2], [26.75], [2803], [24.75], [-35.125], [63.875],
      [Alexandra], [1], [4], [13], [988], [9], [-9.5], [26.5],
      [Anthony], [1], [1], [11], [858], [10], [-14], [26],
      [Koren], [1], [1], [8], [764], [7], [-9.5], [18.5],
    ))
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_artist_2025.png"),
      image("../data/distributions/plots/boxplot_plays_per_artist_2025_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [2], [49.25], [1184], [47.25], [-68.875], [120.125],
      [Alexandra], [1], [3], [10], [563], [7], [-7.5], [20.5],
      [Anthony], [1], [2], [15], [1199], [13], [-17.5], [34.5],
      [Koren], [1], [1], [11], [1071], [10], [-14], [26],
    ))
  ],
)

=== Plays Per Album

Plays per album sits between plays-per-track and plays-per-artist in terms of aggregation granularity. It distinguishes users who cycle through entire records from those who cherry-pick individual tracks.

#figure(
  caption: "Distribution of Plays per Album for Each User (All-Time, 2024, 2025)",
  table(
    columns: 8,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 8, align: center)[*All-Time*],
    [], [*Mean*], [*Median*], [*Mode*], [*Range*], [*Standard Deviation*], [*Variance*], [*Skewness*],
    [*Alan*], [114.75], [4.00], [2.00], [8731.00], [503.24], [253250.73], [9.14],
    [*Alexandra*], [57.97], [18.00], [2.00], [1766.00], [150.36], [22609.62], [6.19],
    [*Anthony*], [16.64], [4.00], [2.00], [1239.00], [52.37], [2742.38], [10.64],
    [*Koren*], [21.64], [5.00], [2.00], [1490.00], [61.03], [3724.59], [10.40],
    table.cell(colspan: 8, align: center)[*2024*],
    [*Alan*], [38.28], [4.00], [2.00], [686.00], [92.17], [8494.98], [3.78],
    [*Alexandra*], [10.91], [6.00], [1.00], [321.00], [20.73], [429.59], [6.63],
    [*Anthony*], [8.07], [3.00], [1.00], [273.00], [18.28], [334.03], [7.64],
    [*Koren*], [7.21], [2.00], [1.00], [418.00], [16.57], [274.53], [11.38],
    table.cell(colspan: 8, align: center)[*2025*],
    [*Alan*], [29.66], [5.00], [1.00], [676.00], [58.62], [3436.35], [4.00],
    [*Alexandra*], [8.11], [5.00], [2.00], [159.00], [13.69], [187.32], [5.03],
    [*Anthony*], [8.30], [3.00], [1.00], [384.00], [20.01], [400.26], [8.69],
    [*Koren*], [7.12], [2.00], [1.00], [583.00], [18.34], [336.26], [17.53],
  ),
)

#figure(
  caption: "Box Plots of Plays per Album for Each User (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_album_alltime.png"),
      image("../data/distributions/plots/boxplot_plays_per_album_alltime_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [2], [17], [8732], [15], [-20.5], [39.5],
      [Alexandra], [1], [3], [49], [1767], [46], [-66], [118],
      [Anthony], [1], [2], [10], [1240], [8], [-10], [22],
      [Koren], [1], [2], [18], [1491], [16], [-22], [42],
    ))
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_album_2024.png"),
      image("../data/distributions/plots/boxplot_plays_per_album_2024_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [2], [20], [687], [18], [-25], [47],
      [Alexandra], [1], [3], [10], [322], [7], [-7.5], [20.5],
      [Anthony], [1], [1], [7], [274], [6], [-8], [16],
      [Koren], [1], [1], [6], [419], [5], [-6.5], [13.5],
    ))
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_plays_per_album_2025.png"),
      image("../data/distributions/plots/boxplot_plays_per_album_2025_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [1], [2], [29], [677], [27], [-38.5], [69.5],
      [Alexandra], [1], [3], [7], [160], [4], [-3], [13],
      [Anthony], [1], [1], [7], [385], [6], [-8], [16],
      [Koren], [1], [1], [9], [584], [8], [-11], [21],
    ))
  ],
)

=== Session Length

A listening session is defined as a continuous sequence of plays with no gap exceeding a defined threshold. Session length (in minutes) captures engagement depth: how long a user stays in a continuous listening context before stopping or pausing.

#figure(
  caption: "Distribution of Session Lengths for Each User (All-Time, 2024, 2025)",
  table(
    columns: 8,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 8, align: center)[*All-Time*],
    [], [*Mean*], [*Median*], [*Mode*], [*Range*], [*Standard Deviation*], [*Variance*], [*Skewness*],
    [*Alan*], [41.36], [26.50], [1.00], [1158.65], [51.30], [2631.50], [4.09],
    [*Alexandra*], [30.54], [19.06], [1.00], [494.45], [39.98], [1598.04], [3.78],
    [*Anthony*], [44.01], [21.21], [2.00], [1199.27], [67.80], [4596.43], [5.25],
    [*Koren*], [30.46], [13.01], [1.00], [1085.80], [52.12], [2716.85], [5.97],
    table.cell(colspan: 8, align: center)[*2024*],
    [*Alan*], [58.19], [36.44], [1.00], [1158.64], [81.48], [6638.73], [5.12],
    [*Alexandra*], [28.37], [17.27], [3.00], [494.45], [41.44], [1717.48], [4.36],
    [*Anthony*], [39.27], [19.95], [1.00], [435.77], [53.36], [2846.83], [3.26],
    [*Koren*], [42.02], [19.35], [1.00], [711.71], [64.38], [4145.35], [3.56],
    table.cell(colspan: 8, align: center)[*2025*],
    [*Alan*], [42.87], [27.97], [1.00], [678.58], [55.24], [3050.96], [4.08],
    [*Alexandra*], [21.77], [15.70], [7.00], [260.91], [24.86], [617.96], [3.43],
    [*Anthony*], [49.83], [24.18], [3.00], [1199.27], [90.70], [8226.07], [6.29],
    [*Koren*], [50.69], [20.59], [1.00], [877.88], [82.47], [6800.97], [4.18],
  ),
)

#figure(
  caption: "Box Plots of Session Length for Each User (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_session_length_alltime.png"),
      image("../data/distributions/plots/boxplot_session_length_alltime_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [0], [6.668], [57.329], [1158.650], [50.661], [-69.323], [133.320],
      [Alexandra], [0], [8.981], [35.642], [494.446], [26.660], [-30.009], [74.632],
      [Anthony], [0], [5.048], [59.096], [1199.269], [54.047], [-76.022], [140.166],
      [Koren], [0], [2.511], [38.261], [1085.802], [35.751], [-51.126], [91.898],
    ))
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_session_length_2024.png"),
      image("../data/distributions/plots/boxplot_session_length_2024_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [0.008], [11.509], [74.306], [1158.650], [62.797], [-82.687], [168.502],
      [Alexandra], [0], [6.387], [34.533], [494.446], [28.146], [-35.832], [76.752],
      [Anthony], [0.028], [6.346], [57.505], [435.802], [51.159], [-70.393], [134.244],
      [Koren], [0], [4.718], [50.605], [711.707], [45.887], [-63.112], [118.435],
    ))
    #grid(
      columns: 2,
      image("../data/distributions/plots/boxplot_session_length_2025.png"),
      image("../data/distributions/plots/boxplot_session_length_2025_log.png"),
    )
    #align(center, table(
      columns: 8,
      align: left,
      [*User*], [*Min*], [$bold(Q_1)$], [$bold(Q_3)$], [*Max*], [*IQR*], [*Lower Fence*], [*Upper Fence*],
      [Alan], [0], [6.582], [55.796], [678.582], [49.213], [-67.337], [129.715],
      [Alexandra], [0], [6.879], [27.848], [260.906], [20.969], [-24.575], [59.302],
      [Anthony], [0], [9.171], [56.035], [1199.269], [46.864], [-61.124], [126.330],
      [Koren], [0], [4.044], [66.133], [877.882], [62.089], [-89.090], [159.267],
    ))
  ],
)

=== Analysis

*Daily Play Count:* All four users show right-skewed daily play count distributions. Alan's all-time distribution is the most extreme: mean 156.57, median 123, mode 1, skewness 1.87. His 2024 distribution is notably the closest to symmetric of any user-period combination (mean 160.68, median 148, skewness 1.02), indicating unusually consistent listening that year with few completely off days and few extreme spikes. His 2025 distribution (mean 54.82, IQR Q1=31 to Q3=123.75) is substantially lower-volume, consistent with the March peak / extended summer trough pattern seen in the events-over-time plot. Alexandra is the most constrained: all-time max is only 235 daily plays, mean 39.78, standard deviation 34.62, and she simply never has the extreme-activity days that the others show. Anthony has the highest all-time skewness (3.17) relative to his mean, driven by occasional extreme days (max 848) against a median of only 33. The histogram for Alan (all-time) confirms the pattern visually: a sharp right-skewed density curve with a long tail well past 500 plays/day.

*Plays Per Track:* The median for all users is low (2-5 plays all-time), while means are substantially higher. Alan's mean/median ratio is approximately 9.5x (47.52 mean vs 5 median), driven by his extreme repeat-listeners: "4th Dimension" at 1,371 plays, "No More Parties in LA" at 1,237 plays, and several others above 1,000. Alexandra's ratio is much lower (\~1.6x: mean 32.20, median 20), consistent with a more evenly distributed catalog where her top tracks are in the 170-237 range rather than the thousands. Alexandra's 2025 skewness (16.46) is anomalously high and stands out from every other user-period combination. This is driven by "Vendetta" by Palisades (119 plays) dominating a year with only 8,712 total plays, inflating the tail on a small sample.

*Plays Per Artist:* Even more skewed than plays per track. Alan's all-time skewness of 16.81 is the highest of any metric-user combination in the entire dataset, driven by 43,739 Kanye West plays against an artist median of 5. On the linear-scale boxplot, Alan's box towers over the others with extreme outlier points. On the log-scale boxplot, the four users converge in IQR range, confirming that once the extreme outliers are removed, their baseline per-artist listening is more comparable. Anthony's all-time skewness (15.17) is nearly as extreme despite having far fewer total plays, and his concentration is proportionally just as severe.

*Plays Per Album:* Alan's all-time mean of 114.75 against a median of 4 (ratio \~29x) reflects the Kanye back-catalog being cycled thousands of times. Alexandra's all-time mean (57.97) with median 18 has a lower ratio (\~3.2x), more consistent with actual album-oriented listening. Session length distributions, discussed next, show a different structure from the count-based variables.

*Session Length:* Modes of 1 minute for most users indicate many very short sessions, just one or two songs before stopping. All-time means (30-44 minutes) and medians (13-27 minutes) confirm the central tendency is well below an hour. The maximum values are clearly artifacts: Anthony's 1,199 minutes and Alan's 1,159 minutes represent roughly 20-hour background-play events where Spotify kept logging through an unattended session. Alan's 2024 sessions are his longest on average (mean 58.19 min), corresponding to his most consistent listening year.

=== Methodology

Distributions are computed on per-day aggregated play counts for daily play count, and on per-entity counts (grouped by track, artist, or album) for the other variables. Histograms overlay a kernel density estimate on frequency bins. Box plots are rendered in both linear and log(value+1) scale; the log transform makes distribution shape visible despite extreme right skew. Summary statistics use standard numpy/scipy functions. Fences follow the Tukey IQR method: lower fence = Q1 - 1.5*IQR, upper fence = Q3 + 1.5*IQR.

== Outliers

Outlier removal isolates the bulk distribution from extreme values, producing cleaned summary statistics that better reflect typical behavior. This is particularly relevant for session length (where very long background-play events inflate means) and plays-per-artist (where one dominant artist distorts everything). Each subsection shows the outlier count and post-removal statistics for direct comparison with the raw distributions above.

=== Daily Play Count

#figure(
  caption: "Distribution of Daily Play Counts for Each User with Outliers Removed (All-Time, 2024, 2025)",
  table(
    columns: 9,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 9, align: center)[*All-Time*],
    [], [*Outliers*], [*Mean*], [*Median*], [*Mode*], [*Range*], [*Standard Deviation*], [*Variance*], [*Skewness*],
    [*Alan*], [94], [140.48], [118.00], [1.00], [479.00], [112.43], [12640.24], [0.82],
    [*Alexandra*], [191], [34.01], [28.00], [12.00], [109.00], [24.83], [616.58], [0.97],
    [*Anthony*], [89], [42.61], [30.00], [1.00], [168.00], [40.15], [1611.64], [1.15],
    [*Koren*], [158], [50.92], [37.00], [1.00], [198.00], [47.00], [2208.74], [1.08],
    table.cell(colspan: 9, align: center)[*2024*],
    [*Alan*], [5], [155.13], [146.50], [165.00], [427.00], [95.29], [9079.38], [0.52],
    [*Alexandra*], [17], [30.21], [28.00], [9.00], [83.00], [18.83], [354.56], [0.67],
    [*Anthony*], [14], [35.28], [25.00], [1.00], [125.00], [30.72], [943.94], [1.08],
    [*Koren*], [17], [36.70], [30.00], [1.00], [130.00], [29.10], [846.94], [0.85],
    table.cell(colspan: 9, align: center)[*2025*],
    [*Alan*], [5], [81.58], [72.00], [2.00], [249.00], [60.15], [3618.18], [0.63],
    [*Alexandra*], [15], [22.07], [18.00], [12.00], [58.00], [13.19], [173.89], [0.79],
    [*Anthony*], [20], [34.59], [26.50], [6.00], [130.00], [29.84], [890.66], [1.08],
    [*Koren*], [17], [44.61], [31.00], [1.00], [166.00], [42.62], [1816.50], [1.04],
  ),
)

=== Plays Per Track

#figure(
  caption: "Distribution of Plays per Track for Each User with Outliers Removed (All-Time, 2024, 2025)",
  table(
    columns: 9,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 9, align: center)[*All-Time*],
    [], [*Outliers*], [*Mean*], [*Median*], [*Mode*], [*Range*], [*Standard Deviation*], [*Variance*], [*Skewness*],
    [*Alan*], [1736], [7.12], [3.00], [2.00], [48.00], [9.29], [86.22], [2.46],
    [*Alexandra*], [281], [25.13], [17.00], [2.00], [103.00], [25.82], [666.52], [1.20],
    [*Anthony*], [1004], [4.19], [3.00], [2.00], [16.00], [3.71], [13.75], [1.62],
    [*Koren*], [1523], [6.58], [3.00], [2.00], [31.00], [7.14], [51.05], [1.70],
    table.cell(colspan: 9, align: center)[*2024*],
    [*Alan*], [146], [12.62], [3.00], [1.00], [58.00], [16.54], [273.70], [1.37],
    [*Alexandra*], [68], [5.51], [5.00], [4.00], [14.00], [3.26], [10.62], [0.69],
    [*Anthony*], [231], [2.84], [2.00], [1.00], [10.00], [2.38], [5.66], [1.64],
    [*Koren*], [345], [2.65], [2.00], [1.00], [10.00], [2.28], [5.22], [1.79],
    table.cell(colspan: 9, align: center)[*2025*],
    [*Alan*], [148], [7.65], [4.00], [1.00], [31.00], [7.77], [60.34], [1.13],
    [*Alexandra*], [51], [4.18], [4.00], [3.00], [9.00], [2.14], [4.58], [0.53],
    [*Anthony*], [404], [2.43], [2.00], [1.00], [7.00], [1.76], [3.09], [1.41],
    [*Koren*], [344], [3.26], [2.00], [1.00], [12.00], [3.30], [10.92], [1.63],
  ),
)

=== Plays Per Artist

#figure(
  caption: "Distribution of Plays per Artist for Each User with Outliers Removed (All-Time, 2024, 2025)",
  table(
    columns: 9,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 9, align: center)[*All-Time*],
    [], [*Outliers*], [*Mean*], [*Median*], [*Mode*], [*Range*], [*Standard Deviation*], [*Variance*], [*Skewness*],
    [*Alan*], [320], [7.51], [3.00], [2.00], [55.00], [10.28], [105.59], [2.59],
    [*Alexandra*], [121], [33.02], [17.00], [2.00], [180.00], [39.93], [1594.69], [1.57],
    [*Anthony*], [207], [6.87], [3.00], [2.00], [41.00], [8.51], [72.40], [2.09],
    [*Koren*], [521], [10.46], [4.50], [2.00], [56.00], [12.82], [164.38], [1.86],
    table.cell(colspan: 9, align: center)[*2024*],
    [*Alan*], [138], [8.12], [3.00], [2.00], [61.00], [11.83], [139.93], [2.47],
    [*Alexandra*], [74], [7.19], [6.00], [1.00], [25.00], [5.23], [27.38], [1.16],
    [*Anthony*], [76], [5.08], [3.00], [1.00], [25.00], [5.72], [32.76], [1.88],
    [*Koren*], [184], [3.70], [2.00], [1.00], [17.00], [3.63], [13.15], [1.83],
    table.cell(colspan: 9, align: center)[*2025*],
    [*Alan*], [70], [18.67], [5.00], [1.00], [113.00], [27.09], [733.92], [1.88],
    [*Alexandra*], [78], [5.50], [5.00], [3.00], [18.00], [3.61], [13.03], [1.33],
    [*Anthony*], [71], [6.52], [3.00], [1.00], [33.00], [7.52], [56.54], [1.72],
    [*Koren*], [128], [5.08], [2.00], [1.00], [25.00], [5.78], [33.39], [1.68],
  ),
)

=== Plays Per Album

#figure(
  caption: "Distribution of Plays per Album for Each User with Outliers Removed (All-Time, 2024, 2025)",
  table(
    columns: 9,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 9, align: center)[*All-Time*],
    [], [*Outliers*], [*Mean*], [*Median*], [*Mode*], [*Range*], [*Standard Deviation*], [*Variance*], [*Skewness*],
    [*Alan*], [753], [5.76], [3.00], [2.00], [38.00], [6.84], [46.79], [2.41],
    [*Alexandra*], [217], [24.90], [15.00], [2.00], [117.00], [27.78], [771.71], [1.41],
    [*Anthony*], [618], [4.78], [3.00], [2.00], [21.00], [4.57], [20.88], [1.75],
    [*Koren*], [1002], [8.33], [4.00], [2.00], [41.00], [9.55], [91.27], [1.71],
    table.cell(colspan: 9, align: center)[*2024*],
    [*Alan*], [255], [6.76], [3.00], [2.00], [46.00], [9.71], [94.36], [2.43],
    [*Alexandra*], [103], [6.10], [5.00], [1.00], [19.00], [4.05], [16.42], [0.90],
    [*Anthony*], [170], [3.68], [2.00], [1.00], [15.00], [3.58], [12.80], [1.69],
    [*Koren*], [292], [3.06], [2.00], [1.00], [12.00], [2.73], [7.43], [1.74],
    table.cell(colspan: 9, align: center)[*2025*],
    [*Alan*], [142], [10.56], [3.00], [1.00], [67.00], [14.63], [214.01], [1.97],
    [*Alexandra*], [108], [4.63], [4.00], [2.00], [12.00], [2.66], [7.10], [0.86],
    [*Anthony*], [180], [3.64], [2.00], [1.00], [15.00], [3.42], [11.70], [1.71],
    [*Koren*], [138], [4.66], [2.00], [1.00], [20.00], [5.04], [25.42], [1.43],
  ),
)

=== Session Length

#figure(
  caption: "Distribution of Session Lengths for Each User with Outliers Removed (All-Time, 2024, 2025)",
  table(
    columns: 9,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 9, align: center)[*All-Time*],
    [], [*Outliers*], [*Mean*], [*Median*], [*Mode*], [*Range*], [*Standard Deviation*], [*Variance*], [*Skewness*],
    [*Alan*], [798], [32.95], [24.14], [1.00], [133.23], [31.60], [998.39], [1.06],
    [*Alexandra*], [922], [21.04], [17.27], [1.00], [75.61], [16.85], [283.85], [0.97],
    [*Anthony*], [178], [31.43], [18.48], [2.00], [140.12], [32.92], [1083.91], [1.18],
    [*Koren*], [796], [19.58], [10.81], [1.00], [91.81], [21.93], [480.72], [1.30],
    table.cell(colspan: 9, align: center)[*2024*],
    [*Alan*], [103], [43.47], [33.20], [1.00], [168.25], [40.73], [1658.75], [1.07],
    [*Alexandra*], [77], [20.05], [15.20], [3.00], [76.48], [17.63], [310.72], [1.02],
    [*Anthony*], [31], [29.84], [18.07], [1.00], [132.36], [29.94], [896.46], [1.09],
    [*Koren*], [100], [25.98], [15.65], [1.00], [118.22], [27.52], [757.41], [1.27],
    table.cell(colspan: 9, align: center)[*2025*],
    [*Alan*], [90], [32.44], [24.89], [1.00], [128.02], [30.39], [923.71], [1.02],
    [*Alexandra*], [70], [17.15], [14.26], [7.00], [59.03], [13.59], [184.57], [0.90],
    [*Anthony*], [65], [30.70], [20.88], [3.00], [125.17], [29.44], [866.96], [1.27],
    [*Koren*], [65], [34.33], [16.78], [1.00], [157.38], [39.37], [1549.89], [1.28],
  ),
)

=== Analysis

After outlier removal via the IQR fence method, the cleaned distributions are substantially more interpretable. For daily play count (all-time), Alan's mean drops from 156.57 to 140.48 and his skewness collapses from 1.87 to 0.82, much closer to symmetric. The median barely changes (123 to 118), confirming that outliers were exclusively in the right tail, not distributed throughout. Alexandra has only 191 daily-count outliers all-time despite being the least active user, which is proportionally high and reflects her occasional exceptionally active days (max 235) standing out against a tight distribution (standard deviation 34.62).

For plays per track, the outlier counts reveal the degree of extreme repeat-listening. Alan has 1,736 tracks flagged as outliers all-time, meaning tracks listened to so many more times than his typical track that they exceed $Q_3 + 1.5 dot "IQR"$. These are his deeply embedded favorites. After removal, his mean drops from 47.52 to 7.12 and skewness from 4.16 to 2.46. Anthony has 1,004 outlier tracks all-time despite a smaller catalog, showing his repeat-listening is proportionally just as concentrated. In 2025, Anthony's outlier count (404) is unusually high relative to his annual play count, suggesting his 2025 listening saw more concentrated repeat tracks even as his unique track count grew.

For plays per artist, Alan's 320 all-time outlier artists (the ones he listens to far more than typical) include Kanye West and the other dominant artists in his top 10. After removing them, his mean drops from 265.65 to 7.51, meaning the \~700 non-outlier artists he has heard each average only about 7.5 plays. The post-removal means for all four users converge (5-10 plays/artist), suggesting the baseline per-artist behavior is similar across users and all differences in the raw data are tail-driven.

Session length outlier removal has the most dramatic effect on the extremes. Alan's 2024 sessions go from a maximum of 1,158 minutes to a cleaned max of \~168 minutes; Anthony's all-time sessions go from 1,199 minutes to 140 minutes. These extreme sessions represent Spotify running unattended in the background and should be excluded from any regression or clustering analysis in subsequent stages. Alexandra has the most session-length outliers all-time (922), a consequence of her having many more session observations relative to her play count compared to other users.

=== Methodology

Outliers are identified using the Tukey IQR method: any value below $Q_1 - 1.5 dot "IQR"$ or above $Q_3 + 1.5 dot "IQR"$ is flagged. The outlier count column shows how many data points were removed per user and period. Post-removal statistics are recomputed on the cleaned subset. No imputation is performed. Thresholds are computed independently per user and per time window.

== Temporal Analysis

Temporal analysis examines when each user listens: which hours of the day and which days of the week see the most activity. The polar bar chart (circular histogram) shows hourly listening volume across 24 hours; the day-of-week heatmap cross-references hour and day to reveal joint patterns that a simple hourly plot misses.

=== Listening Times

#figure(
  caption: "Distribution of Listening Times for Alan (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alanjzamora_alltime.png", width: 80%),
      [*Most Active Hour*: 6:00 PM \ *Least Active Hour*: 9:00 AM],
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alanjzamora_2024.png", width: 80%),
      [*Most Active Hour*: 6:00 PM \ *Least Active Hour*: 9:00 AM],
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alanjzamora_2025.png", width: 80%),
      [*Most Active Hour*: 4:00 PM \ *Least Active Hour*: 9:00 AM],
    )
  ],
)

#figure(
  caption: "Distribution of Listening Times for Alexandra (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alexxxxxrs_alltime.png", width: 80%),
      [*Most Active Hour*: 11:00 PM \ *Least Active Hour*: 10:00 AM],
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alexxxxxrs_2024.png", width: 80%),
      [*Most Active Hour*: 8:00 PM \ *Least Active Hour*: 11:00 AM],
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_alexxxxxrs_2025.png", width: 80%),
      [*Most Active Hour*: 9:00 PM \ *Least Active Hour*: 10:00 AM],
    )
  ],
)

#figure(
  caption: "Distribution of Listening Times for Anthony (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_dasucc_alltime.png", width: 80%),
      [*Most Active Hour*: 12:00 AM \ *Least Active Hour*: 12:00 PM],
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_dasucc_2024.png", width: 80%),
      [*Most Active Hour*: 1:00 AM \ *Least Active Hour*: 12:00 PM],
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_dasucc_2025.png", width: 80%),
      [*Most Active Hour*: 5:00 PM \ *Least Active Hour*: 12:00 PM],
    )
  ],
)

#figure(
  caption: "Distribution of Listening Times for Koren (All-Time, 2024, 2025)",
  [
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_korenns_alltime.png", width: 80%),
      [*Most Active Hour*: 11:00 PM \ *Least Active Hour*: 10:00 AM],
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_korenns_2024.png", width: 80%),
      [*Most Active Hour*: 10:00 PM \ *Least Active Hour*: 11:00 AM],
    )
    #grid(
      columns: 1,
      row-gutter: 2em,
      image("../data/listening_times/plots/listening_times_korenns_2025.png", width: 80%),
      [*Most Active Hour*: 2:00 PM \ *Least Active Hour*: 11:00 AM],
    )
  ],
)

#figure(
  caption: "Listening Times Heatmap for Alan (All-Time, 2024, 2025)",
  [
    #grid(
      image("../data/heatmap/plots/heatmap_dow_hour_alanjzamora_alltime.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_alanjzamora_2024.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_alanjzamora_2025.png"),
    )
  ],
)

#figure(
  caption: "Listening Times Heatmap for Alexandra (All-Time, 2024, 2025)",
  [
    #grid(
      image("../data/heatmap/plots/heatmap_dow_hour_alexxxxxrs_alltime.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_alexxxxxrs_2024.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_alexxxxxrs_2025.png"),
    )
  ],
)

#figure(
  caption: "Listening Times Heatmap for Anthony (All-Time, 2024, 2025)",
  [
    #grid(
      image("../data/heatmap/plots/heatmap_dow_hour_dasucc_alltime.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_dasucc_2024.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_dasucc_2025.png"),
    )
  ],
)

#figure(
  caption: "Listening Times Heatmap for Koren (All-Time, 2024, 2025)",
  [
    #grid(
      image("../data/heatmap/plots/heatmap_dow_hour_korenns_alltime.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_korenns_2024.png"),
      image("../data/heatmap/plots/heatmap_dow_hour_korenns_2025.png"),
    )
  ],
)

=== Analysis

Users have distinct and stable daily listening rhythms. Alan's polar chart shows a bimodal distribution: a primary peak at 6pm (18:00; 31,056 events all-time) and a strong secondary cluster from midnight through 3am (26,000-28,000 events per hour). His 9am is the dead zone (674 events). The heatmap reinforces this: a black void runs from roughly 7am-12pm across all days, while 4pm-10pm and 12am-4am light up consistently. Notably, Friday evening around 6pm shows the strongest individual cell. This bimodal pattern is characteristic of someone who listens heavily in the afternoon/evening and continues into the early morning hours. In 2025, Alan's peak shifts to 4pm rather than 6pm, a modest earlier shift that aligns with his overall lower volume and possibly a schedule change.

Alexandra's listening is concentrated in the late night window. Her all-time peak is 11pm (23:00; 10,331 events), and hours 20-23 form a sustained plateau. Her minimum at 10am (2,906 events) is not as extreme as Alan's morning gap, suggesting she does some daytime listening, but her intensity is clearly nocturnal. In 2025, her peak shifts to 9pm (vs 11pm all-time), suggesting an earlier schedule.

Anthony's all-time peak at midnight (12am; 8,182 events) and the gradual ramp from 5pm through midnight point to consistent late-night listening. His 2025 peak, however, shifts dramatically to 5pm, a substantial change indicating a schedule shift that pushed active hours into the early evening. His minimum remains at noon across all periods.

Koren's all-time pattern shows a strong late-evening cluster (11pm: 15,234 events, 10pm: 14,634) and a secondary mid-afternoon peak starting around 1pm. His 2025 peak at 2pm is the most anomalous shift of any user, moving from 11pm all-time to 2pm in 2025. This realignment of his peak listening to the early afternoon may reflect a change in school schedule, work context, or daily routine, and will be worth examining against productivity or course-load data in a future multivariate stage.

=== Methodology

Listening times are extracted using `EXTRACT(HOUR FROM timestamp) GROUP BY username, hour` to get total event counts per hour. Polar bar charts use 15-degree sectors for each hour, colored on a viridis scale by event count. The day-of-week heatmap uses `EXTRACT(DOW FROM timestamp)` and `EXTRACT(HOUR FROM timestamp)`, with `COUNT(*)` aggregated per (day, hour) cell and rendered on a fire palette.

== Bool Flags

The boolean flags (`shuffle`, `skipped`, `offline`) capture playback behavior metadata that reveals how actively each user curates their listening experience. Shuffle mode, skip rate, and offline rate each indicate distinct aspects of listening intent, while start and end reason fields provide granular Spotify event context.

=== Shuffle, Skipped, Offline

#figure(
  caption: "Rate of Shuffle, Skipped, and Offline Plays for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    image("../data/bool_flags/plots/bool_flags_users_alltime.png"),
    image("../data/bool_flags/plots/bool_flags_users_2024.png"),
    image("../data/bool_flags/plots/bool_flags_users_2025.png"),
  ),
)

#figure(
  caption: "Rate of Shuffle, Skipped, and Offline Plays for Each User (All-Time, 2024, 2025)",
  table(
    columns: 4,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 4, align: center)[*All-Time*],
    [*User*], [*Shuffle Rate*], [*Skip Rate*], [*Offline Rate*],
    [Alan], [0.633 (63.3%)], [0.260 (26.0%)], [0.001 (0.1%)],
    [Alexandra], [0.933 (93.3%)], [0.117 (11.7%)], [0.050 (5.0%)],
    [Anthony], [0.538 (53.8%)], [0.341 (34.1%)], [0.004 (0.4%)],
    [Koren], [0.651 (65.1%)], [0.275 (27.5%)], [0.009 (0.9%)],
    table.cell(colspan: 4, align: center)[*2024*],
    [Alan], [0.728 (72.8%)], [0.806 (80.6%)], [0.001 (0.1%)],
    [Alexandra], [0.895 (89.5%)], [0.371 (37.1%)], [0 (0.0%)],
    [Anthony], [0.683 (68.3%)], [0.556 (55.6%)], [0 (0.0%)],
    [Koren], [0.761 (76.1%)], [0.588 (58.8%)], [0.017 (1.7%)],
    table.cell(colspan: 4, align: center)[*2025*],
    [Alan], [0.496 (49.6%)], [0.802 (80.2%)], [0.001 (0.1%)],
    [Alexandra], [0.958 (95.8%)], [0.264 (26.4%)], [0.014 (1.4%)],
    [Anthony], [0.615 (61.5%)], [0.319 (31.9%)], [0.005 (0.5%)],
    [Koren], [0.766 (76.6%)], [0.551 (55.1%)], [0.080 (8.0%)],
  ),
)

=== Skip Rate by Shuffle

#figure(
  caption: "Skip Rate by Shuffle for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    image("../data/skip_by_shuffle/plots/skip_by_shuffle_users_alltime.png"),
    image("../data/skip_by_shuffle/plots/skip_by_shuffle_users_2024.png"),
    image("../data/skip_by_shuffle/plots/skip_by_shuffle_users_2025.png"),
  ),
)

#figure(
  caption: "Skip Rate by Shuffle for Each User (All-Time, 2024, 2025)",
  table(
    columns: 3,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 3, align: center)[*All-Time*],
    [*User*], [*Skip Rate (Shuffle On)*], [*Skip Rate (Shuffle Off)*],
    [Alan], [0.239 (23.9%)], [0.297 (29.7%)],
    [Alexandra], [0.114 (11.4%)], [0.164 (16.4%)],
    [Anthony], [0.464 (46.4%)], [0.197 (19.7%)],
    [Koren], [0.294 (29.4%)], [0.240 (24.0%)],
    table.cell(colspan: 3, align: center)[*2024*],
    [Alan], [0.814 (81.4%)], [0.784 (78.4%)],
    [Alexandra], [0.372 (37.2%)], [0.359 (35.9%)],
    [Anthony], [0.655 (65.5%)], [0.343 (34.3%)],
    [Koren], [0.541 (54.1%)], [0.740 (74.0%)],
    table.cell(colspan: 3, align: center)[*2025*],
    [Alan], [0.830 (83.0%)], [0.774 (77.4%)],
    [Alexandra], [0.260 (26.0%)], [0.337 (33.7%)],
    [Anthony], [0.389 (38.9%)], [0.207 (20.7%)],
    [Koren], [0.478 (47.8%)], [0.789 (78.9%)],
  ),
)

=== Start & End Reasons

#figure(
  caption: "Start Reasons Proportions for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    image("../data/reason_start_end/plots/reason_start_users_alltime.png"),
    image("../data/reason_start_end/plots/reason_start_users_2024.png"),
    image("../data/reason_start_end/plots/reason_start_users_2025.png"),
  ),
)

#figure(
  caption: "Start Reasons Proportions for Each User (All-Time, 2024, 2025)",
  table(
    columns: 5,
    align: left,
    fill: (col, row) => {
      if row in (0, 11, 22) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 5, align: center)[*All-Time*],
    [*Reason*], [*Alan*], [*Alexandra*], [*Anthony*], [*Koren*],
    [`fwdbtn`], [0.555 (55.5%)], [0.349 (34.9%)], [0.527 (52.7%)], [0.515 (51.5%)],
    [`trackdone`], [0.101 (10.1%)], [0.540 (54.0%)], [0.357 (35.7%)], [0.199 (19.9%)],
    [`clickrow`], [0.226 (22.6%)], [0.036 (3.6%)], [0.052 (5.2%)], [0.155 (15.5%)],
    [`playbtn`], [0.036 (3.6%)], [0.024 (2.4%)], [0.030 (3.0%)], [0.058 (5.8%)],
    [`backbtn`], [0.070 (7.0%)], [0.028 (2.8%)], [0.018 (1.8%)], [0.043 (4.3%)],
    [`appload`], [0.010 (1.0%)], [0.019 (1.9%)], [0.008 (0.8%)], [0.014 (1.4%)],
    [`remote`], [0.002 (0.2%)], [0.002 (0.2%)], [0.008 (0.8%)], [0.007 (0.7%)],
    [`trackerror`], [0.000 (0.0%)], [0.001 (0.1%)], [0.000 (0.0%)], [0.006 (0.6%)],
    [`unknown`], [0 (0%)], [0.001 (0.1%)], [0.001 (0.1%)], [0.001 (0.1%)],
    table.cell(colspan: 5, align: center)[*2024*],
    [*Reason*], [*Alan*], [*Alexandra*], [*Anthony*], [*Koren*],
    [`fwdbtn`], [0.555 (55.5%)], [0.331 (33.1%)], [0.461 (46.1%)], [0.416 (41.6%)],
    [`trackdone`], [0.174 (17.4%)], [0.576 (57.6%)], [0.410 (41.0%)], [0.368 (36.8%)],
    [`clickrow`], [0.210 (21.0%)], [0.029 (2.9%)], [0.076 (7.6%)], [0.118 (11.8%)],
    [`playbtn`], [0.021 (2.1%)], [0.016 (1.6%)], [0.013 (1.3%)], [0.031 (3.1%)],
    [`backbtn`], [0.025 (2.5%)], [0.033 (3.3%)], [0.018 (1.8%)], [0.043 (4.3%)],
    [`appload`], [0.012 (1.2%)], [0.012 (1.2%)], [0.009 (0.9%)], [0.010 (1.0%)],
    [`remote`], [0.003 (0.3%)], [0.003 (0.3%)], [0.013 (1.3%)], [0.008 (0.8%)],
    [`trackerror`], [0.000 (0.0%)], [0.001 (0.1%)], [0.000 (0.0%)], [0.004 (0.4%)],
    [`unknown`], [0 (0%)], [0.000 (0.0%)], [0.000 (0.0%)], [0.001 (0.1%)],
    table.cell(colspan: 5, align: center)[*2025*],
    [*Reason*], [*Alan*], [*Alexandra*], [*Anthony*], [*Koren*],
    [`fwdbtn`], [0.405 (40.5%)], [0.258 (25.8%)], [0.247 (24.7%)], [0.418 (41.8%)],
    [`trackdone`], [0.178 (17.8%)], [0.634 (63.4%)], [0.646 (64.6%)], [0.416 (41.6%)],
    [`clickrow`], [0.353 (35.3%)], [0.033 (3.3%)], [0.062 (6.2%)], [0.095 (9.5%)],
    [`playbtn`], [0.021 (2.1%)], [0.011 (1.1%)], [0.008 (0.8%)], [0.026 (2.6%)],
    [`backbtn`], [0.026 (2.6%)], [0.019 (1.9%)], [0.010 (1.0%)], [0.025 (2.5%)],
    [`appload`], [0.012 (1.2%)], [0.027 (2.7%)], [0.011 (1.1%)], [0.005 (0.5%)],
    [`remote`], [0.003 (0.3%)], [0.000 (0.0%)], [0.014 (1.4%)], [0.005 (0.5%)],
    [`trackerror`], [0.001 (0.1%)], [0.001 (0.1%)], [0.001 (0.1%)], [0.009 (0.9%)],
    [`unknown`], [0.001 (0.1%)], [0.016 (1.6%)], [0.001 (0.1%)], [0.001 (0.1%)],
  ),
)

#figure(
  caption: "End Reasons Proportions for Each User (All-Time, 2024, 2025)",
  grid(
    columns: 1,
    image("../data/reason_start_end/plots/reason_end_users_alltime.png"),
    image("../data/reason_start_end/plots/reason_end_users_2024.png"),
    image("../data/reason_start_end/plots/reason_end_users_2025.png"),
  ),
)

#figure(
  caption: "End Reasons Proportions for Each User (All-Time, 2024, 2025)",
  table(
    columns: 5,
    align: left,
    fill: (col, row) => {
      if row in (0, 12, 23) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 5, align: center)[*All-Time*],
    [*Reason*], [*Alan*], [*Alexandra*], [*Anthony*], [*Koren*],
    [`fwdbtn`], [0.552 (55.2%)], [0.342 (34.2%)], [0.525 (52.5%)], [0.519 (51.9%)],
    [`trackdone`], [0.100 (10%)], [0.543 (54.3%)], [0.363 (36.3%)], [0.203 (20.3%)],
    [`endplay`], [0.258 (25.8%)], [0.033 (3.3%)], [0.066 (6.6%)], [0.187 (18.7%)],
    [`backbtn`], [0.069 (6.9%)], [0.028 (2.8%)], [0.018 (1.8%)], [0.043 (4.3%)],
    [`unexpected-exit-while-paused`], [0.015 (1.5%)], [0.032 (3.2%)], [0.016 (1.6%)], [0.020 (2.0%)],
    [`logout`], [0.002 (0.2%)], [0.018 (1.8%)], [0.007 (0.7%)], [0.013 (1.3%)],
    [`remote`], [0.001 (0.1%)], [0.001 (0.1%)], [0.002 (0.2%)], [0.006 (0.6%)],
    [`unexpected-exit`], [0.001 (0.1%)], [0.001 (0.1%)], [0.001 (0.1%)], [0.004 (0.4%)],
    [`trackerror`], [0.001 (0.1%)], [0.001 (0.1%)], [0.000 (0.0%)], [0.002 (0.2%)],
    [`unknown`], [0 (0%)], [0.001 (0.1%)], [0.003 (0.3%)], [0.003 (0.3%)],
    table.cell(colspan: 5, align: center)[*2024*],
    [`fwdbtn`], [0.545 (54.5%)], [0.308 (30.8%)], [0.456 (45.6%)], [0.417 (41.7%)],
    [`trackdone`], [0.170 (17.0%)], [0.577 (57.7%)], [0.402 (40.2%)], [0.370 (37.0%)],
    [`endplay`], [0.236 (23.6%)], [0.031 (3.1%)], [0.083 (8.3%)], [0.130 (13.0%)],
    [`backbtn`], [0.025 (2.5%)], [0.032 (3.2%)], [0.018 (1.8%)], [0.042 (4.2%)],
    [`unexpected-exit-while-paused`], [0.019 (1.9%)], [0.033 (3.3%)], [0.021 (2.1%)], [0.015 (1.5%)],
    [`logout`], [0.001 (0.1%)], [0.017 (1.7%)], [0.010 (1.0%)], [0.012 (1.2%)],
    [`remote`], [0.004 (0.4%)], [0.002 (0.2%)], [0.003 (0.3%)], [0.011 (1.1%)],
    [`unexpected-exit`], [0.000 (0.0%)], [0.001 (0.1%)], [0.001 (0.1%)], [0.000 (0.0%)],
    [`trackerror`], [0.000 (0.0%)], [0.000 (0.0%)], [0.000 (0.0%)], [0.003 (0.3%)],
    [`unknown`], [0 (0%)], [0 (0%)], [0.007 (0.7%)], [0 (0%)],
    table.cell(colspan: 5, align: center)[*2025*],
    [`fwdbtn`], [0.398 (39.8%)], [0.222 (22.2%)], [0.244 (24.4%)], [0.423 (42.3%)],
    [`trackdone`], [0.173 (17.3%)], [0.646 (64.6%)], [0.640 (64.0%)], [0.416 (41.6%)],
    [`endplay`], [0.379 (37.9%)], [0.024 (2.4%)], [0.066 (6.6%)], [0.103 (10.3%)],
    [`backbtn`], [0.025 (2.5%)], [0.018 (1.8%)], [0.010 (1.0%)], [0.025 (2.5%)],
    [`unexpected-exit-while-paused`], [0.015 (1.5%)], [0.083 (8.3%)], [0.023 (2.3%)], [0.015 (1.5%)],
    [`logout`], [0.005 (0.5%)], [0.006 (0.6%)], [0.014 (1.4%)], [0.007 (0.7%)],
    [`remote`], [0.004 (0.4%)], [0.000 (0.0%)], [0.003 (0.3%)], [0.009 (0.9%)],
    [`unexpected-exit`], [0.001 (0.1%)], [0.000 (0.0%)], [0.001 (0.1%)], [0.001 (0.1%)],
    [`trackerror`], [0.001 (0.1%)], [0.001 (0.1%)], [0.001 (0.1%)], [0.001 (0.1%)],
    [`unknown`], [0 (0%], [0 (0%)], [0 (0%)], [0 (0%)],
  ),
)

=== Analysis

*Shuffle, Skip, Offline:* Alexandra's 93.3% all-time shuffle rate is the defining characteristic of her playback style: she almost exclusively uses Spotify's shuffle mode. This makes sense with her genre focus: when your entire catalog is within one subgenre, shuffle is an effective randomizer. Her skip rate (11.7%) is the lowest of any user: she trusts her catalog and doesn't skip. Her offline rate (5.0%) is the only meaningful offline figure in the dataset, suggesting she downloads music for commutes or areas without connectivity. Alan, Koren, and Anthony shuffle at 53-65%, a moderate range, with Anthony as the most selective (lowest shuffle rate at 53.8%, highest skip rate at 34.1%).

The 2024 and 2025 skip rates warrant careful attention. In 2024, Alan's skip rate is 80.6%, more than triple his all-time rate. Koren's jumps to 58.8%, Anthony's to 55.6%. This systematic increase across all users in 2024 is unlikely to be purely behavioral. It more plausibly reflects a change in how Spotify logs or exports skip events, or a change in the preprocessing pipeline. This is flagged as a potential data artifact and should be considered when interpreting skip rate in any downstream modeling.

*Skip Rate by Shuffle:* The relationship between shuffle mode and skip rate is user-specific. For Anthony, shuffle dramatically increases skip rate: 46.4% shuffled vs. 19.7% non-shuffled all-time. Anthony likely uses shuffle for exploration, skipping faster when a random track doesn't match his mood, while non-shuffle represents albums or queued playlists he wants to hear. Alan shows the reverse: 23.9% on shuffle vs. 29.7% off shuffle. He skips more when not shuffling, possibly because non-shuffle for him includes artist radio or automated queues where tracks become less relevant as the session drifts. Alexandra's rates are low in both modes (11.4% shuffle, 16.4% off), consistent with her high completion behavior everywhere.

*Start & End Reasons:* The `fwdbtn` (forward/skip button) is the dominant start reason for Alan (55.5%), Anthony (52.7%), and Koren (51.5%) all-time, meaning most of their listening events begin because the previous track was skipped. Alexandra is the opposite: `trackdone` accounts for 54% of her starts, meaning tracks complete and the next one begins automatically. This is fully consistent with her skip rate and shuffle data.

Alan's `clickrow` rate (22.6% all-time, rising to 35.3% in 2025) indicates he manually selects specific tracks from a list or queue with increasing frequency. This rise in 2025 is consistent with his shift toward deliberate listening seen in the Listening Times and Total Listening sections. Anthony's `trackdone` rate rose from 35.7% all-time to 64.6% in 2025, directly mirroring his dramatic hours-per-play increase. End reasons closely mirror start reasons for all users, as expected, since the end of one event triggers the start of the next. Alan's `endplay` rate (25.8% all-time, rising to 37.9% in 2025) is notable: he increasingly stops playback manually rather than letting it continue, another marker of intentional listening behavior.

=== Methodology

Shuffle, skip, and offline rates are computed as `SUM(CASE WHEN flag = true THEN 1 ELSE 0 END) / COUNT(*)` per user and year. Skip-by-shuffle is computed separately for `shuffle = true` and `shuffle = false` subsets. Start and end reason proportions use `COUNT(*) GROUP BY reason_start` normalized by total events per user. Bar charts render three rates side-by-side per user; start/end reason plots use stacked proportional bars.

== Top Artist Concentration

Artist concentration metrics quantify how dominant a user's top artists are relative to their full listening history. Shannon entropy measures evenness of the distribution (higher = more diverse); the Gini coefficient measures inequality (higher = more concentrated). Top N share directly shows what fraction of all plays the top 1, 5, and 10 artists account for.

#figure(
  caption: "Concentration of Top Artist in Listening History for Each User (All-Time, 2024, 2025)",
  grid(
    image("../data/artist_concentration/plots/artist_concentration_alltime.png"),
    image("../data/artist_concentration/plots/artist_concentration_2024.png"),
    image("../data/artist_concentration/plots/artist_concentration_2025.png"),
  ),
)

#figure(
  caption: "Concentration of Top Artist in Listening History for Each User (All-Time, 2024, 2025)",
  table(
    columns: 6,
    align: left,
    fill: (col, row) => {
      if row in (0, 6, 11) { gray.lighten(80%) } else { white }
    },
    table.cell(colspan: 6, align: center)[*All-Time*],
    [*User*], [*Top 1 Share*], [*Top 5 Share*], [*Top 10 Share*], [*Entropy*], [*Gini*],
    [Alan], [0.097 (9.7%)], [0.231 (23.1%)], [0.327 (32.7%)], [6.922], [0.933],
    [Alexandra], [0.067 (6.7%)], [0.248 (24.8%)], [0.343 (34.3%)], [7.391], [0.833],
    [Anthony], [0.094 (9.4%)], [0.223 (22.3%)], [0.316 (31.6%)], [7.297], [0.874],
    [Koren], [0.032 (3.2%)], [0.108 (10.8%)], [0.163 (16.3%)], [9.338], [0.829],
    table.cell(colspan: 6, align: center)[*2024*],
    [Alan], [0.049 (4.9%)], [0.155 (15.5%)], [0.241 (24.1%)], [7.188], [0.854],
    [Alexandra], [0.080 (8.0%)], [0.242 (24.2%)], [0.360 (36.0%)], [7.118], [0.737],
    [Anthony], [0.073 (7.3%)], [0.230 (23.0%)], [0.357 (35.7%)], [6.897], [0.803],
    [Koren], [0.052 (5.2%)], [0.144 (14.4%)], [0.207 (20.7%)], [8.450], [0.740],
    table.cell(colspan: 6, align: center)[*2025*],
    [Alan], [0.040 (4.0%)], [0.162 (16.2%)], [0.260 (26.0%)], [7.113], [0.778],
    [Alexandra], [0.065 (6.5%)], [0.228 (22.8%)], [0.346 (34.6%)], [7.215], [0.711],
    [Anthony], [0.087 (8.7%)], [0.243 (24.3%)], [0.361 (36.1%)], [6.845], [0.804],
    [Koren], [0.062 (6.2%)], [0.140 (14.0%)], [0.201 (20.1%)], [8.564], [0.743],
  ),
)

=== Analysis

Koren stands apart from the other three users on every concentration metric. His all-time top artist accounts for only 3.2% of plays (Lil Uzi Vert at 5,764 out of 181,858), while his top 10 account for just 16.3%. Alan's top artist alone (Kanye West, 43,739 plays) accounts for 9.7% of his entire catalog, three times Koren's top-1 share. Alan and Anthony are similar in top-1 share (\~9-10%), while Alexandra sits slightly lower (6.7%), but all three are well above Koren's 3.2%.

Koren's all-time entropy (9.338) is substantially higher than the next closest user (Alexandra at 7.391). His Gini of 0.829 is the lowest, meaning his plays are the most evenly distributed across artists. This is consistent with his catalog structure: a wide blend of DnB producers, drill rappers, and indie acts means no single artist accumulates plays the way Kanye does for Alan. In 2025, Alan's top-1 share drops to 4.0% (from 9.7% all-time), reflecting his diversification across 2025; the monthly top artist chart shows nine distinct artists leading different months rather than Kanye dominating. However, his top-10 share (26%) remains well above Koren's (20.1%). Anthony's 2025 top-1 share actually increases to 8.7% (Kanye West with 1,199 plays of 13,706), his highest single-artist concentration across all three windows, confirming Kanye's growing dominance in Anthony's 2025 listening despite an expanding unique track catalog.

=== Methodology

Top N shares are computed as the sum of the top N artists' play counts divided by total plays, for N = 1, 5, 10. Shannon entropy uses $H = -sum(p_i dot log_2(p_i))$ over the per-artist play probability distribution. The Gini coefficient uses the standard formula over the sorted plays distribution. All metrics are computed with `numpy` and `scipy`.

== Artist Diversity Over Time

Tracking diversity metrics year-by-year from 2020-2025 reveals whether each user's listening habits have become more or less concentrated over time, providing a longitudinal view of behavioral change that a single-window snapshot cannot capture.

#figure(
  caption: "Artist Entropy Over Time for Each User (All-Time, 2024, 2025)",
  image("../data/artist_diversity/artist_entropy_over_time.png"),
)

#figure(
  caption: "Artist Gini Coefficient Over Time for Each User (All-Time, 2024, 2025)",
  image("../data/artist_diversity/artist_gini_over_time.png"),
)

=== Analysis

Alan's entropy has increased steadily from 5.5 in 2020 to 7.1 in 2025, one of the clearest upward trends in the dataset. His early years were highly concentrated around Kanye West during the lockdown listening spike, and as his overall volume decreased post-2021, his listening diversified. The Gini coefficient confirms this: 0.91 in 2020, falling to 0.78 in 2025. He started as the most concentrated listener in the group and remains near the bottom, but the direction of change is consistent.

Anthony's trajectory is volatile. He starts at 6.4 entropy in 2020, spikes to 7.3 in 2021, collapses to 5.9 in 2022 (his most concentrated year), then recovers to 6.9 by 2025. His Gini shows a corresponding pattern: 0.43 in 2020 (unusually low, suggesting an oddly even distribution for a new dataset), jumping to 0.81 in 2021. The 2020 data point for Anthony should be treated cautiously given his limited data before October 2020. His volatility year-to-year suggests his listening focus shifts more dramatically than the other users, a hypothesis that connects to the monthly top artist variation and his high new-play rate.

Koren's entropy is consistently the highest (7.9 in 2020, growing to \~8.6 in 2022-2025) and the most stable. His Gini (0.74-0.80) reflects moderate but not extreme inequality. This stability suggests Koren's broad, eclectic listening style is not a recent development; it's been consistent since 2020.

Alexandra's entropy rises from 6.6 in 2020 to 7.5 in 2023, then pulls back to 7.2 in 2025. Her Gini decreases from 0.68 in 2020 to 0.71 in 2025. Her 2023 entropy spike is the highest she reaches and likely corresponds to a period of broader musical exploration that subsequently narrowed. Both metrics suggest moderate, mostly stable diversity with no dramatic trend in either direction.

=== Methodology

Entropy and Gini are computed per year by restricting `listening_history` to that year's data, computing plays-per-artist distributions, and applying the same formulas described in the Top Artist Concentration methodology. Line plots cover 2020-2025 (full overlap period), colored by user with point markers.

== Discovered/Rediscovered Items

Within the 2025 window, a "discovered" item is one that first appears in the user's history during that year, and a "rediscovered" item is a return to something not played for a gap exceeding half the user's total listening span.

=== Analysis

Alan has the largest absolute discovery count: 11 new artists, 38 tracks, and 22 albums. The range of discovered artists is wide: underscores (394 plays), The Alan Parsons Project (275), LCD Soundsystem (160), SeZon (113), Scarface (74), and The Moody Blues (60), spanning indie hyperpop, prog-rock, post-punk, rap, and video game OST. This breadth is consistent with the entropy increase documented in Artist Diversity Over Time and the late-year top-artist diversification visible in Artist Plays per Month. Two top discovered albums (Wallsocket by underscores at 359 plays and I LAY DOWN MY LIFE FOR YOU: DIRECTOR'S CUT by JPEGMAFIA at 356 plays) account for a combined 715 discovery plays, indicating that both were consumed extensively and not just sampled. One data quality note: ARIANNE and Arianne appear as two separate discovered artists (50 and 46 plays respectively), both attributable to the same Evangelion soundtrack source; they are distinct Spotify artist entries for the same vocalist.

Alan has the most rediscovered items despite the strict threshold: two tracks (Sullen Girl by Fiona Apple after 1,574 days, Fear Not Of Man by Mos Def after 1,656 days) and one album (XXX by Danny Brown after 2,054 days). All three gaps exceed four years, making these genuine long-dormant returns.

Koren has the highest discovery volume by play count. His top discovered album, MUSIC - SORRY 4 DA WAIT by Playboi Carti, accumulated 584 plays in 2025, and MUSIC by Playboi Carti added another 307, a combined 891 plays on two versions of the same release. This directly explains the March 2025 peak in Events Over Time and the Playboi Carti dominance in Artist Plays per Month. Beyond Carti, Koren discovered seven new artists including Che (290 plays on REST IN BASS), fakemink (153), and Protect (123), all from the DnB and underground rap space that defines his broader catalog. His one rediscovered artist and album are both Dolan Beatz, returning after 2,513 days (6.9 years).

Anthony discovered only three new artists: DONDA (103 plays) and Ye (51 plays) are both Kanye West alias accounts on Spotify, leaving GELO (33 plays) as the sole genuinely new artist. His top discovered album is Playboi Carti's MUSIC (385 plays), identical to the release Koren also discovered in 2025. Ken Carson's More Chaos also appears in both users' discovered albums lists (Anthony: 80 plays, Koren: 64 plays), as does Travis Scott's JACKBOYS 2, confirming that a shared Carti-adjacent release cycle drove synchronized behavior for both users. Anthony had no rediscovered tracks or artists; two rediscovered albums returned after roughly 3.5-4 year gaps (Dangerous Woman by Ariana Grande at 1,428 days, Slimeball by Young Nudy at 1,293 days).

Alexandra has the smallest discovery footprint: three artists (Palisades at 119 plays, bbno\$ at 72, Dead Eyes at 30), one track (Vendetta by Palisades at 119 plays), and three albums. That a single track accounts for the entirety of her top discovered track count, and that both the track and album have identical play counts (119), means Vendetta is the only track from Erase The Pain she played in 2025. No rediscoveries of any kind, consistent with her narrow, stable catalog and the highest threshold days (1,805) of any user.

=== Methodology

For each user, items are classified as "discovered" in 2025 if the artist, track, or album has no recorded plays before January 1, 2025 in the user's full listening history. "Rediscovered" items are those that had prior plays but whose most recent play before 2025 occurred at least `threshold_days` ago, where `threshold_days` is computed as 50% of the user's total listening span in days (Alan: 1,541 days; Alexandra: 1,805 days; Anthony: 774 days; Koren: 1,641 days). Results are ranked by 2025 play count within each category. Data is drawn from `discoveries_2025.json`; no visualization was generated for this section.

== Repeat vs. New Artists

Repeat vs. new artist plays distinguish events where the user plays an artist they have heard before from first-time artist encounters. This provides a direct, simple measure of catalog consolidation vs. active exploration behavior.

#figure(
  caption: "Proportion of Repeat vs. New Artists for Each User (All-Time, 2024, 2025)",
  grid(
    image("../data/repeat_vs_new/plots/repeat_vs_new_alltime.png"),
    image("../data/repeat_vs_new/plots/repeat_vs_new_2024.png"),
    image("../data/repeat_vs_new/plots/repeat_vs_new_2025.png"),
  ),
)

=== Analysis

All four users are overwhelmingly repeat listeners: Alan (98% repeat), Alexandra (96% repeat), Koren (92% repeat), Anthony (87% repeat). The near-total dominance of repeat plays across the group confirms that each user's listening catalog is effectively established; the vast majority of every session draws from familiar artists. Only 2-13% of plays are first-time artist encounters.

Anthony has the highest new-play rate at 13%, consistent with his increasing entropy over time and the Ken Carson emergence visible in his 2025 top tracks. His catalog started later (2020) so it's natural that it still includes more ongoing discovery. Koren's 8% new rate is second highest, consistent with his broad artist catalog (4,039 unique artists all-time) and consistently high entropy. Alan's 2% new rate despite 450,283 plays and 1,064 unique artists illustrates how established his listening catalog is; he may encounter new artists occasionally, but they make up a negligible fraction of his total listening time. This is consistent with his 2020 entropy of 5.5 being driven primarily by Kanye West plays with very little else. Alexandra's 4% rate reflects her narrow but stable pop-punk catalog.

=== Methodology

Each play event is classified as "new" if it is the first recorded play of that artist by that user within the analysis window, and "repeat" if the artist has appeared before. The classification is cumulative across the full all-time dataset. Donut charts display the proportion of total play events in each category per user.

== Artist Plays per Month

Monthly top-artist tracking captures how each user's dominant listening focus shifts over time, revealing whether users maintain a consistent favorite throughout the year or cycle through phases of different artists.

#figure(
  caption: "Monthly Plays of Top Artist for Alan (2024, 2025)",
  grid(
    image("../data/monthly_top_artist/plots/monthly_top_artist_alan_2024.png"),
    image("../data/monthly_top_artist/plots/monthly_top_artist_alan_2025.png"),
  ),
)

#figure(
  caption: "Monthly Plays of Top Artist for Alexandra (2024, 2025)",
  grid(
    image("../data/monthly_top_artist/plots/monthly_top_artist_alexandra_2024.png"),
    image("../data/monthly_top_artist/plots/monthly_top_artist_alexandra_2025.png"),
  ),
)

#figure(
  caption: "Monthly Plays of Top Artist for Anthony (2024, 2025)",
  grid(
    image("../data/monthly_top_artist/plots/monthly_top_artist_anthony_2024.png"),
    image("../data/monthly_top_artist/plots/monthly_top_artist_anthony_2025.png"),
  ),
)

#figure(
  caption: "Monthly Plays of Top Artist for Koren (2024, 2025)",
  grid(
    image("../data/monthly_top_artist/plots/monthly_top_artist_koren_2024.png"),
    image("../data/monthly_top_artist/plots/monthly_top_artist_koren_2025.png"),
  ),
)

=== Analysis

Alan shows the clearest artist lifecycle pattern across both years. In 2024, Kanye West led 8 of 12 months, with Lana Del Rey (Sep), Danny Brown (Oct), Kendrick Lamar (Nov), and Jessie Ware (Dec) displacing him in the final quarter, a late-year shift that directly precedes the Kanye/Kendrick dynamic visible in Alan's 2025 top tracks. In 2025, 9 distinct artists led individual months for Alan, the broadest monthly top-artist distribution of any user, consistent with the entropy increase from 6.1 to 7.1 documented in Artist Diversity Over Time. Alexandra is the inverse: Beartooth led 8 of 12 months in 2025, with only Palisades (Jan), Wage War (Jul), and bbno\$ (Oct) interrupting the run. Her play counts range narrowly between roughly 500 and 1,000 per month, matching the low variance in her overall monthly totals and confirming the narrow repeat-listener profile from Repeat vs. New Artists.

Anthony's 2025 monthly leaders show a clear volume decline: his top-artist play counts go from approximately 1,900 in January to around 450 in December, following the same downward curve as his overall monthly totals. Kanye West leads 5 of Anthony's months in 2025 despite not ranking as his all-time top artist, indicating an active Kanye phase that ran from January through mid-summer before giving way to a rotating cast of artists at very low play counts. Koren has the greatest top-artist variety at 7 distinct leaders in 2025, with Playboi Carti leading March at 4,050 plays, the largest single-month top-artist figure of any user in the 2025 window. This confirms that Koren's March 2025 peak in Events Over Time is almost entirely attributable to a concentrated Playboi Carti phase rather than a broad increase across his catalog.

=== Methodology

For each user and calendar month, the artist with the highest total play count within that month is identified as the monthly top artist. A line chart plots total monthly play count with each point colored and labeled by that month's top artist. Analysis covers 2024 and 2025.

== Daily Play Count

Calendar heatmaps show daily play counts arranged week-by-week across 2025, providing the finest temporal resolution in this analysis and complementing the monthly aggregations in Events Over Time and Monthly Plays.

#figure(
  caption: "Daily Play Count Heatmap for Each User (2025)",
  grid(
    image("../data/calendar_heatmap/plots/calendar_heatmap_alan_2025.png"),
    image("../data/calendar_heatmap/plots/calendar_heatmap_alexandra_2025.png"),
    image("../data/calendar_heatmap/plots/calendar_heatmap_anthony_2025.png"),
    image("../data/calendar_heatmap/plots/calendar_heatmap_koren_2025.png"),
  ),
)

=== Analysis

Alan's heatmap has the most concentrated high-intensity region: March forms a near-solid block of dark cells, with individual days exceeding 400 to 500 plays, the densest single-month cluster of any user's calendar. The surrounding months show conspicuous gray gaps (zero-play days), confirming that Alan's listening is highly bursty, concentrated into active periods rather than sustained daily use. This matches the long right tail in his daily play count distribution.

Alexandra's heatmap operates on a much smaller scale (maximum around 100 plays per day) and shows no equivalent dead zones. Days are consistently light-to-medium green throughout the year with no month showing a dramatic density shift, matching her low monthly variance and stable repeat-listening profile established across earlier sections. Anthony's heatmap spatially expresses the behavioral shift discussed in Events Over Time: February through June contain moderately dark cells (up to roughly 300 per day), while September through December show long stretches of gray with complete zero-play weeks. The transition from active to near-inactive is visible as a gradient from left to right across the calendar. Koren's heatmap concentrates its darkest cells in February and March, corresponding to the tenkay and Playboi Carti phases identified in Artist Plays per Month. From May onward the calendar becomes progressively lighter and more fragmented, with scattered medium-intensity days rather than dense contiguous blocks.

=== Methodology

Daily play counts are computed by grouping `listening_history` records by user and `DATE(timestamp)`. Each cell in the calendar heatmap represents one day, arranged in a week-by-week grid with rows for each day of the week (Monday through Sunday). Cell color encodes play count on a sequential green scale. The 2025 window is shown for all users.

== Shuffle vs. Play Time

// shuffle_vs_ms_played.jl
// Alan:
//   shuffle_off: mean = 1.7048 min
//   shuffle_on: mean = 1.2958 min

// Anthony:
//   shuffle_off: mean = 2.763 min
//   shuffle_on: mean = 2.212 min

// Alexandra:
//   shuffle_off: mean = 1.4721 min
//   shuffle_on: mean = 2.4303 min

// Koren:
//   shuffle_off: mean = 0.8219 min
//   shuffle_on: mean = 2.982 min

=== Analysis

=== Methodology

== Plays vs. Engagement

// plays_vs_engagement.jl
// Alan:
//   artist plays vs skip rate    - n_artists=480  r=0.0777
//   track plays vs avg duration  - n_tracks=3104  r=0.028
//   artist plays vs avg duration - n_artists=480  r=0.0499
//   album plays vs skip rate     - n_albums=975  r=0.1048

// Anthony:
//   artist plays vs skip rate    - n_artists=543  r=-0.0548
//   track plays vs avg duration  - n_tracks=3375  r=-0.0129
//   artist plays vs avg duration - n_artists=543  r=0.0646
//   album plays vs skip rate     - n_albums=1622  r=-0.0335

// Alexandra:
//   artist plays vs skip rate    - n_artists=503  r=0.0078
//   track plays vs avg duration  - n_tracks=1955  r=0.0169
//   artist plays vs avg duration - n_artists=503  r=-0.0484
//   album plays vs skip rate     - n_albums=1064  r=0.0011

// Koren:
//   artist plays vs skip rate    - n_artists=1404  r=-0.1558
//   track plays vs avg duration  - n_tracks=3647  r=0.436
//   artist plays vs avg duration - n_artists=1404  r=0.1438
//   album plays vs skip rate     - n_albums=2312  r=-0.2201

=== Analysis

=== Methodology

== Monthly Plays vs. Engagement

// monthly_plays_vs_engagement.jl
// Alan:
//   monthly plays vs skip rate       — n=12  r=0.3491
//   monthly plays vs new artist rate — n=12  r=-0.3855
//   monthly plays vs entropy         — n=12  r=0.5933
// Anthony:
//   monthly plays vs skip rate       — n=12  r=-0.2228
//   monthly plays vs new artist rate — n=12  r=0.4152
//   monthly plays vs entropy         — n=12  r=0.7474
// Alexandra:
//   monthly plays vs skip rate       — n=12  r=-0.1037
//   monthly plays vs new artist rate — n=12  r=0.3048
//   monthly plays vs entropy         — n=12  r=0.3952
// Koren:
//   monthly plays vs skip rate       — n=12  r=-0.3409
//   monthly plays vs new artist rate — n=12  r=-0.0686
//   monthly plays vs entropy         — n=12  r=0.1759

=== Analysis

=== Methodology

== Time vs. Engagement

// Alan:
//   peak play duration:    hour 10  (3.109 min avg)
//   peak skip rate:        hour 19  (85.69%)
//   peak shuffle rate:     hour 9  (71.59%)
//   peak play count day:   Fri
//   peak skip rate day:    Fri

// Anthony:
//   peak play duration:    hour 7  (3.29 min avg)
//   peak skip rate:        hour 17  (54.12%)
//   peak shuffle rate:     hour 14  (80.98%)
//   peak play count day:   Wed
//   peak skip rate day:    Mon

// Alexandra:
//   peak play duration:    hour 11  (3.338 min avg)
//   peak skip rate:        hour 5  (42.56%)
//   peak shuffle rate:     hour 10  (100.0%)
//   peak play count day:   Thu
//   peak skip rate day:    Fri

// Koren:
//   peak play duration:    hour 11  (3.852 min avg)
//   peak skip rate:        hour 13  (84.08%)
//   peak shuffle rate:     hour 2  (87.7%)
//   peak play count day:   Thu
//   peak skip rate day:    Thu

=== Analysis

=== Methodology

== Spearman Correlation Matrix

#figure(
  caption: "Spearman Correlation Matrix of Engagement Metrics for Alan (All-Time)",
  [
    *Alan* ($n = 449199$) 
    #table(
      columns: 9,
      align: left,
      [],[*`ms_played`*],[*`hour`*],[*`dow`*],[*`month`*],[*`year`*],[*`skip`*],[*`shuffle`*],[*`offline`*],
      [*`ms_played`*],[1.000],[0.001],[-0.012],[0.039],[0.226],[0.081],[-0.127],[0.006],
      [*`hour`*],[0.001],[1.000],[0.001],[-0.004],[0.039],[0.016],[0.013],[0.015],
      [*`dow`*],[-0.012],[0.001],[1.000],[-0.024],[-0.019],[-0.014],[-0.008],[-0.004],
      [*`month`*],[0.039],[-0.004],[-0.024],[1.000],[-0.081],[0.008],[0.157],[0.010],
      [*`year`*],[0.226],[0.039],[-0.019],[-0.081],[1.000],[0.711],[-0.063],[-0.007],
      [*`skip`*],[0.081],[0.016],[-0.014],[0.008],[0.711],[1.000],[-0.064],[-0.004],
      [*`shuffle`*],[-0.127],[0.013],[-0.008],[0.157],[-0.063],[-0.064],[1.000],[0.002],
      [*`offline`*],[0.006],[0.015],[-0.004],[0.010],[-0.007],[-0.004],[0.002],[1.000],
    )
  ]
)

#figure(
  caption: "Spearman Correlation Matrix of Engagement Metrics for Anthony (All-Time)",
  [
    *Anthony* ($n = 72428$)
    #table(
      columns: 9,
      align: left,
      [],[*`ms_played`*],[*`hour`*],[*`dow`*],[*`month`*],[*`year`*],[*`skip`*],[*`shuffle`*],[*`offline`*],
      [*`ms_played`*],[1.000],[-0.029],[0.058],[0.107],[0.278],[-0.338],[-0.080],[0.023],
      [*`hour`*],[-0.029],[1.000],[-0.054],[-0.004],[-0.025],[0.045],[0.012],[0.014],
      [*`dow`*],[0.058],[-0.054],[1.000],[0.027],[-0.023],[-0.094],[-0.071],[-0.031],
      [*`month`*],[0.107],[-0.004],[0.027],[1.000],[-0.143],[-0.023],[-0.085],[-0.002],
      [*`year`*],[0.278],[-0.025],[-0.023],[-0.143],[1.000],[0.370],[0.266],[-0.018],
      [*`skip`*],[-0.338],[0.045],[-0.094],[-0.023],[0.370],[1.000],[0.282],[-0.035],
      [*`shuffle`*],[-0.080],[0.012],[-0.071],[-0.085],[0.266],[0.282],[1.000],[0.023],
      [*`offline`*],[0.023],[0.014],[-0.031],[-0.002],[-0.018],[-0.035],[0.023],[1.000],
    )
  ]
)

#figure(
  caption: "Spearman Correlation Matrix of Engagement Metrics for Alexandra (All-Time)",
  [
    *Alexandra* ($n = 139509$)
    #table(
      columns: 9,
      align: left,
      [],[*`ms_played`*],[*`hour`*],[*`dow`*],[*`month`*],[*`year`*],[*`skip`*],[*`shuffle`*],[*`offline`*],
      [*`ms_played`*],[1.000],[-0.023],[0.008],[0.011],[0.051],[-0.339],[-0.010],[0.005],
      [*`hour`*],[-0.023],[1.000],[-0.051],[-0.028],[-0.010],[0.018],[0.023],[-0.014],
      [*`dow`*],[0.008],[-0.051],[1.000],[0.016],[0.013],[-0.008],[0.014],[-0.006],
      [*`month`*],[0.011],[-0.028],[0.016],[1.000],[-0.058],[0.033],[0.019],[-0.018],
      [*`year`*],[0.051],[-0.010],[0.013],[-0.058],[1.000],[0.292],[0.098],[-0.301],
      [*`skip`*],[-0.339],[0.018],[-0.008],[0.033],[0.292],[1.000],[-0.038],[-0.082],
      [*`shuffle`*],[-0.010],[0.023],[0.014],[0.019],[0.098],[-0.038],[1.000],[-0.179],
      [*`offline`*],[0.005],[-0.014],[-0.006],[-0.018],[-0.301],[-0.082],[-0.179],[1.000],
    )
  ]
)

#figure(
  caption: "Spearman Correlation Matrix of Engagement Metrics for Koren (All-Time)",
  [
    *Koren* ($n = 181756$)
    #table(
      columns: 9,
      align: left,
      [],[*`ms_played`*],[*`hour`*],[*`dow`*],[*`month`*],[*`year`*],[*`skip`*],[*`shuffle`*],[*`offline`*],
      [*`ms_played`*],[1.000],[-0.021],[0.019],[-0.046],[0.132],[-0.241],[0.036],[-0.005],
      [*`hour`*],[-0.021],[1.000],[-0.010],[0.033],[0.003],[0.051],[0.061],[0.017],
      [*`dow`*],[0.019],[-0.010],[1.000],[-0.008],[-0.049],[-0.048],[0.003],[0.011],
      [*`month`*],[-0.046],[0.033],[-0.008],[1.000],[-0.203],[-0.034],[-0.027],[0.002],
      [*`year`*],[0.132],[0.003],[-0.049],[-0.203],[1.000],[0.600],[0.181],[-0.004],
      [*`skip`*],[-0.241],[0.051],[-0.048],[-0.034],[0.600],[1.000],[0.058],[0.027],
      [*`shuffle`*],[0.036],[0.061],[0.003],[-0.027],[0.181],[0.058],[1.000],[0.004],
      [*`offline`*],[-0.005],[0.017],[0.011],[0.002],[-0.004],[0.027],[0.004],[1.000],
    )
  ]
)

#figure(
  caption: "Spearman Correlation Matrix of Engagement Metrics for Pooled Users (All-Time)",
  [
    *Pooled (all users)* ($n = 842892$)
    #table(
      columns: 9,
      align: left,
      [],[*`ms_played`*],[*`hour`*],[*`dow`*],[*`month`*],[*`year`*],[*`skip`*],[*`shuffle`*],[*`offline`*],
      [*`ms_played`*],[1.000],[-0.005],[0.002],[0.021],[0.163],[-0.118],[-0.005],[0.046],
      [*`hour`*],[-0.005],[1.000],[-0.022],[0.003],[0.018],[0.033],[0.018],[0.001],
      [*`dow`*],[0.002],[-0.022],[1.000],[-0.010],[-0.022],[-0.030],[-0.007],[-0.002],
      [*`month`*],[0.021],[0.003],[-0.010],[1.000],[-0.102],[-0.001],[0.085],[-0.001],
      [*`year`*],[0.163],[0.018],[-0.022],[-0.102],[1.000],[0.607],[0.003],[-0.124],
      [*`skip`*],[-0.118],[0.033],[-0.030],[-0.001],[0.607],[1.000],[-0.032],[-0.040],
      [*`shuffle`*],[-0.005],[0.018],[-0.007],[0.085],[0.003],[-0.032],[1.000],[0.010],
      [*`offline`*],[0.046],[0.001],[-0.002],[-0.001],[-0.124],[-0.040],[0.010],[1.000],
    )
  ]
)

=== Analysis

=== Methodology

== Pearson Correlation Matrix

#figure(
  caption: "Pearson Correlation Matrix of Engagement Metrics for Alan (All-Time)",
  [
    *Alan* ($n = 449199$)
    #table(
      columns: 9,
      align: left,
      [],[*`ms_played`*],[*`hour`*],[*`dow`*],[*`month`*],[*`year`*],[*`skip`*],[*`shuffle`*],[*`offline`*],
      [*`ms_played`*],[1.000],[0.019],[-0.009],[0.034],[0.133],[-0.057],[-0.080],[0.007],
      [*`hour`*],[0.019],[1.000],[-0.010],[-0.001],[0.040],[0.012],[0.018],[0.015],
      [*`dow`*],[-0.009],[-0.010],[1.000],[-0.024],[-0.021],[-0.014],[-0.008],[-0.004],
      [*`month`*],[0.034],[-0.001],[-0.024],[1.000],[-0.070],[0.009],[0.161],[0.010],
      [*`year`*],[0.133],[0.040],[-0.021],[-0.070],[1.000],[0.765],[-0.074],[-0.005],
      [*`skip`*],[-0.057],[0.012],[-0.014],[0.009],[0.765],[1.000],[-0.064],[-0.004],
      [*`shuffle`*],[-0.080],[0.018],[-0.008],[0.161],[-0.074],[-0.064],[1.000],[0.002],
      [*`offline`*],[0.007],[0.015],[-0.004],[0.010],[-0.005],[-0.004],[0.002],[1.000],
    )
  ]
)

#figure(
  caption: "Pearson Correlation Matrix of Engagement Metrics for Anthony (All-Time)",
  [
    *Anthony* ($n = 72428$)
    #table(
      columns: 9,
      align: left,
      [],[*`ms_played`*],[*`hour`*],[*`dow`*],[*`month`*],[*`year`*],[*`skip`*],[*`shuffle`*],[*`offline`*],
      [*`ms_played`*],[1.000],[-0.048],[0.066],[0.064],[0.184],[-0.466],[-0.117],[0.017],
      [*`hour`*],[-0.048],[1.000],[-0.062],[0.010],[-0.005],[0.085],[0.034],[0.021],
      [*`dow`*],[0.066],[-0.062],[1.000],[0.023],[-0.026],[-0.099],[-0.076],[-0.031],
      [*`month`*],[0.064],[0.010],[0.023],[1.000],[-0.138],[-0.009],[-0.079],[-0.002],
      [*`year`*],[0.184],[-0.005],[-0.026],[-0.138],[1.000],[0.373],[0.265],[-0.020],
      [*`skip`*],[-0.466],[0.085],[-0.099],[-0.009],[0.373],[1.000],[0.282],[-0.035],
      [*`shuffle`*],[-0.117],[0.034],[-0.076],[-0.079],[0.265],[0.282],[1.000],[0.023],
      [*`offline`*],[0.017],[0.021],[-0.031],[-0.002],[-0.020],[-0.035],[0.023],[1.000],
    )
  ]
)

#figure(
  caption: "Pearson Correlation Matrix of Engagement Metrics for Alexandra (All-Time)",
  [
    *Alexandra* ($n = 139509$)
    #table(
      columns: 9,
      align: left,
      [],[*`ms_played`*],[*`hour`*],[*`dow`*],[*`month`*],[*`year`*],[*`skip`*],[*`shuffle`*],[*`offline`*],
      [*`ms_played`*],[1.000],[-0.033],[0.010],[0.009],[0.058],[-0.355],[-0.004],[0.006],
      [*`hour`*],[-0.033],[1.000],[-0.061],[-0.032],[-0.030],[0.020],[0.019],[-0.005],
      [*`dow`*],[0.010],[-0.061],[1.000],[0.016],[0.017],[-0.008],[0.015],[-0.005],
      [*`month`*],[0.009],[-0.032],[0.016],[1.000],[-0.058],[0.032],[0.017],[-0.018],
      [*`year`*],[0.058],[-0.030],[0.017],[-0.058],[1.000],[0.257],[0.123],[-0.321],
      [*`skip`*],[-0.355],[0.020],[-0.008],[0.032],[0.257],[1.000],[-0.038],[-0.082],
      [*`shuffle`*],[-0.004],[0.019],[0.015],[0.017],[0.123],[-0.038],[1.000],[-0.179],
      [*`offline`*],[0.006],[-0.005],[-0.005],[-0.018],[-0.321],[-0.082],[-0.179],[1.000],
    )
  ]
)

#figure(
  caption: "Pearson Correlation Matrix of Engagement Metrics for Koren (All-Time)",
  [
    *Koren* ($n = 181756$)
    #table(
      columns: 9,
      align: left,
      [],[*`ms_played`*],[*`hour`*],[*`dow`*],[*`month`*],[*`year`*],[*`skip`*],[*`shuffle`*],[*`offline`*],
      [*`ms_played`*],[1.000],[-0.031],[0.004],[-0.092],[0.239],[-0.228],[0.120],[-0.015],
      [*`hour`*],[-0.031],[1.000],[-0.043],[0.039],[-0.043],[0.039],[0.047],[0.026],
      [*`dow`*],[0.004],[-0.043],[1.000],[-0.006],[-0.052],[-0.050],[0.002],[0.012],
      [*`month`*],[-0.092],[0.039],[-0.006],[1.000],[-0.202],[-0.026],[-0.022],[0.009],
      [*`year`*],[0.239],[-0.043],[-0.052],[-0.202],[1.000],[0.591],[0.181],[-0.010],
      [*`skip`*],[-0.228],[0.039],[-0.050],[-0.026],[0.591],[1.000],[0.058],[0.027],
      [*`shuffle`*],[0.120],[0.047],[0.002],[-0.022],[0.181],[0.058],[1.000],[0.004],
      [*`offline`*],[-0.015],[0.026],[0.012],[0.009],[-0.010],[0.027],[0.004],[1.000],
    )
  ]
)

#figure(
  caption: "Pearson Correlation Matrix of Engagement Metrics for Pooled Users (All-Time)",
  [
    *Pooled (all users)* ($n = 842892$)
    #table(
      columns: 9,
      align: left,
      [],[*`ms_played`*],[*`hour`*],[*`dow`*],[*`month`*],[*`year`*],[*`skip`*],[*`shuffle`*],[*`offline`*],
      [*`ms_played`*],[1.000],[-0.008],[0.002],[0.001],[0.130],[-0.199],[0.030],[0.040],
      [*`hour`*],[-0.008],[1.000],[-0.034],[0.005],[0.008],[0.033],[0.017],[0.005],
      [*`dow`*],[0.002],[-0.034],[1.000],[-0.010],[-0.023],[-0.031],[-0.008],[-0.002],
      [*`month`*],[0.001],[0.005],[-0.010],[1.000],[-0.109],[-0.001],[0.086],[-0.001],
      [*`year`*],[0.130],[0.008],[-0.023],[-0.109],[1.000],[0.597],[-0.003],[-0.153],
      [*`skip`*],[-0.199],[0.033],[-0.031],[-0.001],[0.597],[1.000],[-0.032],[-0.040],
      [*`shuffle`*],[0.030],[0.017],[-0.008],[0.086],[-0.003],[-0.032],[1.000],[0.010],
      [*`offline`*],[0.040],[0.005],[-0.002],[-0.001],[-0.153],[-0.040],[0.010],[1.000],
    )
  ]
)

=== Analysis

=== Methodology

== Chi-Square Tests

=== Shuffle vs. Skip

#figure(
  caption: "Chi-Square Test Summary: Shuffle vs. Skip (2025)",
  table(
    columns: 5,
    align: left,
    [*Group*],[*n*],[*chi-square*],[*df*],[*p-value*],
    [Alan],[29316],[143.7298],[1],[< 0.0001],
    [Anthony],[13703],[492.4649],[1],[< 0.0001],
    [Alexandra],[8711],[10.6595],[1],[0.0011],
    [Koren],[17142],[1200.5723],[1],[< 0.0001],
    [Pooled],[68872],[811.6101],[1],[< 0.0001],
  )
)

=== Reason Start vs. Skipped

#figure(
  caption: "Chi-Square Test Summary: Reason Start vs. Skipped (2025)",
  table(
    columns: 6,
    align: left,
    [*Group*],[*n*],[*chi-square*],[*df*],[*p-value*],[*Expected < 5*],
    [Alan],[29316],[6615.6347],[9],[< 0.0001],[3],
    [Anthony],[13703],[6608.2983],[9],[< 0.0001],[4],
    [Alexandra],[8711],[1256.5354],[8],[< 0.0001],[3],
    [Koren],[17142],[7214.4648],[8],[< 0.0001],[0],
  )
)

=== Analysis

=== Methodology

== Cramer's V

#figure(
  caption: "Cramer's V Matrix for Categorical Variables (Pooled, 2025)",
  [
    *Pooled (all users)* ($n = 68872$)
    #table(
      columns: 7,
      align: left,
      [],[*`shuffle`*],[*`skipped`*],[*`offline`*],[*`reason_start`*],[*`reason_end`*],[*`username`*],
      [*`shuffle`*],[1.0000],[0.1086],[0.0123],[0.3186],[0.3095],[0.3339],
      [*`skipped`*],[0.1086],[1.0000],[0.0107],[0.6382],[1.0000],[0.4411],
      [*`offline`*],[0.0123],[0.0107],[1.0000],[0.0294],[0.0269],[0.0594],
      [*`reason_start`*],[0.3186],[0.6382],[0.0294],[1.0000],[0.3142],[0.2871],
      [*`reason_end`*],[0.3095],[1.0000],[0.0269],[0.3142],[1.0000],[0.2978],
      [*`username`*],[0.3339],[0.4411],[0.0594],[0.2871],[0.2978],[1.0000],
    )
  ]
)

=== Analysis

=== Methodology

== Point-Biserial Correlation

=== Skipped vs. Play Time

#figure(
  caption: "Point-Biserial Correlation: Skipped vs. Play Time (2025)",
  table(
    columns: 9,
    align: left,
    [*User*],[*n*],[*r_pb*],[*t*],[*p-value*],[*Mean (Not Skipped)*],[*n*],[*Mean (Skipped)*],[*n*],
    [Alan],[29316],[-0.5634],[-116.76],[< 0.0001],[3.5322],[5781],[1.0028],[23535],
    [Anthony],[13703],[-0.7342],[-126.57],[< 0.0001],[3.2698],[9332],[0.6180],[4371],
    [Alexandra],[8711],[-0.7301],[-99.69],[< 0.0001],[3.0463],[6415],[0.5554],[2296],
    [Koren],[17142],[-0.7760],[-161.08],[< 0.0001],[4.9218],[7684],[0.4886],[9458],
  )
)

=== Offline vs. Play Time

#figure(
  caption: "Point-Biserial Correlation: Offline vs. Play Time (2025)",
  table(
    columns: 9,
    align: left,
    [*User*],[*n*],[*r_pb*],[*t*],[*p-value*],[*Mean (Offline=false)*],[*n*],[*Mean (Offline=true)*],[*n*],
    [Alan],[29316],[0.0070],[1.1969],[0.2314],[1.5012],[29281],[1.8628],[35],
    [Anthony],[13703],[-0.0011],[-0.1344],[0.8931],[2.4240],[13639],[2.3957],[64],
    [Alexandra],[8711],[0.0645],[6.0357],[< 0.0001],[2.3783],[8591],[3.2107],[120],
    [Koren],[17142],[-0.0594],[-7.7968],[< 0.0001],[2.4910],[17005],[0.5941],[137],
  )
)

=== Shuffle vs. Play Time

#figure(
  caption: "Point-Biserial Correlation: Shuffle vs. Play Time (2025)",
  table(
    columns: 9,
    align: left,
    [*User*],[*n*],[*r_pb*],[*t*],[*p-value*],[*Mean (Shuffle=false)*],[*n*],[*Mean (Shuffle=true)*],[*n*],
    [Alan],[29316],[-0.1145],[-19.73],[< 0.0001],[1.7048],[14750],[1.2958],[14566],
    [Anthony],[13703],[-0.1592],[-18.88],[< 0.0001],[2.7630],[5270],[2.2120],[8433],
    [Alexandra],[8711],[0.1282],[12.06],[< 0.0001],[1.4721],[368],[2.4303],[8343],
    [Koren],[17142],[0.3221],[44.54],[< 0.0001],[0.8219],[4017],[2.9820],[13125],
  )
)

== Kruskal-Wallis H Test

=== Time Played Across Users

#figure(
  caption: "Kruskal-Wallis H Test: Time Played Across Users (2025, H = 3478.93, df = 3, p < 0.0001)",
  table(
    columns: 5,
    align: left,
    [*User*],[*n*],[*Mean Rank*],[*Median (min)*],[*Mean (min)*],
    [Alan],[29316],[29719.58],[0.67],[1.50],
    [Anthony],[13703],[39751.22],[2.72],[2.42],
    [Alexandra],[8711],[40566.90],[2.89],[2.39],
    [Koren],[17142],[35139.56],[1.21],[2.48],
  )
)

#figure(
  caption: "Dunn's Post-hoc Test (Bonferroni, m = 6 comparisons, α = 0.05)",
  table(
    columns: 5,
    align: left,
    [*Group 1*],[*Group 2*],[*z*],[*p (raw)*],[*p (Bonf)*],
    [Anthony],[Alan],[48.76],[< 0.0001],[< 0.0001],
    [Anthony],[Alexandra],[-2.99],[0.0028],[0.0165],
    [Anthony],[Koren],[20.24],[< 0.0001],[< 0.0001],
    [Alan],[Alexandra],[-44.71],[< 0.0001],[< 0.0001],
    [Alan],[Koren],[-28.35],[< 0.0001],[< 0.0001],
    [Alexandra],[Koren],[20.75],[< 0.0001],[< 0.0001],
  )
)

=== Time Played by Reason Start

#figure(
  caption: "Alan: Kruskal-Wallis H Test by Reason Start (H = 6729.48, df = 9, p < 0.0001)",
  table(
    columns: 5,
    align: left,
    [*Reason Start*],[*n*],[*Mean Rank*],[*Median (min)*],[*Mean (min)*],
    [appload],[352],[15401.27],[0.43],[1.31],
    [backbtn],[746],[14335.52],[0.94],[1.57],
    [clickrow],[10327],[15797.15],[0.89],[1.53],
    [fwdbtn],[11902],[10545.53],[0.03],[0.85],
    [playbtn],[607],[15049.67],[0.52],[1.36],
    [reconnect],[6],[12694.67],[0.18],[0.63],
    [remote],[80],[14388.66],[0.32],[1.21],
    [trackdone],[5242],[21764.47],[3.11],[2.97],
    [trackerror],[36],[12014.10],[0.06],[1.03],
    [unknown],[18],[4371.89],[0.01],[0.04],
  )
)

#figure(
  caption: "Alan: Dunn's Post-hoc Test (Bonferroni, m = 45 comparisons, α = 0.05) — Significant Pairs Only",
  table(
    columns: 5,
    align: left,
    [*Group 1*],[*Group 2*],[*z*],[*p (raw)*],[*p (Bonf)*],
    [appload],[fwdbtn],[10.61],[< 0.0001],[< 0.0001],
    [appload],[trackdone],[-13.66],[< 0.0001],[< 0.0001],
    [appload],[unknown],[5.39],[< 0.0001],[< 0.0001],
    [backbtn],[clickrow],[-4.56],[< 0.0001],[0.0002],
    [backbtn],[fwdbtn],[11.87],[< 0.0001],[< 0.0001],
    [backbtn],[trackdone],[-22.43],[< 0.0001],[< 0.0001],
    [backbtn],[unknown],[4.94],[< 0.0001],[< 0.0001],
    [clickrow],[fwdbtn],[46.14],[< 0.0001],[< 0.0001],
    [clickrow],[trackdone],[-41.58],[< 0.0001],[< 0.0001],
    [clickrow],[unknown],[5.72],[< 0.0001],[< 0.0001],
    [fwdbtn],[playbtn],[-12.79],[< 0.0001],[< 0.0001],
    [fwdbtn],[remote],[-4.05],[< 0.0001],[0.0023],
    [fwdbtn],[trackdone],[-79.97],[< 0.0001],[< 0.0001],
    [playbtn],[trackdone],[-18.51],[< 0.0001],[< 0.0001],
    [playbtn],[unknown],[5.28],[< 0.0001],[< 0.0001],
    [remote],[trackdone],[-7.74],[< 0.0001],[< 0.0001],
    [remote],[unknown],[4.54],[< 0.0001],[0.0003],
    [trackdone],[trackerror],[6.89],[< 0.0001],[< 0.0001],
    [trackdone],[unknown],[8.70],[< 0.0001],[< 0.0001],
  )
)

#figure(
  caption: "Anthony: Kruskal-Wallis H Test by Reason Start (H = 4957.22, df = 8, p < 0.0001)",
  table(
    columns: 5,
    align: left,
    [*Reason Start*],[*n*],[*Mean Rank*],[*Median (min)*],[*Mean (min)*],
    [appload],[155],[4561.80],[1.07],[1.41],
    [backbtn],[133],[5088.14],[1.69],[1.68],
    [clickrow],[855],[6635.81],[2.40],[2.37],
    [fwdbtn],[3384],[2901.48],[0.02],[0.69],
    [playbtn],[111],[6138.92],[2.43],[2.00],
    [remote],[195],[8079.11],[3.16],[2.89],
    [trackdone],[8846],[8445.81],[3.18],[3.12],
    [trackerror],[9],[2146.89],[0.03],[0.39],
    [unknown],[14],[1099.86],[0.01],[0.03],
  )
)

#figure(
  caption: "Anthony: Dunn's Post-hoc Test (Bonferroni, m = 36 comparisons, α = 0.05) — Significant Pairs Only",
  table(
    columns: 5,
    align: left,
    [*Group 1*],[*Group 2*],[*z*],[*p (raw)*],[*p (Bonf)*],
    [appload],[clickrow],[-6.01],[< 0.0001],[< 0.0001],
    [appload],[fwdbtn],[5.11],[< 0.0001],[< 0.0001],
    [appload],[playbtn],[-3.21],[0.0013],[0.0484],
    [appload],[remote],[-8.26],[< 0.0001],[< 0.0001],
    [appload],[trackdone],[-12.12],[< 0.0001],[< 0.0001],
    [backbtn],[clickrow],[-4.20],[< 0.0001],[0.0010],
    [backbtn],[fwdbtn],[6.25],[< 0.0001],[< 0.0001],
    [backbtn],[remote],[-6.72],[< 0.0001],[< 0.0001],
    [backbtn],[trackdone],[-9.72],[< 0.0001],[< 0.0001],
    [backbtn],[unknown],[3.59],[0.0003],[0.0120],
    [clickrow],[fwdbtn],[24.66],[< 0.0001],[< 0.0001],
    [clickrow],[remote],[-4.60],[< 0.0001],[0.0002],
    [clickrow],[trackdone],[-12.78],[< 0.0001],[< 0.0001],
    [clickrow],[trackerror],[3.39],[0.0007],[0.0255],
    [clickrow],[unknown],[5.19],[< 0.0001],[< 0.0001],
    [fwdbtn],[playbtn],[-8.48],[< 0.0001],[< 0.0001],
    [fwdbtn],[remote],[-17.77],[< 0.0001],[< 0.0001],
    [fwdbtn],[trackdone],[-69.35],[< 0.0001],[< 0.0001],
    [playbtn],[remote],[-4.13],[< 0.0001],[0.0013],
    [playbtn],[trackdone],[-6.11],[< 0.0001],[< 0.0001],
    [playbtn],[unknown],[4.49],[< 0.0001],[0.0003],
    [remote],[trackerror],[4.40],[< 0.0001],[0.0004],
    [remote],[unknown],[6.38],[< 0.0001],[< 0.0001],
    [trackdone],[trackerror],[4.77],[< 0.0001],[< 0.0001],
    [trackdone],[unknown],[6.94],[< 0.0001],[< 0.0001],
  )
)

#figure(
  caption: "Alexandra: Kruskal-Wallis H Test by Reason Start (H = 1093.22, df = 8, p < 0.0001)",
  table(
    columns: 5,
    align: left,
    [*Reason Start*],[*n*],[*Mean Rank*],[*Median (min)*],[*Mean (min)*],
    [appload],[235],[4187.53],[2.88],[2.32],
    [backbtn],[165],[4311.68],[2.91],[2.41],
    [clickrow],[290],[3183.09],[1.54],[1.72],
    [fwdbtn],[2249],[3167.78],[0.98],[1.64],
    [playbtn],[93],[4048.12],[2.80],[2.07],
    [remote],[4],[1964.25],[0.61],[0.68],
    [trackdone],[5525],[4986.29],[3.09],[2.79],
    [trackerror],[7],[5812.21],[3.63],[3.09],
    [unknown],[143],[1593.84],[0.50],[0.41],
  )
)

#figure(
  caption: "Alexandra: Dunn's Post-hoc Test (Bonferroni, m = 36 comparisons, α = 0.05) — Significant Pairs Only",
  table(
    columns: 5,
    align: left,
    [*Group 1*],[*Group 2*],[*z*],[*p (raw)*],[*p (Bonf)*],
    [appload],[clickrow],[4.55],[< 0.0001],[0.0002],
    [appload],[fwdbtn],[5.91],[< 0.0001],[< 0.0001],
    [appload],[trackdone],[-4.77],[< 0.0001],[< 0.0001],
    [appload],[unknown],[9.72],[< 0.0001],[< 0.0001],
    [backbtn],[clickrow],[4.60],[< 0.0001],[0.0002],
    [backbtn],[fwdbtn],[5.64],[< 0.0001],[< 0.0001],
    [backbtn],[trackdone],[-3.40],[0.0007],[0.0247],
    [backbtn],[unknown],[9.46],[< 0.0001],[< 0.0001],
    [clickrow],[trackdone],[-11.90],[< 0.0001],[< 0.0001],
    [clickrow],[unknown],[6.18],[< 0.0001],[< 0.0001],
    [fwdbtn],[playbtn],[-3.31],[0.0009],[0.0338],
    [fwdbtn],[trackdone],[-28.91],[< 0.0001],[< 0.0001],
    [fwdbtn],[unknown],[7.26],[< 0.0001],[< 0.0001],
    [playbtn],[trackdone],[-3.57],[0.0004],[0.0130],
    [playbtn],[unknown],[7.33],[< 0.0001],[< 0.0001],
    [trackdone],[unknown],[15.93],[< 0.0001],[< 0.0001],
    [trackerror],[unknown],[4.33],[< 0.0001],[0.0005],
  )
)

#figure(
  caption: "Koren: Kruskal-Wallis H Test by Reason Start (H = 8181.87, df = 8, p < 0.0001)",
  table(
    columns: 5,
    align: left,
    [*Reason Start*],[*n*],[*Mean Rank*],[*Median (min)*],[*Mean (min)*],
    [appload],[88],[8462.18],[1.27],[1.86],
    [backbtn],[436],[6585.78],[0.29],[1.20],
    [clickrow],[1623],[6816.51],[0.14],[0.85],
    [fwdbtn],[7172],[5248.86],[0.02],[0.83],
    [playbtn],[451],[9032.44],[1.17],[2.33],
    [remote],[85],[8324.12],[0.52],[1.78],
    [trackdone],[7118],[12521.17],[4.99],[4.65],
    [trackerror],[149],[4292.32],[0.02],[0.53],
    [unknown],[20],[3107.68],[0.02],[0.04],
  )
)

#figure(
  caption: "Koren: Dunn's Post-hoc Test (Bonferroni, m = 36 comparisons, α = 0.05) — Significant Pairs Only",
  table(
    columns: 5,
    align: left,
    [*Group 1*],[*Group 2*],[*z*],[*p (raw)*],[*p (Bonf)*],
    [appload],[backbtn],[3.24],[0.0012],[0.0423],
    [appload],[fwdbtn],[6.05],[< 0.0001],[< 0.0001],
    [appload],[trackdone],[-7.65],[< 0.0001],[< 0.0001],
    [appload],[trackerror],[6.27],[< 0.0001],[< 0.0001],
    [appload],[unknown],[4.37],[< 0.0001],[0.0005],
    [backbtn],[fwdbtn],[5.48],[< 0.0001],[< 0.0001],
    [backbtn],[playbtn],[-7.36],[< 0.0001],[< 0.0001],
    [backbtn],[trackdone],[-24.31],[< 0.0001],[< 0.0001],
    [backbtn],[trackerror],[4.88],[< 0.0001],[< 0.0001],
    [clickrow],[fwdbtn],[11.52],[< 0.0001],[< 0.0001],
    [clickrow],[playbtn],[-8.41],[< 0.0001],[< 0.0001],
    [clickrow],[trackdone],[-41.91],[< 0.0001],[< 0.0001],
    [clickrow],[trackerror],[5.96],[< 0.0001],[< 0.0001],
    [clickrow],[unknown],[3.33],[0.0009],[0.0311],
    [fwdbtn],[playbtn],[-15.75],[< 0.0001],[< 0.0001],
    [fwdbtn],[remote],[-5.70],[< 0.0001],[< 0.0001],
    [fwdbtn],[trackdone],[-87.84],[< 0.0001],[< 0.0001],
    [playbtn],[trackdone],[-14.52],[< 0.0001],[< 0.0001],
    [playbtn],[trackerror],[10.14],[< 0.0001],[< 0.0001],
    [playbtn],[unknown],[5.24],[< 0.0001],[< 0.0001],
    [remote],[trackdone],[-7.77],[< 0.0001],[< 0.0001],
    [remote],[trackerror],[5.99],[< 0.0001],[< 0.0001],
    [remote],[unknown],[4.24],[< 0.0001],[0.0008],
    [trackdone],[trackerror],[20.09],[< 0.0001],[< 0.0001],
    [trackdone],[unknown],[8.50],[< 0.0001],[< 0.0001],
  )
)


== genre stuff

Unique Genres

#table(
  columns: 4,
  align: left,
  [*User*],[*All-Time*],[*2024*],[*2025*],
  [Anthony],[290],[207],[180],
  [Alan],[407],[298],[267],
  [Alexandra],[322],[233],[231],
  [Koren],[531],[354],[368],
)

Top Genres

Anthony

#table(
  columns: 4,
  align: left,
  fill: (col, row) => {
    if row in (0, 12, 23) { gray.lighten(80%) } else { white }
  },
  table.cell(colspan: 4, align: center)[*All-Time*],
  [*Genre*],[*Plays*],[*Percentage*],[*Cumulative Percentage*],
  [trap],[49947],[17.65%],[17.65%],
  [hip hop],[45588],[16.11%],[33.75%],
  [pop rap],[31026],[10.96%],[44.72%],
  [contemporary r&b],[13847],[4.89%],[49.61%],
  [pop],[12273],[4.34%],[53.95%],
  [southern hip hop],[9899],[3.50%],[57.44%],
  [abstract hip hop],[8410],[2.97%],[60.41%],
  [gangsta rap],[8329],[2.94%],[63.36%],
  [electronic],[7538],[2.66%],[66.02%],
  [chicago hip hop],[7341],[2.59%],[68.61%],
  table.cell(colspan: 4, align: center)[*2024*],
  [trap],[8009],[18.06%],[18.06%],
  [hip hop],[7568],[17.07%],[35.12%],
  [pop rap],[5083],[11.46%],[46.59%],
  [contemporary r&b],[2088],[4.71%],[51.29%],
  [southern hip hop],[2073],[4.67%],[55.97%],
  [pop],[1625],[3.66%],[59.63%],
  [gangsta rap],[1174],[2.65%],[62.28%],
  [abstract hip hop],[1108],[2.50%],[64.78%],
  [electronic],[1017],[2.29%],[67.07%],
  [chicago hip hop],[964],[2.17%],[69.25%],
  table.cell(colspan: 4, align: center)[*2025*],
  [trap],[9622],[18.07%],[18.07%],
  [hip hop],[7419],[13.93%],[31.99%],
  [pop rap],[6038],[11.34%],[43.33%],
  [contemporary r&b],[2939],[5.52%],[48.85%],
  [pop],[2077],[3.90%],[52.75%],
  [gangsta rap],[1621],[3.04%],[55.79%],
  [southern hip hop],[1544],[2.90%],[58.69%],
  [abstract hip hop],[1520],[2.85%],[61.54%],
  [electronic],[1419],[2.66%],[64.21%],
  [rage],[1314],[2.47%],[66.67%],
)

#image("../data/genre_stats/plots/genre_top20_dasucc_all_time.png", width: 80%)
#image("../data/genre_stats/plots/genre_top20_dasucc_2024.png", width: 80%)
#image("../data/genre_stats/plots/genre_top20_dasucc_2025.png", width: 80%)

Alan

#table(
  columns: 4,
  align: left,
  fill: (col, row) => {
    if row in (0, 12, 23) { gray.lighten(80%) } else { white }
  },
  table.cell(colspan: 4, align: center)[*All-Time*],
  [*Genre*],[*Plays*],[*Percentage*],[*Cumulative Percentage*],
  [hip hop],[230824],[12.08%],[12.08%],
  [trap],[196373],[10.28%],[22.37%],
  [pop rap],[151720],[7.94%],[30.31%],
  [abstract hip hop],[79559],[4.17%],[34.47%],
  [conscious hip hop],[66423],[3.48%],[37.95%],
  [alternative hip hop],[64297],[3.37%],[41.32%],
  [pop],[62271],[3.26%],[44.58%],
  [electronic],[57806],[3.03%],[47.60%],
  [jazz rap],[55206],[2.89%],[50.49%],
  [soul],[52239],[2.73%],[53.23%],
  table.cell(colspan: 4, align: center)[*2024*],
  [hip hop],[21133],[9.14%],[9.14%],
  [alternative hip hop],[10555],[4.56%],[13.70%],
  [conscious hip hop],[10020],[4.33%],[18.03%],
  [boom bap],[9294],[4.02%],[22.05%],
  [jazz rap],[8874],[3.84%],[25.89%],
  [trap],[8786],[3.80%],[29.69%],
  [pop rap],[8375],[3.62%],[33.31%],
  [abstract hip hop],[7269],[3.14%],[36.45%],
  [east coast hip hop],[6150],[2.66%],[39.11%],
  [alternative rock],[5570],[2.41%],[41.52%],
  table.cell(colspan: 4, align: center)[*2025*],
  [hip hop],[9677],[8.26%],[8.26%],
  [conscious hip hop],[4847],[4.14%],[12.40%],
  [trap],[4638],[3.96%],[16.36%],
  [alternative hip hop],[4451],[3.80%],[20.16%],
  [boom bap],[4413],[3.77%],[23.93%],
  [pop rap],[4245],[3.62%],[27.55%],
  [abstract hip hop],[3532],[3.02%],[30.57%],
  [jazz rap],[3491],[2.98%],[33.55%],
  [experimental hip hop],[3405],[2.91%],[36.46%],
  [east coast hip hop],[3333],[2.85%],[39.30%],
)

#image("../data/genre_stats/plots/genre_top20_alanjzamora_all_time.png", width: 80%)
#image("../data/genre_stats/plots/genre_top20_alanjzamora_2024.png", width: 80%)
#image("../data/genre_stats/plots/genre_top20_alanjzamora_2025.png", width: 80%)

Alexandra

#table(
  columns: 4,
  align: left,
  fill: (col, row) => {
    if row in (0, 12, 23) { gray.lighten(80%) } else { white }
  },
  table.cell(colspan: 4, align: center)[*All-Time*],
  [*Genre*],[*Plays*],[*Percentage*],[*Cumulative Percentage*],
  [pop punk],[55254],[11.81%],[11.81%],
  [alternative rock],[52820],[11.29%],[23.10%],
  [pop rock],[31380],[6.71%],[29.80%],
  [post hardcore],[25682],[5.49%],[35.29%],
  [metalcore],[22943],[4.90%],[40.19%],
  [punk rock],[22273],[4.76%],[44.95%],
  [electro pop],[17535],[3.75%],[48.70%],
  [indie rock],[13087],[2.80%],[51.50%],
  [hard rock],[12938],[2.76%],[54.26%],
  [alternative metal],[12193],[2.61%],[56.87%],
  table.cell(colspan: 4, align: center)[*2024*],
  [metalcore],[4514],[10.19%],[10.19%],
  [pop punk],[4449],[10.04%],[20.23%],
  [post hardcore],[3777],[8.52%],[28.75%],
  [alternative rock],[3760],[8.49%],[37.24%],
  [punk rock],[2063],[4.66%],[41.90%],
  [pop rock],[1890],[4.27%],[46.16%],
  [alternative metal],[1727],[3.90%],[50.06%],
  [hard rock],[1532],[3.46%],[53.52%],
  [metal],[1198],[2.70%],[56.22%],
  [deathcore],[1129],[2.55%],[58.77%],
  table.cell(colspan: 4, align: center)[*2025*],
  [pop punk],[3158],[10.28%],[10.28%],
  [metalcore],[2873],[9.35%],[19.63%],
  [alternative rock],[2725],[8.87%],[28.50%],
  [post hardcore],[2479],[8.07%],[36.57%],
  [punk rock],[1442],[4.69%],[41.26%],
  [pop rock],[1368],[4.45%],[45.71%],
  [hard rock],[1174],[3.82%],[49.53%],
  [alternative metal],[1006],[3.27%],[52.81%],
  [deathcore],[715],[2.33%],[55.13%],
  [hip hop],[708],[2.30%],[57.44%],
)

#image("../data/genre_stats/plots/genre_top20_alexxxxxrs_all_time.png", width: 80%)
#image("../data/genre_stats/plots/genre_top20_alexxxxxrs_2024.png", width: 80%)
#image("../data/genre_stats/plots/genre_top20_alexxxxxrs_2025.png", width: 80%)

Koren

#table(
  columns: 4,
  align: left,
  fill: (col, row) => {
    if row in (0, 12, 23) { gray.lighten(80%) } else { white }
  },
  table.cell(colspan: 4, align: center)[*All-Time*],
  [*Genre*],[*Plays*],[*Percentage*],[*Cumulative Percentage*],
  [trap],[98095],[15.85%],[15.85%],
  [hip hop],[72280],[11.68%],[27.54%],
  [pop rap],[30067],[4.86%],[32.40%],
  [underground trap],[22523],[3.64%],[36.04%],
  [rage],[21675],[3.50%],[39.54%],
  [cloud rap],[21215],[3.43%],[42.97%],
  [drum and bass],[21159],[3.42%],[46.39%],
  [plugg],[18131],[2.93%],[49.32%],
  [drill],[14320],[2.31%],[51.63%],
  [liquid funk],[14305],[2.31%],[53.95%],
  table.cell(colspan: 4, align: center)[*2024*],
  [drum and bass],[7212],[16.86%],[16.86%],
  [liquid funk],[4760],[11.13%],[27.99%],
  [jungle],[4614],[10.79%],[38.77%],
  [jazz fusion],[1597],[3.73%],[42.50%],
  [trap],[1471],[3.44%],[45.94%],
  [math rock],[1179],[2.76%],[48.70%],
  [underground trap],[1067],[2.49%],[51.19%],
  [hip hop],[1046],[2.45%],[53.64%],
  [post rock],[996],[2.33%],[55.97%],
  [plugg],[863],[2.02%],[57.98%],
  table.cell(colspan: 4, align: center)[*2025*],
  [drum and bass],[5726],[10.72%],[10.72%],
  [trap],[5210],[9.76%],[20.48%],
  [liquid funk],[3698],[6.93%],[27.41%],
  [jungle],[3487],[6.53%],[33.94%],
  [underground trap],[2576],[4.82%],[38.76%],
  [hip hop],[2286],[4.28%],[43.04%],
  [plugg],[2241],[4.20%],[47.24%],
  [rage],[2181],[4.08%],[51.32%],
  [math rock],[1450],[2.72%],[54.04%],
  [cloud rap],[1432],[2.68%],[56.72%],
)

#image("../data/genre_stats/plots/genre_top20_korenns_all_time.png", width: 80%)
#image("../data/genre_stats/plots/genre_top20_korenns_2024.png", width: 80%)
#image("../data/genre_stats/plots/genre_top20_korenns_2025.png", width: 80%)

Genres vs. Plays

=== Anthony

==== All-Time

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[trap],[49947],[1342],[hip hop],[1495],[45588],
  [2],[hip hop],[45588],[1495],[trap],[1342],[49947],
  [3],[pop rap],[31026],[559],[pop rap],[559],[31026],
  [4],[contemporary r&b],[13847],[419],[southern hip hop],[420],[9899],
  [5],[pop],[12273],[249],[contemporary r&b],[419],[13847],
  [6],[southern hip hop],[9899],[420],[gangsta rap],[309],[8329],
  [7],[abstract hip hop],[8410],[39],[pop],[249],[12273],
  [8],[gangsta rap],[8329],[309],[west coast hip hop],[194],[3620],
  [9],[electronic],[7538],[102],[east coast hip hop],[185],[3265],
  [10],[chicago hip hop],[7341],[30],[dance pop],[180],[2265],
)

*Top by plays:* trap (49947 plays, 1342 artists)

*Top by artists:* hip hop (1495 artists, 45588 plays)

*Diverges:* YES

==== 2024

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[trap],[8009],[214],[hip hop],[246],[7568],
  [2],[hip hop],[7568],[246],[trap],[214],[8009],
  [3],[pop rap],[5083],[99],[pop rap],[99],[5083],
  [4],[contemporary r&b],[2088],[80],[contemporary r&b],[80],[2088],
  [5],[southern hip hop],[2073],[79],[southern hip hop],[79],[2073],
  [6],[pop],[1625],[62],[gangsta rap],[64],[1174],
  [7],[gangsta rap],[1174],[64],[pop],[62],[1625],
  [8],[abstract hip hop],[1108],[5],[dance pop],[50],[417],
  [9],[electronic],[1017],[22],[west coast hip hop],[35],[769],
  [10],[chicago hip hop],[964],[4],[east coast hip hop],[28],[360],
)

*Top by plays:* trap (8009 plays, 214 artists)

*Top by artists:* hip hop (246 artists, 7568 plays)

*Diverges:* YES

==== 2025

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[trap],[9622],[270],[trap],[270],[9622],
  [2],[hip hop],[7419],[263],[hip hop],[263],[7419],
  [3],[pop rap],[6038],[97],[pop rap],[97],[6038],
  [4],[contemporary r&b],[2939],[75],[contemporary r&b],[75],[2939],
  [5],[pop],[2077],[40],[southern hip hop],[67],[1544],
  [6],[gangsta rap],[1621],[53],[gangsta rap],[53],[1621],
  [7],[southern hip hop],[1544],[67],[west coast hip hop],[42],[598],
  [8],[abstract hip hop],[1520],[6],[pop],[40],[2077],
  [9],[electronic],[1419],[25],[dance pop],[31],[623],
  [10],[rage],[1314],[17],[alternative r&b],[31],[849],
)

*Top by plays:* trap (9622 plays, 270 artists)

*Top by artists:* trap (270 artists, 9622 plays)

*Diverges:* NO

=== Alan

==== All-Time

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[hip hop],[230824],[1291],[hip hop],[1291],[230824],
  [2],[trap],[196373],[909],[trap],[909],[196373],
  [3],[pop rap],[151720],[506],[pop rap],[506],[151720],
  [4],[abstract hip hop],[79559],[142],[contemporary r&b],[431],[38942],
  [5],[conscious hip hop],[66423],[236],[pop],[389],[62271],
  [6],[alternative hip hop],[64297],[334],[alternative hip hop],[334],[64297],
  [7],[pop],[62271],[389],[dance pop],[275],[14043],
  [8],[electronic],[57806],[232],[indie pop],[239],[13967],
  [9],[jazz rap],[55206],[180],[indie rock],[237],[21925],
  [10],[soul],[52239],[202],[electro pop],[236],[10631],
)

*Top by plays:* hip hop (230824 plays, 1291 artists)

*Top by artists:* hip hop (1291 artists, 230824 plays)

*Diverges:* NO

==== 2024

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[hip hop],[21133],[190],[hip hop],[190],[21133],
  [2],[alternative hip hop],[10555],[59],[lo fi hip hop],[83],[414],
  [3],[conscious hip hop],[10020],[41],[trap],[83],[8786],
  [4],[boom bap],[9294],[60],[soul],[65],[5471],
  [5],[jazz rap],[8874],[40],[indie rock],[64],[4513],
  [6],[trap],[8786],[83],[contemporary r&b],[64],[4355],
  [7],[pop rap],[8375],[51],[boom bap],[60],[9294],
  [8],[abstract hip hop],[7269],[30],[alternative hip hop],[59],[10555],
  [9],[east coast hip hop],[6150],[43],[pop rap],[51],[8375],
  [10],[alternative rock],[5570],[48],[pop],[50],[4431],
)

*Top by plays:* hip hop (21133 plays, 190 artists)

*Top by artists:* hip hop (190 artists, 21133 plays)

*Diverges:* NO

==== 2025

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[hip hop],[9677],[113],[hip hop],[113],[9677],
  [2],[conscious hip hop],[4847],[31],[trap],[63],[4638],
  [3],[trap],[4638],[63],[alternative hip hop],[39],[4451],
  [4],[alternative hip hop],[4451],[39],[electronic],[37],[2283],
  [5],[boom bap],[4413],[28],[pop rap],[36],[4245],
  [6],[pop rap],[4245],[36],[contemporary r&b],[35],[2150],
  [7],[abstract hip hop],[3532],[23],[soul],[34],[2329],
  [8],[jazz rap],[3491],[26],[alternative rock],[32],[2795],
  [9],[experimental hip hop],[3405],[16],[conscious hip hop],[31],[4847],
  [10],[east coast hip hop],[3333],[28],[indie rock],[30],[1562],
)

*Top by plays:* hip hop (9677 plays, 113 artists)

*Top by artists:* hip hop (113 artists, 9677 plays)

*Diverges:* NO

=== Alexandra

==== All-Time

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[pop punk],[55254],[1038],[alternative rock],[1295],[52820],
  [2],[alternative rock],[52820],[1295],[pop punk],[1038],[55254],
  [3],[pop rock],[31380],[537],[pop rock],[537],[31380],
  [4],[post hardcore],[25682],[509],[post hardcore],[509],[25682],
  [5],[metalcore],[22943],[502],[metalcore],[502],[22943],
  [6],[punk rock],[22273],[350],[indie rock],[451],[13087],
  [7],[electro pop],[17535],[297],[pop],[421],[8966],
  [8],[indie rock],[13087],[451],[emo],[388],[9828],
  [9],[hard rock],[12938],[361],[indie pop],[367],[6203],
  [10],[alternative metal],[12193],[298],[hard rock],[361],[12938],
)

*Top by plays:* pop punk (55254 plays, 1038 artists)

*Top by artists:* alternative rock (1295 artists, 52820 plays)

*Diverges:* YES

==== 2024

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[metalcore],[4514],[104],[alternative rock],[149],[3760],
  [2],[pop punk],[4449],[125],[pop punk],[125],[4449],
  [3],[post hardcore],[3777],[76],[metalcore],[104],[4514],
  [4],[alternative rock],[3760],[149],[post hardcore],[76],[3777],
  [5],[punk rock],[2063],[44],[pop rock],[58],[1890],
  [6],[pop rock],[1890],[58],[emo],[55],[860],
  [7],[alternative metal],[1727],[54],[alternative metal],[54],[1727],
  [8],[hard rock],[1532],[47],[pop],[51],[433],
  [9],[metal],[1198],[13],[hard rock],[47],[1532],
  [10],[deathcore],[1129],[35],[punk rock],[44],[2063],
)

*Top by plays:* metalcore (4514 plays, 104 artists)

*Top by artists:* alternative rock (149 artists, 3760 plays)

*Diverges:* YES

==== 2025

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[pop punk],[3158],[121],[alternative rock],[141],[2725],
  [2],[metalcore],[2873],[98],[pop punk],[121],[3158],
  [3],[alternative rock],[2725],[141],[metalcore],[98],[2873],
  [4],[post hardcore],[2479],[67],[post hardcore],[67],[2479],
  [5],[punk rock],[1442],[42],[pop rock],[52],[1368],
  [6],[pop rock],[1368],[52],[alternative metal],[51],[1006],
  [7],[hard rock],[1174],[49],[hard rock],[49],[1174],
  [8],[alternative metal],[1006],[51],[emo],[47],[625],
  [9],[deathcore],[715],[32],[punk rock],[42],[1442],
  [10],[hip hop],[708],[27],[pop],[41],[396],
)

*Top by plays:* pop punk (3158 plays, 121 artists)

*Top by artists:* alternative rock (141 artists, 2725 plays)

*Diverges:* YES

=== Koren

==== All-Time

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[trap],[98095],[2905],[hip hop],[3486],[72280],
  [2],[hip hop],[72280],[3486],[trap],[2905],[98095],
  [3],[pop rap],[30067],[826],[drum and bass],[885],[21159],
  [4],[underground trap],[22523],[764],[pop rap],[826],[30067],
  [5],[rage],[21675],[254],[underground trap],[764],[22523],
  [6],[cloud rap],[21215],[502],[electronic],[632],[6579],
  [7],[drum and bass],[21159],[885],[pop],[512],[5356],
  [8],[plugg],[18131],[398],[southern hip hop],[506],[12404],
  [9],[drill],[14320],[289],[contemporary r&b],[504],[7595],
  [10],[liquid funk],[14305],[408],[cloud rap],[502],[21215],
)

*Top by plays:* trap (98095 plays, 2905 artists)

*Top by artists:* hip hop (3486 artists, 72280 plays)

*Diverges:* YES

==== 2024

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[drum and bass],[7212],[194],[hip hop],[223],[1046],
  [2],[liquid funk],[4760],[87],[trap],[198],[1471],
  [3],[jungle],[4614],[103],[drum and bass],[194],[7212],
  [4],[jazz fusion],[1597],[42],[jungle],[103],[4614],
  [5],[trap],[1471],[198],[electronic],[101],[758],
  [6],[math rock],[1179],[43],[liquid funk],[87],[4760],
  [7],[underground trap],[1067],[86],[underground trap],[86],[1067],
  [8],[hip hop],[1046],[223],[jazz],[65],[486],
  [9],[post rock],[996],[33],[pop rap],[65],[341],
  [10],[plugg],[863],[54],[dub techno],[57],[344],
)

*Top by plays:* drum and bass (7212 plays, 194 artists)

*Top by artists:* hip hop (223 artists, 1046 plays)

*Diverges:* YES

==== 2025

#table(
  columns: 7,
  align: left,
  [*Rank*],[*By Play Count*],[*Plays*],[*Artists*],[*By Artist Count*],[*Artists*],[*Plays*],
  [1],[drum and bass],[5726],[201],[hip hop],[348],[2286],
  [2],[trap],[5210],[324],[trap],[324],[5210],
  [3],[liquid funk],[3698],[88],[drum and bass],[201],[5726],
  [4],[jungle],[3487],[105],[underground trap],[114],[2576],
  [5],[underground trap],[2576],[114],[jungle],[105],[3487],
  [6],[hip hop],[2286],[348],[liquid funk],[88],[3698],
  [7],[plugg],[2241],[65],[pop rap],[85],[1017],
  [8],[rage],[2181],[35],[electronic],[82],[660],
  [9],[math rock],[1450],[42],[plugg],[65],[2241],
  [10],[cloud rap],[1432],[64],[cloud rap],[64],[1432],
)

*Top by plays:* drum and bass (5726 plays, 201 artists)

*Top by artists:* hip hop (348 artists, 2286 plays)

*Diverges:* YES

Genre Histogram

Alan

All-Time

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_alanjzamora_alltime.png"),
  image("../data/genre_histogram/plots/genre_hist_log_alanjzamora_alltime.png"),
)

2024

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_alanjzamora_2024.png"),
  image("../data/genre_histogram/plots/genre_hist_log_alanjzamora_2024.png"),
)

2024

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_alanjzamora_2025.png"),
  image("../data/genre_histogram/plots/genre_hist_log_alanjzamora_2025.png"),
)

Anthony

All-Time

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_dasucc_alltime.png"),
  image("../data/genre_histogram/plots/genre_hist_log_dasucc_alltime.png"),
)

2024

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_dasucc_2024.png"),
  image("../data/genre_histogram/plots/genre_hist_log_dasucc_2024.png"),
)

2024

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_dasucc_2025.png"),
  image("../data/genre_histogram/plots/genre_hist_log_dasucc_2025.png"),
)

Alexandra

All-Time

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_alexxxxxrs_alltime.png"),
  image("../data/genre_histogram/plots/genre_hist_log_alexxxxxrs_alltime.png"),
)

2024

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_alexxxxxrs_2024.png"),
  image("../data/genre_histogram/plots/genre_hist_log_alexxxxxrs_2024.png"),
)

2024

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_alexxxxxrs_2025.png"),
  image("../data/genre_histogram/plots/genre_hist_log_alexxxxxrs_2025.png"),
)

Koren

All-Time

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_korenns_alltime.png"),
  image("../data/genre_histogram/plots/genre_hist_log_korenns_alltime.png"),
)

2024

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_korenns_2024.png"),
  image("../data/genre_histogram/plots/genre_hist_log_korenns_2024.png"),
)

2024

#grid(
  columns: 2,
  image("../data/genre_histogram/plots/genre_hist_linear_korenns_2025.png"),
  image("../data/genre_histogram/plots/genre_hist_log_korenns_2025.png"),
)

User vs. User Q-Q

#image("../data/genre_qq/plots/genre_qq_2025.png")

2025 Genres Lorenz Curve

#image("../data/genre_lorenz/plots/genre_lorenz_alanjzamora_2025.png", width: 80%)

*Gini:* 0.7886

#image("../data/genre_lorenz/plots/genre_lorenz_dasucc_2025.png", width: 80%)

*Gini:* 0.8776

#image("../data/genre_lorenz/plots/genre_lorenz_alexxxxxrs_2025.png", width: 80%)

*Gini:* 0.8478

#image("../data/genre_lorenz/plots/genre_lorenz_korenns_2025.png", width: 80%)

*Gini:* 0.8757

Genre Diversity

#table(
  columns: 4,
  align: left,
  fill: (col, row) => {
    if row in (0, 6, 11) { gray.lighten(80%) } else { white }
  },
  table.cell(colspan: 4, align: center)[*All-Time*],
  [*User*],[*Number of Genres*],[*Gini*],[*Entropy*],
  [Anthony],[290],[0.9249],[4.6444],
  [Alan],[407],[0.9101],[5.4565],
  [Alexandra],[322],[0.8802],[5.4580],
  [Koren],[531],[0.9079],[5.6271],
  table.cell(colspan: 4, align: center)[*2024*],
  [Anthony],[207],[0.8959],[4.5960],
  [Alan],[298],[0.8268],[6.0399],
  [Alexandra],[233],[0.8510],[5.3392],
  [Koren],[354],[0.8706],[5.4786],
  table.cell(colspan: 4, align: center)[*2025*],
  [Anthony],[180],[0.8776],[4.6969],
  [Alan],[267],[0.7886],[6.1883],
  [Alexandra],[231],[0.8478],[5.3743],
  [Koren],[368],[0.8757],[5.6191],
)

Top N Genre Share

#table(
  columns: 4,
  align: left,
  fill: (col, row) => {
    if row in (0, 6, 11) { gray.lighten(80%) } else { white }
  },
  table.cell(colspan: 4, align: center)[*All-Time*],
  [*User*],[*Top 1 Share*],[*Top 5 Share*],[*Top 10 Share*],
  [Anthony],[17.65%],[53.95%],[68.61%],
  [Alan],[12.08%],[37.95%],[53.23%],
  [Alexandra],[11.81%],[40.19%],[56.87%],
  [Koren],[15.85%],[39.54%],[53.95%],
  table.cell(colspan: 4, align: center)[*2024*],
  [Anthony],[18.06%],[55.97%],[69.25%],
  [Alan],[9.14%],[25.89%],[41.52%],
  [Alexandra],[10.19%],[41.90%],[58.77%],
  [Koren],[16.86%],[45.94%],[57.98%],
  table.cell(colspan: 4, align: center)[*2025*],
  [Anthony],[18.07%],[52.75%],[66.67%],
  [Alan],[8.26%],[23.93%],[39.30%],
  [Alexandra],[10.28%],[41.26%],[57.44%],
  [Koren],[10.72%],[38.76%],[56.72%],
)

#image("../data/genre_topn_share/plots/genre_topn_share_alanjzamora.png", width: 80%)
#image("../data/genre_topn_share/plots/genre_topn_share_dasucc.png", width: 80%)
#image("../data/genre_topn_share/plots/genre_topn_share_alexxxxxrs.png", width: 80%)
#image("../data/genre_topn_share/plots/genre_topn_share_korenns.png", width: 80%)

Monthly Genres

Alan

#table(
  columns: 4,
  align: left,
  [*Month*],[*Total Plays*],[*Top Genre Plays*],[*Top Genre*],
  [Jan],[2241],[691],[hip hop],
  [Feb],[3946],[1256],[hip hop],
  [Mar],[4254],[1508],[hip hop],
  [Apr],[1095],[374],[hip hop],
  [May],[1148],[314],[hip hop],
  [Jun],[1937],[615],[hip hop],
  [Jul],[2309],[667],[hip hop],
  [Aug],[2350],[810],[hip hop],
  [Sep],[3088],[1190],[hip hop],
  [Oct],[1935],[459],[hip hop],
  [Nov],[3226],[1171],[hip hop],
  [Dec],[1783],[622],[hip hop],
)

#image("../data/genre_monthly_top_2025/plots/genre_monthly_top_alanjzamora_2025.png")

Anthony

#table(
  columns: 4,
  align: left,
  [*Month*],[*Total Plays*],[*Top Genre Plays*],[*Top Genre*],
  [Jan],[1899],[1442],[trap],
  [Feb],[1967],[1194],[hip hop],
  [Mar],[1617],[1203],[trap],
  [Apr],[2270],[1589],[trap],
  [May],[1262],[846],[trap],
  [Jun],[1293],[908],[trap],
  [Jul],[1047],[783],[trap],
  [Aug],[821],[532],[hip hop],
  [Sep],[250],[211],[trap],
  [Oct],[405],[288],[trap],
  [Nov],[421],[302],[trap],
  [Dec],[451],[391],[trap],
)

#image("../data/genre_monthly_top_2025/plots/genre_monthly_top_dasucc_2025.png")

Alexandra

#table(
  columns: 4,
  align: left,
  [*Month*],[*Total Plays*],[*Top Genre Plays*],[*Top Genre*],
  [Jan],[947],[384],[metalcore],
  [Feb],[836],[324],[pop punk],
  [Mar],[779],[274],[pop punk],
  [Apr],[786],[272],[pop punk],
  [May],[1004],[377],[pop punk],
  [Jun],[504],[172],[pop punk],
  [Jul],[510],[185],[metalcore],
  [Aug],[599],[222],[pop punk],
  [Sep],[601],[214],[pop punk],
  [Oct],[682],[235],[pop punk],
  [Nov],[831],[305],[pop punk],
  [Dec],[632],[276],[pop punk],
)

#image("../data/genre_monthly_top_2025/plots/genre_monthly_top_alexxxxxrs_2025.png")

Koren

#table(
  columns: 4,
  align: left,
  [*Month*],[*Total Plays*],[*Top Genre Plays*],[*Top Genre*],
  [Jan],[1478],[585],[trap],
  [Feb],[2641],[783],[math rock],
  [Mar],[4059],[1777],[drum and bass],
  [Apr],[2045],[1047],[drum and bass],
  [May],[681],[403],[trap],
  [Jun],[570],[185],[drum and bass],
  [Jul],[887],[366],[drum and bass],
  [Aug],[881],[333],[trap],
  [Sep],[1211],[772],[drum and bass],
  [Oct],[1378],[441],[trap],
  [Nov],[443],[151],[drum and bass],
  [Dec],[851],[311],[trap],
)

#image("../data/genre_monthly_top_2025/plots/genre_monthly_top_korenns_2025.png")

Genre First Appearance

#image("../data/genre_first_appearance/plots/genre_first_appearance_alanjzamora.png")
#image("../data/genre_first_appearance/plots/genre_first_appearance_dasucc.png")
#image("../data/genre_first_appearance/plots/genre_first_appearance_alexxxxxrs.png")
#image("../data/genre_first_appearance/plots/genre_first_appearance_korenns.png")

Unique Genres Per Session

#table(
  columns: 8,
  align: left,
  [*User*],[*Number of Sessions*],[*Mean Genres*],[*Median Genres*],[*Range*],[*1 Genre*],[*5+ Genres*],[*10+ Genres*],
  [Alan],[1408],[20.38],[16.0],[$[1,104]$],[0.78%],[81.96%],[64.28%],
  [Anthony],[798],[14.80],[12.0],[$[1,75]$],[0.88%],[79.82%],[58.15%],
  [Alexandra],[1216],[13.64],[12.0],[$[1,63]$],[0.9%],[81.17%],[58.96%],
  [Koren],[1019],[13.30],[9.0],[$[1,154]$],[1.37%],[72.23%],[46.22%],
)

#image("../data/genre_session_variety_2025/plots/genre_session_variety_alanjzamora_2025.png", width: 80%)
#image("../data/genre_session_variety_2025/plots/genre_session_variety_dasucc_2025.png", width: 80%)
#image("../data/genre_session_variety_2025/plots/genre_session_variety_alexxxxxrs_2025.png", width: 80%)
#image("../data/genre_session_variety_2025/plots/genre_session_variety_korenns_2025.png", width: 80%)

Genre Discovery Rate 2025

Alan (2025, Total New Genres: 6)

#table(
  columns: 2,
  align: left,
  [*Month*],[*New Genres*],
  [Jan],[2],
  [Feb],[1],
  [Mar],[1],
  [Apr],[1],
  [May],[0],
  [Jun],[1],
  [Jul],[0],
  [Aug],[0],
  [Sep],[0],
  [Oct],[0],
  [Nov],[0],
  [Dec],[0],
)

#image("../data/genre_discovery_rate_2025/plots/genre_discovery_rate_2025_alanjzamora.png", width: 80%)

Anthony (2025, Total New Genres: 10)

#table(
  columns: 2,
  align: left,
  [*Month*],[*New Genres*],
  [Jan],[2],
  [Feb],[1],
  [Mar],[0],
  [Apr],[3],
  [May],[1],
  [Jun],[2],
  [Jul],[1],
  [Aug],[0],
  [Sep],[0],
  [Oct],[0],
  [Nov],[0],
  [Dec],[0],
)

#image("../data/genre_discovery_rate_2025/plots/genre_discovery_rate_2025_dasucc.png", width: 80%)

Alexandra (2025, Total New Genres: 3)

#table(
  columns: 2,
  align: left,
  [*Month*],[*New Genres*],
  [Jan],[0],
  [Feb],[1],
  [Mar],[2],
  [Apr],[0],
  [May],[0],
  [Jun],[0],
  [Jul],[0],
  [Aug],[0],
  [Sep],[0],
  [Oct],[0],
  [Nov],[0],
  [Dec],[0],
)

#image("../data/genre_discovery_rate_2025/plots/genre_discovery_rate_2025_alexxxxxrs.png", width: 80%)

Koren (2025, Total New Genres: 9)

#table(
  columns: 2,
  align: left,
  [*Month*],[*New Genres*],
  [Jan],[0],
  [Feb],[1],
  [Mar],[4],
  [Apr],[0],
  [May],[0],
  [Jun],[2],
  [Jul],[0],
  [Aug],[1],
  [Sep],[0],
  [Oct],[0],
  [Nov],[0],
  [Dec],[1],
)

#image("../data/genre_discovery_rate_2025/plots/genre_discovery_rate_2025_korenns.png", width: 80%)

Genre Discovery by Year

Alan  (total genres discovered: 407)

#table(
  columns: 3,
  align: left,
  [*Year*],[*New Genres*],[*Cumulative*],
  [2016],[108],[108],
  [2017],[26],[134],
  [2018],[13],[147],
  [2019],[56],[203],
  [2020],[60],[263],
  [2021],[33],[296],
  [2022],[36],[332],
  [2023],[42],[374],
  [2024],[26],[400],
  [2025],[6],[406],
  [2026],[1],[407],
)

#image("../data/genre_discovery_by_year/plots/genre_discovery_by_year_alanjzamora.png")

Anthony  (total genres discovered: 290)

#table(
  columns: 3,
  align: left,
  [*Year*],[*New Genres*],[*Cumulative*],
  [2020],[68],[68],
  [2021],[128],[196],
  [2022],[14],[210],
  [2023],[46],[256],
  [2024],[24],[280],
  [2025],[10],[290],
)

#image("../data/genre_discovery_by_year/plots/genre_discovery_by_year_dasucc.png")

Alexandra  (total genres discovered: 322)

#table(
  columns: 3,
  align: left,
  [*Year*],[*New Genres*],[*Cumulative*],
  [2015],[107],[107],
  [2016],[70],[177],
  [2017],[29],[206],
  [2018],[22],[228],
  [2019],[5],[233],
  [2020],[11],[244],
  [2021],[14],[258],
  [2022],[26],[284],
  [2023],[24],[308],
  [2024],[10],[318],
  [2025],[3],[321],
  [2026],[1],[322],
)

#image("../data/genre_discovery_by_year/plots/genre_discovery_by_year_alexxxxxrs.png")

Koren  (total genres discovered: 528)

#table(
  columns: 3,
  align: left,
  [*Year*],[*New Genres*],[*Cumulative*],
  [2016],[126],[126],
  [2017],[82],[208],
  [2018],[42],[250],
  [2019],[60],[310],
  [2020],[49],[359],
  [2021],[66],[425],
  [2022],[35],[460],
  [2023],[37],[497],
  [2024],[22],[519],
  [2025],[9],[528],
)

#image("../data/genre_discovery_by_year/plots/genre_discovery_by_year_korenns.png")

Average Play Time Per Genre

Note: Min 25 plays per genre

Alan (All-Time, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [dance rock],[2.92],[26],
  [rockabilly],[2.79],[51],
  [liquid funk],[2.51],[275],
  [digicore],[2.44],[457],
  [roots rock],[2.41],[111],
  [midwest emo],[2.40],[448],
  [dark wave],[2.37],[169],
  [dance punk],[2.35],[183],
  [country rock],[2.31],[117],
  [rap rock],[2.28],[119],
  [pop soul],[2.25],[1580],
  [alternative country],[2.20],[25],
  [soft pop],[2.14],[59],
  [drum and bass],[2.11],[430],
  [chillhop],[2.08],[48],
  [vocal jazz],[2.07],[516],
  [blues],[2.07],[652],
  [chillout],[2.02],[38],
  [electronic rock],[2.02],[558],
  [new jack swing],[1.99],[500],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_alanjzamora_alltime.png", width: 80%)

Alan (2024, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [pop reggae],[3.12],[26],
  [roots rock],[2.71],[68],
  [country rock],[2.67],[69],
  [rap rock],[2.57],[101],
  [afro jazz],[2.51],[25],
  [new age],[2.44],[62],
  [pop soul],[2.42],[518],
  [dark wave],[2.32],[29],
  [j pop],[2.19],[227],
  [nerdcore],[2.17],[35],
  [chillhop],[2.16],[43],
  [sophisti pop],[2.12],[280],
  [anime],[2.09],[35],
  [quiet storm],[2.06],[297],
  [j rock],[2.05],[48],
  [detroit hip hop],[2.05],[42],
  [smooth soul],[2.04],[294],
  [bebop],[2.00],[173],
  [blues],[1.98],[318],
  [hard bop],[1.96],[179],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_alanjzamora_2024.png", width: 80%)

Alan (2025, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [rockabilly],[2.99],[44],
  [punk rock],[2.95],[60],
  [grunge],[2.95],[60],
  [dance punk],[2.50],[159],
  [lo fi hip hop],[2.49],[67],
  [dark wave],[2.49],[78],
  [liquid funk],[2.45],[127],
  [digicore],[2.41],[405],
  [electronic rock],[2.41],[253],
  [midwest emo],[2.41],[389],
  [blues],[2.39],[214],
  [downtempo],[2.36],[58],
  [new jack swing],[2.34],[74],
  [country pop],[2.33],[78],
  [pop soul],[2.31],[796],
  [vocal jazz],[2.26],[159],
  [indietronica],[2.20],[283],
  [drum and bass],[2.20],[175],
  [gospel],[2.16],[363],
  [stoner rock],[2.16],[286],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_alanjzamora_2025.png", width: 80%)

Anthony (All-Time, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [bass house],[2.65],[145],
  [riddim],[2.62],[49],
  [houston rap],[2.42],[65],
  [melodic dubstep],[2.39],[71],
  [drum and bass],[2.32],[175],
  [chopped and screwed],[2.27],[36],
  [dubstep],[2.22],[257],
  [house],[2.21],[115],
  [uk garage],[2.15],[36],
  [chicano rap],[2.12],[74],
  [chicago hip hop],[2.09],[7341],
  [soul],[2.09],[7000],
  [electronic],[2.08],[7538],
  [abstract hip hop],[2.07],[8410],
  [brostep],[2.07],[50],
  [coke rap],[2.07],[35],
  [experimental],[2.07],[128],
  [psychedelia],[2.06],[80],
  [electro house],[2.03],[289],
  [future bass],[1.98],[244],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_dasucc_alltime.png", width: 80%)

Anthony (2024, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [hardcore hip hop],[2.57],[125],
  [jazz rap],[2.54],[467],
  [progressive house],[2.40],[54],
  [electro house],[2.40],[91],
  [conscious hip hop],[2.32],[836],
  [alternative hip hop],[2.22],[702],
  [house],[2.21],[32],
  [west coast hip hop],[2.19],[769],
  [neo soul],[2.19],[154],
  [chicago hip hop],[2.10],[964],
  [abstract hip hop],[2.06],[1108],
  [soul],[2.05],[907],
  [electronic],[2.04],[1017],
  [trap metal],[2.01],[59],
  [rap],[1.99],[141],
  [psychedelic hip hop],[1.98],[266],
  [edm],[1.96],[73],
  [mafioso rap],[1.93],[27],
  [bass house],[1.90],[44],
  [melodic hip hop],[1.89],[349],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_dasucc_2024.png", width: 80%)

Anthony (2025, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [horrorcore],[3.66],[56],
  [psychedelia],[3.58],[38],
  [synth pop],[3.27],[283],
  [psychedelic rock],[3.25],[30],
  [chicago hip hop],[3.12],[1276],
  [soul],[3.10],[1239],
  [electro pop],[3.09],[350],
  [electronic],[3.07],[1419],
  [bass house],[3.07],[94],
  [abstract hip hop],[3.05],[1520],
  [conscious hip hop],[2.97],[590],
  [riddim],[2.94],[38],
  [future bass],[2.94],[63],
  [house],[2.94],[52],
  [pop],[2.92],[2077],
  [jazz rap],[2.90],[400],
  [dirty south],[2.90],[286],
  [indie rock],[2.89],[131],
  [dance pop],[2.87],[623],
  [neo soul],[2.86],[280],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_dasucc_2025.png", width: 80%)

Alexandra (All-Time, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [folk metal],[3.82],[27],
  [blues],[3.75],[36],
  [melodic hip hop],[3.68],[84],
  [psychedelic hip hop],[3.68],[84],
  [abstract hip hop],[3.65],[87],
  [thrash metal],[3.29],[100],
  [riddim],[3.28],[71],
  [melodic metalcore],[3.15],[460],
  [complextro],[3.12],[80],
  [bass house],[3.09],[30],
  [glitch hop],[3.05],[71],
  [future funk],[3.05],[71],
  [electro soul],[3.05],[71],
  [bluegrass],[3.03],[62],
  [electronic dance music],[2.99],[63],
  [nu disco],[2.96],[51],
  [industrial metal],[2.93],[980],
  [death metal],[2.91],[667],
  [gothic metal],[2.91],[362],
  [rave],[2.89],[25],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_alexxxxxrs_alltime.png", width: 80%)

Alexandra (2024, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [blues],[3.76],[29],
  [post rock],[3.41],[89],
  [folk],[3.17],[52],
  [melodic dubstep],[3.15],[52],
  [electro house],[3.09],[66],
  [industrial metal],[3.09],[204],
  [future bass],[2.92],[62],
  [melodic metalcore],[2.89],[124],
  [soul],[2.88],[75],
  [hardcore],[2.88],[125],
  [gothic metal],[2.87],[114],
  [death metal],[2.82],[158],
  [slam],[2.80],[104],
  [symphonic metal],[2.78],[99],
  [heavy metal],[2.74],[378],
  [hardstyle],[2.71],[139],
  [east coast hip hop],[2.70],[26],
  [underground hip hop],[2.68],[25],
  [progressive metalcore],[2.67],[81],
  [progressive metal],[2.64],[173],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_alexxxxxrs_2024.png", width: 80%)

Alexandra (2025, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [folk metal],[3.77],[25],
  [post rock],[3.43],[37],
  [industrial metal],[3.21],[129],
  [brostep],[3.16],[54],
  [heavy metal],[3.07],[233],
  [future bass],[3.06],[30],
  [hardstyle],[3.06],[117],
  [gothic metal],[3.05],[60],
  [electro house],[3.02],[45],
  [electronic rock],[2.98],[156],
  [melodic metalcore],[2.95],[70],
  [hardcore],[2.90],[83],
  [house],[2.85],[27],
  [symphonic metal],[2.84],[54],
  [dubstep],[2.83],[303],
  [glam rock],[2.81],[26],
  [progressive metalcore],[2.79],[48],
  [slam],[2.76],[76],
  [deathcore],[2.75],[715],
  [horror punk],[2.73],[58],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_alexxxxxrs_2025.png", width: 80%)

Koren (All-Time, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [ambient dub],[5.98],[25],
  [darkcore],[4.88],[33],
  [deep techno],[4.76],[40],
  [autonomic],[4.63],[29],
  [dub techno],[4.24],[706],
  [breakbeat hardcore],[4.20],[369],
  [detroit techno],[4.16],[118],
  [mood music],[4.12],[35],
  [jazzstep],[4.03],[843],
  [deep tech],[3.75],[58],
  [techstep],[3.66],[276],
  [rave],[3.65],[276],
  [electronic punk],[3.40],[34],
  [liquid funk],[3.27],[14721],
  [chamber jazz],[3.25],[99],
  [drum and bass],[3.21],[21575],
  [minimal techno],[3.21],[602],
  [dub],[3.18],[454],
  [jungle],[3.07],[14082],
  [jazz fusion],[3.01],[3911],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_korenns_alltime.png", width: 80%)

Koren (2024, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [electro],[5.54],[40],
  [trance],[5.51],[58],
  [dub techno],[5.36],[344],
  [detroit techno],[4.88],[41],
  [acid techno],[4.69],[37],
  [minimal techno],[4.25],[210],
  [ambient techno],[4.24],[252],
  [techno],[4.19],[368],
  [deep house],[4.13],[159],
  [rave],[4.12],[61],
  [tech house],[4.10],[35],
  [uk bass],[3.88],[50],
  [jazzstep],[3.49],[339],
  [liquid funk],[3.45],[4920],
  [techstep],[3.43],[124],
  [drum and bass],[3.30],[7372],
  [progressive house],[3.25],[54],
  [jungle],[3.23],[4771],
  [breakbeat hardcore],[3.15],[89],
  [jazz fusion],[3.05],[1481],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_korenns_2024.png", width: 80%)

Koren (2025, Top 20 Genres by Average Minutes Played)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Average Minutes Played*],[*Plays*],
  [detroit techno],[6.12],[36],
  [jazzstep],[5.32],[245],
  [electro],[5.30],[30],
  [dub techno],[5.21],[161],
  [minimal techno],[5.10],[111],
  [techno],[5.06],[273],
  [liquid funk],[5.05],[3847],
  [industrial],[4.93],[47],
  [drum and bass],[4.83],[5875],
  [jungle],[4.78],[3610],
  [techstep],[4.74],[64],
  [breakbeat hardcore],[4.68],[204],
  [ambient techno],[4.67],[145],
  [dub],[4.59],[148],
  [electronica],[4.54],[49],
  [rave],[4.51],[106],
  [happy hardcore],[4.40],[49],
  [future funk],[4.12],[28],
  [breakbeat],[4.04],[257],
  [ambient],[3.90],[305],
)

#image("../data/genre_avg_ms_played/plots/genre_avg_ms_played_korenns_2025.png", width: 80%)

Genre vs. Skip Rate

#image("../data/genre_bool_flags_2025/plots/genre_skip_rate_alanjzamora_2025.png", width: 80%)
#image("../data/genre_bool_flags_2025/plots/genre_skip_rate_dasucc_2025.png", width: 80%)
#image("../data/genre_bool_flags_2025/plots/genre_skip_rate_alexxxxxrs_2025.png", width: 80%)
#image("../data/genre_bool_flags_2025/plots/genre_skip_rate_korenns_2025.png", width: 80%)

Genre Share Time

Alan

#image("../data/genre_share_time_2025/plots/genre_share_hour_alanjzamora.png", width: 80%)
#image("../data/genre_share_time_2025/plots/genre_share_dow_alanjzamora.png", width: 80%)
#image("../data/genre_share_time_2025/plots/genre_share_month_alanjzamora.png", width: 80%)

Anthony

#image("../data/genre_share_time_2025/plots/genre_share_hour_dasucc.png", width: 80%)
#image("../data/genre_share_time_2025/plots/genre_share_dow_dasucc.png", width: 80%)
#image("../data/genre_share_time_2025/plots/genre_share_month_dasucc.png", width: 80%)

Alexandra

#image("../data/genre_share_time_2025/plots/genre_share_hour_alexxxxxrs.png", width: 80%)
#image("../data/genre_share_time_2025/plots/genre_share_dow_alexxxxxrs.png", width: 80%)
#image("../data/genre_share_time_2025/plots/genre_share_month_alexxxxxrs.png", width: 80%)

Koren

#image("../data/genre_share_time_2025/plots/genre_share_hour_korenns.png", width: 80%)
#image("../data/genre_share_time_2025/plots/genre_share_dow_korenns.png", width: 80%)
#image("../data/genre_share_time_2025/plots/genre_share_month_korenns.png", width: 80%)

Genre Lifecycle

#image("../data/genre_lifecycle_alltime/plots/genre_lifecycle_alanjzamora.png")
#image("../data/genre_lifecycle_alltime/plots/genre_lifecycle_dasucc.png")
#image("../data/genre_lifecycle_alltime/plots/genre_lifecycle_alexxxxxrs.png")
#image("../data/genre_lifecycle_alltime/plots/genre_lifecycle_korenns.png")

Jaccard

All-Time (Minimum 25 Artist Plays)

Genre Set Sizes

#table(
  columns: 2,
  align: left,
  [*User*],[*Genre Set Size*],
  [Alan],[250],
  [Alexandra],[234],
  [Anthony],[103],
  [Koren],[291],
)

Pairwise Jaccard

#table(
  columns: 5,
  align: left,
  [*User A*],[*User B*],[*Intersection*],[*Union*],[*Jaccard*],
  [Alan],[Alexandra],[128],[356],[0.360],
  [Alan],[Anthony],[85],[268],[0.317],
  [Alan],[Koren],[172],[369],[0.466],
  [Alexandra],[Anthony],[57],[280],[0.204],
  [Alexandra],[Koren],[142],[383],[0.371],
  [Anthony],[Koren],[92],[302],[0.305],
)

#image("../data/genre_jaccard_similarity/genre_jaccard_alltime.png")

2024 (Minimum 25 Artist Plays)

Genre Set Sizes

#table(
  columns: 2,
  align: left,
  [*User*],[*Genre Set Size*],
  [Alan],[189],
  [Alexandra],[78],
  [Anthony],[58],
  [Koren],[90],
)

Pairwise Jaccard

#table(
  columns: 5,
  align: left,
  [*User A*],[*User B*],[*Intersection*],[*Union*],[*Jaccard*],
  [Alan],[Alexandra],[38],[229],[0.166],
  [Alan],[Anthony],[48],[199],[0.241],
  [Alan],[Koren],[49],[230],[0.213],
  [Alexandra],[Anthony],[16],[120],[0.133],
  [Alexandra],[Koren],[18],[150],[0.120],
  [Anthony],[Koren],[33],[115],[0.287],
)

#image("../data/genre_jaccard_similarity/genre_jaccard_2024.png")

2025 (Minimum 25 Artist Plays)

Genre Set Sizes

#table(
  columns: 2,
  align: left,
  [*User*],[*Genre Set Size*],
  [Alan],[171],
  [Alexandra],[71],
  [Anthony],[57],
  [Koren],[89],
)

Pairwise Jaccard

#table(
  columns: 5,
  align: left,
  [*User A*],[*User B*],[*Intersection*],[*Union*],[*Jaccard*],
  [Alan],[Alexandra],[31],[211],[0.147],
  [Alan],[Anthony],[43],[185],[0.232],
  [Alan],[Koren],[51],[209],[0.244],
  [Alexandra],[Anthony],[15],[113],[0.133],
  [Alexandra],[Koren],[19],[141],[0.135],
  [Anthony],[Koren],[38],[108],[0.352],
)

#image("../data/genre_jaccard_similarity/genre_jaccard_2025.png")

Cosine Similarity

All-Time:

#table(
  columns: 5,
  align: left,
  [*User*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Alan],[1.000],[0.002],[0.875],[0.268],
  [Alexandra],[0.002],[1.000],[0.000],[0.010],
  [Anthony],[0.875],[0.000],[1.000],[0.353],
  [Koren],[0.268],[0.010],[0.353],[1.000],
)

#image("../data/genre_cosine_similarity/genre_cosine_alltime.png")

2024:

#table(
  columns: 5,
  align: left,
  [*User*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Alan],[1.000],[0.003],[0.452],[0.035],
  [Alexandra],[0.003],[1.000],[0.001],[0.003],
  [Anthony],[0.452],[0.001],[1.000],[0.025],
  [Koren],[0.035],[0.003],[0.025],[1.000],
)

#image("../data/genre_cosine_similarity/genre_cosine_2024.png")

2025:

#table(
  columns: 5,
  align: left,
  [*User*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Alan],[1.000],[0.006],[0.242],[0.055],
  [Alexandra],[0.006],[1.000],[0.001],[0.011],
  [Anthony],[0.242],[0.001],[1.000],[0.190],
  [Koren],[0.055],[0.011],[0.190],[1.000],
)

#image("../data/genre_cosine_similarity/genre_cosine_2025.png")

Average Session Rate When Genre Dominates

#image("../data/genre_session_length_2025/plots/genre_session_length_alanjzamora.png")
#image("../data/genre_session_length_2025/plots/genre_session_length_dasucc.png")
#image("../data/genre_session_length_2025/plots/genre_session_length_alexxxxxrs.png")
#image("../data/genre_session_length_2025/plots/genre_session_length_korenns.png")

Genre Session Opening Rate

Alan

All-Time

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [hip hop],[7775],
  [trap],[6222],
  [pop rap],[5009],
  [abstract hip hop],[2903],
  [pop],[2324],
  [conscious hip hop],[2301],
  [electronic],[2072],
  [alternative hip hop],[2063],
  [soul],[1895],
  [jazz rap],[1828],
  [boom bap],[1718],
  [chicago hip hop],[1644],
  [contemporary r&b],[1299],
  [gangsta rap],[1280],
  [east coast hip hop],[1227],
  [melodic hip hop],[1173],
  [southern hip hop],[1045],
  [experimental hip hop],[908],
  [emo rap],[900],
  [alternative rock],[822],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_alanjzamora_alltime.png")

2024

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [hip hop],[614],
  [conscious hip hop],[286],
  [alternative hip hop],[281],
  [boom bap],[260],
  [pop rap],[259],
  [trap],[249],
  [abstract hip hop],[244],
  [jazz rap],[237],
  [east coast hip hop],[197],
  [alternative rock],[172],
  [contemporary r&b],[170],
  [soul],[155],
  [experimental hip hop],[145],
  [electronic],[138],
  [pop],[130],
  [neo soul],[127],
  [gangsta rap],[124],
  [indie pop],[121],
  [indie rock],[107],
  [dance pop],[104],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_alanjzamora_2024.png")

2025

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [hip hop],[438],
  [conscious hip hop],[212],
  [alternative hip hop],[207],
  [pop rap],[206],
  [trap],[194],
  [boom bap],[174],
  [alternative rock],[162],
  [abstract hip hop],[157],
  [contemporary r&b],[148],
  [jazz rap],[127],
  [experimental hip hop],[123],
  [east coast hip hop],[122],
  [dance pop],[118],
  [soul],[113],
  [electronic],[103],
  [pop],[91],
  [nu disco],[91],
  [gangsta rap],[91],
  [indie pop],[90],
  [neo soul],[89],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_alanjzamora_2025.png")

Anthony

All-Time

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [trap],[2076],
  [hip hop],[1929],
  [pop rap],[1249],
  [contemporary r&b],[605],
  [pop],[552],
  [abstract hip hop],[384],
  [gangsta rap],[346],
  [southern hip hop],[345],
  [electronic],[333],
  [chicago hip hop],[323],
  [soul],[306],
  [conscious hip hop],[173],
  [melodic rap],[166],
  [cloud rap],[163],
  [alternative hip hop],[162],
  [west coast hip hop],[158],
  [alternative r&b],[148],
  [emo rap],[145],
  [rage],[143],
  [drill],[141],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_dasucc_alltime.png")

2024

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [hip hop],[415],
  [trap],[413],
  [pop rap],[234],
  [contemporary r&b],[121],
  [southern hip hop],[83],
  [conscious hip hop],[77],
  [pop],[70],
  [alternative hip hop],[70],
  [west coast hip hop],[70],
  [jazz rap],[58],
  [gangsta rap],[49],
  [abstract hip hop],[48],
  [cloud rap],[38],
  [chicago hip hop],[37],
  [electronic],[35],
  [soul],[31],
  [rage],[26],
  [melodic hip hop],[25],
  [dance pop],[25],
  [melodic rap],[23],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_dasucc_2024.png")

2025

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [trap],[558],
  [hip hop],[450],
  [pop rap],[340],
  [contemporary r&b],[168],
  [pop],[144],
  [abstract hip hop],[125],
  [gangsta rap],[110],
  [electronic],[109],
  [soul],[98],
  [chicago hip hop],[97],
  [southern hip hop],[79],
  [rage],[74],
  [alternative r&b],[47],
  [punk rap],[43],
  [alternative hip hop],[42],
  [plugg],[40],
  [cloud rap],[39],
  [dance pop],[37],
  [conscious hip hop],[36],
  [melodic hip hop],[36],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_dasucc_2025.png")

Alexandra 

All-Time

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [pop punk],[4205],
  [alternative rock],[4041],
  [pop rock],[2352],
  [metalcore],[2325],
  [post hardcore],[2306],
  [punk rock],[1750],
  [electro pop],[1189],
  [hard rock],[1157],
  [alternative metal],[1086],
  [indie rock],[947],
  [emo],[740],
  [metal],[669],
  [deathcore],[669],
  [emo pop],[660],
  [power pop],[642],
  [pop],[626],
  [hip hop],[592],
  [rock],[501],
  [trap],[490],
  [nu metal],[454],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_alexxxxxrs_alltime.png")

2024

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [metalcore],[532],
  [post hardcore],[440],
  [pop punk],[431],
  [alternative rock],[365],
  [punk rock],[207],
  [pop rock],[198],
  [alternative metal],[194],
  [hard rock],[170],
  [deathcore],[138],
  [metal],[131],
  [hip hop],[118],
  [nu metal],[96],
  [emo],[91],
  [emo pop],[77],
  [electro pop],[71],
  [trap],[57],
  [indie rock],[56],
  [electronic],[50],
  [pop rap],[46],
  [pop],[45],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_alexxxxxrs_2024.png")

2025

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [pop punk],[433],
  [metalcore],[427],
  [alternative rock],[380],
  [post hardcore],[360],
  [punk rock],[204],
  [pop rock],[193],
  [hard rock],[181],
  [alternative metal],[140],
  [deathcore],[110],
  [metal],[106],
  [hip hop],[99],
  [electro pop],[93],
  [emo],[86],
  [trap],[80],
  [pop rap],[69],
  [easycore],[68],
  [nu metal],[67],
  [emo pop],[62],
  [pop],[61],
  [electronic],[58],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_alexxxxxrs_2025.png")

Koren

All-Time

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [trap],[5131],
  [hip hop],[3761],
  [drum and bass],[1610],
  [pop rap],[1515],
  [underground trap],[1303],
  [rage],[1156],
  [cloud rap],[1154],
  [liquid funk],[1106],
  [jungle],[1053],
  [plugg],[982],
  [drill],[777],
  [southern hip hop],[662],
  [gangsta rap],[643],
  [emo rap],[602],
  [alternative hip hop],[530],
  [punk rap],[520],
  [east coast hip hop],[510],
  [electronic],[467],
  [melodic hip hop],[449],
  [pluggnb],[439],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_korenns_alltime.png")

2024

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [drum and bass],[615],
  [liquid funk],[420],
  [jungle],[381],
  [jazz fusion],[106],
  [trap],[101],
  [plugg],[78],
  [math rock],[75],
  [underground trap],[71],
  [hip hop],[71],
  [post rock],[69],
  [electronic],[61],
  [jazzstep],[47],
  [jazz funk],[46],
  [cloud rap],[42],
  [jazz],[39],
  [dub techno],[39],
  [techno],[38],
  [ambient],[37],
  [rage],[37],
  [ambient techno],[32],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_korenns_2024.png")

2025

#table(
  columns: 2,
  align: left,
  [*Genre*],[*Session Opens*],
  [drum and bass],[470],
  [jungle],[305],
  [liquid funk],[294],
  [trap],[270],
  [underground trap],[132],
  [rage],[127],
  [plugg],[115],
  [hip hop],[99],
  [cloud rap],[87],
  [jazz fusion],[76],
  [punk rap],[76],
  [math rock],[75],
  [post rock],[70],
  [pop rap],[59],
  [jerk],[55],
  [pluggnb],[42],
  [electronic],[37],
  [indie rock],[28],
  [hyperpop],[27],
  [techno],[27],
)

#image("../data/genre_session_opening_rate/plots/genre_session_opening_korenns_2025.png")

Genre Transistions 2025

Alan (top transitions: genre_from -> genre_to, row-normalized)

#table(
  columns: 3,
  align: left,
  [*From*],[*To*],[*Probability*],
  [alternative rock],[alternative rock],[0.411],
  [indie pop],[indie pop],[0.277],
  [contemporary r&b],[contemporary r&b],[0.267],
  [hip hop],[hip hop],[0.218],
  [east coast hip hop],[hip hop],[0.214],
  [pop rap],[hip hop],[0.193],
  [experimental hip hop],[experimental hip hop],[0.192],
  [abstract hip hop],[hip hop],[0.186],
  [jazz rap],[hip hop],[0.184],
  [soul],[hip hop],[0.181],
  [alternative hip hop],[hip hop],[0.181],
  [trap],[hip hop],[0.179],
  [electronic],[hip hop],[0.174],
  [conscious hip hop],[hip hop],[0.170],
  [indie pop],[alternative rock],[0.168],
)

#image("../data/genre_transition_matrix_2025/plots/genre_transition_matrix_alanjzamora.png")

Anthony (top transitions: genre_from -> genre_to, row-normalized)

#table(
  columns: 3,
  align: left,
  [*From*],[*To*],[*Probability*],
  [rage],[trap],[0.298],
  [punk rap],[trap],[0.294],
  [trap],[trap],[0.287],
  [southern hip hop],[trap],[0.284],
  [gangsta rap],[trap],[0.282],
  [cloud rap],[trap],[0.268],
  [contemporary r&b],[trap],[0.247],
  [alternative r&b],[trap],[0.213],
  [hip hop],[trap],[0.210],
  [southern hip hop],[hip hop],[0.205],
  [hip hop],[hip hop],[0.202],
  [pop rap],[trap],[0.199],
  [contemporary r&b],[hip hop],[0.196],
  [gangsta rap],[hip hop],[0.190],
  [trap],[hip hop],[0.188],
)

#image("../data/genre_transition_matrix_2025/plots/genre_transition_matrix_dasucc.png")

Alexandra (top transitions: genre_from -> genre_to, row-normalized)

#table(
  columns: 3,
  align: left,
  [*From*],[*To*],[*Probability*],
  [pop punk],[pop punk],[0.168],
  [emo],[pop punk],[0.165],
  [metalcore],[metalcore],[0.161],
  [punk rock],[pop punk],[0.161],
  [alternative metal],[pop punk],[0.158],
  [alternative rock],[pop punk],[0.156],
  [post hardcore],[metalcore],[0.153],
  [hard rock],[pop punk],[0.152],
  [alternative rock],[alternative rock],[0.151],
  [pop rock],[pop punk],[0.150],
  [hard rock],[metalcore],[0.148],
  [deathcore],[pop punk],[0.147],
  [deathcore],[metalcore],[0.145],
  [alternative rock],[metalcore],[0.142],
  [post hardcore],[post hardcore],[0.141],
)

#image("../data/genre_transition_matrix_2025/plots/genre_transition_matrix_alexxxxxrs.png")

Koren (top transitions: genre_from -> genre_to, row-normalized)

#table(
  columns: 3,
  align: left,
  [*From*],[*To*],[*Probability*],
  [math rock],[math rock],[0.438],
  [post rock],[math rock],[0.437],
  [jungle],[drum and bass],[0.394],
  [liquid funk],[drum and bass],[0.392],
  [drum and bass],[drum and bass],[0.391],
  [post rock],[post rock],[0.364],
  [math rock],[post rock],[0.361],
  [hip hop],[trap],[0.276],
  [trap],[trap],[0.275],
  [liquid funk],[liquid funk],[0.265],
  [pop rap],[trap],[0.263],
  [jungle],[liquid funk],[0.261],
  [drum and bass],[liquid funk],[0.260],
  [rage],[trap],[0.256],
  [punk rap],[trap],[0.253],
)

#image("../data/genre_transition_matrix_2025/plots/genre_transition_matrix_korenns.png")

Genre Discoveries

Alan (26 genres from discovered artists, top 20 shown)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Artists*],[*Total Plays*],
  [soundtrack],[4],[246],
  [pop rock],[3],[370],
  [art rock],[2],[335],
  [progressive rock],[2],[335],
  [indietronica],[1],[160],
  [gangsta rap],[1],[74],
  [synth pop],[1],[37],
  [digicore],[1],[394],
  [mafioso rap],[1],[74],
  [anime],[1],[50],
  [pop],[1],[34],
  [contemporary r&b],[1],[35],
  [symphonic prog],[1],[60],
  [folk],[1],[35],
  [electronic rock],[1],[160],
  [gospel],[1],[34],
  [alternative pop],[1],[35],
  [country],[1],[34],
  [orchestral],[1],[37],
  [pop punk],[1],[394],
)

#image("../data/genre_of_discovered_artists_2025/plots/genre_of_discovered_alan.png")

Anthony (7 genres from discovered artists, top 7 shown)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Artists*],[*Total Plays*],
  [trap],[3],[187],
  [gospel hip hop],[2],[154],
  [hip hop],[2],[154],
  [crunk],[1],[33],
  [southern hip hop],[1],[33],
  [alternative hip hop],[1],[51],
  [experimental],[1],[103],
)

#image("../data/genre_of_discovered_artists_2025/plots/genre_of_discovered_anthony.png")

Alexandra (10 genres from discovered artists, top 10 shown)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Artists*],[*Total Plays*],
  [metalcore],[2],[149],
  [alternative rock],[1],[119],
  [hip hop],[1],[72],
  [melodic rap],[1],[72],
  [hard rock],[1],[30],
  [post hardcore],[1],[119],
  [alternative hip hop],[1],[72],
  [electronicore],[1],[119],
  [pop rap],[1],[72],
  [trap],[1],[72],
)

#image("../data/genre_of_discovered_artists_2025/plots/genre_of_discovered_alexandra.png")

Koren (11 genres from discovered artists, top 11 shown)

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Artists*],[*Total Plays*],
  [trap],[4],[489],
  [underground trap],[3],[552],
  [jerk],[3],[552],
  [cloud rap],[2],[195],
  [experimental hip hop],[1],[290],
  [math rock],[1],[93],
  [experimental],[1],[93],
  [post rock],[1],[93],
  [rage],[1],[42],
  [hip hop],[1],[123],
  [hyperpop],[1],[153],
)

#image("../data/genre_of_discovered_artists_2025/plots/genre_of_discovered_koren.png")

Genre Diversity vs New Artists 2025

#image("../data/genre_diversity_vs_new_artist_2025/plots/genre_diversity_vs_new_artist_alanjzamora.png")
#image("../data/genre_diversity_vs_new_artist_2025/plots/genre_diversity_vs_new_artist_dasucc.png")
#image("../data/genre_diversity_vs_new_artist_2025/plots/genre_diversity_vs_new_artist_alexxxxxrs.png")
#image("../data/genre_diversity_vs_new_artist_2025/plots/genre_diversity_vs_new_artist_korenns.png")

Genre PCA

#image("../data/genre_pca_2025/genre_pca_biplot_2025.png")

#table(
  columns: 3,
  align: left,
  [*PC1 Variance*],[*PC2 Variance*],[*Total Variance*],
  [58.8%],[28.4%],[87.2%],
)

User scores

#table(
  columns: 3,
  align: left,
  [*User*],[*PC1*],[*PC2*],
  [Alan],[0.0310],[-0.0747],
  [Alexandra],[-0.2575],[0.0083],
  [Anthony],[0.1245],[-0.1030],
  [Koren],[0.1020],[0.1694],
)

Top genre loadings by magnitude

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
  [underground trap],[0.0742],[0.2293],[0.2410],
  [punk rock],[-0.2002],[0.0124],[0.2006],
  [plugg],[0.0816],[0.1697],[0.1883],
  [pop rock],[-0.1873],[0.0049],[0.1873],
  [contemporary r&b],[0.0826],[-0.1518],[0.1728],
  [rage],[0.0963],[0.1356],[0.1664],
  [hard rock],[-0.1614],[0.0048],[0.1615],
  [abstract hip hop],[0.0603],[-0.1290],[0.1424],
  [math rock],[0.0378],[0.1341],[0.1394],
  [conscious hip hop],[0.0381],[-0.1130],[0.1193],
)

PC1 separates rock, punk, and metal preferences from hip hop and trap preferences, while PC2 separates drum and bass, jungle, and liquid funk from hip hop and contemporary R&B. Together, these two components explain 87.2% of total variance, so the biplot captures most of the structure in the genre distribution.

The loading geometry is consistent across related genre families. Rock-oriented genres cluster in the negative direction of PC1, hip hop and trap genres cluster in the positive direction of PC1, and drum and bass related genres align strongly with positive PC2 values. The relative arrow directions indicate high within-group correlation for rock genres, high within-group correlation for hip hop subgenres, and a clear separation between the drum and bass cluster and the other two families.

Alexandra has a strongly negative PC1 score and a near-zero PC2 score, which places her closest to the rock cluster and indicates a listening profile centered on rock, punk, and metalcore. Anthony has a strongly positive PC1 score and a negative PC2 score, which places him along the hip hop and trap direction with weaker alignment to drum and bass styles. Alan has a mildly positive PC1 score and a negative PC2 score, which indicates moderate hip hop and R&B alignment but a less extreme position than Anthony. Koren has positive PC1 and strongly positive PC2 scores, which places him closest to the drum and bass and jungle region while still retaining overlap with electronic and trap-adjacent genres.

PC2 is heavily influenced by drum and bass, which has the largest loading magnitude on that axis. This suggests that variation in drum and bass and closely related genres contributes substantially to user separation in the second component. The rock cluster remains tightly collinear on PC1, while hip hop-related loadings spread more across PC2, indicating meaningful variation within that family.

Genre Behavioral PCA

#table(
  columns: 3,
  align: left,
  [*PC1 Variance*],[*PC2 Variance*],[*Total Variance*],
  [43.8%],[22.8%],[66.6%],
)

Feature loadings

#table(
  columns: 3,
  align: left,
  [*Feature*],[*PC1*],[*PC2*],
  [plays],[0.3078],[-0.0122],
  [skip_rate],[0.4632],[0.2026],
  [shuffle_rate],[-0.2031],[-0.6053],
  [artist_entropy],[0.2243],[-0.6275],
  [genre_entropy],[0.5414],[-0.1623],
  [genre_gini],[-0.2965],[-0.3649],
  [top1_genre_share],[-0.4671],[0.1982],
)

#image("../data/genre_behavioral_pca_2025/plots/genre_behavioral_pca_alanjzamora.png")
#image("../data/genre_behavioral_pca_2025/plots/genre_behavioral_pca_dasucc.png")
#image("../data/genre_behavioral_pca_2025/plots/genre_behavioral_pca_alexxxxxrs.png")
#image("../data/genre_behavioral_pca_2025/plots/genre_behavioral_pca_korenns.png")

PC1 reflects a diversity versus concentration axis. Positive PC1 values align with higher genre entropy and higher skip rate, while negative PC1 values align with higher top-genre share and higher genre concentration. In practical terms, listeners on the positive side show broader genre spread, and listeners on the negative side show stronger genre loyalty.

PC2 reflects a listening mode axis. Strong negative loadings for artist_entropy and shuffle_rate indicate broad, randomized exploration, while positive loadings for skip_rate and top1_genre_share indicate a more selective and intentional style. This axis separates passive shuffle-heavy behavior from deliberate curation.

Including genre features changes the interpretation of the PCA in a meaningful way. Without genre dimensions, the dominant direction would be closer to pure activity volume, such as plays versus disengagement. With genre statistics included, the components capture structural differences in preference diversity and listening strategy, which makes user trajectories easier to interpret behaviorally.

Alan remains strongly positive on PC1 across the year, indicating consistently high diversity, and his PC2 values trend upward in the middle of the year, indicating periods of more selective listening. Alexandra stays negative on PC1 and strongly negative on PC2, which indicates concentrated genre taste combined with broad within-cluster exploration through shuffle. Anthony remains strongly negative on PC1 and shows large positive movement on PC2 over time, which indicates a shift from mixed behavior toward intentional, selective listening. Koren spans a wide range on both axes and crosses quadrants repeatedly, which indicates the most dynamic profile in the group, alternating between high-diversity phases and concentrated phases.

The model explains 66.6% of total variance, which is lower than the earlier genre-only PCA but still substantial for behavioral data. With 48 observations across 7 features, the sample-to-feature ratio is adequate for stable component estimates, while leaving room for additional higher-order structure that the first two components do not capture.

Genre Word Cloud 2025

Alan

#image("../data/genre_wordcloud_2025/plots/genre_wordcloud_alanjzamora.png")

Anthony

#image("../data/genre_wordcloud_2025/plots/genre_wordcloud_dasucc.png")

Alexandra

#image("../data/genre_wordcloud_2025/plots/genre_wordcloud_alexxxxxrs.png")

Koren

#image("../data/genre_wordcloud_2025/plots/genre_wordcloud_korenns.png")

Genre Artist Heatmap

Alan

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Top Artist*],[*Plays*],
  [hip hop],[Kanye West],[1179],
  [conscious hip hop],[Kendrick Lamar],[922],
  [trap],[Denzel Curry],[756],
  [alternative hip hop],[Kendrick Lamar],[922],
  [boom bap],[Danny Brown],[636],
  [pop rap],[Kanye West],[1179],
  [abstract hip hop],[Kanye West],[1179],
  [jazz rap],[Kendrick Lamar],[922],
  [experimental hip hop],[JPEGMAFIA],[1086],
  [east coast hip hop],[A Tribe Called Quest],[475],
  [alternative rock],[Fiona Apple],[594],
  [soul],[Kanye West],[1179],
  [electronic],[Kanye West],[1179],
  [contemporary r&b],[Jessie Ware],[794],
  [gangsta rap],[Freddie Gibbs],[585],
  [indie pop],[Sufjan Stevens],[469],
  [pop],[Kanye West],[1179],
  [dance pop],[Jessie Ware],[794],
  [cloud rap],[JPEGMAFIA],[1086],
  [indie rock],[Sufjan Stevens],[469],
)

#image("../data/genre_artist_heatmap_2025/plots/genre_artist_heatmap_alanjzamora.png")

Anthony

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Top Artist*],[*Plays*],
  [trap],[Playboi Carti],[639],
  [hip hop],[Kanye West],[1199],
  [pop rap],[Kanye West],[1199],
  [contemporary r&b],[Drake],[556],
  [pop],[Kanye West],[1199],
  [gangsta rap],[21 Savage],[313],
  [southern hip hop],[21 Savage],[313],
  [abstract hip hop],[Kanye West],[1199],
  [electronic],[Kanye West],[1199],
  [rage],[Playboi Carti],[639],
  [chicago hip hop],[Kanye West],[1199],
  [soul],[Kanye West],[1199],
  [cloud rap],[Gunna],[342],
  [punk rap],[Playboi Carti],[639],
  [alternative r&b],[The Weeknd],[271],
  [plugg],[Playboi Carti],[639],
  [melodic rap],[Lil Baby],[319],
  [alternative hip hop],[Kendrick Lamar],[321],
  [dance pop],[The Weeknd],[271],
  [west coast hip hop],[Kendrick Lamar],[321],
)

#image("../data/genre_artist_heatmap_2025/plots/genre_artist_heatmap_dasucc.png")

Alexandra

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Top Artist*],[*Plays*],
  [pop punk],[Neck Deep],[444],
  [metalcore],[Beartooth],[563],
  [alternative rock],[Neck Deep],[444],
  [post hardcore],[Beartooth],[563],
  [punk rock],[Beartooth],[563],
  [pop rock],[State Champs],[385],
  [hard rock],[Wage War],[306],
  [alternative metal],[Bring Me The Horizon],[284],
  [deathcore],[Bring Me The Horizon],[284],
  [hip hop],[Ashnikko],[233],
  [metal],[Beartooth],[563],
  [electro pop],[Ashnikko],[233],
  [emo],[My Chemical Romance],[94],
  [trap],[Ashnikko],[233],
  [nu metal],[Kim Dracula],[124],
  [pop rap],[Ashnikko],[233],
  [emo pop],[A Day To Remember],[79],
  [easycore],[WSTR],[195],
  [pop],[All Time Low],[60],
  [electronic],[Ashnikko],[233],
)

#image("../data/genre_artist_heatmap_2025/plots/genre_artist_heatmap_alexxxxxrs.png")

Koren

#table(
  columns: 3,
  align: left,
  [*Genre*],[*Top Artist*],[*Plays*],
  [drum and bass],[Mint],[463],
  [trap],[Playboi Carti],[1071],
  [liquid funk],[Mint],[463],
  [jungle],[Mint],[463],
  [underground trap],[Che],[290],
  [hip hop],[Drake],[114],
  [plugg],[Playboi Carti],[1071],
  [rage],[Playboi Carti],[1071],
  [math rock],[toe],[219],
  [cloud rap],[tenkay],[255],
  [punk rap],[Playboi Carti],[1071],
  [jerk],[Che],[290],
  [post rock],[toe],[219],
  [jazz fusion],[LTJ Bukem],[299],
  [pop rap],[Ken Carson],[143],
  [pluggnb],[Glokk40Spaz],[98],
  [electronic],[Calibre],[73],
  [underground hip hop],[tenkay],[255],
  [indie rock],[toe],[219],
  [experimental hip hop],[Che],[290],
)

#image("../data/genre_artist_heatmap_2025/plots/genre_artist_heatmap_korenns.png")

Genre Surprises

Alan  (overall surprise rate: 52.2%,  15310 / 29312 plays)

#table(
  columns: 4,
  align: left,
  [*Month*],[*Plays*],[*Surprising*],[*Rate*],
  [Jan],[2241],[1236],[55.2%],
  [Feb],[3946],[2219],[56.2%],
  [Mar],[4254],[2139],[50.3%],
  [Apr],[1095],[487],[44.5%],
  [May],[1148],[606],[52.8%],
  [Jun],[1937],[1105],[57.0%],
  [Jul],[2309],[1403],[60.8%],
  [Aug],[2350],[1170],[49.8%],
  [Sep],[3088],[1426],[46.2%],
  [Oct],[1935],[1141],[59.0%],
  [Nov],[3226],[1527],[47.3%],
  [Dec],[1783],[851],[47.7%],
)

#image("../data/genre_surprise_score_2025/plots/genre_surprise_score_alanjzamora.png")

Anthony  (overall surprise rate: 10.0%,  1367 / 13703 plays)

#table(
  columns: 4,
  align: left,
  [*Month*],[*Plays*],[*Surprising*],[*Rate*],
  [Jan],[1899],[57],[3.0%],
  [Feb],[1967],[299],[15.2%],
  [Mar],[1617],[176],[10.9%],
  [Apr],[2270],[337],[14.8%],
  [May],[1262],[175],[13.9%],
  [Jun],[1293],[90],[7.0%],
  [Jul],[1047],[102],[9.7%],
  [Aug],[821],[42],[5.1%],
  [Sep],[250],[2],[0.8%],
  [Oct],[405],[12],[3.0%],
  [Nov],[421],[71],[16.9%],
  [Dec],[451],[4],[0.9%],
)

#image("../data/genre_surprise_score_2025/plots/genre_surprise_score_dasucc.png")

Alexandra  (overall surprise rate: 29.7%,  2584 / 8711 plays)

#table(
  columns: 4,
  align: left,
  [*Month*],[*Plays*],[*Surprising*],[*Rate*],
  [Jan],[947],[273],[28.8%],
  [Feb],[836],[270],[32.3%],
  [Mar],[779],[225],[28.9%],
  [Apr],[786],[254],[32.3%],
  [May],[1004],[277],[27.6%],
  [Jun],[504],[147],[29.2%],
  [Jul],[510],[133],[26.1%],
  [Aug],[599],[199],[33.2%],
  [Sep],[601],[183],[30.4%],
  [Oct],[682],[206],[30.2%],
  [Nov],[831],[240],[28.9%],
  [Dec],[632],[177],[28.0%],
)

#image("../data/genre_surprise_score_2025/plots/genre_surprise_score_alexxxxxrs.png")

Koren  (overall surprise rate: 39.2%,  6707 / 17125 plays)

#table(
  columns: 4,
  align: left,
  [*Month*],[*Plays*],[*Surprising*],[*Rate*],
  [Jan],[1478],[555],[37.6%],
  [Feb],[2641],[1334],[50.5%],
  [Mar],[4059],[1216],[30.0%],
  [Apr],[2045],[216],[10.6%],
  [May],[681],[271],[39.8%],
  [Jun],[570],[346],[60.7%],
  [Jul],[887],[492],[55.5%],
  [Aug],[881],[332],[37.7%],
  [Sep],[1211],[392],[32.4%],
  [Oct],[1378],[904],[65.6%],
  [Nov],[443],[232],[52.4%],
  [Dec],[851],[417],[49.0%],
)

#image("../data/genre_surprise_score_2025/plots/genre_surprise_score_korenns.png")

K Means 2025

K-means on monthly user behavioral profiles

48 user-month observations, 6 features.

Cluster profiles (feature means, raw scale)

#table(
  columns: 8,
  align: left,
  [*Cluster*],[*n*],[*Plays*],[*Skip %*],[*Shuffle %*],[*Offline %*],[*Entropy*],[*New %*],
  [1],[15],[2094],[71.1],[48.3],[0.1],[6.29],[1.9],
  [2],[11],[1419],[55.9],[71.5],[0.2],[7.31],[7.1],
  [3],[20],[997],[29.8],[82.9],[0.7],[6.36],[1.3],
  [4],[2],[942],[50.5],[78.1],[11.1],[7.25],[1.6],
)

User-month assignments (compacted)

#table(
  columns: 5,
  align: left,
  [*User*],[*Cluster 1 Months*],[*Cluster 2 Months*],[*Cluster 3 Months*],[*Cluster 4 Months*],
  [Alan],[Jan, Feb, Mar, Apr, Jun, Jul, Aug, Sep, Oct, Nov, Dec],[May],[-],[-],
  [Alexandra],[-],[Jan],[Feb, Mar, Apr, Jun, Jul, Aug, Sep, Oct, Nov, Dec],[May],
  [Anthony],[Jun, Aug, Dec],[-],[Jan, Feb, Mar, Apr, May, Jul, Sep, Oct, Nov],[-],
  [Koren],[May],[Jan, Feb, Mar, Jun, Jul, Sep, Oct, Nov, Dec],[Apr],[Aug],
)

#image("../data/kmeans_behavioral_profiles_2025/plots/kmeans_behavioral_profiles_2025.png")

K-means on per-session genre profiles 

4441 sessions, 5 features.

Cluster profiles (feature means, raw scale)

#table(
  columns: 7,
  align: left,
  [*Cluster*],[*n*],[*Avg Min*],[*Skip %*],[*Unique Genres*],[*Top Genre Share*],[*Genre Entropy*],
  [1],[1305],[2.82],[17.2],[16.3],[16.7],[2.463],
  [2],[441],[5.35],[13.7],[8.8],[32.4],[1.626],
  [3],[819],[1.72],[11.6],[3.7],[36.2],[1.177],
  [4],[1160],[1.35],[81.9],[11.7],[21.3],[2.096],
  [5],[716],[1.38],[79.3],[39.9],[12.3],[3.224],
)

Sessions per cluster per user

#table(
  columns: 6,
  align: left,
  [*User*],[*Cluster 1*],[*Cluster 2*],[*Cluster 3*],[*Cluster 4*],[*Cluster 5*],
  [Alan],[131],[47],[191],[547],[492],
  [Alexandra],[723],[37],[255],[120],[81],
  [Anthony],[342],[34],[176],[186],[60],
  [Koren],[109],[323],[197],[307],[83],
)

#image("../data/kmeans_session_profiles_2025/plots/kmeans_session_profiles_pca_2025.png")
#image("../data/kmeans_session_profiles_2025/plots/kmeans_session_profiles_dist_2025.png")

K-means on user genre profiles

48 user-month observations over 19 genre families
Cluster profiles (mean genre family share %, raw; n=48 user-months)

#table(
  columns: 11,
  align: left,
  [*Cluster*],[*n*],[*Hip-Hop*],[*R&B*],[*Soul/Funk*],[*Electronic*],[*House*],[*Drum & Bass*],[*Pop*],[*Alternative*],[*Rock*],
  [1],[12],[48.2%],[4.3%],[4.7%],[4.5%],[0.3%],[0.1%],[11.2%],[6.4%],[3.7%],
  [2],[11],[34.2%],[1.5%],[8.7%],[3.1%],[3.0%],[19.0%],[3.1%],[1.4%],[5.3%],
  [3],[13],[71.2%],[8.1%],[2.5%],[3.6%],[0.4%],[0.8%],[5.6%],[0.3%],[0.1%],
  [4],[12],[9.0%],[0.7%],[0.6%],[6.2%],[0.3%],[1.2%],[20.6%],[13.6%],[12.0%],
)

#table(
  columns: 12,
  align: left,
  [*Cluster*],[*n*],[*Metal*],[*Punk/Emo*],[*Jazz*],[*Classical*],[*Country/Folk*],[*Latin*],[*K-Pop/J-Pop*],[*Reggae*],[*Ambient/Lo-Fi*],[*Other*],
  [1],[12],[0.1%],[1.2%],[1.4%],[0.4%],[1.1%],[0.0%],[0.1%],[0.2%],[0.3%],[11.8%],
  [2],[11],[0.1%],[0.5%],[3.9%],[0.0%],[0.1%],[0.2%],[0.0%],[0.8%],[0.7%],[14.5%],
  [3],[13],[0.0%],[0.0%],[0.1%],[0.0%],[0.0%],[0.0%],[0.0%],[0.2%],[0.0%],[7.1%],
  [4],[12],[18.9%],[12.7%],[0.0%],[0.0%],[0.2%],[0.0%],[0.0%],[0.1%],[0.0%],[3.8%],
)

User-month assignments (compacted)

#table(
  columns: 5,
  align: left,
  [*User*],[*Cluster 1 Months*],[*Cluster 2 Months*],[*Cluster 3 Months*],[*Cluster 4 Months*],
  [Alan],[Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec],[-],[-],[-],
  [Alexandra],[-],[-],[-],[Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec],
  [Anthony],[-],[-],[Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec],[-],
  [Koren],[-],[Jan, Feb, Mar, Apr, Jun, Jul, Aug, Sep, Oct, Nov, Dec],[May],[-],
)

#image("../data/kmeans_genre_profiles_2025/plots/kmeans_genre_profiles_pca_2025.png")
#image("../data/kmeans_genre_profiles_2025/plots/kmeans_genre_profiles_loadings_2025.png")

Hierarchical Clustering Dendrogram

#image("../data/hierarchical_clustering_users/plots/hierarchical_clustering_users_alltime.png")

All-Time

#table(
  columns: 5,
  align: left,
  [*Feature*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Skip Rate],[0.260],[0.117],[0.341],[0.275],
  [Shuffle Rate],[0.634],[0.933],[0.538],[0.651],
  [Offline Rate],[0.001],[0.050],[0.004],[0.009],
  [Average Minutes Played],[0.951],[2.096],[1.531],[1.194],
  [Artist Entropy],[6.920],[7.390],[7.296],[9.326],
  [Top 1 Artist Share],[0.097],[0.067],[0.094],[0.032],
)

#image("../data/hierarchical_clustering_users/plots/hierarchical_clustering_users_2024.png")

2024

#table(
  columns: 5,
  align: left,
  [*Feature*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Skip Rate],[0.807],[0.371],[0.556],[0.587],
  [Shuffle Rate],[0.729],[0.895],[0.683],[0.762],
  [Offline Rate],[0.001],[0.000],[0.000],[0.017],
  [Average Minutes Played],[1.309],[2.204],[1.617],[2.532],
  [Artist Entropy],[7.187],[7.118],[6.894],[8.438],
  [Top 1 Artist Share],[0.049],[0.080],[0.073],[0.052],
)

#image("../data/hierarchical_clustering_users/plots/hierarchical_clustering_users_2025.png")

2025

#table(
  columns: 5,
  align: left,
  [*Feature*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Skip Rate],[0.803],[0.264],[0.319],[0.551],
  [Shuffle Rate],[0.497],[0.958],[0.615],[0.766],
  [Offline Rate],[0.001],[0.014],[0.005],[0.008],
  [Average Minutes Played],[1.502],[2.390],[2.424],[2.477],
  [Artist Entropy],[7.112],[7.214],[6.846],[8.558],
  [Top 1 Artist Share],[0.040],[0.065],[0.087],[0.063],
)

Listening DNA Chart

All-Time

#table(
  columns: 5,
  align: left,
  [*Feature*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Average Play Length],[0.9507],[2.0963],[1.5314],[1.1942],
  [Skip Rate],[0.2600],[0.1175],[0.3411],[0.2752],
  [Shuffle Rate],[0.6339],[0.9330],[0.5383],[0.6515],
  [Offline Rate],[0.0013],[0.0498],[0.0040],[0.0089],
  [Artist Diversity],[6.9203],[7.3896],[7.2960],[9.3260],
  [Top 1 Artist Share],[0.0972],[0.0667],[0.0936],[0.0318],
  [Discovery Rate],[0.0038],[0.0076],[0.0178],[0.0219],
  [Session Length],[27.8805],[26.2996],[36.7185],[20.7163],
  [Genre Diversity],[5.4565],[5.4580],[4.6444],[5.6150],
)

2024

#table(
  columns: 5,
  align: left,
  [*Feature*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Average Play Length],[1.3093],[2.2037],[1.6168],[2.5321],
  [Skip Rate],[0.8066],[0.3709],[0.5563],[0.5874],
  [Shuffle Rate],[0.7291],[0.8949],[0.6830],[0.7616],
  [Offline Rate],[0.0014],[0.0000],[0.0001],[0.0169],
  [Artist Diversity],[7.1874],[7.1176],[6.8940],[8.4376],
  [Top 1 Artist Share],[0.0492],[0.0799],[0.0733],[0.0523],
  [Discovery Rate],[0.0140],[0.0429],[0.0469],[0.0861],
  [Session Length],[44.1657],[21.9586],[31.2231],[32.5228],
  [Genre Diversity],[6.0399],[5.3392],[4.5960],[5.4152],
)

2025

#table(
  columns: 5,
  align: left,
  [*Feature*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Average Play Length],[1.5017],[2.3898],[2.4239],[2.4771],
  [Skip Rate],[0.8028],[0.2636],[0.3190],[0.5514],
  [Shuffle Rate],[0.4969],[0.9578],[0.6154],[0.7660],
  [Offline Rate],[0.0012],[0.0138],[0.0047],[0.0080],
  [Artist Diversity],[7.1122],[7.2145],[6.8457],[8.5583],
  [Top 1 Artist Share],[0.0402],[0.0646],[0.0875],[0.0625],
  [Discovery Rate],[0.0163],[0.0577],[0.0396],[0.0815],
  [Session Length],[31.2630],[17.1197],[41.6225],[41.6296],
  [Genre Diversity],[6.1883],[5.3743],[4.6969],[5.5685],
)

Plots

All-Time

#image("../data/listening_dna_radar/plots/listening_dna_alltime.png")

2024

#image("../data/listening_dna_radar/plots/listening_dna_2024.png")

2025

#image("../data/listening_dna_radar/plots/listening_dna_2025.png")

Artist Loyalty Decay Curve

Alan (top 20 artists by total plays)

#table(
  columns: 5,
  align: left,
  [*Artist*],[*Total Plays*],[*Peak Month*],[*Max Month*],[*Peak Plays*],
  [Kanye West],[43646],[41],[48],[3240],
  [Travis Scott],[22217],[27],[48],[1383],
  [Kendrick Lamar],[15448],[42],[48],[995],
  [Denzel Curry],[13139],[11],[48],[740],
  [Juice WRLD],[9558],[9],[48],[1041],
  [Playboi Carti],[8927],[33],[48],[779],
  [Freddie Gibbs],[8808],[15],[48],[849],
  [Lil Uzi Vert],[8536],[42],[48],[769],
  [Drake],[8494],[43],[48],[474],
  [Future],[8127],[41],[48],[713],
)

#image("../data/artist_loyalty_decay_alltime/plots/artist_loyalty_decay_alanjzamora.png")

Anthony (top 20 artists by total plays)

#table(
  columns: 5,
  align: left,
  [*Artist*],[*Total Plays*],[*Peak Month*],[*Max Month*],[*Peak Plays*],
  [Kanye West],[6779],[11],[48],[487],
  [Drake],[3828],[6],[48],[231],
  [Future],[2130],[5],[48],[170],
  [Young Thug],[1959],[7],[48],[112],
  [Travis Scott],[1456],[34],[48],[134],
  [YoungBoy Never Broke Again],[1428],[9],[48],[172],
  [Kendrick Lamar],[1418],[45],[48],[190],
  [Playboi Carti],[1381],[9],[48],[46],
  [21 Savage],[1305],[39],[48],[86],
  [Juice WRLD],[1233],[27],[48],[122],
)
  
#image("../data/artist_loyalty_decay_alltime/plots/artist_loyalty_decay_dasucc.png")

Alexandra (top 20 artists by total plays)

#table(
  columns: 5,
  align: left,
  [*Artist*],[*Total Plays*],[*Peak Month*],[*Max Month*],[*Peak Plays*],
  [Neck Deep],[9307],[31],[48],[256],
  [State Champs],[8301],[31],[48],[358],
  [Panic! At The Disco],[7117],[22],[48],[163],
  [Beartooth],[5600],[24],[48],[3],
  [Bring Me The Horizon],[4318],[11],[48],[109],
  [Fall Out Boy],[3133],[1],[48],[70],
  [blink-182],[2697],[17],[48],[74],
  [My Chemical Romance],[2484],[14],[48],[76],
  [mgk],[2460],[28],[48],[121],
  [Wage War],[2410],[5],[48],[145],
)

#image("../data/artist_loyalty_decay_alltime/plots/artist_loyalty_decay_alexxxxxrs.png")

Koren (top 20 artists by total plays)

#table(
  columns: 5,
  align: left,
  [*Artist*],[*Total Plays*],[*Peak Month*],[*Max Month*],[*Peak Plays*],
  [Lil Uzi Vert],[5764],[13],[48],[410],
  [Playboi Carti],[4323],[11],[48],[197],
  [Mint],[4030],[14],[48],[253],
  [G Herbo],[2820],[13],[48],[217],
  [Chief Keef],[2732],[25],[48],[154],
  [Cdot Honcho],[2654],[17],[48],[297],
  [Tee Grizzley],[1999],[23],[48],[188],
  [Travis Scott],[1807],[45],[48],[69],
  [Pi’erre Bourne],[1789],[32],[48],[62],
  [Future],[1642],[46],[48],[88],
)

#image("../data/artist_loyalty_decay_alltime/plots/artist_loyalty_decay_korenns.png")

Artist Transition Matrix

Alan top transitions (Artist From to Artist To, row-normalized)

#table(
  columns: 3,
  align: left,
  [*From Artist*],[*To Artist*],[*Probability*],
  [underscores],[underscores],[0.899],
  [Lianne La Havas],[Lianne La Havas],[0.866],
  [Fiona Apple],[Fiona Apple],[0.845],
  [Jessie Ware],[Jessie Ware],[0.845],
  [The Avalanches],[The Avalanches],[0.813],
  [JPEGMAFIA],[JPEGMAFIA],[0.801],
  [Travis Scott],[Travis Scott],[0.627],
  [Fleet Foxes],[Fleet Foxes],[0.624],
  [Danny Brown],[Danny Brown],[0.608],
  [Sufjan Stevens],[Sufjan Stevens],[0.591],
  [A\$AP Rocky],[A\$AP Rocky],[0.491],
  [Logic],[Logic],[0.484],
  [JID],[JID],[0.456],
  [Denzel Curry],[Denzel Curry],[0.441],
  [Kanye West],[Kanye West],[0.400],
)

#image("../data/artist_transition_matrix_2025/plots/artist_transition_matrix_alanjzamora.png")

Anthony top transitions (Artist From to Artist To, row-normalized)

#table(
  columns: 3,
  align: left,
  [*From Artist*],[*To Artist*],[*Probability*],
  [Kanye West],[Kanye West],[0.814],
  [Ken Carson],[Ken Carson],[0.726],
  [The Weeknd],[The Weeknd],[0.665],
  [Playboi Carti],[Playboi Carti],[0.659],
  [Young Thug],[Young Thug],[0.645],
  [Lil Wayne],[Lil Wayne],[0.557],
  [21 Savage],[21 Savage],[0.372],
  [Drake],[Drake],[0.331],
  [Kendrick Lamar],[Kendrick Lamar],[0.301],
  [Travis Scott],[Travis Scott],[0.294],
  [Gunna],[Gunna],[0.259],
  [J. Cole],[Drake],[0.173],
  [Don Toliver],[Gunna],[0.160],
  [YoungBoy Never Broke Again],[YoungBoy Never Broke Again],[0.151],
  [BigXthaPlug],[Lil Baby],[0.139],
)

#image("../data/artist_transition_matrix_2025/plots/artist_transition_matrix_dasucc.png")

Alexandra top transitions (Artist From to Artist To, row-normalized)

#table(
  columns: 3,
  align: left,
  [*From Artist*],[*To Artist*],[*Probability*],
  [Palisades],[Palisades],[0.981],
  [Wage War],[Wage War],[0.318],
  [Kayzo],[Kayzo],[0.280],
  [I Prevail],[I Prevail],[0.250],
  [Neck Deep],[Neck Deep],[0.235],
  [State Champs],[State Champs],[0.220],
  [Bring Me The Horizon],[Beartooth],[0.217],
  [WSTR],[WSTR],[0.205],
  [Panic! At The Disco],[Panic! At The Disco],[0.187],
  [mgk],[State Champs],[0.186],
  [Beartooth],[Beartooth],[0.185],
  [YUNGBLUD],[Beartooth],[0.183],
  [State Champs],[Beartooth],[0.177],
  [Three Days Grace],[Beartooth],[0.171],
  [Falling In Reverse],[Beartooth],[0.149],
)

#image("../data/artist_transition_matrix_2025/plots/artist_transition_matrix_alexxxxxrs.png")

Koren top transitions (Artist From to Artist To, row-normalized)

#table(
  columns: 3,
  align: left,
  [*From Artist*],[*To Artist*],[*Probability*],
  [Playboi Carti],[Playboi Carti],[0.950],
  [Lil Uzi Vert],[Lil Uzi Vert],[0.878],
  [Che],[Che],[0.863],
  [Protect],[Protect],[0.823],
  [Ken Carson],[Ken Carson],[0.701],
  [Mint],[Mint],[0.624],
  [Jace!],[Jace!],[0.529],
  [Floral],[toe],[0.500],
  [tenkay],[tenkay],[0.490],
  [OsamaSon],[OsamaSon],[0.470],
  [Roni Size],[Roni Size],[0.469],
  [Benji Blue Bills],[Benji Blue Bills],[0.458],
  [fakemink],[fakemink],[0.438],
  [Stage Kids],[toe],[0.423],
  [toe],[toe],[0.377],
)

Artist Jaccard

All-Time (Minimum 25 Plays per Artist)

Artist Set Sizes

#table(
  columns: 2,
  align: left,
  [*User*],[*Artist Set Size*],
  [Alan],[424],
  [Alexandra],[508],
  [Anthony],[282],
  [Koren],[993],
)

Pairwise Jaccard

#table(
  columns: 5,
  align: left,
  [*User A*],[*User B*],[*Intersection*],[*Union*],[*Jaccard*],
  [Alan],[Alexandra],[22],[910],[0.024],
  [Alan],[Anthony],[138],[568],[0.243],
  [Alan],[Koren],[180],[1237],[0.146],
  [Alexandra],[Anthony],[11],[779],[0.014],
  [Alexandra],[Koren],[28],[1473],[0.019],
  [Anthony],[Koren],[179],[1096],[0.163],
)

#image("../data/artist_jaccard_similarity/plots/artist_jaccard_alltime.png")

2024 (Minimum 25 Plays per Artist)

Artist Set Sizes

#table(
  columns: 2,
  align: left,
  [*User*],[*Artist Set Size*],
  [Alan],[206],
  [Alexandra],[78],
  [Anthony],[80],
  [Koren],[136],
)

Pairwise Jaccard

#table(
  columns: 5,
  align: left,
  [*User A*],[*User B*],[*Intersection*],[*Union*],[*Jaccard*],
  [Alan],[Alexandra],[1],[283],[0.004],
  [Alan],[Anthony],[24],[262],[0.092],
  [Alan],[Koren],[6],[336],[0.018],
  [Alexandra],[Anthony],[0],[158],[0.000],
  [Alexandra],[Koren],[0],[214],[0.000],
  [Anthony],[Koren],[6],[210],[0.029],
)

#image("../data/artist_jaccard_similarity/plots/artist_jaccard_2024.png")

2025 (Minimum 25 Plays per Artist)

Artist Set Sizes

#table(
  columns: 2,
  align: left,
  [*User*],[*Artist Set Size*],
  [Alan],[176],
  [Alexandra],[70],
  [Anthony],[88],
  [Koren],[143],
)

Pairwise Jaccard

#table(
  columns: 5,
  align: left,
  [*User A*],[*User B*],[*Intersection*],[*Union*],[*Jaccard*],
  [Alan],[Alexandra],[0],[246],[0.000],
  [Alan],[Anthony],[22],[242],[0.091],
  [Alan],[Koren],[8],[311],[0.026],
  [Alexandra],[Anthony],[0],[158],[0.000],
  [Alexandra],[Koren],[0],[213],[0.000],
  [Anthony],[Koren],[13],[218],[0.060],
)

#image("../data/artist_jaccard_similarity/plots/artist_jaccard_2025.png")

Artist Cosine Similarity

All-Time

#table(
  columns: 1,
  align: left,
  [*Vocabulary Size (Artists)*],
  [5858],
)

Top Artists

#table(
  columns: 3,
  align: left,
  [*User*],[*Artist*],[*Weight*],
  [Alan],[Kanye West],[0.0280],
  [Alan],[Sufjan Stevens],[0.0111],
  [Alan],[Denzel Curry],[0.0084],
  [Alan],[Deltron 3030],[0.0072],
  [Alan],[Fleet Foxes],[0.0068],
  [Alan],[Playboi Carti],[0.0057],
  [Alan],[Freddie Gibbs],[0.0056],
  [Alan],[Lil Uzi Vert],[0.0055],
  [Alexandra],[State Champs],[0.0825],
  [Alexandra],[Beartooth],[0.0557],
  [Alexandra],[Neck Deep],[0.0462],
  [Alexandra],[Wage War],[0.0240],
  [Alexandra],[Bring Me The Horizon],[0.0215],
  [Alexandra],[Brick + Mortar],[0.0166],
  [Alexandra],[WSTR],[0.0160],
  [Alexandra],[Panic! At The Disco],[0.0147],
  [Anthony],[Kanye West],[0.0269],
  [Anthony],[YoungBoy Never Broke Again],[0.0057],
  [Anthony],[Playboi Carti],[0.0055],
  [Anthony],[21 Savage],[0.0052],
  [Anthony],[Lil Uzi Vert],[0.0048],
  [Anthony],[Kodak Black],[0.0046],
  [Anthony],[The Weeknd],[0.0046],
  [Anthony],[A\$AP Rocky],[0.0043],
  [Koren],[Mint],[0.0308],
  [Koren],[Cdot Honcho],[0.0203],
  [Koren],[LTJ Bukem],[0.0106],
  [Koren],[Lil Uzi Vert],[0.0091],
  [Koren],[Playboi Carti],[0.0069],
  [Koren],[tenkay],[0.0068],
  [Koren],[UnoTheActivist],[0.0065],
  [Koren],[Duwap Kaine],[0.0057],
)

Cosine Similarity Matrix

#table(
  columns: 5,
  align: left,
  [*User*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Alan],[1.000],[0.000],[0.713],[0.106],
  [Alexandra],[0.000],[1.000],[0.000],[0.001],
  [Anthony],[0.713],[0.000],[1.000],[0.136],
  [Koren],[0.106],[0.001],[0.136],[1.000],
)

#image("../data/artist_cosine_similarity/plots/artist_cosine_alltime.png")

2024

#table(
  columns: 1,
  align: left,
  [*Vocabulary Size (Artists)*],
  [2634],
)

Top Artists

#table(
  columns: 3,
  align: left,
  [*User*],[*Artist*],[*Weight*],
  [Alan],[Danny Brown],[0.0354],
  [Alan],[Sufjan Stevens],[0.0225],
  [Alan],[J Dilla],[0.0186],
  [Alan],[PJ Harvey],[0.0168],
  [Alan],[The Avalanches],[0.0152],
  [Alan],[The Strokes],[0.0151],
  [Alan],[Black Star],[0.0148],
  [Alan],[Freddie Gibbs],[0.0147],
  [Alexandra],[Beartooth],[0.1108],
  [Alexandra],[Neck Deep],[0.0735],
  [Alexandra],[Bring Me The Horizon],[0.0561],
  [Alexandra],[Wage War],[0.0496],
  [Alexandra],[State Champs],[0.0457],
  [Alexandra],[Falling In Reverse],[0.0380],
  [Alexandra],[Ashnikko],[0.0354],
  [Alexandra],[Panic! At The Disco],[0.0309],
  [Anthony],[Kanye West],[0.0211],
  [Anthony],[42 Dugg],[0.0185],
  [Anthony],[Young Thug],[0.0175],
  [Anthony],[YoungBoy Never Broke Again],[0.0173],
  [Anthony],[BigXthaPlug],[0.0166],
  [Anthony],[Future],[0.0159],
  [Anthony],[Young Dolph],[0.0119],
  [Anthony],[Shoreline Mafia],[0.0107],
  [Koren],[Mint],[0.0725],
  [Koren],[LTJ Bukem],[0.0495],
  [Koren],[Lonnie Liston Smith],[0.0308],
  [Koren],[Nookie],[0.0254],
  [Koren],[toe],[0.0229],
  [Koren],[Alex Reece],[0.0220],
  [Koren],[Roni Size],[0.0177],
  [Koren],[Wax Doctor],[0.0177],
)

Cosine Similarity Matrix

#table(
  columns: 5,
  align: left,
  [*User*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Alan],[1.000],[0.001],[0.118],[0.005],
  [Alexandra],[0.001],[1.000],[0.000],[0.000],
  [Anthony],[0.118],[0.000],[1.000],[0.006],
  [Koren],[0.005],[0.000],[0.006],[1.000],
)

#image("../data/artist_cosine_similarity/plots/artist_cosine_2024.png")

2025

#table(
  columns: 1,
  align: left,
  [*Vocabulary Size (Artists)*],
  [2473],
)

Top Artists

#table(
  columns: 3,
  align: left,
  [*User*],[*Artist*],[*Weight*],
  [Alan],[JPEGMAFIA],[0.0514],
  [Alan],[Jessie Ware],[0.0376],
  [Alan],[Fiona Apple],[0.0281],
  [Alan],[Sufjan Stevens],[0.0222],
  [Alan],[The Avalanches],[0.0184],
  [Alan],[Lianne La Havas],[0.0157],
  [Alan],[Fleet Foxes],[0.0152],
  [Alan],[PJ Harvey],[0.0148],
  [Alexandra],[Beartooth],[0.0896],
  [Alexandra],[Neck Deep],[0.0707],
  [Alexandra],[State Champs],[0.0613],
  [Alexandra],[Wage War],[0.0487],
  [Alexandra],[I Prevail],[0.0363],
  [Alexandra],[WSTR],[0.0310],
  [Alexandra],[YUNGBLUD],[0.0256],
  [Alexandra],[Bring Me The Horizon],[0.0226],
  [Anthony],[Kanye West],[0.0252],
  [Anthony],[Ken Carson],[0.0160],
  [Anthony],[Playboi Carti],[0.0134],
  [Anthony],[Drake],[0.0117],
  [Anthony],[Mike Sherm],[0.0109],
  [Anthony],[Young Thug],[0.0107],
  [Anthony],[Knock2],[0.0092],
  [Anthony],[Future],[0.0089],
  [Koren],[Mint],[0.0375],
  [Koren],[LTJ Bukem],[0.0242],
  [Koren],[Che],[0.0235],
  [Koren],[Roni Size],[0.0223],
  [Koren],[tenkay],[0.0206],
  [Koren],[Playboi Carti],[0.0180],
  [Koren],[toe],[0.0177],
  [Koren],[Nookie],[0.0164],
)

Cosine Similarity Matrix

#table(
  columns: 5,
  align: left,
  [*User*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Alan],[1.000],[0.001],[0.084],[0.004],
  [Alexandra],[0.001],[1.000],[0.000],[0.000],
  [Anthony],[0.084],[0.000],[1.000],[0.095],
  [Koren],[0.004],[0.000],[0.095],[1.000],
)

#image("../data/artist_cosine_similarity/plots/artist_cosine_2025.png")

Session Opening Artists

Alan - All-Time (Total Sessions Opened: 7108)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Kanye West],[1625],[22.9%],
  [Travis Scott],[813],[11.4%],
  [Kendrick Lamar],[538],[7.6%],
  [Denzel Curry],[443],[6.2%],
  [Freddie Gibbs],[347],[4.9%],
  [Pusha T],[308],[4.3%],
  [Drake],[291],[4.1%],
  [Juice WRLD],[258],[3.6%],
  [Future],[252],[3.5%],
  [JID],[245],[3.4%],
  [Nas],[236],[3.3%],
  [Playboi Carti],[229],[3.2%],
  [Lil Uzi Vert],[222],[3.1%],
  [A Tribe Called Quest],[201],[2.8%],
  [Danny Brown],[200],[2.8%],
  [A\$AP Rocky],[194],[2.7%],
  [Radiohead],[185],[2.6%],
  [Logic],[176],[2.5%],
  [21 Savage],[175],[2.5%],
  [Metro Boomin],[170],[2.4%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_alanjzamora_alltime.png")

Anthony - All-Time (Total Sessions Opened: 1466)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Kanye West],[301],[20.5%],
  [Drake],[179],[12.2%],
  [Young Thug],[110],[7.5%],
  [Future],[106],[7.2%],
  [Kendrick Lamar],[88],[6.0%],
  [Travis Scott],[74],[5.0%],
  [Playboi Carti],[60],[4.1%],
  [Lil Wayne],[59],[4.0%],
  [The Weeknd],[56],[3.8%],
  [Kodak Black],[48],[3.3%],
  [Juice WRLD],[47],[3.2%],
  [A\$AP Rocky],[45],[3.1%],
  [21 Savage],[44],[3.0%],
  [Young Dolph],[41],[2.8%],
  [YoungBoy Never Broke Again],[39],[2.7%],
  [Migos],[35],[2.4%],
  [Lil Uzi Vert],[34],[2.3%],
  [King Von],[34],[2.3%],
  [Gunna],[33],[2.3%],
  [Roddy Ricch],[33],[2.3%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_dasucc_alltime.png")

Alexandra - All-Time (Total Sessions Opened: 5033)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Neck Deep],[808],[16.1%],
  [State Champs],[632],[12.6%],
  [Beartooth],[580],[11.5%],
  [Panic! At The Disco],[465],[9.2%],
  [Bring Me The Horizon],[367],[7.3%],
  [Fall Out Boy],[236],[4.7%],
  [Wage War],[219],[4.4%],
  [My Chemical Romance],[172],[3.4%],
  [YUNGBLUD],[167],[3.3%],
  [Ashnikko],[157],[3.1%],
  [mgk],[153],[3.0%],
  [blink-182],[142],[2.8%],
  [WSTR],[134],[2.7%],
  [Krewella],[131],[2.6%],
  [Neon Trees],[126],[2.5%],
  [Green Day],[121],[2.4%],
  [Seether],[116],[2.3%],
  [I Prevail],[111],[2.2%],
  [Catfish and the Bottlemen],[101],[2.0%],
  [Papa Roach],[95],[1.9%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_alexxxxxrs_alltime.png")

Koren - All-Time (Total Sessions Opened: 2573)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Lil Uzi Vert],[281],[10.9%],
  [Mint],[250],[9.7%],
  [Playboi Carti],[225],[8.7%],
  [A Tribe Called Quest],[176],[6.8%],
  [G Herbo],[161],[6.3%],
  [Cdot Honcho],[160],[6.2%],
  [Pi’erre Bourne],[125],[4.9%],
  [Chief Keef],[121],[4.7%],
  [LTJ Bukem],[120],[4.7%],
  [Young Nudy],[106],[4.1%],
  [Drake],[104],[4.0%],
  [Tee Grizzley],[98],[3.8%],
  [Duwap Kaine],[91],[3.5%],
  [Thouxanbanfauni],[89],[3.5%],
  [Lancey Foux],[88],[3.4%],
  [Travis Scott],[85],[3.3%],
  [21 Savage],[83],[3.2%],
  [Future],[71],[2.8%],
  [Pop Smoke],[70],[2.7%],
  [D. Savage],[69],[2.7%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_korenns_alltime.png")

Alan - 2024 (Total Sessions Opened: 630)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Kanye West],[85],[13.5%],
  [Kendrick Lamar],[54],[8.6%],
  [The Roots],[39],[6.2%],
  [Denzel Curry],[38],[6.0%],
  [Freddie Gibbs],[36],[5.7%],
  [Jessie Ware],[35],[5.6%],
  [Danny Brown],[31],[4.9%],
  [Fiona Apple],[31],[4.9%],
  [Nas],[28],[4.4%],
  [The Avalanches],[26],[4.1%],
  [MGMT],[25],[4.0%],
  [Black Star],[24],[3.8%],
  [Bruno Pernadas],[24],[3.8%],
  [Pusha T],[24],[3.8%],
  [Gorillaz],[23],[3.7%],
  [Mobb Deep],[23],[3.7%],
  [A\$AP Rocky],[23],[3.7%],
  [The Weeknd],[21],[3.3%],
  [DJ Shadow],[20],[3.2%],
  [Danger Mouse],[20],[3.2%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_alanjzamora_2024.png")

Anthony - 2024 (Total Sessions Opened: 343)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Kendrick Lamar],[56],[16.3%],
  [Future],[49],[14.3%],
  [Kanye West],[30],[8.7%],
  [Young Thug],[28],[8.2%],
  [¥\$],[21],[6.1%],
  [Drake],[18],[5.2%],
  [Travis Scott],[17],[5.0%],
  [Playboi Carti],[14],[4.1%],
  [BigXthaPlug],[12],[3.5%],
  [Young Dolph],[12],[3.5%],
  [Gunna],[11],[3.2%],
  [Tyler, The Creator],[10],[2.9%],
  [21 Savage],[10],[2.9%],
  [Shoreline Mafia],[9],[2.6%],
  [Kodak Black],[9],[2.6%],
  [Denzel Curry],[8],[2.3%],
  [Eminem],[8],[2.3%],
  [YoungBoy Never Broke Again],[7],[2.0%],
  [\$uicideboy\$],[7],[2.0%],
  [Juice WRLD],[7],[2.0%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_dasucc_2024.png")

Alexandra - 2024 (Total Sessions Opened: 632)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Beartooth],[111],[17.6%],
  [Neck Deep],[75],[11.9%],
  [Bring Me The Horizon],[68],[10.8%],
  [Falling In Reverse],[54],[8.5%],
  [Wage War],[53],[8.4%],
  [I Prevail],[32],[5.1%],
  [Ashnikko],[26],[4.1%],
  [State Champs],[24],[3.8%],
  [Panic! At The Disco],[22],[3.5%],
  [mgk],[18],[2.8%],
  [Diamond Construct],[18],[2.8%],
  [Kim Dracula],[18],[2.8%],
  [Fall Out Boy],[16],[2.5%],
  [Gorepig],[15],[2.4%],
  [Kayzo],[15],[2.4%],
  [YUNGBLUD],[15],[2.4%],
  [Motionless In White],[14],[2.2%],
  [WSTR],[14],[2.2%],
  [All Time Low],[12],[1.9%],
  [Slipknot],[12],[1.9%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_alexxxxxrs_2024.png")

Koren - 2024 (Total Sessions Opened: 369)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Mint],[52],[14.1%],
  [LTJ Bukem],[45],[12.2%],
  [Nookie],[31],[8.4%],
  [Hidden Agenda],[25],[6.8%],
  [Wax Doctor],[22],[6.0%],
  [M-Beat],[21],[5.7%],
  [Lonnie Liston Smith],[17],[4.6%],
  [Alex Reece],[16],[4.3%],
  [Goldie],[15],[4.1%],
  [Peshay],[14],[3.8%],
  [LAZER DIM 700],[14],[3.8%],
  [Big Bud],[13],[3.5%],
  [Aquasky],[12],[3.3%],
  [Roni Size],[11],[3.0%],
  [mouse on the keys],[11],[3.0%],
  [Omni Trio],[10],[2.7%],
  [toe],[10],[2.7%],
  [Seba],[10],[2.7%],
  [J Laze],[10],[2.7%],
  [Tayla],[10],[2.7%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_korenns_2024.png")

Alan - 2025 (Total Sessions Opened: 582)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Jessie Ware],[68],[11.7%],
  [Kanye West],[59],[10.1%],
  [JPEGMAFIA],[43],[7.4%],
  [Fiona Apple],[41],[7.0%],
  [Kendrick Lamar],[36],[6.2%],
  [Denzel Curry],[34],[5.8%],
  [underscores],[33],[5.7%],
  [JID],[29],[5.0%],
  [Logic],[28],[4.8%],
  [Danny Brown],[24],[4.1%],
  [Danger Mouse],[21],[3.6%],
  [Freddie Gibbs],[21],[3.6%],
  [Tyler, The Creator],[21],[3.6%],
  [Fleet Foxes],[20],[3.4%],
  [Lianne La Havas],[19],[3.3%],
  [Nas],[18],[3.1%],
  [The Avalanches],[18],[3.1%],
  [The Notorious B.I.G.],[17],[2.9%],
  [The Roots],[16],[2.7%],
  [Lupe Fiasco],[16],[2.7%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_alanjzamora_2025.png")

Anthony - 2025 (Total Sessions Opened: 466)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Kanye West],[96],[20.6%],
  [Young Thug],[40],[8.6%],
  [Playboi Carti],[36],[7.7%],
  [Lil Wayne],[29],[6.2%],
  [Drake],[29],[6.2%],
  [Travis Scott],[23],[4.9%],
  [Ken Carson],[23],[4.9%],
  [Kodak Black],[22],[4.7%],
  [Kendrick Lamar],[21],[4.5%],
  [Future],[19],[4.1%],
  [1900Rugrat],[19],[4.1%],
  [The Weeknd],[18],[3.9%],
  [Jeezy],[15],[3.2%],
  [Gunna],[14],[3.0%],
  [21 Savage],[13],[2.8%],
  [Bryson Tiller],[12],[2.6%],
  [Lil Baby],[10],[2.1%],
  [DONDA],[9],[1.9%],
  [Ye],[9],[1.9%],
  [King Von],[9],[1.9%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_dasucc_2025.png")

Alexandra - 2025 (Total Sessions Opened: 583)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Beartooth],[89],[15.3%],
  [Neck Deep],[60],[10.3%],
  [Bring Me The Horizon],[50],[8.6%],
  [State Champs],[48],[8.2%],
  [Wage War],[47],[8.1%],
  [Ashnikko],[36],[6.2%],
  [WSTR],[31],[5.3%],
  [I Prevail],[28],[4.8%],
  [Panic! At The Disco],[23],[3.9%],
  [YUNGBLUD],[21],[3.6%],
  [mgk],[21],[3.6%],
  [Falling In Reverse],[19],[3.3%],
  [Kayzo],[17],[2.9%],
  [Three Days Grace],[17],[2.9%],
  [My Chemical Romance],[16],[2.7%],
  [Belmont],[14],[2.4%],
  [Woe, Is Me],[12],[2.1%],
  [Kim Dracula],[12],[2.1%],
  [A Day To Remember],[11],[1.9%],
  [Brand of Sacrifice],[11],[1.9%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_alexxxxxrs_2025.png")

Koren - 2025 (Total Sessions Opened: 341)

#table(
  columns: 3,
  align: left,
  [*Artist*],[*Opens*],[*Share*],
  [Playboi Carti],[56],[16.4%],
  [LTJ Bukem],[38],[11.1%],
  [Mint],[27],[7.9%],
  [toe],[19],[5.6%],
  [Roni Size],[19],[5.6%],
  [Lil Uzi Vert],[19],[5.6%],
  [ark762],[15],[4.4%],
  [Ken Carson],[15],[4.4%],
  [J Majik],[14],[4.1%],
  [Drake],[13],[3.8%],
  [tenkay],[13],[3.8%],
  [Big Bud],[11],[3.2%],
  [Wax Doctor],[11],[3.2%],
  [Alex Reece],[11],[3.2%],
  [Nuito],[10],[2.9%],
  [Pi’erre Bourne],[10],[2.9%],
  [M-Beat],[10],[2.9%],
  [fakemink],[10],[2.9%],
  [JMJ & Richie],[10],[2.9%],
  [Omni Trio],[10],[2.9%],
)

#image("../data/session_opening_artist/plots/session_opening_artist_korenns_2025.png")

User Distance Function

Composite Distance $d(x, y) in [0,1]$:

$
  d(x,y) = (1/10) dot [ &|hat(x)_1 - hat(y)_1| + |hat(x)_2 - hat(y)_2| + |hat(x)_3 - hat(y)_3| 
         + |hat(x)_4 - hat(y)_4| + |hat(x)_5 - hat(y)_5| + |hat(x)_6 - hat(y)_6| 
         + |hat(x)_7 - hat(y)_7| + \
         &delta_Q ("Gini"_x, "Gini"_y) 
         + delta_Q (H_"genre"_x / (log_2 (n_x)), H_"genre"_y / (log_2 (n_y))) 
         + delta_"top" ("Top Genre"_x, "Top Genre"_y)
  ]     
$

$
  hat(x)_i = (x_i - min) / (max - min) space "(min-max over the 4 users)"
$

Numeric Features ($i$):
+ mean play dur ($min$)
+ skip rate
+ shuffle rate
+ offline rate 
+ artist entropy (bits) 
+ top-1 artist share
+ mean session length (min)  

Nominal Features ($delta$):
+ $delta_Q (a,b) = 0$ if $a=b$, else 1
+ $delta_"top" (a,b) = 0$ if top genre same, else 1

Per-User Feature Values (All-Time)

#table(
  columns: 5,
  align: left,
  [*Feature*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Mean Play Time (Min)],[0.95],[2.10],[1.53],[1.19],
  [Skip Rate],[26.0%],[11.7%],[34.1%],[27.5%],
  [Shuffle Rate],[63.4%],[93.3%],[53.8%],[65.1%],
  [Offline Rate],[0.1%],[5.0%],[0.4%],[0.9%],
  [Artist Entropy],[6.920],[7.390],[7.296],[9.326],
  [Top 1 Artist Share],[9.7%],[6.7%],[9.4%],[3.2%],
  [Mean Session Length (Min)],[36.46],[26.59],[39.98],[26.96],
  [Gini],[0.910],[0.880],[0.925],[0.909],
  [Genre Entropy],[5.456],[5.458],[4.644],[5.615],
  [Top Genre],[hip hop],[pop punk],[trap],[trap],
)

Composite Distance Matrix $d(x, y)$

#table(
  columns: 5,
  align: left,
  [*User*],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
  [Alan],[0.0000],[0.5793],[0.2642],[0.4190],
  [Alexandra],[0.5793],[0.0000],[0.5886],[0.5417],
  [Anthony],[0.2642],[0.5886],[0.0000],[0.3736],
  [Koren],[0.4190],[0.5417],[0.3736],[0.0000],
)

#image("../data/composite_user_distance/plots/composite_user_distance_alltime.png")

Distance 2024 vs. 2025 - Self-Drift

Self-Drift $d("User 2024", "User 2025")$

#table(
  columns: 4,
  align: left,
  [*User*],[*Drift*],[*Top Genre (2024)*],[*Top Genre (2025)*],
  [Alan],[0.2348],[hip hop],[hip hop],
  [Alexandra],[0.2872],[metalcore],[pop punk],
  [Anthony],[0.2138],[trap],[trap],
  [Koren],[0.1201],[drum and bass],[drum and bass],
)

#table(
  columns: 2,
  align: left,
  [*Metric*],[*Value*],
  [Mean Self-Drift],[0.2140],
  [Max Self-Drift],[0.2872 (Alexandra)],
  [Min Self-Drift],[0.1201 (Koren)],
)

#image("../data/user_self_drift/plots/user_self_drift_2024_2025.png")

Track Anamolies (2025)

Alan

#table(
  columns: 5,
  align: left,
  table.cell(colspan: 5, fill: gray.lighten(80%), align: center)[*TOP OBSESSIONS ($bold("plays" >> "expected")$)*],
  [*Track*],[*Artist*],[*Actual*],[*Expected*],[*Ratio*],
  [House Of Balloons / Glass Table Girls],[The Weeknd],[33],[4.6],[$7.10 times$],
  [Faith],[The Weeknd],[33],[4.6],[$7.10 times$],
  [Break Da Law '95'],[Three 6 Mafia],[21],[3.2],[$6.56 times$],
  [I Wonder],[King Geedorah],[64],[10.7],[$5.99 times$],
  [either on or off the drugs],[JPEGMAFIA],[95],[17.2],[$5.51 times$],
  [Endtroduction - Live At Electric Lady],[Denzel Curry],[75],[13.7],[$5.46 times$],
  [Darling, I (feat. Teezo Touchdown)],[Tyler, The Creator],[39],[7.2],[$5.45 times$],
  [Never Catch Me],[Travis Scott],[39],[7.2],[$5.43 times$],
  [Waltz (Better Than Fine)],[Fiona Apple],[61],[11.4],[$5.34 times$],
  [Young Metro],[Future],[14],[2.6],[$5.29 times$],
  [Aux Cord],[Big K.R.I.T.],[63],[12.1],[$5.20 times$],
  [Soul Food],[Logic],[45],[8.8],[$5.11 times$],
  table.cell(colspan: 5, fill: gray.lighten(80%), align: center)[*TOP AVOIDANCES ($bold("plays" << "expected")$)*],
  [*Track*],[*Artist*],[*Actual*],[*Expected*],[*Ratio*],
  [Orange Juice Jones],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [SCARING THE HOES],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [Shut Yo Bitch Ass Up / Muddy Waters],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [100 EMOJI! - INSTRUMENTAL],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [THE GHOST OF RANKING DREAD! - OFFLINE],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [TIRED, NERVOUS & BROKE!],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [FLAME EMOJI!],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [UNTITLED],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [END CREDITS! - OFFLINE],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [DAM! DAM! DAM! - OFFLINE],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [Jesus Forgive Me, I Am A Thot],[JPEGMAFIA],[1],[17.2],[$0.06 times$],
  [Rey's Theme],[John Williams],[1],[19.7],[$0.05 times$],
)

#image("../data/track_anomaly_2025/plots/track_anomaly_alanjzamora.png")

Anthony

#table(
  columns: 5,
  align: left,
  table.cell(colspan: 5, fill: gray.lighten(80%), align: center)[*TOP OBSESSIONS ($bold("plays" >> "expected")$)*],
  [*Track*],[*Artist*],[*Actual*],[*Expected*],[*Ratio*],
  [Headlines],[Drake],[37],[3.6],[$10.25 times$],
  [Empty Out Your Pockets],[Juice WRLD],[26],[2.6],[$10.11 times$],
  [Make No Sense],[YoungBoy Never Broke Again],[27],[2.7],[$9.91 times$],
  [4X4],[Travis Scott],[32],[3.5],[$9.09 times$],
  [tv off (feat. lefty gunplay)],[Kendrick Lamar],[44],[5.0],[$8.77 times$],
  [Yale],[Ken Carson],[51],[6.1],[$8.37 times$],
  [Timeless (feat Playboi Carti)],[The Weeknd],[29],[3.5],[$8.24 times$],
  [ss],[Ken Carson],[50],[6.1],[$8.20 times$],
  [Sticky (feat. GloRilla, Sexyy Red & Lil Wayne)],[Tyler, The Creator],[27],[3.5],[$7.71 times$],
  [20 Min],[Lil Uzi Vert],[32],[4.2],[$7.62 times$],
  [HIM ALL ALONG],[Gunna],[37],[4.9],[$7.57 times$],
  [No Pole],[Don Toliver],[48],[6.4],[$7.56 times$],
  table.cell(colspan: 5, fill: gray.lighten(80%), align: center)[*TOP AVOIDANCES ($bold("plays" << "expected")$)*],
  [*Track*],[*Artist*],[*Actual*],[*Expected*],[*Ratio*],
  [Get Mine (feat. Young Thug)],[Bryson Tiller],[1],[8.4],[$0.12 times$],
  [Sorry Not Sorry],[Bryson Tiller],[1],[8.4],[$0.12 times$],
  [502 Come Up],[Bryson Tiller],[1],[8.4],[$0.12 times$],
  [Cold],[Kanye West],[1],[8.9],[$0.11 times$],
  [Clique],[Kanye West],[1],[8.9],[$0.11 times$],
  [H•A•M],[Kanye West],[1],[8.9],[$0.11 times$],
  [To The World],[Kanye West],[1],[8.9],[$0.11 times$],
  [24],[Kanye West],[1],[8.9],[$0.11 times$],
  [Intro],[Kanye West],[1],[8.9],[$0.11 times$],
  [Heaven and Hell],[Kanye West],[1],[8.9],[$0.11 times$],
  [All Day],[Kanye West],[1],[8.9],[$0.11 times$],
  [Cold.1],[Kanye West],[1],[8.9],[$0.11 times$],
)

#image("../data/track_anomaly_2025/plots/track_anomaly_dasucc.png")

Alexandra

#table(
  columns: 5,
  align: left,
  table.cell(colspan: 5, fill: gray.lighten(80%), align: center)[*TOP OBSESSIONS ($bold("plays" >> "expected")$)*],
  [*Track*],[*Artist*],[*Actual*],[*Expected*],[*Ratio*],
  [check],[bbno\$],[13],[3.1],[$4.15 times$],
  [Sunshine!],[Beartooth],[25],[6.2],[$4.04 times$],
  [Heartbreak Of The Century],[Neck Deep],[19],[5.0],[$3.77 times$],
  [Static],[Sleep Theory],[21],[6.3],[$3.32 times$],
  [Riptide],[Beartooth],[19],[6.2],[$3.07 times$],
  [antidepressants],[bbno\$],[9],[3.1],[$2.88 times$],
  [Everybody but You],[State Champs],[13],[4.7],[$2.77 times$],
  [Doomed],[I Prevail],[15],[5.4],[$2.76 times$],
  [Nerve],[The Story So Far],[8],[3.0],[$2.67 times$],
  [NAIL5],[Wage War],[14],[5.3],[$2.65 times$],
  [Bowser's Castle],[Belmont],[12],[4.5],[$2.65 times$],
  [Land Of The Sun],[Kim Dracula],[12],[4.6],[$2.61 times$],
  table.cell(colspan: 5, fill: gray.lighten(80%), align: center)[*TOP AVOIDANCES ($bold("plays" << "expected")$)*],
  [*Track*],[*Artist*],[*Actual*],[*Expected*],[*Ratio*],
  [Quarry],[Neck Deep],[1],[5.0],[$0.20 times$],
  [Emergency Contact],[Pierce The Veil],[1],[5.1],[$0.19 times$],
  [You Want That Scene Shit],[Diamond Construct],[1],[5.2],[$0.19 times$],
  [Cloud 9],[Red Handed Denial],[1],[5.2],[$0.19 times$],
  [Circle The Drain - Stripped],[Wage War],[1],[5.3],[$0.19 times$],
  [Johnny Cash - Stripped],[Wage War],[1],[5.3],[$0.19 times$],
  [Bad Things - Stripped],[I Prevail],[1],[5.4],[$0.18 times$],
  [Relapsing],[Beartooth],[1],[6.2],[$0.16 times$],
  [Pick Your Poison],[Beartooth],[1],[6.2],[$0.16 times$],
  [Find a Way - Remixed/Remastered],[Beartooth],[1],[6.2],[$0.16 times$],
  [King of Anything],[Beartooth],[1],[6.2],[$0.16 times$],
  [Finish Line],[Beartooth],[1],[6.2],[$0.16 times$],
)

#image("../data/track_anomaly_2025/plots/track_anomaly_alexxxxxrs.png")

Koren

#table(
  columns: 5,
  align: left,
  table.cell(colspan: 5, fill: gray.lighten(80%), align: center)[*TOP OBSESSIONS ($bold("plays" >> "expected")$)*],
  [*Track*],[*Artist*],[*Actual*],[*Expected*],[*Ratio*],
  [Myron],[Lil Uzi Vert],[39],[2.7],[$14.70 times$],
  [Off The Meter (with Playboi Carti & Destroy Lonely)],[Ken Carson],[38],[3.3],[$11.43 times$],
  [NOKIA],[Drake],[16],[1.9],[$8.56 times$],
  [ss],[Ken Carson],[23],[3.3],[$6.92 times$],
  [Headlines],[Drake],[12],[1.9],[$6.42 times$],
  [Fancy],[Drake],[12],[1.9],[$6.42 times$],
  [The Bell],[Yeat],[11],[2.1],[$5.23 times$],
  [thought i was playing],[Gunna],[11],[2.2],[$4.89 times$],
  [Laced max],[LAZER DIM 700],[22],[4.8],[$4.54 times$],
  [G2G],[Skrillex],[11],[2.5],[$4.43 times$],
  [POP OUT],[Playboi Carti],[45],[11.0],[$4.08 times$],
  [Brown Paper Bag],[Roni Size],[44],[11.0],[$3.99 times$],
  table.cell(colspan: 5, fill: gray.lighten(80%), align: center)[*TOP AVOIDANCES ($bold("plays" << "expected")$)*],
  [*Track*],[*Artist*],[*Actual*],[*Expected*],[*Ratio*],
  [WE NEED ALL DA VIBES],[Playboi Carti],[1],[11.0],[$0.09 times$],
  [Teen X (feat. Future)],[Playboi Carti],[1],[11.0],[$0.09 times$],
  [Top (feat. Pi'erre Bourne)],[Playboi Carti],[1],[11.0],[$0.09 times$],
  [TRIM],[Playboi Carti],[1],[11.0],[$0.09 times$],
  [TWIN TRIM],[Playboi Carti],[1],[11.0],[$0.09 times$],
  [JUMPIN],[Playboi Carti],[1],[11.0],[$0.09 times$],
  [Intelligent Woman - Remastered],[DJ Rap],[1],[11.3],[$0.09 times$],
  [See U In H3ll],[Lil Shine],[1],[11.4],[$0.09 times$],
  [End Up Gone],[ian],[1],[11.5],[$0.09 times$],
  [Mermaids],[J Majik],[1],[11.8],[$0.09 times$],
  [Zero-G],[Minus 8],[1],[13.3],[$0.07 times$],
  [Pressin' On],[Hidden Agenda],[1],[13.7],[$0.07 times$],
)

#image("../data/track_anomaly_2025/plots/track_anomaly_korenns.png")

Genre Mood Manifold

Skip Oracle

This section reports the full Skip Oracle analysis from the generated artifact `data/skip_oracle/skip_oracle_results.json` and companion plots in `data/skip_oracle/plots`.

*Goal.* Recover clear, user-specific skip decision rules while quantifying how much predictive performance is gained by moving from an interpretable tree to a black-box gradient boosting model.

*Data and setup.*
- Total rows: 842,499
- Users: Alan, Alexandra, Anthony, Koren
- Feature count: 13
- Primary temporal split cutoff: 2024-01-01
- Transfer test: train on 2024, evaluate on 2025
- Tree depth search: 3, 4, 5, 6 (5-fold CV)

*Feature families used.*
- Numeric: shuffle, offline, is_session_opening, session_position, session_skip_rate_so_far, days_since_artist_last_played, artist_personal_skip_rate, ms_played_pct
- Categorical: hour_bin, dow, month, reason_start, platform_group

*Primary performance by user (held-out primary split).* 

#table(
  columns: 8,
  align: left,
  [*User*],[*Accuracy*],[*F1*],[*ROC AUC*],[*PR AUC*],[*Shuffle Baseline F1*],[*F1 Lift vs Shuffle*],[*Tree vs GBM AUC Gap*],
  [Alan],[0.8305],[0.9049],[0.8891],[0.9664],[0.7321],[+0.1727],[+0.0125],
  [Alexandra],[0.8377],[0.7738],[0.9153],[0.8624],[0.4721],[+0.3017],[+0.0286],
  [Anthony],[0.8028],[0.8026],[0.9267],[0.9237],[0.6264],[+0.1762],[+0.0103],
  [Koren],[0.7930],[0.8333],[0.9196],[0.9351],[0.5763],[+0.2570],[+0.0173],
)

Interpretation:
- All trees outperform the shuffle baseline by a meaningful F1 margin.
- ROC AUC is consistently high across users (0.889 to 0.927), confirming strong class separation.
- Gradient boosting improves AUC for every user, but only modestly (+0.010 to +0.029), indicating most useful signal is already captured by interpretable trees.

*Transfer test (2024 to 2025).* 

#table(
  columns: 7,
  align: left,
  [*User*],[*Primary Accuracy*],[*Transfer Accuracy*],[*Accuracy Delta*],[*Primary ROC AUC*],[*Transfer ROC AUC*],[*AUC Delta*],
  [Alan],[0.8305],[0.7653],[-0.0652],[0.8891],[0.8880],[-0.0011],
  [Alexandra],[0.8377],[0.8867],[+0.0490],[0.9153],[0.9458],[+0.0305],
  [Anthony],[0.8028],[0.8883],[+0.0855],[0.9267],[0.9503],[+0.0236],
  [Koren],[0.7930],[0.8694],[+0.0764],[0.9196],[0.9428],[+0.0232],
)

Interpretation:
- Alan shows the only substantial transfer degradation in accuracy.
- Alexandra, Anthony, and Koren improve under the 2024 to 2025 transfer regime, suggesting stable or even cleaner rule structure in their later-period listening behavior.

*Feature importance consistency.*

#table(
  columns: 5,
  align: left,
  [*User*],[*Top Permutation Signals*],[*Top SHAP Signals*],[*Agreement Score*],[*Reading*],
  [Alan],[session_skip_rate_so_far, reason_start, ms_played_pct],[artist_personal_skip_rate, session_skip_rate_so_far, session_position],[0.7424],[Strong ranking agreement],
  [Alexandra],[ms_played_pct, session_skip_rate_so_far, session_position],[session_skip_rate_so_far, ms_played_pct, artist_personal_skip_rate],[0.8053],[Strong ranking agreement],
  [Anthony],[session_skip_rate_so_far, ms_played_pct, artist_personal_skip_rate],[artist_personal_skip_rate, session_skip_rate_so_far, ms_played_pct],[0.5077],[Moderate agreement],
  [Koren],[session_skip_rate_so_far, ms_played_pct, session_position],[session_skip_rate_so_far, artist_personal_skip_rate, session_position],[0.2919],[Weak to moderate agreement],
)

Cross-user checks from the final artifact:
- session_skip_rate_so_far appears in top rules for all users.
- artist_personal_skip_rate is globally important, but not top-3 for every user under strict ranking.
- Exact path-level rule signatures are mostly user-specific in the cross-user rule comparison CSV, meaning shared behavior appears more at the feature level than at the exact decision-path level.

*Conclusions.*
- Interpretable trees provide strong predictive performance for all four users.
- The small black-box AUC lift shows the main behavioral structure is already captured by human-readable rules.
- Session context and personal artist history are the dominant axes of skip behavior.
- Transfer behavior is user-dependent: one user drifts negatively, three users remain robust or improve.

Key model diagnostics:

#image("../data/skip_oracle/plots/roc_all_users.png")

#image("../data/skip_oracle/plots/pr_all_users.png")

#image("../data/skip_oracle/plots/transfer_accuracy_degradation.png")

#image("../data/skip_oracle/plots/tradeoff_auc_gap.png")

#image("../data/skip_oracle/plots/importance_agreement.png")

Per-user decision trees:

Alan

#image("../data/skip_oracle/plots/decision_tree_alanjzamora.png")

Alexandra

#image("../data/skip_oracle/plots/decision_tree_alexxxxxrs.png")

Anthony

#image("../data/skip_oracle/plots/decision_tree_dasucc.png")

Koren

#image("../data/skip_oracle/plots/decision_tree_korenns.png")

Per-user permutation importance:

Alan

#image("../data/skip_oracle/plots/permutation_importance_alanjzamora.png")

Alexandra

#image("../data/skip_oracle/plots/permutation_importance_alexxxxxrs.png")

Anthony

#image("../data/skip_oracle/plots/permutation_importance_dasucc.png")

Koren

#image("../data/skip_oracle/plots/permutation_importance_korenns.png")