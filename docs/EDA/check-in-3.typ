#import "template/lib2.typ": *
#import "@preview/frame-it:1.2.0": *
#import "@preview/mannot:0.3.0": *
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": chart, plot
#import "@preview/wrap-it:0.1.1": *
#import calc: exp, ln, pow

#show: typsidian.with(
  title: "Check-In 3",
  author: "Koren Stalnaker, Alexandra Williams, Cesar Cervantes, Alan Zamora, Anthony Chen",
  footer-text: "K. Stalnaker, A. Williams, C. Cervantes, A. Zamora, A. Chen",
  course: "Spotify Data Project",
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
#show table: set align(center)

= Similarity Measure

Using the data collected from four group member's Spotify extended listening history, we created a composite, multi-dimensional similarity measure to compare the listening profiles of four users across seven different categories: artist similarity, genre similarity, temporal behavior, session behavior, track interaction behavior, distribution structure, and audio feature similarity. 

== Similarity Features & Methodology

The seven different categories are each weighted differently, according to their perceived importance in determining overall similarity between two users. The features and their weights are shown below.

#table(
  columns: 4,
  align: left,
  [*Feature*],[*Method*],[*What It Measures*],[*Weight*],
  [Artist Similarity],[TF-IDF weighted vector over artist play counts for each user, normalized to unit length, cosine similarity computed through an artist-to-artist similarity matrix, plus Jaccard similarity over top 50 artists, combined as 0.8 cosine component and 0.2 Jaccard component.],[How similar two users' artist preferences are. Captures overlap and proximity in the artists they repeatedly choose to listen to.],[0.25],
  [Genre Similarity],[Normalized genre frequency vector per user derived from artist-to-genre mapping, cosine similarity computed using a genre similarity matrix applied over the vectors.],[How similar two users are in their genre preferences. Two users can have similar tastes even if their specific artists differ.],[0.20],
  [Temporal Behavior],[24-bin hourly play histogram and 12-bin monthly play histogram per user, both normalized, cosine similarity computed on each, combined as 0.6 hourly similarity and 0.4 monthly similarity.],[Whether two users listen to music at similar times of day and periods of the year. Measures habitual listening patterns.],[0.15],
  [Session Behavior],[Session segmentation using 30-minute inactivity threshold, mean session length per user and mean plays per track per user, similarity computed as exponential decay of differences for both metrics and averaged equally.],[How similarly users engage with music in terms of session structure (short vs. continuous sessions), and replay tendencies.],[0.10],
  [Interaction Behavior],[Similarity defined as one minus absolute difference for skip rate and shuffle rate, averaged.],[How similarly users interact with tracks. Reflects how users curate their music; whether they skip songs or let a playlist play fully.],[0.10],
  [Distribution Structure],[Top artist share defined as fraction of plays from most frequent artist and normalized artist entropy, similarity defined as one minus absolute difference for each and averaged equally.],[How concentrated or diverse each user's listening history is; whether they focus heavily on a few artists or songs, or have a more broad taste.],[0.10],
  [Audio Feature Similarity],[Mean feature vector over top 10 songs per user using energy, instrumentalness, danceability, happiness, BPM, acousticness, camelot key, and loudness, cosine similarity between the two vectors.],[How similar user's top tracks are in terms of sonic characteristics, independent of artist genre labels.],[0.10],
)

The artist similarity is weighted the highest, since shared artists is the strongest signal of two users having aligned music tastes. TF-IDF weighting is used to give more importance to artists that are distinctive to a user's profile, while the artist similarity matrix captures relationships between artists that may not be directly shared but are similar. The Jaccard similarity over top artists adds an additional signal of direct overlap in key artists. The genre similarity is the second-highest weight. 

The genre similarity matrix means that related genres (e.g., trap and hip-hop) contribute partial similarity even if the users don't share the exact same genre distribution. Temporal behavior is also important, as users who listen at similar times may have more similar lifestyles or contexts for their music listening. Session behavior and interaction behavior capture how users engage with their music, whether passively or actively. The exponential decay for the session behavior penalizes large differences more heavily. The distribution structure captures whether users have a focused or diverse listening history, which can be an important aspect of their music taste. 

Finally, the audio feature similarity captures whether the sonic characteristics of users' top tracks are similar. The data for each audio feature is sourced from #link("https://tunebat.com/", "Tunebat"). Energy, danceability, and happiness are weighted the highest in this component, since these are the primary mood indicators, while loudness can be present in all genres of music. This component allows for users to have similar tastes even if they don't share artists or genres, as long as the overall sonic qualities of their music are similar. 

The final similarity measure is a weighted sum of the component categories. Each component produces a value between 0 and 1, and all the weights sum to 1. The similarity measure is also a value between 0 and 1, where 1 indicates identical listening profiles and 0 indicates completely different profiles:

$
  S(u, v) = 0.25 dot s_"artist" + 0.20 dot s_"genre" + 0.15 dot s_"temporal" + 0.10 dot s_"session" + 0.10 dot s_"interaction" + 0.10 dot s_"distribution" + 0.10 dot s_"audio"
$

== Results by Category

*Artist Similarity*

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    #table(
      align: left,
      columns: 5,
      [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
      [*Alan*],[1.0000],[0.1171],[0.7234],[0.5055],
      [*Alexandra*],[0.1171],[1.0000],[0.0414],[0.0571],
      [*Anthony*],[0.7234],[0.0414],[1.0000],[0.6005],
      [*Koren*],[0.5055],[0.0571],[0.6005],[1.000]
    )
  ],
  [
    The matrix shows the combined artist similarity (TF-IDF cosine similarity plus Jaccard similarity) between each pair of users. Anthony and Alan have the highest artist similarity, while Alexandra has low artist similarity with all other users.
  ]
)

