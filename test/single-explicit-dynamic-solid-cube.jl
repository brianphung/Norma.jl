cp("../examples/single/explicit-dynamic-solid/cube/cube.yaml", "cube.yaml", force=true)
cp("../examples/single/explicit-dynamic-solid/cube/cube.g", "cube.g", force=true)
simulation = Norma.run("cube.yaml")
integrator = simulation.integrator
model = simulation.model
rm("cube.yaml")
rm("cube.g")
rm("cube.e")
avg_disp = average_components(integrator.displacement)
avg_stress = average_components(model.stress)
@testset "single-explicit-dynamic-solid-cube" begin
    @test avg_disp[1] ≈ 0.0 atol = 1.0e-06
    @test avg_disp[2] ≈ 0.0 atol = 1.0e-06
    @test avg_disp[3] ≈ 1.0 rtol = 1.0e-06
    @test avg_stress[1] ≈ 0.0 atol = 1.0e-06
    @test avg_stress[2] ≈ 0.0 atol = 1.0e-06 
    @test avg_stress[3] ≈ 0.0 atol = 1.0e-06
    @test avg_stress[4] ≈ 0.0 atol = 1.0e-06 
    @test avg_stress[5] ≈ 0.0 atol = 1.0e-06 
    @test avg_stress[6] ≈ 0.0 atol = 1.0e-06 
end
