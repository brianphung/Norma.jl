module Norma

using Logging

# Enable debugging for a specific module in the environment variable JULIA_DEBUG (all for all modules)
function configure_logger()
    debug_level = get(ENV, "JULIA_DEBUG", "")

    if debug_level != ""
        # Enable debug logging
        global_logger(ConsoleLogger(stderr, Logging.Debug))
        @info "Debugging enabled for: $debug_level"
    else
        # Default to Info level
        global_logger(ConsoleLogger(stderr, Logging.Info))
        @info "Debugging disabled"
    end
end

configure_logger()

include("minitensor.jl")
include("simulation.jl")
include("evolve.jl")

function run(input_file::String)
    sim = create_simulation(input_file)
    print("Created simulation \n")
    evolve(sim)
    return sim
end

function run(params::Dict{Any,Any}, name::String)
    sim = create_simulation(params, name)
    evolve(sim)
    return sim
end

for input_file ∈ ARGS
    run(input_file)
end

end