*Genre Similarity*

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    The matrix shows the genre similarity between each pair of users. Anthony and Alan have the highest genre similarity, while Alexandra has low genre similarity with all other users. This component, along with the artist similarity, accounts for 45% of the total weight, and is the strongest driver of overall similarity between users. The high genre similarity between Anthony and Alan, combined with their high artist similarity, results in them having the highest overall similarity score.
  ],
  [
    #table(
      align: left,
      columns: 5,
      [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
      [*Alan*],[1.0000],[0.1960],[0.9458],[0.8612],
      [*Alexandra*],[0.1960],[1.0000],[0.1540],[0.1509],
      [*Anthony*],[0.9458],[0.1540],[1.0000],[0.9125],
      [*Koren*],[0.8612],[0.1509],[0.9125],[1.0000]
    )
  ]
)

*Temporal Similarity*

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    #table(
      align: left,
      columns: 5,
      [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
      [*Alan*],[1.0000],[0.9388],[0.9015],[0.9481],
      [*Alexandra*],[0.9388],[1.0000],[0.9200],[0.9171],
      [*Anthony*],[0.9015],[0.9200],[1.0000],[0.9338],
      [*Koren*],[0.9481],[0.9171],[0.9338],[1.0000]
    )
  ],
  [
    The matrix shows the combined day-of-week and period-of-month similarity between each pair of users. All users have high temporal similarity with each other, indicating that they have similar listening patterns in terms of when they listen to music. This is the least discriminating component, since every group member is a student, around the same age, and likely shares similar schedules. Notably, Alexandra and Anthony have a 0.92 temporal similarity, which is the highest temporal similarity between any two users, despite being the least similar overall.
  ]
)

*Session Similarity*

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    The matrix shows the combined session similarity between each pair of users. Koren and Alexandra have the highest session similarity, while Alan and Koren have the lowest session similarity. The average session length for each of the users reveals a pattern: Alan and Anthony tend to listen to longer (\~40 minute long) sessions, while Koren and Alexandra listen to shorter (\~25 minute long) sessions, leading to higher session similarity between Koren and Alexandra, and lower session similarity between Alan and Koren. Plays per track is more informative: Alan (49.22) vs. Anthony (9.10) produces the largest gap in the plays per track matrix, which contributes to their lower session similarity.
  ],
  [
    #table(
      align: left,
      columns: 5,
      [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
      [*Alan*],[1.0000],[0.3304],[0.3541],[0.1971],
      [*Alexandra*],[0.3304],[1.0000],[0.2023],[0.6466],
      [*Anthony*],[0.3541],[0.2023],[1.0000],[0.4573],
      [*Koren*],[0.1971],[0.6466],[0.4573],[1.0000]
    )
  ]
)

