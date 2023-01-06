cp("../examples/single/dynamic-solid/cube/cube.yaml", "cube.yaml", force=true)
cp("../examples/single/dynamic-solid/cube/cube.g", "cube.g", force=true)
model, solver = Norma.run("cube.yaml")
rm("cube.yaml")
rm("cube.g")
rm("cube.e")
avg_disp = average_components(solver.solution)
avg_stress = average_components(model.stress)
@testset "single-dynamic-solid-cube" begin
    @test avg_disp[1] ≈ 0.0 atol = 1.0e-06
    @test avg_disp[2] ≈ 0.0 atol = 1.0e-06
    @test avg_disp[3] ≈  1.0 rtol = 1.0e-06
    @test avg_stress[1] ≈ 0.0 atol = 1.0e-06
    @test avg_stress[2] ≈ 0.0 atol = 1.0e-06 
    @test avg_stress[3] ≈ 0.0 atol = 1.0e-06
    @test avg_stress[4] ≈ 0.0 atol = 1.0e-06 
    @test avg_stress[5] ≈ 0.0 atol = 1.0e-06 
    @test avg_stress[6] ≈ 0.0 atol = 1.0e-06 
end
