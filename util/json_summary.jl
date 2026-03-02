using JSON

isdict(x) = isa(x, AbstractDict)
isvec(x) = isa(x, AbstractArray)

function summarize(io::IO, key::String, val, indent::Int)
  pad = "  "^indent

  if isdict(val)
    println(io, "$(pad)$(key) ($(length(val)))")
    for (k, v) in val
      summarize(io, string(k), v, indent + 1)
    end

  elseif isvec(val)
    println(io, "$(pad)$(key) ($(length(val)))")
    merged = Dict{String,Any}()
    for item in val
      if isdict(item)
        for (k, v) in item
          merged[string(k)] = v
        end
      end
    end
    for (k, v) in merged
      summarize(io, k, v, indent + 1)
    end

  else
    println(io, "$(pad)$(key)")
  end
end

function process_file(input_path::String, output_path::String)
  data = JSON.parsefile(input_path)
  open(output_path, "w") do io
    if isdict(data)
      for (k, v) in data
        summarize(io, string(k), v, 0)
      end
    elseif isvec(data)
      println(io, "root ($(length(data)))")
      merged = Dict{String,Any}()
      for item in data
        if isdict(item)
          for (k, v) in item
            merged[string(k)] = v
          end
        end
      end
      for (k, v) in merged
        summarize(io, k, v, 1)
      end
    else
      println(io, data)
    end
  end
  println("Summary written to: $output_path")
end

function main()
  args = ARGS

  if length(args) >= 1 && args[1] == "--all"
    if length(args) < 3
      println("Usage: julia json_summary.jl --all <folder> <output_dir>")
      exit(1)
    end
    folder = args[2]
    output_dir = args[3]

    !isdir(folder) && (println("Folder not found: $folder"); exit(1))
    mkpath(output_dir)

    json_files = filter(f -> endswith(f, ".json"), readdir(folder, join=true))
    if isempty(json_files)
      println("No JSON files found in: $folder")
      exit(0)
    end

    for input_path in json_files
      base = splitext(basename(input_path))[1]
      output_path = joinpath(output_dir, "$(base)_summary.txt")
      process_file(input_path, output_path)
    end

  else
    if length(args) < 1
      println("Usage:")
      println("  julia json_summary.jl <input.json> [output.txt]")
      println("  julia json_summary.jl --all <folder> <output_dir>")
      exit(1)
    end

    input_path = args[1]
    !isfile(input_path) && (println("File not found: $input_path"); exit(1))

    base = splitext(basename(input_path))[1]
    output_path = length(args) >= 2 ? args[2] : joinpath(pwd(), "$(base)_summary.txt")

    process_file(input_path, output_path)
  end
end

main()