*Interaction Similarity*

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    #table(
      align: left,
      columns: 5,
      [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
      [*Alan*],[1.0000],[0.7792],[0.9116],[0.9836],
      [*Alexandra*],[0.7792],[1.0000],[0.6908],[0.7804],
      [*Anthony*],[0.9116],[0.6908],[1.0000],[0.9105],
      [*Koren*],[0.9836],[0.7804],[0.9105],[1.0000]
    )
  ],
  [
    The matrix shows the combined iteration similarity (skip and shuffle rate) for the pairs of users. Skip rate is fairly uniform across the group (0.78-0.98), so shuffle rate is the more discriminating factor. Alexandra has a 93.3% shuffle rate, producing lower scores compared to everyone else's shuffle rate (\~50-60%). Alan and Koren have the highest interaction similarity, since they both have high shuffle rates, while Alexandra has the lowest interaction similarity with everyone else.  
  ]
)

*Distribution Structure Similarity*

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    The matrix shows the combined similarity for artist Gini and entropy. This is the least informative component after temporal similarity, since all users have relatively similar distribution structure in their listening history. Alexandra and Anthony have the highest distribution structure similarity, while Alan and Koren have the lowest distribution structure similarity.
  ],
  [
    #table(
      align: left,
      columns: 5,
      [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
      [*Alan*],[1.0000],[0.9399],[0.9680],[0.9001],
      [*Alexandra*],[0.9399],[1.0000],[0.9720],[0.9602],
      [*Anthony*],[0.9680],[0.9720],[1.0000],[0.9322],
      [*Koren*],[0.9001],[0.9602],[0.9322],[1.0000]
    ) 
  ]
)

*Audio Feature Similarity*

#grid(
  columns: 2,
  column-gutter: 2em,
  [
    #table(
      align: left,
      columns: 5,
      [],[*Alan*],[*Alexandra*],[*Anthony*],[*Koren*],
      [*Alan*],[1.0000],[0.9699],[0.9504],[0.9165],
      [*Alexandra*],[0.9699],[1.0000],[0.9104],[0.8973],
      [*Anthony*],[0.9504],[0.9104],[1.0000],[0.8993],
      [*Koren*],[0.9165],[0.8973],[0.8993],[1.0000]
    )
  ],
  [
    The matrix shows the audio feature similarity between each pair of users. Although some users listen to different artists and genres than other users, all pairs are very high, including Alan and Alexandra, with a score of 0.97, despite their genre gap. This is due to the fact that, even though their top genres are different (hip-hop trap vs. metalcore and pop punk), they are both similar in energy, intensity, and loudness, since they both listen to aggressive, high-energy music. These two genre grouping are also typically non-acoustic, non-instrumental, and high-BPM (130-190), which likely contributes to their high audio feature similarity. Anthony and Koren have the lowest audio feature similarity, likely because Koren's DnB and math rock tracks are almost entirely instrumental, which is different from Anthony's hip-hop and trap. 
  ]
)

== Composite Similarity Measure

The final similarity matrix confirms the structure present in the exploratory data analysis. Alan, Anthony, and Koren form a cohesive cluster, all three pairwise similarities fall between 0.74 and 0.82. This is driven in large part by the two highest-weighted components: artist and genre. They listen to many similar hip-hop/trap artists, and their behavioral profiles (interaction style, session habits) are similarly aligned. Within this cluster, Alan and Anthony are the most similar pair at 0.8236: their artist Jaccard is the highest in the dataset, their genre vectors are nearly identical, and their interaction habits closely mirror each other. Koren is less similar. His genre similarity with the other two remains very high, but his artist catalog diverges more, since Alan and Anthony have no DnB artists in their top 50.

#align(center, image("assets/user_similarity_matrix.png", width: 65%))

Alexandra is clearly isolated. Her mean similarity to the other three is approximately 0.49. Since the temporal, distribution, and audio components are all relatively high and uniform across users, the main drivers of her lower similarity are the artist and genre components. Her best similarity is to Alan (0.5112), since Alan's broader catalog and moderate shuffle rate make him slightly less different than Anthony or Koren. Alexandra's shuffle-heavy interaction style and more focused catalog of pop punk and metalcore artists results in her being the least similar to the other three users.

