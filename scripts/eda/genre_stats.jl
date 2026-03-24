include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["dasucc", "alanjzamora", "alexxxxxrs", "korenns"]
const DISPLAY_ORDER = ["Anthony", "Alan", "Alexandra", "Koren"]

const PERIODS = [
  ("2024", 2024),
  ("2025", 2025),
  ("alltime", nothing),
]

function get_data()
  conn = get_connection()

  query = """
    SELECT
      lh.username,
      EXTRACT(YEAR FROM lh.timestamp)::INT  AS year,
      ag.genre,
      COUNT(*)                              AS play_count
    FROM listening_history   lh
    JOIN artist_genres        ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
    GROUP BY lh.username,
             EXTRACT(YEAR FROM lh.timestamp)::INT,
             ag.genre
    ORDER BY lh.username, play_count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function filter_period(df, year_filter)
  year_filter === nothing && return df
  filter(r -> r.year == year_filter, df)
end

function genre_counts(df)
  result = Dict{String,Int}()
  for row in eachrow(df)
    g = String(row.genre)
    result[g] = get(result, g, 0) + Int(row.play_count)
  end
  genres = sort(collect(keys(result)), by=g -> -result[g])
  counts = [result[g] for g in genres]
  return genres, counts
end

function build_freq_table(counts)
  total = sum(counts)
  pcts = counts ./ total .* 100.0
  cumul = cumsum(pcts)
  return pcts, cumul, total
end

function plot_top20(genres, counts, title, fname)
  n = min(20, length(genres))
  g20 = reverse(genres[1:n])
  c20 = Float64.(reverse(counts[1:n]))

  fig = Figure(size=(950, 700))
  ax = Axis(fig[1, 1],
    title=title,
    xlabel="Play Count (by genre)",
    yticks=(1:n, g20),
  )
  barplot!(ax, 1:n, c20, direction=:x, color=Makie.wong_colors()[1])

  save(fname, fig)
  println("  plot saved: $fname")
end

function print_freq_table(display_name, period_label, genres, counts, pcts, cumul, total)
  n_total = length(genres)
  n_shown = min(30, n_total)
  println("$display_name - $period_label")
  println("  total genre-plays: $total  |  distinct genres: $n_total  |  showing top $n_shown")
  @printf "  %-32s  %8s  %7s  %14s\n" "genre" "plays" "%" "cumulative %"
  for i in 1:n_shown
    @printf "  %-32s  %8d  %7.2f  %14.2f\n" genres[i] counts[i] pcts[i] cumul[i]
  end
  if n_total > n_shown
    println("  ... $(n_total - n_shown) more genres saved in JSON")
  end
  println()
end

function print_unique_table(unique_data)
  println("\nTotal Unique Genres:")
  @printf "  %-14s  %8s  %8s  %10s\n" "" "2024" "2025" "alltime"
  for label in vcat(DISPLAY_ORDER, ["group"])
    v2024 = get(get(unique_data, "2024", Dict()), label, "-")
    v2025 = get(get(unique_data, "2025", Dict()), label, "-")
    vall = get(get(unique_data, "alltime", Dict()), label, "-")
    @printf "  %-14s  %8s  %8s  %10s\n" label string(v2024) string(v2025) string(vall)
  end
  println()
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  j_unique = Dict{String,Any}()
  j_top20 = Dict{String,Any}()
  j_freq = Dict{String,Any}()

  for (period_label, year_filter) in PERIODS
    period_df = filter_period(df, year_filter)
    nrow(period_df) == 0 && continue

    j_unique[period_label] = Dict{String,Any}()
    j_top20[period_label] = Dict{String,Any}()
    j_freq[period_label] = Dict{String,Any}()

    g_genres, g_counts = genre_counts(period_df)
    n20g = min(20, length(g_genres))

    j_unique[period_label]["group"] = length(g_genres)

    plot_top20(g_genres, g_counts,
      "Top 20 Genres - All Users - $period_label",
      "genre_top20_group_$(period_label).png")

    j_top20[period_label]["group"] = [
      Dict{String,Any}("genre" => g_genres[i], "play_count" => g_counts[i])
      for i in 1:n20g
    ]

    for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
      user_df = filter(r -> String(r.username) == username, period_df)
      nrow(user_df) == 0 && continue

      genres, counts = genre_counts(user_df)
      n20u = min(20, length(genres))

      j_unique[period_label][display_name] = length(genres)

      plot_top20(genres, counts,
        "Top 20 Genres - $display_name - $period_label",
        "genre_top20_$(username)_$(period_label).png")

      j_top20[period_label][display_name] = [
        Dict{String,Any}("genre" => genres[i], "play_count" => counts[i])
        for i in 1:n20u
      ]

      pcts, cumul, total = build_freq_table(counts)
      print_freq_table(display_name, period_label, genres, counts, pcts, cumul, total)

      j_freq[period_label][display_name] = Dict{String,Any}(
        "total_genre_plays" => total,
        "n_distinct_genres" => length(genres),
        "genres" => [
          Dict{String,Any}(
            "genre" => genres[i],
            "play_count" => counts[i],
            "pct" => pcts[i],
            "cumulative_pct" => cumul[i],
          )
          for i in 1:length(genres)
        ],
      )
    end
  end

  print_unique_table(j_unique)

  save_json("genre_total_unique.json", j_unique)
  save_json("genre_top20.json", j_top20)
  save_json("genre_frequency_table.json", j_freq)
end

main()
