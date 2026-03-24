include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using Statistics
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
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function filter_period(df, year_filter)
  year_filter === nothing && return df
  filter(r -> r.year == year_filter, df)
end

function genre_play_counts(df, username)
  sub = filter(r -> String(r.username) == username, df)
  result = Dict{String,Int}()
  for row in eachrow(sub)
    g = String(row.genre)
    result[g] = get(result, g, 0) + Int(row.play_count)
  end
  return collect(values(result))
end

function gini(counts)
  sorted = sort(Float64.(counts))
  n = length(sorted)
  total = sum(sorted)
  cuml_plays = [0.0; cumsum(sorted) ./ total]
  cuml_genres = collect(range(0.0, 1.0, length=n + 1))
  area = sum(
    (cuml_genres[i+1] - cuml_genres[i]) * (cuml_plays[i+1] + cuml_plays[i]) / 2.0
    for i in 1:n
  )
  return 1.0 - 2.0 * area
end

function shannon_entropy(counts)
  total = Float64(sum(counts))
  total == 0.0 && return 0.0
  H = 0.0
  for c in counts
    c == 0 && continue
    p = c / total
    H -= p * log2(p)
  end
  return H
end

function print_table(all_data)
  println("\nGenre Concentration Metrics:")
  @printf "  %-12s  %-10s  %10s  %8s  %10s\n" "user" "period" "n_genres" "gini" "entropy"
  println("  " * "-"^56)
  for display_name in DISPLAY_ORDER
    haskey(all_data, display_name) || continue
    for (period_label, _) in PERIODS
      haskey(all_data[display_name], period_label) || continue
      d = all_data[display_name][period_label]
      @printf "  %-12s  %-10s  %10d  %8.4f  %10.4f\n" display_name period_label d["n_genres"] d["gini"] d["entropy"]
    end
    println()
  end
end

function main()
  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  all_data = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    all_data[display_name] = Dict{String,Any}()

    for (period_label, year_filter) in PERIODS
      period_df = filter_period(df, year_filter)
      counts = genre_play_counts(period_df, username)
      length(counts) < 2 && continue

      g = gini(counts)
      h = shannon_entropy(counts)

      all_data[display_name][period_label] = Dict{String,Any}(
        "n_genres" => length(counts),
        "gini" => g,
        "entropy" => h,
      )
    end
  end

  print_table(all_data)
  save_json("genre_concentration.json", all_data)
end

main()
