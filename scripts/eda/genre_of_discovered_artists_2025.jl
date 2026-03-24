include(joinpath(@__DIR__, "..", "database.jl"))
include(joinpath(@__DIR__, "..", "utils.jl"))

using DataFrames
using CairoMakie
using JSON3
using Printf

const DATA_DIR = "C:\\Users\\clips\\!Code\\COSC-3337\\data"
const DISCOVERIES_JSON = joinpath(DATA_DIR, "discoveries", "discoveries_2025.json")
const SCRIPT_DIR = joinpath(DATA_DIR, "genre_of_discovered_artists_2025")
const PLOTS_DIR = joinpath(SCRIPT_DIR, "plots")

const USER_ORDER = ["alanjzamora", "alexxxxxrs", "dasucc", "korenns"]
const DISPLAY_ORDER = ["Alan", "Alexandra", "Anthony", "Koren"]

const TOP_N = 20

function load_discoveries()
  raw = JSON3.read(read(DISCOVERIES_JSON, String))
  result = Dict{String,Vector{NamedTuple{(:artist_name, :plays),Tuple{String,Int}}}}()
  for (display_name, data) in pairs(raw)
    artists = [
      (artist_name=String(a[:artist_name]), plays=Int(a[:plays]))
      for a in data[:discovered_artists]
    ]
    result[String(display_name)] = artists
  end
  return result
end

function get_artist_genres(artist_names::Vector{String})
  isempty(artist_names) && return DataFrame()
  conn = get_connection()

  quoted = join(["'" * replace(a, "'" => "''") * "'" for a in artist_names], ", ")
  query = """
   SELECT artist_name, genre
   FROM   artist_genres
   WHERE  artist_name IN ($quoted)
   ORDER  BY artist_name, genre
 """

  df = DataFrame(execute(conn, query))
  close(conn)
  return df
end

function genre_counts(artists, genre_df)
  isempty(artists) && return DataFrame()

  plays_map = Dict(a.artist_name => a.plays for a in artists)

  genre_artists = Dict{String,Int}()
  genre_plays = Dict{String,Int}()

  for row in eachrow(genre_df)
    a = String(row.artist_name)
    g = String(row.genre)
    haskey(plays_map, a) || continue
    genre_artists[g] = get(genre_artists, g, 0) + 1
    genre_plays[g] = get(genre_plays, g, 0) + plays_map[a]
  end

  genres = sort(collect(keys(genre_artists)), by=g -> -genre_artists[g])
  return DataFrame(
    genre=genres,
    n_artists=[genre_artists[g] for g in genres],
    total_plays=[genre_plays[g] for g in genres],
  )
end

function print_table(display_name, df)
  n_shown = min(TOP_N, nrow(df))
  println("$display_name  ($(nrow(df)) genres from discovered artists, top $n_shown shown)")
  @printf "  %-32s  %10s  %12s\n" "genre" "n_artists" "total_plays"
  for row in eachrow(df[1:n_shown, :])
    @printf "  %-32s  %10d  %12d\n" String(row.genre) Int(row.n_artists) Int(row.total_plays)
  end
  println()
end

function plot_bar(df, display_name, fname)
  nrow(df) == 0 && return

  plot_df = df[1:min(TOP_N, nrow(df)), :]
  sorted = sort(plot_df, :n_artists)
  genres = String.(sorted.genre)
  counts = Int.(sorted.n_artists)
  n_g = length(genres)

  fig_h = max(420, n_g * 34 + 180)
  fig = Figure(size=(820, fig_h))

  ax = Axis(fig[1, 1],
    title="Genres Introduced by Discovered Artists - $display_name - 2025",
    xlabel="Number of Discovered Artists",
    ylabel="Genre",
    yticks=(1:n_g, genres),
  )

  barplot!(ax, 1:n_g, Float64.(counts),
    direction=:x,
    color=(Makie.wong_colors()[5], 0.85),
    strokecolor=:white,
    strokewidth=0.5,
  )

  save(fname, fig)
  println("  plot saved: $fname")
end

function main()
  mkpath(SCRIPT_DIR)
  mkpath(PLOTS_DIR)

  discoveries = load_discoveries()

  all_artists = unique([a.artist_name
                        for artists in values(discoveries)
                        for a in artists])

  println("Fetching genres for $(length(all_artists)) discovered artists...")
  genre_df = get_artist_genres(all_artists)

  json_out = Dict{String,Any}()

  for (username, display_name) in zip(USER_ORDER, DISPLAY_ORDER)
    artists = get(discoveries, display_name, [])
    isempty(artists) && continue

    user_artist_names = Set(a.artist_name for a in artists)
    user_genre_df = filter(r -> String(r.artist_name) in user_artist_names, genre_df)

    counts_df = genre_counts(artists, user_genre_df)
    isempty(counts_df) && continue

    print_table(display_name, counts_df)

    fname = joinpath(PLOTS_DIR, "genre_of_discovered_$(username).png")
    plot_bar(counts_df, display_name, fname)

    json_out[display_name] = Dict{String,Any}(
      "n_discovered_artists" => length(artists),
      "genres" => [
        Dict{String,Any}(
          "genre" => String(row.genre),
          "n_artists" => Int(row.n_artists),
          "total_plays" => Int(row.total_plays),
        )
        for row in eachrow(counts_df)
      ],
    )
  end

  save_json(joinpath(SCRIPT_DIR, "genre_of_discovered_artists_2025.json"), json_out)
end

main()
