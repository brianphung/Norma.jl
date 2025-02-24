# Norma.jl 1.0: Copyright 2025 National Technology & Engineering Solutions of
# Sandia, LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS,
# the U.S. Government retains certain rights in this software. This software
# is released under the BSD license detailed in the file license.txt in the
# top-level Norma.jl directory.
@testset "adaptive-time-stepping" begin
    cp("../examples/adaptive-time-stepping/single/cube.yaml", "cube.yaml", force = true)
    cp("../examples/adaptive-time-stepping/single/cube.g", "cube.g", force = true)
    simulation = Norma.run("cube.yaml")
    integrator = simulation.integrator
    model = simulation.model
    rm("cube.yaml")
    rm("cube.g")
    rm("cube.e")
    avg_disp = average_components(integrator.displacement)
    avg_stress = average_components(model.stress)
    @test avg_disp[1] ≈ 0.0625 rtol = 1.0e-06
    @test avg_disp[2] ≈ 0.0625 rtol = 1.0e-06
    @test avg_disp[3] ≈ -0.250 rtol = 1.0e-06
    @test avg_stress[1] ≈ 0.0 atol = 1.0e-06
    @test avg_stress[2] ≈ 0.0 atol = 1.0e-06
    @test avg_stress[3] ≈ -5.0e+08 rtol = 1.0e-06
    @test avg_stress[4] ≈ 0.0 atol = 1.0e-06
    @test avg_stress[5] ≈ 0.0 atol = 1.0e-06
    @test avg_stress[6] ≈ 0.0 atol = 1.0e-06
end
