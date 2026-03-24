include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_share_time_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const MIN_PLAYS = 25
const TOP_N = 15

function get_dim_data(conn, dim_sql)
  query = """
    SELECT
      lh.username,
      ag.genre,
      $dim_sql   AS time_val,
      COUNT(*)::int AS plays
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE EXTRACT(YEAR FROM lh.timestamp) = 2025
      AND lh.artist_name IS NOT NULL
    GROUP BY lh.username, ag.genre, time_val
    ORDER BY lh.username, ag.genre, time_val
  """
  return DataFrame(execute(conn, query))
end

function get_all_data()
  conn = get_connection()
  hour_df = get_dim_data(conn, "EXTRACT(HOUR  FROM lh.timestamp)::int")
  dow_df = get_dim_data(conn, "EXTRACT(DOW   FROM lh.timestamp)::int")
  month_df = get_dim_data(conn, "EXTRACT(MONTH FROM lh.timestamp)::int")
  close(conn)
  return hour_df, dow_df, month_df
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
  isempty(genres) || isempty(time_vals) && return zeros(0, 0)

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

function plot_heatmap(genres, time_labels, mat, title_str, fname;
  fig_w=900, xlabel="", xrot=0.0)
  n_g, n_t = size(mat)
  (n_g == 0 || n_t == 0) && return

  fig_h = max(420, n_g * 30 + 180)
  fig = Figure(size=(fig_w, fig_h))

  ax = Axis(fig[1, 1],
    title=title_str,
    xlabel=xlabel,
    ylabel="Genre",
    xticks=(1:n_t, time_labels),
    xticklabelrotation=xrot,
    yticks=(1:n_g, genres),
    yreversed=true,
  )

  hm = heatmap!(ax, 1:n_t, 1:n_g, mat',
    colormap=:YlOrRd,
    colorrange=(0.0, maximum(mat) > 0 ? maximum(mat) : 1.0),
  )

  Colorbar(fig[1, 2], hm, label="Share of Plays")

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  println("Fetching data...")
  hour_df, dow_df, month_df = get_all_data()

  hour_vals = collect(0:23)
  hour_labels = [@sprintf("%02d", h) for h in hour_vals]

  dow_vals = [1, 2, 3, 4, 5, 6, 0]
  dow_labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

  month_vals = collect(1:12)
  month_labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

  json_out = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    println("\n$display_name")

    genres = top_genres(hour_df, username)
    isempty(genres) && (println("  no qualifying genres"); continue)
    println("  $(length(genres)) qualifying genres")

    hour_mat = build_share_matrix(hour_df, username, genres, hour_vals)
    plot_heatmap(genres, hour_labels, hour_mat,
      "Genre Share by Hour - $display_name - 2025 (min $MIN_PLAYS plays)",
      joinpath(PLOTS_DIR, "genre_share_hour_$(username).png"),
      fig_w=1100, xlabel="Hour of Day", xrot=0.0)

    dow_mat = build_share_matrix(dow_df, username, genres, dow_vals)
    plot_heatmap(genres, dow_labels, dow_mat,
      "Genre Share by Day of Week - $display_name - 2025 (min $MIN_PLAYS plays)",
      joinpath(PLOTS_DIR, "genre_share_dow_$(username).png"),
      fig_w=700, xlabel="Day of Week", xrot=0.0)

    month_mat = build_share_matrix(month_df, username, genres, month_vals)
    plot_heatmap(genres, month_labels, month_mat,
      "Genre Share by Month - $display_name - 2025 (min $MIN_PLAYS plays)",
      joinpath(PLOTS_DIR, "genre_share_month_$(username).png"),
      fig_w=850, xlabel="Month", xrot=0.0)

    json_out[display_name] = Dict{String,Any}(
      "genres" => genres,
      "min_plays" => MIN_PLAYS,
      "hour" => Dict("labels" => hour_labels, "matrix" => [hour_mat[i, :] for i in 1:length(genres)]),
      "dow" => Dict("labels" => dow_labels, "matrix" => [dow_mat[i, :] for i in 1:length(genres)]),
      "month" => Dict("labels" => month_labels, "matrix" => [month_mat[i, :] for i in 1:length(genres)]),
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_share_time_2025.json"), json_out)
end

main()
