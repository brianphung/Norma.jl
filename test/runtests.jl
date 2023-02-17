using Statistics
using Test

include("../src/norma.jl")
include("helpers.jl")

@testset "Norma" begin
    include("single-static-solid-cube.jl")
    include("single-implicit-dynamic-solid-cube.jl")
    include("single-implicit-dynamic-solid-sho.jl")
    include("single-implicit-dynamic-solid-clamped.jl")
    include("single-explicit-dynamic-solid-cube.jl")
    include("single-explicit-dynamic-solid-sho.jl")
    include("single-explicit-dynamic-solid-clamped.jl")
end