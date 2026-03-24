include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_monthly_top_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = ["dasucc", "alanjzamora", "alexxxxxrs", "korenns"]
const DISPLAY_ORDER = ["Anthony", "Alan", "Alexandra", "Koren"]

const MONTH_NAMES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

function get_genre_data()
  conn = get_connection()

  query = """
    SELECT
      lh.username,
      EXTRACT(MONTH FROM lh.timestamp)::INT  AS month,
      ag.genre,
      COUNT(*)                               AS genre_plays
    FROM listening_history   lh
    JOIN artist_genres        ag ON lh.artist_name = ag.artist_name
    WHERE lh.artist_name IS NOT NULL
      AND EXTRACT(YEAR FROM lh.timestamp)::INT = 2025
    GROUP BY lh.username,
             EXTRACT(MONTH FROM lh.timestamp)::INT,
             ag.genre
    ORDER BY lh.username, month, genre_plays DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_play_data()
  conn = get_connection()

  query = """
    SELECT
      username,
      EXTRACT(MONTH FROM timestamp)::INT  AS month,
      COUNT(*)                            AS total_plays
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp)::INT = 2025
    GROUP BY username,
             EXTRACT(MONTH FROM timestamp)::INT
    ORDER BY username, month
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function build_monthly_data(genre_df, play_df, username)
  user_genre = filter(r -> String(r.username) == username, genre_df)
  user_play = filter(r -> String(r.username) == username, play_df)

  months = sort(unique(Int.(user_play.month)))

  result = NamedTuple[]
  for m in months
    month_play = filter(r -> r.month == m, user_play)
    month_genre = filter(r -> r.month == m, user_genre)

    total_plays = nrow(month_play) > 0 ? Int(month_play.total_plays[1]) : 0

    if nrow(month_genre) > 0
      best = argmax(Int.(month_genre.genre_plays))
      top_genre = String(month_genre.genre[best])
      top_genre_plays = Int(month_genre.genre_plays[best])
    else
      top_genre = "unknown"
      top_genre_plays = 0
    end

    push!(result, (
      month=m,
      month_name=MONTH_NAMES[m],
      total_plays=total_plays,
      top_genre=top_genre,
      top_genre_plays=top_genre_plays,
    ))
  end

  return result
end

function build_color_map(all_monthly_data)
  all_genres = String[]
  for md in values(all_monthly_data)
    for d in md
      push!(all_genres, d.top_genre)
    end
  end
  unique_genres = unique(all_genres)
  palette = Makie.wong_colors()
  return Dict(g => palette[mod1(i, length(palette))] for (i, g) in enumerate(unique_genres))
end

function color_to_hex(c)
  @sprintf("#%02X%02X%02X",
    round(Int, c.r * 255),
    round(Int, c.g * 255),
    round(Int, c.b * 255),
  )
end

function plot_monthly_top_genre(monthly_data, color_map, display_name, fname)
  isempty(monthly_data) && return

  months = Float64.([d.month for d in monthly_data])
  plays = Float64.([d.total_plays for d in monthly_data])
  top_genres = [d.top_genre for d in monthly_data]
  pt_colors = [color_map[g] for g in top_genres]
  tick_labels = [MONTH_NAMES[d.month] for d in monthly_data]

  y_span = maximum(plays) - minimum(plays)
  y_offset = max(y_span * 0.05, 3.0)

  fig = Figure(size=(1050, 560))
  ax = Axis(fig[1, 1],
    title="Monthly Top Genre - $display_name - 2025",
    xlabel="Month",
    ylabel="Total Plays",
    xticks=(months, tick_labels),
  )

  lines!(ax, months, plays, color=(:gray60, 0.55), linewidth=1.8)

  scatter!(ax, months, plays,
    color=pt_colors, markersize=13, strokecolor=:white, strokewidth=1.2)

  for (i, d) in enumerate(monthly_data)
    text!(ax, months[i], plays[i] + y_offset,
      text=d.top_genre,
      fontsize=8,
      rotation=pi / 5,
      align=(:left, :bottom),
      color=color_map[d.top_genre],
    )
  end

  seen = unique(top_genres)
  Legend(fig[2, 1],
    [MarkerElement(color=color_map[g], marker=:circle, markersize=12) for g in seen],
    seen,
    orientation=:horizontal,
    tellwidth=false,
    nbanks=2,
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

function print_monthly_table(display_name, monthly_data)
  println("$display_name - 2025")
  @printf "  %-5s  %12s  %16s  %s\n" "month" "total_plays" "top_genre_plays" "top_genre"
  for d in monthly_data
    @printf "  %-5s  %12d  %16d  %s\n" d.month_name d.total_plays d.top_genre_plays d.top_genre
  end
  println()
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  genre_df = get_genre_data()
  play_df = get_play_data()
  (nrow(genre_df) == 0 || nrow(play_df) == 0) && (println("No data for 2025"); return)

  all_monthly = Dict(
    username => build_monthly_data(genre_df, play_df, username)
    for username in USER_ORDER
  )

  color_map = build_color_map(all_monthly)
  hex_map = Dict(g => color_to_hex(c) for (g, c) in color_map)

  all_data = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    monthly_data = all_monthly[username]
    isempty(monthly_data) && continue

    print_monthly_table(display_name, monthly_data)

    fname = joinpath(PLOTS_DIR, "genre_monthly_top_$(username)_2025.png")
    plot_monthly_top_genre(monthly_data, color_map, display_name, fname)

    user_genres = unique([d.top_genre for d in monthly_data])

    all_data[display_name] = Dict{String,Any}(
      "months" => [
        Dict{String,Any}(
          "month" => d.month,
          "month_name" => d.month_name,
          "total_plays" => d.total_plays,
          "top_genre" => d.top_genre,
          "top_genre_plays" => d.top_genre_plays,
          "color" => hex_map[d.top_genre],
        )
        for d in monthly_data
      ],
      "genre_colors" => Dict(g => hex_map[g] for g in user_genres),
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_monthly_top_2025.json"), all_data)
end

main()
