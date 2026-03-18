using LibPQ
using DotEnv

const ENV_PATH = joinpath(@__DIR__, "..", ".env")

function get_connection()
  DotEnv.load!(ENV_PATH)

  url = get(ENV, "DATABASE_URL", "")

  if isempty(url)
    error("DATABASE_URL must be set in .env")
  end

  return LibPQ.Connection(url)
end
