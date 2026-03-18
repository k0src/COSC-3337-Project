include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Colors

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const USER_ORDER = sort(collect(keys(NAMES)))

const MONTH_NAMES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

# Data

function get_monthly_top_artist(year)
  conn = get_connection()

  query = """
    SELECT
      username,
      TO_CHAR(DATE_TRUNC('month', timestamp), 'YYYY-MM') AS month,
      artist_name,
      COUNT(*) AS play_count
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = $year
    GROUP BY username, month, artist_name
    ORDER BY username, month, play_count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Plots

function plot_monthly_top_artist(df, year)
  nrow(df) == 0 && return

  all_top_artists = String[]
  user_monthly = Dict{String,Vector{Tuple{Int,Int,String}}}()

  for username in USER_ORDER
    user_df = filter(r -> String(r.username) == username, df)
    entries = Tuple{Int,Int,String}[]
    for m in sort(unique(String.(user_df.month)))
      month_df = filter(r -> String(r.month) == m, user_df)
      top_artist = String(first(month_df).artist_name)
      total = sum(Int.(month_df.play_count))
      push!(entries, (parse(Int, m[6:7]), total, top_artist))
      push!(all_top_artists, top_artist)
    end
    user_monthly[username] = entries
  end

  unique_artists = unique(all_top_artists)
  palette = distinguishable_colors(length(unique_artists), [RGB(1, 1, 1), RGB(0, 0, 0)], dropseed=true)
  artist_color = Dict(a => palette[i] for (i, a) in enumerate(unique_artists))

  for username in USER_ORDER
    display_name = get(NAMES, username, username)
    entries = get(user_monthly, username, Tuple{Int,Int,String}[])
    isempty(entries) && continue

    month_nums = [e[1] for e in entries]
    month_totals = [e[2] for e in entries]
    top_artists = [e[3] for e in entries]
    dot_colors = [artist_color[a] for a in top_artists]

    user_unique_artists = unique(top_artists)

    fig = Figure(size=(1300, 500))
    Label(fig[0, 1:2], "Monthly Play Count & Top Artist - $display_name - $year",
      fontsize=16, font=:bold)

    ax = Axis(fig[1, 1],
      xlabel="Month",
      ylabel="Play Count",
      xticks=(1:12, MONTH_NAMES),
    )

    colsize!(fig.layout, 1, Relative(0.78))

    lines!(ax, month_nums, month_totals, color=:gray70, linewidth=1.5)
    scatter!(ax, month_nums, month_totals, color=dot_colors, markersize=12)

    ypad = (maximum(month_totals) - minimum(month_totals)) * 0.05 + 1
    for (mn, mt, artist) in zip(month_nums, month_totals, top_artists)
      text!(ax, mn, mt + ypad,
        text=artist,
        fontsize=7,
        rotation=π / 3,
        align=(:left, :bottom),
        color=artist_color[artist],
      )
    end

    elems = [PolyElement(polycolor=artist_color[a]) for a in user_unique_artists]
    Legend(fig[1, 2], elems, user_unique_artists, "Top Artist")

    fname = "monthly_top_artist_$(lowercase(display_name))_$(year).png"
    save(fname, fig)
    println("Plot saved to $fname")
  end
end

# Main

function main()
  for year in [2024, 2025]
    df = get_monthly_top_artist(year)
    nrow(df) == 0 && continue

    plot_monthly_top_artist(df, year)

    json_data = Dict{String,Any}()
    for username in USER_ORDER
      display_name = get(NAMES, username, username)
      user_df = filter(r -> String(r.username) == username, df)
      user_data = Dict{String,Any}()
      for m in sort(unique(String.(user_df.month)))
        month_df = filter(r -> String(r.month) == m, user_df)
        top = first(month_df)
        user_data[m] = Dict{String,Any}(
          "total_plays" => sum(Int.(month_df.play_count)),
          "top_artist" => String(top.artist_name),
          "top_artist_plays" => Int(top.play_count),
          "artists" => [
            Dict{String,Any}("artist" => String(r.artist_name), "plays" => Int(r.play_count))
            for r in eachrow(month_df)
          ],
        )
      end
      json_data[display_name] = user_data
    end

    save_json("monthly_top_artist_$(year).json", json_data)
  end
end

main()
