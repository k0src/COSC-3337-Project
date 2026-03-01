using DataFrames
using CairoMakie
using StatsBase

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
      DATE_TRUNC('day', timestamp)::DATE::TEXT AS date,
      COUNT(*) AS events
    FROM listening_history
    GROUP BY username, date
    ORDER BY username, date
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

function plot_events_over_time(df)
  all_dates = sort(unique(String.(df.date)))
  date_index = Dict(d => i for (i, d) in enumerate(all_dates))

  jan_positions = [date_index[d] for d in all_dates if endswith(d, "-01-01")]
  jan_labels = [d[1:4] for d in all_dates if endswith(d, "-01-01")]

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
    sort!(user_df, :date)

    xs = [date_index[d] for d in String.(user_df.date)]
    ys = Int.(user_df.events)

    lines!(ax, xs, ys, label=display_name, color=colors[i])
  end

  axislegend(ax, position=:rt)
  save("events_over_time.png", fig)
  println("Plot saved to events_over_time.png")
end

function plot_listening_times(username, df)
  display_name = get(names, username, username)

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

function run_summary_statistics(names)
  println("Calculating...\n")

  # Fetch data

  group = first(get_group_summary())
  user_summary = get_user_summary()
  events_df = get_events_over_time()
  hourly_dfs = Dict(username => get_hourly_counts(username) for username in keys(names))

  # Print data

  println("Group Statistics\n")

  println("Total listening events: $(group.total_events)")
  println("Unique tracks: $(group.unique_tracks)")
  println("Unique artists: $(group.unique_artists)")
  println("Unique albums: $(group.unique_albums)")
  println("Unique platforms: $(group.unique_platforms)")
  println("Unique countries: $(group.unique_countries)")

  println("\nIndividual Statistics\n")

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

  # Generate plots

  println("Generating plots...")

  plot_total_events_per_user(user_summary)
  plot_unique_tracks_per_user(user_summary)
  plot_unique_artists_per_user(user_summary)
  plot_unique_albums_per_user(user_summary)
  plot_events_over_time(events_df)

  for username in keys(names)
    plot_listening_times(username, hourly_dfs[username])
  end

  # Save JSON

  println("Saving JSON...")

  summary_data = Dict(
    "group" => Dict(
      "total_events" => Int(group.total_events),
      "unique_tracks" => Int(group.unique_tracks),
      "unique_artists" => Int(group.unique_artists),
      "unique_albums" => Int(group.unique_albums),
      "unique_platforms" => Int(group.unique_platforms),
      "unique_countries" => Int(group.unique_countries),
    ),
    "individual" => Dict(
      get(names, String(row.username), String(row.username)) => Dict(
        "total_events" => Int(row.total_events),
        "unique_tracks" => Int(row.unique_tracks),
        "unique_artists" => Int(row.unique_artists),
        "unique_albums" => Int(row.unique_albums),
        "unique_platforms" => Int(row.unique_platforms),
        "unique_countries" => Int(row.unique_countries),
      )
      for row in eachrow(user_summary)
    ),
  )

  events_data = Dict(
    get(names, username, username) => begin
      user_df = filter(r -> r.username == username, events_df)
      sort!(user_df, :date)
      Dict(String(r.date) => Int(r.events) for r in eachrow(user_df))
    end
    for username in keys(names)
  )

  hourly_data = Dict(
    get(names, username, username) => begin
      df = hourly_dfs[username]
      Dict(string(Int(r.hour)) => Int(r.events) for r in eachrow(df))
    end
    for username in keys(names)
  )

  save_json("summary_statistics_alltime.json", summary_data)
  save_json("events_over_time_alltime.json", events_data)
  save_json("hourly_counts_alltime.json", hourly_data)
end

# Main

function summary_statistics(names)
  println("ALL-TIME STATISITCS\n")
  println("PER-YEAR STATISITCS\n")
end
