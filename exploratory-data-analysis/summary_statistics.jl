using DataFrames
using CairoMakie
using StatsBase

names = Dict(
  "korenns" => "Koren",
  "alexxxxxrs" => "Alexandra",
  "alanjzamora" => "Alan",
  "dasucc" => "Anthony",
)

# Data

function get_group_summary()
  conn = get_connection()

  query = """
    SELECT 
      COUNT(*) AS total_events,
      COUNT(DISTINCT track_id) AS unique_tracks,
      COUNT(DISTINCT artist_name) AS unique_artists,
      COUNT(DISTINCT album_name) AS unique_albums,
      COUNT(DISTINCT platform) AS unique_platforms,
      COUNT(DISTINCT conn_country) AS unique_countries
    FROM listening_history
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_user_summary()
  conn = get_connection()

  query = """
    SELECT 
      username,
      COUNT(*) AS total_events,
      COUNT(DISTINCT track_id) AS unique_tracks,
      COUNT(DISTINCT artist_name) AS unique_artists,
      COUNT(DISTINCT album_name) AS unique_albums,
      COUNT(DISTINCT platform) AS unique_platforms,
      COUNT(DISTINCT conn_country) AS unique_countries
    FROM listening_history
    GROUP BY username
    ORDER BY username
  """

  df = DataFrame(execute(conn, query))
  close(conn)

  return df
end

function get_events_over_time()
  conn = get_connection()

  query = """
    SELECT
      username,
      TO_CHAR(DATE_TRUNC('month', timestamp), 'YYYY-MM') AS month,
      COUNT(*) AS events
    FROM listening_history
    GROUP BY username, month
    ORDER BY username, month
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_hourly_counts(username)
  conn = get_connection()

  query = """
    SELECT
      EXTRACT(HOUR FROM timestamp)::INT AS hour,
      COUNT(*) AS events
    FROM listening_history
    WHERE username = '$username'
    GROUP BY hour
    ORDER BY hour
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Plots

function plot_total_events_per_user(df)
  fig = Figure(size=(800, 600))
  ax = Axis(fig[1, 1],
    title="Total Listening Events per User (2015-2026)",
    xlabel="User",
    ylabel="Total Listening Events"
  )

  labels = [get(names, u, u) for u in df.username]
  ax.xticks = (1:length(labels), String.(labels))
  barplot!(ax, 1:length(labels), Int.(df.total_events))

  save("total_listening_events_per_user.png", fig)
  println("Plot saved to total_listening_events_per_user.png")
end

function plot_unique_tracks_per_user(df)
  fig = Figure(size=(800, 600))
  ax = Axis(fig[1, 1],
    title="Unique Tracks per User (2015-2026)",
    xlabel="User",
    ylabel="Unique Tracks"
  )

  labels = [get(names, u, u) for u in df.username]
  ax.xticks = (1:length(labels), String.(labels))
  barplot!(ax, 1:length(labels), Int.(df.unique_tracks))

  save("unique_tracks_per_user.png", fig)
  println("Plot saved to unique_tracks_per_user.png")
end

function plot_unique_artists_per_user(df)
  fig = Figure(size=(800, 600))
  ax = Axis(fig[1, 1],
    title="Unique Artists per User (2015-2026)",
    xlabel="User",
    ylabel="Unique Artists"
  )

  labels = [get(names, u, u) for u in df.username]
  ax.xticks = (1:length(labels), String.(labels))
  barplot!(ax, 1:length(labels), Int.(df.unique_artists))

  save("unique_artists_per_user.png", fig)
  println("Plot saved to unique_artists_per_user.png")
end

function plot_unique_albums_per_user(df)
  fig = Figure(size=(800, 600))
  ax = Axis(fig[1, 1],
    title="Unique Albums per User (2015-2026)",
    xlabel="User",
    ylabel="Unique Albums"
  )

  labels = [get(names, u, u) for u in df.username]
  ax.xticks = (1:length(labels), String.(labels))
  barplot!(ax, 1:length(labels), Int.(df.unique_albums))

  save("unique_albums_per_user.png", fig)
  println("Plot saved to unique_albums_per_user.png")
end

function plot_events_over_time()
  df = get_events_over_time()

  all_months = sort(unique(String.(df.month)))
  month_index = Dict(m => i for (i, m) in enumerate(all_months))

  jan_positions = [month_index[m] for m in all_months if endswith(m, "-01")]
  jan_labels = [m[1:4] for m in all_months if endswith(m, "-01")]

  fig = Figure(size=(1200, 500))
  ax = Axis(fig[1, 1],
    title="Listening Events Over Time",
    xlabel="Year",
    ylabel="Listening Events"
  )
  ax.xticks = (jan_positions, jan_labels)

  colors = Makie.wong_colors()

  for (i, (username, display_name)) in enumerate(names)
    user_df = filter(row -> row.username == username, df)
    sort!(user_df, :month)

    xs = [month_index[m] for m in String.(user_df.month)]
    ys = Int.(user_df.events)

    lines!(ax, xs, ys, label=display_name, color=colors[i])
  end

  axislegend(ax, position=:rt)
  save("events_over_time.png", fig)
  println("Plot saved to events_over_time.png")
end

function plot_listening_times(username)
  display_name = get(names, username, username)
  df = get_hourly_counts(username)

  counts = zeros(Int, 24)
  for row in eachrow(df)
    counts[Int(row.hour)+1] = Int(row.events)
  end

  max_count = maximum(counts)
  norm_counts = counts ./ max_count

  fig = Figure(size=(750, 700))
  ax = Axis(fig[1, 1], title="Listening Times - $display_name", aspect=DataAspect())
  hidedecorations!(ax)
  hidespines!(ax)
  limits!(ax, -1.25, 1.25, -1.25, 1.25)

  cmap = cgrad(:inferno)
  inner_r = 0.18
  max_r = 0.82
  label_r = 0.98
  arc_steps = 40

  for h in 0:23
    angle_start = π / 2 - h * (2π / 24)
    angle_end = π / 2 - (h + 1) * (2π / 24)

    r_outer = inner_r + norm_counts[h+1] * (max_r - inner_r)

    angles = range(angle_start, angle_end, length=arc_steps)
    outer_pts = [Point2f(r_outer * cos(a), r_outer * sin(a)) for a in angles]
    inner_pts = [Point2f(inner_r * cos(a), inner_r * sin(a)) for a in reverse(angles)]

    poly!(ax, vcat(outer_pts, inner_pts),
      color=cmap[norm_counts[h+1]],
      strokecolor=:white, strokewidth=0.8)
  end

  for h in 0:23
    mid_angle = π / 2 - (h + 0.5) * (2π / 24)
    lx = label_r * cos(mid_angle)
    ly = label_r * sin(mid_angle)

    label = if h == 0
      "12am"
    elseif h == 12
      "12pm"
    elseif h < 12
      "$(h)am"
    else
      "$(h - 12)pm"
    end

    text!(ax, lx, ly, text=label, align=(:center, :center), fontsize=11)
  end

  Colorbar(fig[1, 2], colormap=:inferno, limits=(0, max_count),
    label="Events", height=Relative(0.6))

  fname = "listening_times_$(username).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

# Main

function summary_statistics()
  group = first(get_group_summary())

  println("Group Statistics\n")

  println("Total listening events: $(group.total_events)")
  println("Unique tracks: $(group.unique_tracks)")
  println("Unique artists: $(group.unique_artists)")
  println("Unique albums: $(group.unique_albums)")
  println("Unique platforms: $(group.unique_platforms)")
  println("Unique countries: $(group.unique_countries)")

  println("\nIndividual Statistics\n")

  user_summary = get_user_summary()

  for row in eachrow(user_summary)
    name = get(names, row.username, row.username)

    println("$name:")
    println("  Total events: $(row.total_events)")
    println("  Unique tracks: $(row.unique_tracks)")
    println("  Unique artists: $(row.unique_artists)")
    println("  Unique albums: $(row.unique_albums)")
    println("  Unique platforms: $(row.unique_platforms)")
    println("  Unique countries: $(row.unique_countries)\n")
  end

  println("Generating plots...")

  plot_total_events_per_user(user_summary)
  plot_unique_tracks_per_user(user_summary)
  plot_unique_artists_per_user(user_summary)
  plot_unique_albums_per_user(user_summary)
  plot_events_over_time()

  for username in keys(names)
    plot_listening_times(username)
  end
end