Overall, the similarity measure effectively captures the structure in the data and produces results that align with the insights from the exploratory data analysis. The weighting of the components allows for a nuanced comparison that takes into account both shared artists and genres, as well as behavioral patterns and audio characteristics. However, the similar lifestyles, age ranges, and social contexts inherently limit the range of similarity scores, since all users have relatively similar temporal patterns, distribution structure, and audio features.

== Similarity Measure Accuracy

The similarity function performs well on its primary task. It correctly identifies the most and least similar pairs and its conceptual design, separating content preference, behavior, and audio texture into distinct components, is sound. The dominant signal is artist and genre similarity, which together account for nearly 78% of the actual discriminating power, which is appropriate given that genre taste is the most fundamental way people differ as listeners. Session and interaction behavior contribute meaningfully as well. It is sensitive to real differences. It correctly identifies Alexandra as an outlier and Koren as the most central user, matching what you’d expect from manual inspection. The main limitation is that temporal, audio, and distribution structure contribute much less for this particular group despite holding 35% of the combined weight. All four users are friends in similar life circumstances, so they naturally listen at similar times of day and their monthly listening volume follows similar shapes. The audio component is similarly flat because high-energy tracks dominate across all four users regardless of genre. Another issue is that artists and genres are strongly correlated, since genres are derived from artists. To improve the function in the future, we could combine the artist and genre similarity into one component, increase the strength of the session behavior, and introduce a new component, possibly a lyric similarity, which could capture similarities in the themes and topics of the songs users listen to, independent of genre or audio features.

= Decision Trees & Classification

== Decision Tree

== Classification

= K-Means Clustering Analysis

To determine whether users' listening behavior is separable, we applied K-Means clustering to genre profiles derived from the the Spotify listening history data. This allows us focus on what genre families a given user listens to in a particular month in 2025, determining what genres they listen to, and if it changes month by month. 

For the genre profiles, each observation is a single (user, month) pair. There are 48 in total, representing all four users across the twelve months of 2025. Each observation is described by a genre share vector: for a given user in a given month, we compute what fraction of their total plays fall into which of 19 broad genre families (Hip-Hop/Rap, Rock, Metal, Pop, Electronic, etc.). The result is a length-19 vector that sums to 1. We run K-Means on these vectors to find groups of user-months that have similar genre distributions. 

The reason for structuring data this way is to see if a user's genre identity is consistent over the year. If it is, every one of their 12 monthly vectors should be similar to each other, and dissimilar to other users' vectors, meaning the algorithm should be able to recover user identify from the genre shares alone, without knowing to whom the data belongs to.

Genre labels from the listening history are mapped to a label that corresponds to that genre's broad family. For each (user, month) pair, it counts plays per family and normalizes it to a share vector, so that each of the 48 observation sum to 1. These vectors are then z-score standardized per dimension before clustering so no one genre family dominates the others. K-Means with $K = 4$ is run 10 times. The run with the lowest total inertia is kept. PCA is then applied to the same standardized data to produce a scatter plot for visualization. 

The loading plot below shows which genre families are most important for defining the principal components.

#align(center, image("assets/kmeans_genre_profiles_loadings_2025.png", width: 85%))

PC1 explains 41.1% of variance. On the plot for PC1, the orange bars (negative loadings) are hip-hop/rap, R&B, soul/funk, house/techno, DnB/dubstep, ambient/lo-fi, reggae, and jazz, the more urban and electronic side of music. The blue bars (positive loadings) are pop, alternative/indie, rock, metal, and punk/emo, the rock and pop side. A user who scores very negative on PC1 listens almost exclusively to hip-hop and its adjacent genres, and a user who scores very positive listens to more pop and rock. PC2 explains 21.9% of variance. It makes a finer distinction within the negative (hip-hop) side. Its two biggest negative loadings are hip-hop/rap and R&B, the modern side of the genre. A user who listens to purely hip-hop (and possibly contemporary R&B) will score very negative on PC2. On the rock side, PC2 is less critical since those genres all load positive regardless.

The scatterplot below shows the 48 (user, month) observations in the space of the first two principal components. The colors indicate the K-Means cluster assignment for each observation.

