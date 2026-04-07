include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using Printf

const DATA_DIR = "/Users/korenstalnaker/!Code/COSC-3337-Project/data"

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const MIN_PLAYS = 25
const TOP_N = 15

function get_dim_data(conn, dim_sql, year_filter)
  where_clause = year_filter === nothing ?
    "lh.artist_name IS NOT NULL" :
    "EXTRACT(YEAR FROM lh.timestamp) = $year_filter AND lh.artist_name IS NOT NULL"
  query = """
    SELECT
      lh.username,
      ag.genre,
      $dim_sql AS time_val,
      COUNT(*)::int AS plays
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE $where_clause
    GROUP BY lh.username, ag.genre, time_val
    ORDER BY lh.username, ag.genre, time_val
  """
  return DataFrame(execute(conn, query))
end

function top_genres(df, username)
  sub = filter(r -> String(r.username) == username, df)
  isempty(sub) && return String[]
  totals = Dict{String,Int}()
  for row in eachrow(sub)
    g = String(row.genre)
    totals[g] = get(totals, g, 0) + Int(row.plays)
  end
  qualified = [(g, n) for (g, n) in totals if n >= MIN_PLAYS]
  sort!(qualified, by=kv -> -kv[2])
  return [kv[1] for kv in qualified[1:min(TOP_N, length(qualified))]]
end

function build_share_matrix(df, username, genres, time_vals)
  (isempty(genres) || isempty(time_vals)) && return zeros(0, 0)
  genre_idx = Dict(g => i for (i, g) in enumerate(genres))
  time_idx = Dict(v => i for (i, v) in enumerate(time_vals))
  n_g, n_t = length(genres), length(time_vals)
  counts = zeros(Float64, n_g, n_t)
  sub = filter(r -> String(r.username) == username, df)
  for row in eachrow(sub)
    g = String(row.genre)
    tv = Int(row.time_val)
    haskey(genre_idx, g) || continue
    haskey(time_idx, tv) || continue
    counts[genre_idx[g], time_idx[tv]] += Int(row.plays)
  end
  for j in 1:n_t
    col_sum = sum(counts[:, j])
    col_sum > 0 && (counts[:, j] ./= col_sum)
  end
  return counts
end

function build_period_json(conn, year_filter)
  dow_df = get_dim_data(conn, "EXTRACT(DOW FROM lh.timestamp)::int", year_filter)

  dow_vals = [1, 2, 3, 4, 5, 6, 0]
  dow_labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

  json_out = Dict{String,Any}()
  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    println("  $display_name")
    genres = top_genres(dow_df, username)
    isempty(genres) && (println("    no qualifying genres"); continue)
    dow_mat = build_share_matrix(dow_df, username, genres, dow_vals)
    json_out[display_name] = Dict{String,Any}(
      "genres" => genres,
      "min_plays" => MIN_PLAYS,
      "dow" => Dict("labels" => dow_labels, "matrix" => [dow_mat[i, :] for i in 1:length(genres)]),
    )
  end
  return json_out
end

function main()
  conn = get_connection()

  for (label, year_filter) in [("2024", 2024), ("2025", 2025), ("alltime", nothing)]
    println("\nProcessing $label...")
    out_dir = joinpath(DATA_DIR, "genre_share_time_$label")
    mkpath(out_dir)
    json_out = build_period_json(conn, year_filter)
    save_json(joinpath(out_dir, "genre_share_time_$label.json"), json_out)
  end

  close(conn)
  println("\nDone.")
end

main()
