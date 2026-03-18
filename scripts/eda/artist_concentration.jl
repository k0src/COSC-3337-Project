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

const PERIODS = [
  (nothing, "alltime"),
  (2024, "2024"),
  (2025, "2025"),
]

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

function concentration(counts, k)
  sum(counts[1:min(k, length(counts))]) / sum(counts)
end

# Data

function get_user_plays_per_artist(; year=nothing)
  conn = get_connection()
  year_filter = year === nothing ? "" : "WHERE EXTRACT(YEAR FROM timestamp) = $year"

  query = """
    SELECT
      username,
      artist_name,
      COUNT(*) AS play_count
    FROM listening_history
    $year_filter
    GROUP BY username, artist_name
    ORDER BY username, play_count DESC
  """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

# Plots

function plot_artist_concentration(df, year_label)
  nrow(df) == 0 && return
  title_label = year_label == "alltime" ? "All-Time" : year_label

  user_keys = sort(unique(String.(df.username)))
  n = length(user_keys)
  display_labels = [get(NAMES, uk, uk) for uk in user_keys]
  conc_colors = [:steelblue, :orangered, :seagreen]

  x_pos = Int[]
  y_vals = Float64[]
  dodge_idxs = Int[]

  for (ui, username) in enumerate(user_keys)
    user_df = filter(r -> String(r.username) == username, df)
    nrow(user_df) == 0 && continue
    counts = Int.(user_df.play_count)
    push!(x_pos, ui)
    push!(y_vals, concentration(counts, 1))
    push!(dodge_idxs, 1)
    push!(x_pos, ui)
    push!(y_vals, concentration(counts, 5))
    push!(dodge_idxs, 2)
    push!(x_pos, ui)
    push!(y_vals, concentration(counts, 10))
    push!(dodge_idxs, 3)
  end

  isempty(x_pos) && return

  fig = Figure(size=(1000, 600))
  ax = Axis(fig[1, 1],
    title="Artist Concentration - Per User - $title_label",
    ylabel="Share of Total Plays",
    xticks=(1:n, display_labels),
  )
  barplot!(ax, x_pos, y_vals; dodge=dodge_idxs, color=[conc_colors[d] for d in dodge_idxs])

  elems = [PolyElement(polycolor=conc_colors[i]) for i in 1:3]
  Legend(fig[1, 2], elems, ["Top 1", "Top 5", "Top 10"])

  fname = "artist_concentration_$(year_label).png"
  save(fname, fig)
  println("Plot saved to $fname")
end

# Main

function main()
  for (year, year_label) in PERIODS
    title_label = year_label == "alltime" ? "All-Time" : year_label
    println("\n$(title_label)\n")

    df = get_user_plays_per_artist(year=year)
    nrow(df) == 0 && continue

    period_data = Dict{String,Any}()

    for (username, display_name) in NAMES
      user_df = filter(r -> String(r.username) == username, df)
      nrow(user_df) == 0 && continue
      counts = Int.(user_df.play_count)
      total = sum(counts)

      period_data[display_name] = Dict{String,Any}(
        "top1_share" => concentration(counts, 1),
        "top5_share" => concentration(counts, 5),
        "top10_share" => concentration(counts, 10),
        "total_plays" => total,
        "unique_artists" => nrow(user_df),
        "gini" => gini(counts),
        "entropy" => shannon_entropy(counts),
      )
    end

    plot_artist_concentration(df, year_label)
    save_json("artist_concentration_$(year_label).json", period_data)
  end
end

main()
