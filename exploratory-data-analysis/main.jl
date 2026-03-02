include("utils.jl")
include("database.jl")
include("summary_statistics.jl")
include("univariate_analysis.jl")
include("outliers.jl")
include("distributions.jl")

names = Dict(
  "korenns" => "Koren",
  "alexxxxxrs" => "Alexandra",
  "alanjzamora" => "Alan",
  "dasucc" => "Anthony",
)

const MENU = [
  ("Summary Statistics", summary_statistics),
  ("Univariate Analysis", univariate_analysis),
  ("Outliers Analysis", outliers),
  ("Distributions", distributions),
]

function main()
  while true
    println("\nExploratory Data Analysis")

    for (i, (label, _)) in enumerate(MENU)
      println("$i. $label")
    end

    println("0. Quit")
    print("Select an option: ")

    input = strip(readline())

    if input == "0"
      println("Exiting...")
      break
    end

    choice = tryparse(Int, input)
    if choice === nothing || choice < 1 || choice > length(MENU)
      println("Invalid option. Please try again.")
      continue
    end

    label, fn = MENU[choice]
    println("\n$label\n")
    fn(names)
  end
end

main()