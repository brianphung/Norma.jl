# Norma.jl 1.0: Copyright 2025 National Technology & Engineering Solutions of
# Sandia, LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS,
# the U.S. Government retains certain rights in this software. This software
# is released under the BSD license detailed in the file license.txt in the
# top-level Norma.jl directory.


mutable struct NumpyFile
    String::prefix,
    model_velocity::Vector{Matrix{Float64}}
    model_reference::Vector{Matrix{Float64}}
    model_current::Vector{Matrix{Float64}}
    model_acceleration::Vector{Matrix{Float64}}
    model_internal_force::Vector{Vector{Float64}}
    model_boundary_force::Vector{Vector{Float64}}
    
end

function NumpyFile(String::prefix, int::timesteps)



end