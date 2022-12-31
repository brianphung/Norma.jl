abstract type TimeIntegrator end

mutable struct QuasiStatic <: TimeIntegrator
    initial_time::Float64
    final_time::Float64
    time_step::Float64
    displacement::Vector{Float64}
end

mutable struct Newmark <: TimeIntegrator
    initial_time::Float64
    final_time::Float64
    time_step::Float64
    β::Float64
    γ::Float64
    displacement::Vector{Float64}
    velocity::Vector{Float64}
    acceleration::Vector{Float64}
    velo_pre::Vector{Float64}
    acce_pre::Vector{Float64}
end

function QuasiStatic(params::Dict{Any, Any})
    time_integrator_params = params["time integrator"]
    initial_time = time_integrator_params["initial time"]
    final_time = time_integrator_params["final time"]
    time_step = time_integrator_params["time step"]
    input_mesh = params["input_mesh"]
    x, _, _ = input_mesh.get_coords()
    num_nodes = length(x)
    num_dof = 3 * num_nodes
    displacement = zeros(num_dof)
    QuasiStatic(initial_time, final_time, time_step, displacement)
end

function Newmark(params::Dict{Any, Any})
    time_integrator_params = params["time integrator"]
    initial_time = time_integrator_params["initial time"]
    final_time = time_integrator_params["final time"]
    time_step = time_integrator_params["time step"]
    β = time_integrator_params["β"]
    γ = time_integrator_params["γ"]
    input_mesh = params["input_mesh"]
    x, _, _ = input_mesh.get_coords()
    num_nodes = length(x)
    num_dof = 3 * num_nodes
    displacement = zeros(num_dof)
    velocity = zeros(num_dof)
    acceleration = zeros(num_dof)
    velo_pre = zeros(num_dof)
    acce_pre = zeros(num_dof)
    Newmark(initial_time, final_time, time_step, β, γ, displacement, velocity, acceleration, velo_pre, acce_pre)
end

function create_time_integrator(params::Dict{Any, Any})
    time_integrator_params = params["time integrator"]
    time_integrator_name = time_integrator_params["type"]
    if time_integrator_name == "quasi static"
        return QuasiStatic(params)
    elseif time_integrator_name == "Newmark"
        return Newmark(params)
    else
        error("Unknown type of solver : ", solver_name)
    end
end

function predict(integrator::QuasiStatic)
end

function correct(integrator::QuasiStatic)
end

function predict(integrator::Newmark)
end