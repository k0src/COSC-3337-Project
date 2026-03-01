using JSON3

function save_json(path, data)
  open(path, "w") do io
    JSON3.pretty(io, data)
  end
  println("Data saved to $path")
end
