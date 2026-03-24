include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_radar_2025")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const N_GROUPS = 8

const FAMILY_RULES = [
  ("Hip-Hop / Rap", ["hip hop", "rap", "trap", "drill", "cloud rap",
    "grime", "phonk", "bounce"]),
  ("R&B", ["r&b", "neo soul", "contemporary r"]),
  ("Soul / Funk", ["soul", "funk", "motown", "gospel", "blues"]),
  ("Electronic", ["electronic", "electro", "edm", "synthwave",
    "synth pop", "industrial", "noise"]),
  ("House / Techno", ["house", "techno", "trance", "rave", "uk garage",
    "afrobeats"]),
  ("Drum & Bass / Dubstep", ["drum and bass", "dnb", "dubstep", "jungle",
    "breakbeat", "drumstep", "liquid funk"]),
  ("Ambient / Lo-Fi", ["ambient", "lo-fi", "lofi", "chillhop", "chill",
    "drone", "new age"]),
  ("Pop", ["pop"]),
  ("Alternative / Indie", ["alternative", "indie", "shoegaze", "dream",
    "post-punk", "new wave", "art rock"]),
  ("Rock", ["rock", "grunge", "garage", "surf"]),
  ("Metal", ["metal", "doom", "sludge", "stoner", "thrash",
    "death", "black metal"]),
  ("Punk / Emo", ["punk", "emo", "hardcore", "screamo"]),
  ("Jazz", ["jazz", "bebop", "swing", "bossa nova", "fusion"]),
  ("Classical", ["classical", "orchestral", "opera", "baroque",
    "chamber", "contemporary classical"]),
  ("Country / Folk", ["country", "folk", "bluegrass", "americana",
    "singer-songwriter", "acoustic"]),
  ("Latin", ["latin", "reggaeton", "salsa", "bachata",
    "cumbia", "dembow", "corrido"]),
  ("K-Pop / J-Pop", ["k-pop", "j-pop", "korean", "japanese", "anime",
    "city pop"]),
  ("Reggae", ["reggae", "dancehall", "ska", "dub"]),
  ("Other", String[]),
]

function assign_family(genre::String)
  g = lowercase(genre)
  for (family, keywords) in FAMILY_RULES
    isempty(keywords) && return family
    any(occursin(kw, g) for kw in keywords) && return family
  end
  return "Other"
end

function get_data()
  conn = get_connection()
  query = """
    SELECT
      lh.username,
      ag.genre,
      COUNT(*)::int AS plays
    FROM  listening_history lh
    JOIN  artist_genres      ag ON lh.artist_name = ag.artist_name
    WHERE EXTRACT(YEAR FROM lh.timestamp) = 2025
      AND lh.artist_name IS NOT NULL
    GROUP BY lh.username, ag.genre
    ORDER BY lh.username, ag.genre
  """
  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function aggregate(df)
  family_plays = Dict{Tuple{String,String},Int}()
  for row in eachrow(df)
    u = String(row.username)
    f = assign_family(String(row.genre))
    key = (u, f)
    family_plays[key] = get(family_plays, key, 0) + Int(row.plays)
  end

  combined = Dict{String,Int}()
  for ((_, f), n) in family_plays
    combined[f] = get(combined, f, 0) + n
  end
  ranked = sort(collect(combined), by=kv -> -kv[2])
  top_groups = [kv[1] for kv in ranked[1:min(N_GROUPS, length(ranked))]]

  user_shares = Dict{String,Vector{Float64}}()
  for username in USER_ORDER
    raw = Float64[get(family_plays, (username, g), 0) for g in top_groups]
    tot = sum(raw)
    user_shares[username] = tot > 0 ? raw ./ tot : raw
  end

  return top_groups, user_shares
end

function print_table(top_groups, user_shares)
  hdr = @sprintf "  %-26s" "group"
  for d in DISPLAY_ORDER
    hdr *= @sprintf "  %10s" d
  end
  println(hdr)
  for (i, g) in enumerate(top_groups)
    row_str = @sprintf "  %-26s" g
    for u in USER_ORDER
      row_str *= @sprintf "  %9.1f%%" user_shares[u][i] * 100
    end
    println(row_str)
  end
  println()
