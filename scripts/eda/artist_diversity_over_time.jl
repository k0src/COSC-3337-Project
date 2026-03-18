include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie

const NAMES = Dict(
  "dasucc" => "Anthony",
  "alanjzamora" => "Alan",
  "alexxxxxrs" => "Alexandra",
  "korenns" => "Koren",
)

const YEAR_RANGE = 2020:2025

# Stats

function gini(vals)
  n = length(vals)
  n <= 1 && return 0.0
  sorted = sort(Float64.(vals))
  total = sum(sorted)
  total == 0.0 && return 0.0
  return (2.0 * sum((1:n) .* sorted) / (n * total)) - (n + 1.0) / n
end

function shannon_entropy(vals)
  total = sum(Float64.(vals))
  total == 0.0 && return 0.0
  probs = Float64.(vals) ./ total
  return -sum(p * log2(p) for p in probs if p > 0.0)
end

# Data

function get_yearly_plays_per_artist()
  conn = get_connection()

  query = """
    SELECT
      username,
      EXTRACT(YEAR FROM timestamp)::INT AS year,
      artist_name,
      COUNT(*) AS play_count
    FROM listening_history
    WHERE EXTRACT(YEAR FROM timestamp) BETWEEN $(first(YEAR_RANGE)) AND $(last(YEAR_RANGE))
    GROUP BY username, year, artist_name
    ORDER BY username, year, play_count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Plots

function plot_gini_over_time(stats_dict, year_range)
  colors = Makie.wong_colors()
  years = collect(year_range)

  fig = Figure(size=(800, 500))
  ax = Axis(fig[1, 1],
    title="Artist Gini Coefficient by Year",
    xlabel="Year",
    ylabel="Gini",
    xticks=(years, string.(years)),
  )

  for (i, (username, display_name)) in enumerate(NAMES)
    user = stats_dict[username]
    ys = [get(user, yr, (gini=NaN, entropy=NaN)).gini for yr in years]
    valid = .!isnan.(ys)
    any(valid) || continue
    lines!(ax, years[valid], ys[valid], label=display_name, color=colors[i])
    scatter!(ax, years[valid], ys[valid], color=colors[i])
  end

  axislegend(ax, position=:rt)
  fname = "artist_gini_over_time.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

function plot_entropy_over_time(stats_dict, year_range)
  colors = Makie.wong_colors()
  years = collect(year_range)

  fig = Figure(size=(800, 500))
  ax = Axis(fig[1, 1],
    title="Artist Shannon Entropy by Year",
    xlabel="Year",
    ylabel="Entropy (bits)",
    xticks=(years, string.(years)),
  )

  for (i, (username, display_name)) in enumerate(NAMES)
    user = stats_dict[username]
    ys = [get(user, yr, (gini=NaN, entropy=NaN)).entropy for yr in years]
    valid = .!isnan.(ys)
    any(valid) || continue
    lines!(ax, years[valid], ys[valid], label=display_name, color=colors[i])
    scatter!(ax, years[valid], ys[valid], color=colors[i])
  end

  axislegend(ax, position=:rt)
  fname = "artist_entropy_over_time.png"
  save(fname, fig)
  println("Plot saved to $fname")
end

# Main

function main()
  df = get_yearly_plays_per_artist()
  nrow(df) == 0 && return

  stats_dict = Dict{String,Dict{Int,NamedTuple}}()
  for username in keys(NAMES)
    stats_dict[username] = Dict{Int,NamedTuple}()
    for year in YEAR_RANGE
      sub = filter(r -> String(r.username) == username && Int(r.year) == year, df)
      nrow(sub) == 0 && continue
      counts = Int.(sub.play_count)
      stats_dict[username][year] = (
        gini=gini(counts),
        entropy=shannon_entropy(counts),
      )
    end
  end

  plot_gini_over_time(stats_dict, YEAR_RANGE)
  plot_entropy_over_time(stats_dict, YEAR_RANGE)

  json_data = Dict{String,Any}(
    display_name => Dict{String,Any}(
      string(year) => Dict{String,Any}(
        "gini" => stats_dict[username][year].gini,
        "entropy" => stats_dict[username][year].entropy,
      )
      for year in YEAR_RANGE if haskey(stats_dict[username], year)
    )
    for (username, display_name) in NAMES
  )

  save_json("artist_diversity_over_time.json", json_data)
end

main()
