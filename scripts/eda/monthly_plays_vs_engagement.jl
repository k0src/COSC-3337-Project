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

function shannon_entropy(vals)
  total = sum(Float64.(vals))
  total == 0.0 && return 0.0
  probs = Float64.(vals) ./ total
  return -sum(p * log2(p) for p in probs if p > 0.0)
end

function safe_cor(x, y)
  length(x) < 3 && return NaN
  return cor(x, y)
end

function get_monthly_artist_plays()
  conn = get_connection()

  query = """
    SELECT
      username,
      EXTRACT(MONTH FROM timestamp)::INT AS month,
      artist_name,
      COUNT(*) AS play_count
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND artist_name IS NOT NULL
    GROUP BY username, month, artist_name
    ORDER BY username, month
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_monthly_skip_rate()
  conn = get_connection()

  query = """
    SELECT
      username,
      EXTRACT(MONTH FROM timestamp)::INT AS month,
      COUNT(*) AS total_plays,
      AVG(CASE WHEN skipped THEN 1.0 ELSE 0.0 END) AS skip_rate
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) = 2025
      AND skipped IS NOT NULL
    GROUP BY username, month
    ORDER BY username, month
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function get_pre2025_artists()
  conn = get_connection()

  query = """
    SELECT DISTINCT username, artist_name
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) < 2025
      AND artist_name IS NOT NULL
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function build_monthly_stats(artist_df, skip_df, pre2025_df, username)
  u_artist = filter(r -> String(r.username) == username, artist_df)
  u_skip = filter(r -> String(r.username) == username, skip_df)
  u_pre = filter(r -> String(r.username) == username, pre2025_df)

  nrow(u_artist) == 0 && return []

  known_pre2025 = Set(String.(u_pre.artist_name))
  seen_this_year = Set{String}()

  result = []

  for m in sort(unique(Int.(u_artist.month)))
    month_df = filter(r -> Int(r.month) == m, u_artist)
    artist_counts = Dict(String(r.artist_name) => Int(r.play_count) for r in eachrow(month_df))
    total_plays = sum(values(artist_counts))

    entropy = shannon_entropy(collect(values(artist_counts)))

    new_artist_plays = 0
    for (a, v) in artist_counts
      if a ∉ known_pre2025 && a ∉ seen_this_year
        new_artist_plays += v
      end
    end
    new_artist_rate = total_plays > 0 ? new_artist_plays / total_plays : 0.0

    skip_row = filter(r -> Int(r.month) == m, u_skip)
    skip_rate = nrow(skip_row) > 0 ? Float64(skip_row[1, :skip_rate]) : NaN

    push!(result, (
      month=m,
      play_count=total_plays,
      skip_rate=skip_rate,
      new_artist_rate=new_artist_rate,
      entropy=entropy,
    ))

    for a in keys(artist_counts)
      push!(seen_this_year, a)
    end
  end

  return result
end

function scatter_plot(xs, ys, title, xlabel, ylabel, color, fname; log_x=false)
  fig = Figure(size=(650, 500))
  ax = if log_x
    Axis(fig[1, 1], title=title, xlabel=xlabel, ylabel=ylabel, xscale=log10)
  else
    Axis(fig[1, 1], title=title, xlabel=xlabel, ylabel=ylabel)
  end
  scatter!(ax, xs, ys, markersize=10, color=(color, 0.8))
  save(fname, fig)
  println("    plot saved: $fname")
end

function main()
  artist_df = get_monthly_artist_plays()
  skip_df = get_monthly_skip_rate()
  pre_df = get_pre2025_artists()

  j1 = Dict{String,Any}()
  j2 = Dict{String,Any}()
  j3 = Dict{String,Any}()

  for (username, display_name) in NAMES
    stats = build_monthly_stats(artist_df, skip_df, pre_df, username)
    isempty(stats) && continue

    valid_skip = filter(s -> !isnan(s.skip_rate), stats)

    xs_all = Float64.([s.play_count for s in stats])
    xs_skip = Float64.([s.play_count for s in valid_skip])
    ys_skip = Float64.([s.skip_rate for s in valid_skip])
    ys_nar = Float64.([s.new_artist_rate for s in stats])
    ys_ent = Float64.([s.entropy for s in stats])

    r1 = safe_cor(xs_skip, ys_skip)
    r2 = safe_cor(xs_all, ys_nar)
    r3 = safe_cor(xs_all, ys_ent)

    println("$display_name:")
    println("  monthly plays vs skip rate       - n=$(length(valid_skip))  r=$(round(r1, digits=4))")
    println("  monthly plays vs new artist rate - n=$(length(stats))  r=$(round(r2, digits=4))")
    println("  monthly plays vs entropy         - n=$(length(stats))  r=$(round(r3, digits=4))")
    println()

    c = Makie.wong_colors()

    scatter_plot(xs_skip, ys_skip,
      "Monthly Play Count vs. Skip Rate - $display_name - 2025",
      "Play Count (per month)", "Skip Rate", c[1],
      "monthly_plays_vs_skip_rate_$(username)_2025.png")
    scatter_plot(xs_skip, ys_skip,
      "Monthly Play Count vs. Skip Rate (Log Scale) - $display_name - 2025",
      "Play Count (per month, log scale)", "Skip Rate", c[1],
      "monthly_plays_vs_skip_rate_log_$(username)_2025.png"; log_x=true)

    scatter_plot(xs_all, ys_nar,
      "Monthly Play Count vs. New Artist Rate - $display_name - 2025",
      "Play Count (per month)", "New Artist Rate", c[2],
      "monthly_plays_vs_new_artist_rate_$(username)_2025.png")
    scatter_plot(xs_all, ys_nar,
      "Monthly Play Count vs. New Artist Rate (Log Scale) - $display_name - 2025",
      "Play Count (per month, log scale)", "New Artist Rate", c[2],
      "monthly_plays_vs_new_artist_rate_log_$(username)_2025.png"; log_x=true)

    scatter_plot(xs_all, ys_ent,
      "Monthly Play Count vs. Listening Diversity - $display_name - 2025",
      "Play Count (per month)", "Shannon Entropy (bits)", c[3],
      "monthly_plays_vs_entropy_$(username)_2025.png")
    scatter_plot(xs_all, ys_ent,
      "Monthly Play Count vs. Listening Diversity (Log Scale) - $display_name - 2025",
      "Play Count (per month, log scale)", "Shannon Entropy (bits)", c[3],
      "monthly_plays_vs_entropy_log_$(username)_2025.png"; log_x=true)

    j1[display_name] = Dict{String,Any}(
      "n_months" => length(valid_skip),
      "correlation" => r1,
      "points" => [
        Dict("month" => s.month, "play_count" => s.play_count, "skip_rate" => s.skip_rate)
        for s in valid_skip
      ],
    )
    j2[display_name] = Dict{String,Any}(
      "n_months" => length(stats),
      "correlation" => r2,
      "points" => [
        Dict("month" => s.month, "play_count" => s.play_count, "new_artist_rate" => s.new_artist_rate)
        for s in stats
      ],
    )
    j3[display_name] = Dict{String,Any}(
      "n_months" => length(stats),
      "correlation" => r3,
      "points" => [
        Dict("month" => s.month, "play_count" => s.play_count, "entropy" => s.entropy)
        for s in stats
      ],
    )
  end

  save_json("monthly_plays_vs_skip_rate_2025.json", j1)
  save_json("monthly_plays_vs_new_artist_rate_2025.json", j2)
  save_json("monthly_plays_vs_entropy_2025.json", j3)
end

main()