The four clusters shown in the plot are in different regions of the PCA space:
- *Cluster 1* (all 12 Alan months, blue circles): 
  - Center-left PC1 $approx$ -2 to +0.4, PC2 $approx$ -0.6 to -2.2. Alan listens to primarily hip-hop, bit has a fair amount of genre breadth (more than Anthony). He also listens to pop, soul/funk, and alternative, keeping his PC1 from going as far negative as Koren's, and his lack of electronic or DnB keeps his PC2 from going positive like Koren's, ending up in the middle-left.
- *Cluster 2* (11 of 12 Koren months, orange triangles):
  - Top-left, PC1 $approx$ -1.7 to -4.7, PC2 $approx$ +1.4 to +3.5. Koren has the most extreme negative PC1 values in the dataset because his listening has both hip-hop/rap and DnB/dubstep, both of which load negative on PC1. DnB/dubstep has one of the largest positive PC2 loadings, which pulls Koren's months into the upper region of the plot. The combination of "very negative PC1, very positive PC2" is unique to his mix of hip-hop and drum & bass. The one outlier, K-May, drops toward Cluster 3 because that month he had very little DnB (\~57% hip-hop, low DnB), removing the positive PC2 pull and making his profile resemble Anthony's.
- *Cluster 3* (all 12 Anthony months plus Koren-May, green diamonds): 
  - Center-bottom, PC1 $approx$ -0.8 to +0.3, PC2 $approx$ -2 to -3. Anthony is very low on PC1, since he listens to mainly hip-hop (\~71% of plays), which has a negative PC1 loading.Because his hip-hop share is so dominant, nothing else pulls it further negative. What puts him at the extreme bottom is PC2: his listening is so concentrated in hip-hop/rap and R&B, the two genres with the most negative PC2 loadings, that he scores lower on PC2 than anyone.
- *Cluster 4* (all 12 Alexandra months, pink squares):
  - Far right, PC1 $approx$ +3.6 to +4.6, PC2 $approx$ +1.2 to +1.7. Alexandra scores the highest PC1 of anyone in the dataset because her listening is almost entirely rock, metal, punk/emo, and alternative. These genres have the largest positive loadings on PC1. Every single one of her 12 months lands in the same tight region, completely isolated from the other three users. There is no overlap with any other cluster.

#align(center, image("assets/kmeans_genre_profiles_pca_2025.png", width: 90%))

Therefore, these users are clearly separable. Each cluster represents a distinct genre profile. Cluster 3 (Anthony) is almost completely hip-hop centric, with \~71% of plays being hip-hop/rap with R&B as a distant second. Cluster 1 (Alan) is also hip-hop dominated at \~48% of plays, but with significant secondary shares in pop, soul/funk, and alternative, indicating a listener centered in hip-hop who still branches into adjacent genres. Cluster 2 (Koren) is split between hip-hio/rap (\~34%) and DnB/dubstep (\~19%), making it the only cluster defined by two co-dominant genres, making it a unique genre identity. Cluster 4 (Alexandra) is completely separate from the rest of the clusters, with ~21% pop, ~19% metal, ~14% alternative/indie, ~14% punk/emo, and ~12% rock, with no meaningful hip-hop presence. This is a pure rock/alternative cluster, and Alexandra's consistent placement in this cluster across all 12 months shows that her genre identity is stable and distinct from the other users. 

The fact that Koren's May month falls into Cluster 3 with Anthony, rather than Cluster 2 with his other months, is interesting and suggests that his genre identity is more fluid than the other users. In May, Koren's hip-hop share was very high (\~57%) and his DnB share was very low, which made his profile resemble Anthony's more than his usual hip-hop/DnB mix. This shows that while Koren has a unique genre identity when his full range of listening is considered, there are moments where his listening behavior can align closely with another user's profile.

Overall, the K-Means clustering analysis reveals that these users have distinct and separable genre profiles, with Alexandra standing out as the most unique, while Anthony and Alan share a hip-hop centric cluster, and Koren occupies a unique space defined by his mix of hip-hop and DnB.

= Outlier Detection

In the Spotify extended listening history data, there are many outliers for each person, in terms of tracks and artists. In this case, these reflect the long tail of music listening behavior, where users have a core set of artists and tracks they listen to frequently, but also a large number of artists and tracks that they listen to only a few times.

Looking at box plots for the distributions of plays per artist and plays per track, it is clear that the distributions are highly right-skewed for all four users. This means most artists and tracks have a low play count, while a small number of artists and tracks have a very high play count.