end

function radar_coords(values, angles)
  xs = [values[i] * cos(angles[i]) for i in eachindex(values)]
  ys = [values[i] * sin(angles[i]) for i in eachindex(values)]
  return xs, ys
end

function text_align(angle)
  c, s = cos(angle), sin(angle)
  h = abs(c) < 0.25 ? :center : (c > 0 ? :left : :right)
  v = abs(s) < 0.25 ? :center : (s > 0 ? :bottom : :top)
  return h, v
end

function plot_radar(top_groups, user_shares, fname)
  N = length(top_groups)
  angles = [π / 2 - 2π * (i - 1) / N for i in 1:N]
  grid_rs = [0.25, 0.5, 0.75, 1.0]
  colors = Makie.wong_colors()

  fig = Figure(size=(820, 760))
  ax = Axis(fig[1, 1],
    aspect=DataAspect(),
    xgridvisible=false,
    ygridvisible=false,
    xticksvisible=false,
    yticksvisible=false,
    xticklabelsvisible=false,
    yticklabelsvisible=false,
    topspinevisible=false,
    bottomspinevisible=false,
    leftspinevisible=false,
    rightspinevisible=false,
    title="Genre Group Profile - All Users - 2025",
  )

  limits!(ax, -1.55, 1.55, -1.55, 1.55)

  θ_circ = range(0, 2π, length=300)
  for r in grid_rs
    lines!(ax, r .* cos.(θ_circ), r .* sin.(θ_circ),
      color=:grey88, linewidth=0.8)
    text!(ax, 0.0, r,
      text=@sprintf("%d%%", round(Int, r * 100)),
      fontsize=9, color=:grey60,
      align=(:center, :bottom))
  end

  for angle in angles
    lines!(ax, [0.0, cos(angle)], [0.0, sin(angle)],
      color=:grey82, linewidth=0.8)
  end

  label_r = 1.18
  for (i, (g, angle)) in enumerate(zip(top_groups, angles))
    ha, va = text_align(angle)
    text!(ax, label_r * cos(angle), label_r * sin(angle),
      text=g, fontsize=11, font=:bold,
      align=(ha, va))
  end

  for (ui, (username, display_name)) in enumerate(zip(USER_ORDER, DISPLAY_ORDER))
    vals = user_shares[username]
    xs, ys = radar_coords(vals, angles)

    poly!(ax, Point2f.(zip(xs, ys)),
      color=(colors[ui], 0.12),
      strokecolor=(colors[ui], 0.0),
      strokewidth=0)

    xs_c = push!(copy(xs), xs[1])
    ys_c = push!(copy(ys), ys[1])
    lines!(ax, xs_c, ys_c,
      color=colors[ui], linewidth=2.2, label=display_name)

    scatter!(ax, xs, ys,
      color=colors[ui], markersize=7,
      strokecolor=:white, strokewidth=1)
  end

  Legend(fig[1, 2], ax, framevisible=false)

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)

  df = get_data()
  nrow(df) == 0 && (println("No data"); return)

  top_groups, user_shares = aggregate(df)

  println("Top $N_GROUPS genre groups (2025)")
  print_table(top_groups, user_shares)

  fname = joinpath(SCRIPT_DIR, "genre_radar_2025.png")
  plot_radar(top_groups, user_shares, fname)

  save_json(joinpath(SCRIPT_DIR, "genre_radar_2025.json"), Dict{String,Any}(
    "groups" => top_groups,
    "users" => Dict{String,Any}(
      DISPLAY_ORDER[i] => Dict{String,Any}(
        "shares" => user_shares[USER_ORDER[i]],
        "raw_pct" => [user_shares[USER_ORDER[i]][j] * 100 for j in 1:length(top_groups)],
      )
      for i in 1:length(USER_ORDER)
    ),
  ))
end

main()
