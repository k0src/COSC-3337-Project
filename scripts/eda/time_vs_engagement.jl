include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Statistics

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const DOW_LABELS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

function get_hourly_stats()
  conn = get_connection()

  query = """
    SELECT
      username,
      EXTRACT(HOUR FROM timestamp)::INT                  AS hour,
      COUNT(*)                                           AS n,
      AVG(ms_played)                                     AS mean_ms,
      STDDEV(ms_played)                                  AS std_ms,
      AVG(CASE WHEN skipped THEN 1.0 ELSE 0.0 END)      AS skip_rate,
      AVG(CASE WHEN shuffle THEN 1.0 ELSE 0.0 END)      AS shuffle_rate
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND ms_played IS NOT NULL
      AND skipped   IS NOT NULL
      AND shuffle   IS NOT NULL
    GROUP BY username, hour
    ORDER BY username, hour
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_dow_play_skip()
  conn = get_connection()

  query = """
    SELECT
      username,
      EXTRACT(ISODOW FROM timestamp)::INT                AS dow,
      COUNT(*)                                           AS play_count,
      AVG(CASE WHEN skipped THEN 1.0 ELSE 0.0 END)      AS skip_rate
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND skipped IS NOT NULL
    GROUP BY username, dow
    ORDER BY username, dow
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_dow_ms_raw()
  conn = get_connection()

  query = """
    SELECT
      username,
      EXTRACT(ISODOW FROM timestamp)::INT  AS dow,
      ms_played
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND ms_played IS NOT NULL
    ORDER BY username, dow
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function plot_hour_vs_duration(user_df, username, display_name)
  nrow(user_df) == 0 && return

  hours = Int.(user_df.hour)
  means = Float64.(user_df.mean_ms) ./ 60000.0
  ns = Float64.(user_df.n)
  stds = [ismissing(v) ? 0.0 : Float64(v) for v in user_df.std_ms] ./ 60000.0
  ci = 1.96 .* stds ./ sqrt.(ns)

  fig = Figure(size=(900, 500))
  ax = Axis(fig[1, 1],
    title="Hour of Day vs. Avg Play Duration - $display_name - 2025",
    xlabel="Hour of Day",
    ylabel="Avg Play Duration (minutes)",
    xticks=0:23,
  )
  band!(ax, hours, means .- ci, means .+ ci, color=(Makie.wong_colors()[1], 0.25))
  lines!(ax, hours, means, color=Makie.wong_colors()[1], linewidth=2)
  scatter!(ax, hours, means, color=Makie.wong_colors()[1], markersize=6)

  fname = "hour_vs_duration_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_hour_vs_skip_rate(user_df, username, display_name)
  nrow(user_df) == 0 && return

  hours = Int.(user_df.hour)
  skip_rate = Float64.(user_df.skip_rate)

  fig = Figure(size=(900, 500))
  ax = Axis(fig[1, 1],
    title="Hour of Day vs. Skip Rate - $display_name - 2025",
    xlabel="Hour of Day",
    ylabel="Skip Rate",
    xticks=0:23,
  )
  lines!(ax, hours, skip_rate, color=Makie.wong_colors()[2], linewidth=2)
  scatter!(ax, hours, skip_rate, color=Makie.wong_colors()[2], markersize=6)

  fname = "hour_vs_skip_rate_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_hour_vs_shuffle_rate(user_df, username, display_name)
  nrow(user_df) == 0 && return

  hours = Int.(user_df.hour)
  shuffle_rate = Float64.(user_df.shuffle_rate)

  fig = Figure(size=(900, 500))
  ax = Axis(fig[1, 1],
    title="Hour of Day vs. Shuffle Rate - $display_name - 2025",
    xlabel="Hour of Day",
    ylabel="Shuffle Rate",
    xticks=0:23,
  )
  lines!(ax, hours, shuffle_rate, color=Makie.wong_colors()[3], linewidth=2)
  scatter!(ax, hours, shuffle_rate, color=Makie.wong_colors()[3], markersize=6)

  fname = "hour_vs_shuffle_rate_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_dow_vs_duration(user_raw_df, username, display_name)
  nrow(user_raw_df) == 0 && return

  xs = Int.(user_raw_df.dow)
  ys = Float64.(user_raw_df.ms_played) ./ 60000.0

  fig = Figure(size=(800, 500))
  ax = Axis(fig[1, 1],
    title="Day of Week vs. Play Duration - $display_name - 2025",
    xlabel="Day of Week",
    ylabel="Play Duration (minutes)",
    xticks=(1:7, DOW_LABELS),
  )
  boxplot!(ax, xs, ys, show_outliers=true)

  fname = "dow_vs_duration_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_dow_vs_play_count(user_df, username, display_name)
  nrow(user_df) == 0 && return

  xs = Int.(user_df.dow)
  ys = Float64.(user_df.play_count)

  fig = Figure(size=(800, 500))
  ax = Axis(fig[1, 1],
    title="Day of Week vs. Play Count - $display_name - 2025",
    xlabel="Day of Week",
    ylabel="Play Count",
    xticks=(1:7, DOW_LABELS),
  )
  barplot!(ax, xs, ys, color=Makie.wong_colors()[4])

  fname = "dow_vs_play_count_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function plot_dow_vs_skip_rate(user_df, username, display_name)
  nrow(user_df) == 0 && return

  xs = Int.(user_df.dow)
  ys = Float64.(user_df.skip_rate)

  fig = Figure(size=(800, 500))
  ax = Axis(fig[1, 1],
    title="Day of Week vs. Skip Rate - $display_name - 2025",
    xlabel="Day of Week",
    ylabel="Skip Rate",
    xticks=(1:7, DOW_LABELS),
  )
  barplot!(ax, xs, ys, color=Makie.wong_colors()[5])

  fname = "dow_vs_skip_rate_$(username)_2025.png"
  save(fname, fig)
  println("    plot saved: $fname")
end

function main()
  hour_df = get_hourly_stats()
  dow_agg = get_dow_play_skip()
  dow_raw = get_dow_ms_raw()

  j1 = Dict{String,Any}()
  j2 = Dict{String,Any}()
  j3 = Dict{String,Any}()
  j4 = Dict{String,Any}()
  j5 = Dict{String,Any}()
  j6 = Dict{String,Any}()

  for (username, display_name) in NAMES
    u_hour = filter(r -> String(r.username) == username, hour_df)
    u_dow_agg = filter(r -> String(r.username) == username, dow_agg)
    u_dow_raw = filter(r -> String(r.username) == username, dow_raw)

    println("$display_name:")

    if nrow(u_hour) > 0
      sort!(u_hour, :hour)

      means = Float64.(u_hour.mean_ms) ./ 60000.0
      ns = Float64.(u_hour.n)
      stds = [ismissing(v) ? 0.0 : Float64(v) for v in u_hour.std_ms] ./ 60000.0
      ci = 1.96 .* stds ./ sqrt.(ns)
      skip_rates = Float64.(u_hour.skip_rate)
      shuffle_rates = Float64.(u_hour.shuffle_rate)

      peak_dur_i = argmax(means)
      peak_skip_i = argmax(skip_rates)
      peak_shuffle_i = argmax(shuffle_rates)

      println("  peak play duration:    hour $(Int(u_hour[peak_dur_i, :hour]))  ($(round(means[peak_dur_i], digits=3)) min avg)")
      println("  peak skip rate:        hour $(Int(u_hour[peak_skip_i, :hour]))  ($(round(skip_rates[peak_skip_i]*100, digits=2))%)")
      println("  peak shuffle rate:     hour $(Int(u_hour[peak_shuffle_i, :hour]))  ($(round(shuffle_rates[peak_shuffle_i]*100, digits=2))%)")

      plot_hour_vs_duration(u_hour, username, display_name)
      plot_hour_vs_skip_rate(u_hour, username, display_name)
      plot_hour_vs_shuffle_rate(u_hour, username, display_name)

      j1[display_name] = Dict{String,Any}(
        "n_hours" => nrow(u_hour),
        "peak_hour" => Int(u_hour[peak_dur_i, :hour]),
        "points" => [
          Dict("hour" => Int(u_hour[i, :hour]),
            "n" => Int(u_hour[i, :n]),
            "mean_minutes" => means[i],
            "ci_lo" => means[i] - ci[i],
            "ci_hi" => means[i] + ci[i])
          for i in 1:nrow(u_hour)
        ],
      )
      j2[display_name] = Dict{String,Any}(
        "n_hours" => nrow(u_hour),
        "peak_hour" => Int(u_hour[peak_skip_i, :hour]),
        "points" => [
          Dict("hour" => Int(row.hour), "n" => Int(row.n), "skip_rate" => Float64(row.skip_rate))
          for row in eachrow(u_hour)
        ],
      )
      j3[display_name] = Dict{String,Any}(
        "n_hours" => nrow(u_hour),
        "peak_hour" => Int(u_hour[peak_shuffle_i, :hour]),
        "points" => [
          Dict("hour" => Int(row.hour), "n" => Int(row.n), "shuffle_rate" => Float64(row.shuffle_rate))
          for row in eachrow(u_hour)
        ],
      )
    end

    if nrow(u_dow_raw) > 0
      plot_dow_vs_duration(u_dow_raw, username, display_name)

      j4[display_name] = [
        Dict("dow" => DOW_LABELS[Int(row.dow)], "dow_index" => Int(row.dow), "minutes" => Float64(row.ms_played) / 60000.0)
        for row in eachrow(u_dow_raw)
      ]
    end

    if nrow(u_dow_agg) > 0
      peak_play_dow = DOW_LABELS[Int(u_dow_agg[argmax(Float64.(u_dow_agg.play_count)), :dow])]
      peak_skip_dow = DOW_LABELS[Int(u_dow_agg[argmax(Float64.(u_dow_agg.skip_rate)), :dow])]

      println("  peak play count day:   $peak_play_dow")
      println("  peak skip rate day:    $peak_skip_dow")

      plot_dow_vs_play_count(u_dow_agg, username, display_name)
      plot_dow_vs_skip_rate(u_dow_agg, username, display_name)

      j5[display_name] = Dict{String,Any}(
        "peak_day" => peak_play_dow,
        "points" => [
          Dict("dow" => DOW_LABELS[Int(row.dow)], "dow_index" => Int(row.dow), "play_count" => Int(row.play_count))
          for row in eachrow(u_dow_agg)
        ],
      )
      j6[display_name] = Dict{String,Any}(
        "peak_day" => peak_skip_dow,
        "points" => [
          Dict("dow" => DOW_LABELS[Int(row.dow)], "dow_index" => Int(row.dow), "skip_rate" => Float64(row.skip_rate))
          for row in eachrow(u_dow_agg)
        ],
      )
    end

    println()
  end

  save_json("hour_vs_duration_2025.json", j1)
  save_json("hour_vs_skip_rate_2025.json", j2)
  save_json("hour_vs_shuffle_rate_2025.json", j3)
  save_json("dow_vs_duration_2025.json", j4)
  save_json("dow_vs_play_count_2025.json", j5)
  save_json("dow_vs_skip_rate_2025.json", j6)
end

main()