#grid(
  columns: 2,
  column-gutter: 2em,
  align: center,
  [
    #image("assets/boxplot_plays_per_artist_2025.png")
    #cap[Distribution of plays per artist for users (2025)]
  ],
  [
    #image("assets/boxplot_plays_per_track_2025.png")
    #cap[Distribution of plays per track for users (2025)]
  ]
)

The 1.5 IQR method was used to detect outliers, so any track or artist above each user's upper bound is categorized as unusually high listening, making it easier to see which artists and songs stand out for each person. Since the IQR rule is applied per user, each person has a different cutoff for what counts as an outlier, meaning a high outlier count does not necessarily indicate more extreme listening behavior, but rather a wider range of play counts. 

The table below shows the upper bound and outlier count for each user for both artists and tracks. Notably, Alexandra has the lowest upper bounds for both artists and tracks, consistent with her more focused listening profile with fewer extremes.

#table(
  align: left,
  columns: 5,
  [*User*],[*Artist Upper Bound*],[*Artist Outliers*],[*Track Upper Bound*],[*Track Outliers*],
  [Alan],[119.5],[70],[32.0],[145],
  [Alexandra],[20.5],[78],[10.5],[51],
  [Anthony],[34.5],[71],[8.5],[404],
  [Koren],[26.0],[128],[13.5],[342],
)

This pattern is visualized in the plots below, comparing the number of artist and track outliers across users. Artist-level counts are relatively similar for Alan, Alexandra, and Anthony, while Koren stands out with the largest artist-level outlier set, consistent with his incredible taste in music. At the track level, Anthony and Koren have far more outliers than Alan or Alexandra, which suggests a broader set of songs that they listen to more frequently, while Alan and Alexandra have a more focused set of tracks that they listen to repeatedly. 

#grid(
  columns: 2,
  column-gutter: 2em,
  align: center,
  [
    #image("assets/artist_outlier_counts.png")
    #cap[Artist outlier counts by user (2025)]
  ],
  [
    #image("assets/track_outlier_counts.png")
    #cap[Track outlier counts by user (2025)]
  ]
)

== User-Level Artist Outliers

*Alan.* Alan's strongest outliers are Kanye West (1179 plays), JPEGMAFIA (1086 plays), Kendrick Lamar (922 plays), Jessie Ware (794 plays), and Denzel Curry (756 plays). Overall, Alan's extreme artists are mostly hip-hop centered, however the list also includes Jessie Ware, a pop/disco/funk artist, making his outlier profile more mixed than a pure rap-only pattern. 

*Alexandra.* Alexandra's strongest artist outliers are Beartooth (563), Neck Deep (444), State Champs (385), Wage War (306), and Bring Me The Horizon (284). Unlike Alan's, her list is tightly grouped inside pop-punk/metalcore-adjacent listening, making Alexandra's artist outliers highly coherent stylistically. Instead of a broad mixture of unrelated artist outliers, her list shows a stable genre-centered pattern which fits the rest of the report’s description of Alexandra as a more style-consistent listener.

*Anthony.* Anthony’s strongest artist outliers are Kanye West (1199), Playboi Carti (639), Drake (556), Young Thug (511), and Future (425). This is the clearest trap/mainstream rap concentration among the four users. Kanye West, Playboi Carti, Drake, Young Thug, and Future all point toward a profile centered around these genres, and the size of Anthony’s broader outlier set suggests that his above-baseline listening is concentrated across many songs within a relatively narrow artist space.

*Koren.* Koren’s strongest artist outliers are Playboi Carti (1071), Mint (463), LTJ Bukem (299), Che (290), and Roni Size (276). Playboi Carti is the largest artist outlier by a wide margin, but the presence of LTJ Bukem and Roni Size is important because it shows the drum-and-bass side of Koren’s profile very clearly. That makes Koren’s outlier set the most split between contemporary hip-hop/trap and and classic jungle/DnB, which is consistent with the exploratory report that suggested that Koren alternates between concentrated and exploratory states.

== User-Level Track Outliers

