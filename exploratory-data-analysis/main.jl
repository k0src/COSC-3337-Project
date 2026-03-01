include("database.jl")
include("summary_statistics.jl")

const MENU = [
  ("Summary Statistics", summary_statistics),
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
      println("Goodbye.")
      break
    end

    choice = tryparse(Int, input)
    if choice === nothing || choice < 1 || choice > length(MENU)
      println("Invalid option. Please try again.")
      continue
    end

    label, fn = MENU[choice]
    println("$label")
    fn()
  end
end

main()