*Alan.* Alan’s strongest track outliers are Begin Again by Jessie Ware (104 plays), In Your Eyes by Jessie Ware (98 plays), either on or off the drugs by JPEGMAFIA (95 plays), Remember Where You Are by Jessie Ware (86 plays), and The Kill by Jessie Ware (84 plays). What stands out immediately is the cluster of Jessie Ware songs near the very top. That means Alan’s track-level outliers are not just coming from one rap-heavy pool of repeated tracks; instead, a small number of Jessie Ware tracks are repeated intensely enough to become some of his largest track anomalies of the year.

*Alexandra.* Alexandra’s strongest track outliers are Vendetta by Palisades (119), Sunshine! by Beartooth (25), Static by Sleep Theory (21), Heartbreak Of The Century by Neck Deep (19), and Riptide by Beartooth (19). These tracks are aligned closely with her artist-level outliers and show a clean continuation of her rock/pop-punk/metalcore profile. In this case, the track-level outliers again reinforce a coherent taste profile.

*Anthony.* Anthony’s strongest track outliers are Yale by Ken Carson (51), ss by Ken Carson (50), No Pole by Don Toliver (48), POWER by Kanye West (46), and tv off (feat. lefty gunplay) by Kendrick Lamar (44). These tracks show a concentrated repeat pattern around Ken Carson, Kanye West, and Kendrick Lamar, which fits Anthony’s broader artist-level pattern. Anthony’s very large number of flagged track outliers indicates that repeated listening is spread across many tracks above his user-specific threshold, not just isolated to one or two songs.

*Koren.* Koren’s strongest track outliers are POP OUT by Playboi Carti (45), Brown Paper Bag by Roni Size (44), K POP by Playboi Carti (42), Myron by Lil Uzi Vert (39), and Autobots by ark762 (38). This list again shows the split in Koren’s listening behavior. Hip=hop/trap artists like Playboi Carti is prominent, but Brown Paper Bag and other DnB entries show that his biggest track-level outliers are not confined to only one contemporary rap cluster. The result is a more stylistically mixed outlier profile than Anthony’s, even when both users share a strong trap component.

=== Cross-User Commonality

The outlier overlap is limited and highly structured. The strongest artist-level overlap occurs between Alan and Anthony, who share ten artist outliers: A\$AP Rocky, Drake, J. Cole, JAY-Z, Kanye West, Kendrick Lamar, Metro Boomin, The Weeknd, Travis Scott, Tyler, The Creator. These results are expected. Both of these users are heavy listeners to hip-hop, rap, and contemporary R&B, and these outliers are mainstream artists from their corresponding genres.

Anthony and Koren also overlap at the artist level, sharing nine artist outliers: 1900Rugrat, Chief Keef, Drake, Gunna, Ken Carson, Kendrick Lamar, Lil Uzi Vert, Playboi Carti, Travis Scott. However, their overlap becomes even stronger at the song level, where they share twenty-six track outliers. This means that Anthony and Koren not only listen to similar artists frequently, but the same songs by these artists, and they listen to them at similarly high frequencies relative to their own listening history.

Alan and Koren share a smaller set of four artist outliers: Clipse, Drake, Kendrick Lamar, Travis Scott. Alexandra shares no 2025 artist outliers and no 2025 track outliers with any other user. This makes Alexandra the clearest outlier in terms of the group: her listening anomalies are almost entirely unique to her and do not sit inside the same artist or track neighborhoods as the other three users.

#grid(
  columns: 2,
  column-gutter: 2em,
  align: center,
  [
    #image("assets/shared_artist_outliers.png")
    #cap[Shared artist outlier counts between users (2025)]
  ],
  [
    #image("assets/shared_track_outliers.png")
    #cap[Shared track outlier counts between users (2025)]
  ]
)

At the broadest level, there is no artist outlier shared by all four users, and there is no track outlier shared by three or more users. The only artist outliers shared by three users are Drake, Kendrick Lamar, and Travis Scott. So, while there is some rap-based overlap, the truly unusual repeat behavior is still mostly personalized.

#hr()

#box(theme: "info", title: "AI Disclosure", [
  The group collected and downloaded their personal Spotify Extended Streaming History data, wrote the data processing and import pipeline, structured all JSON outputs, and built the summary tables and visualizations used throughout this report. Claude was used to assist in writing the written analysis and drawing insights from the data. Prompts provided to Claude included requests to identify trends, behavioral patterns, and cross-user comparisons based on the structured data files. All AI-generated analysis was reviewed and verified by group members against the underlying data.
])
