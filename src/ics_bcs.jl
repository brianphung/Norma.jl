@variables t, x, y, z
D = Differential(t)

function SMDirichletBC(input_mesh::ExodusDatabase, bc_params::Dict{Any,Any})
    node_set_name = bc_params["node set"]
    expression = bc_params["function"]
    offset = component_offset_from_string(bc_params["component"])
    node_set_id = node_set_id_from_name(node_set_name, input_mesh)
    node_set_node_indices = Exodus.read_node_set_nodes(input_mesh, node_set_id)
    # expression is an arbitrary function of t, x, y, z in the input file
    disp_num = eval(Meta.parse(expression))
    velo_num = expand_derivatives(D(disp_num))
    acce_num = expand_derivatives(D(velo_num))
    SMDirichletBC(
        node_set_name,
        offset,
        node_set_id,
        node_set_node_indices,
        disp_num,
        velo_num,
        acce_num,
    )
end

function SMNeumannBC(input_mesh::ExodusDatabase, bc_params::Dict{Any,Any})
    side_set_name = bc_params["side set"]
    expression = bc_params["function"]
    offset = component_offset_from_string(bc_params["component"])
    side_set_id = side_set_id_from_name(side_set_name, input_mesh)
    num_nodes_per_side, side_set_node_indices =
        Exodus.read_side_set_node_list(input_mesh, side_set_id)
    # expression is an arbitrary function of t, x, y, z in the input file
    traction_num = eval(Meta.parse(expression))
    SMNeumannBC(
        side_set_name,
        offset,
        side_set_id,
        num_nodes_per_side,
        side_set_node_indices,
        traction_num,
    )
end

function SMContactSchwarzBC(
    coupled_subsim::SingleDomainSimulation,
    input_mesh::ExodusDatabase,
    bc_params::Dict{Any,Any},
)
    side_set_name = bc_params["side set"]
    side_set_id = side_set_id_from_name(side_set_name, input_mesh)
    global_to_local_map, num_nodes_per_side, side_set_node_indices =
        get_side_set_global_to_local_map(input_mesh, side_set_id)
    coupled_block_name = bc_params["source block"]
    coupled_bc_index = 0
    coupled_mesh = coupled_subsim.params["input_mesh"]
    coupled_block_id = block_id_from_name(coupled_block_name, coupled_mesh)
    coupled_side_set_name = bc_params["source side set"]
    coupled_side_set_id = side_set_id_from_name(coupled_side_set_name, coupled_mesh)
    coupled_global_to_local_map =
        get_side_set_global_to_local_map(coupled_mesh, coupled_side_set_id)[1]
    is_dirichlet = true
    transfer_operator =
        zeros(length(global_to_local_map), length(coupled_global_to_local_map))
    SMContactSchwarzBC(
        side_set_name,
        side_set_id,
        num_nodes_per_side,
        side_set_node_indices,
        coupled_subsim,
        coupled_bc_index,
        coupled_mesh,
        coupled_block_id,
        coupled_side_set_id,
        is_dirichlet,
        transfer_operator,
    )
end

function SMSchwarzDBC(
    subsim::SingleDomainSimulation,
    coupled_subsim::SingleDomainSimulation,
    input_mesh::ExodusDatabase,
    bc_params::Dict{Any,Any},
)
    node_set_name = bc_params["node set"]
    node_set_id = node_set_id_from_name(node_set_name, input_mesh)
    node_set_node_indices = Exodus.read_node_set_nodes(input_mesh, node_set_id)
    coupled_block_name = bc_params["source block"]
    coupled_mesh = coupled_subsim.params["input_mesh"]
    coupled_block_id = block_id_from_name(coupled_block_name, coupled_mesh)
    element_type = Exodus.read_block_parameters(coupled_mesh, coupled_block_id)[1]
    coupled_nodes_indices = Vector{Vector{Int64}}(undef, 0)
    interpolation_function_values = Vector{Vector{Float64}}(undef, 0)
    tol = 1.0e-06
    if haskey(bc_params, "search tolerance") == true
        tol = bc_params["search tolerance"]
    end
    for node_index ∈ node_set_node_indices
        point = subsim.model.reference[:, node_index]
        node_indices, ξ, found =
            find_in_mesh(point, coupled_subsim.model, coupled_mesh, coupled_block_id, tol)
        if found == false
            error("Could not find subdomain ", subsim.name, " point ", point, " in subdomain ", coupled_subsim.name)
        end
        N = interpolate(element_type, ξ)[1]
        push!(coupled_nodes_indices, node_indices)
        push!(interpolation_function_values, N)
    end
    SMSchwarzDBC(
        node_set_name,
        node_set_id,
        node_set_node_indices,
        coupled_subsim,
        coupled_mesh,
        coupled_block_id,
        coupled_nodes_indices,
        interpolation_function_values,
    )
end

function apply_bc(model::SolidMechanics, bc::SMDirichletBC)
    for node_index ∈ bc.node_set_node_indices
        values = Dict(
            t => model.time,
            x => model.reference[1, node_index],
            y => model.reference[2, node_index],
            z => model.reference[3, node_index],
        )
        disp_sym = substitute(bc.disp_num, values)
        velo_sym = substitute(bc.velo_num, values)
        acce_sym = substitute(bc.acce_num, values)
        disp_val = extract_value(disp_sym)
        velo_val = extract_value(velo_sym)
        acce_val = extract_value(acce_sym)
        dof_index = 3 * (node_index - 1) + bc.offset
        model.current[bc.offset, node_index] =
            model.reference[bc.offset, node_index] + disp_val
        model.velocity[bc.offset, node_index] = velo_val
        model.acceleration[bc.offset, node_index] = acce_val
        model.free_dofs[dof_index] = false
    end
end

function apply_bc(model::SolidMechanics, bc::SMNeumannBC)
    ss_node_index = 1
    for side ∈ bc.num_nodes_per_side
        side_nodes = bc.side_set_node_indices[ss_node_index:ss_node_index+side-1]
        side_coordinates = model.reference[:, side_nodes]
        nodal_force_component =
            get_side_set_nodal_forces(side_coordinates, bc.traction_num, model.time)
        ss_node_index += side
        side_node_index = 1
        for node_index ∈ side_nodes
            bc_val = nodal_force_component[side_node_index]
            side_node_index += 1
            dof_index = 3 * (node_index - 1) + bc.offset
            model.boundary_force[dof_index] += bc_val
        end
    end
end

function find_in_mesh(
    point::Vector{Float64},
    model::SolidMechanics,
    mesh::ExodusDatabase,
    blk_id::Int,
    tol::Float64
)
    element_type = Exodus.read_block_parameters(mesh, Int32(blk_id))[1]
    elem_blk_conn = get_block_connectivity(mesh, blk_id)
    num_blk_elems, num_elem_nodes = size(elem_blk_conn)
    node_indices = Vector{Int64}()
    found = false
    ξ = zeros(length(point))
    for blk_elem_index ∈ 1:num_blk_elems
        conn_indices = (blk_elem_index-1)*num_elem_nodes+1:blk_elem_index*num_elem_nodes
        node_indices = elem_blk_conn[conn_indices]
        elem_ref_pos = model.reference[:, node_indices]
        ξ, found = is_inside(element_type, elem_ref_pos, point, tol)
        if found == true
            break
        end
    end
    return node_indices, ξ, found
end

function apply_bc_detail(model::SolidMechanics, bc::SMContactSchwarzBC)
    if bc.is_dirichlet == true
        apply_sm_schwarz_contact_dirichlet(model, bc)
    else
        apply_sm_schwarz_contact_neumann(model, bc)
    end
end

function apply_bc_detail(model::SolidMechanics, bc::SMSchwarzDBC)
    for i ∈ 1:length(bc.node_set_node_indices)
        node_index = bc.node_set_node_indices[i]
        coupled_node_indices = bc.coupled_nodes_indices[i]
        N = bc.interpolation_function_values[i]
        elem_posn = bc.coupled_subsim.model.current[:, coupled_node_indices]
        elem_velo = bc.coupled_subsim.model.velocity[:, coupled_node_indices]
        elem_acce = bc.coupled_subsim.model.acceleration[:, coupled_node_indices]
        point_posn = elem_posn * N
        point_velo = elem_velo * N
        point_acce = elem_acce * N
        model.current[:, node_index] = point_posn
        model.velocity[:, node_index] = point_velo
        model.acceleration[:, node_index] = point_acce
        dof_index = [3 * node_index - 2, 3 * node_index - 1, 3 * node_index]
        model.free_dofs[dof_index] .= false
    end
end

function apply_bc(model::SolidMechanics, bc::SchwarzBoundaryCondition)
    global_sim = bc.coupled_subsim.params["global_simulation"]
    schwarz_controller = global_sim.schwarz_controller
    if schwarz_controller.schwarz_contact == true &&
       schwarz_controller.active_contact == false
        return
    end
    empty_history = length(global_sim.schwarz_controller.time_hist) == 0
    same_step = schwarz_controller.same_step == true
    if empty_history == true
        apply_bc_detail(model, bc)
        return
    end
    # Save solution of coupled simulation
    saved_disp = bc.coupled_subsim.integrator.displacement
    saved_velo = bc.coupled_subsim.integrator.velocity
    saved_acce = bc.coupled_subsim.integrator.acceleration
    saved_∂Ω_f = bc.coupled_subsim.model.internal_force
    time = model.time
    coupled_name = bc.coupled_subsim.name
    coupled_index = global_sim.subsim_name_index_map[coupled_name]
    time_hist = global_sim.schwarz_controller.time_hist[coupled_index]
    disp_hist = global_sim.schwarz_controller.disp_hist[coupled_index]
    velo_hist = global_sim.schwarz_controller.velo_hist[coupled_index]
    acce_hist = global_sim.schwarz_controller.acce_hist[coupled_index]
    ∂Ω_f_hist = global_sim.schwarz_controller.∂Ω_f_hist[coupled_index]
    interp_disp =
        same_step == true ? disp_hist[end] : interpolate(time_hist, disp_hist, time)
    interp_velo =
        same_step == true ? velo_hist[end] : interpolate(time_hist, velo_hist, time)
    interp_acce =
        same_step == true ? acce_hist[end] : interpolate(time_hist, acce_hist, time)
    interp_∂Ω_f =
        same_step == true ? ∂Ω_f_hist[end] : interpolate(time_hist, ∂Ω_f_hist, time)
    bc.coupled_subsim.model.internal_force = interp_∂Ω_f
    if global_sim.schwarz_controller.schwarz_contact == true
        relaxation_parameter = global_sim.schwarz_controller.relaxation_parameter
        Schwarz_iteration = global_sim.schwarz_controller.iteration_number
        if Schwarz_iteration == 1
            lambda_dispᵖʳᵉᵛ = zeros(length(interp_disp))
            lambda_veloᵖʳᵉᵛ = zeros(length(interp_velo))
            lambda_acceᵖʳᵉᵛ = zeros(length(interp_acce))
        else
            lambda_dispᵖʳᵉᵛ = global_sim.schwarz_controller.lambda_disp[coupled_index]
            lambda_veloᵖʳᵉᵛ = global_sim.schwarz_controller.lambda_velo[coupled_index]
            lambda_acceᵖʳᵉᵛ = global_sim.schwarz_controller.lambda_acce[coupled_index]
        end
        bc.coupled_subsim.integrator.displacement =
            global_sim.schwarz_controller.lambda_disp[coupled_index] =
                relaxation_parameter * interp_disp +
                (1 - relaxation_parameter) * lambda_dispᵖʳᵉᵛ
        bc.coupled_subsim.integrator.velocity =
            global_sim.schwarz_controller.lambda_velo[coupled_index] =
                relaxation_parameter * interp_velo +
                (1 - relaxation_parameter) * lambda_veloᵖʳᵉᵛ
        bc.coupled_subsim.integrator.acceleration =
            global_sim.schwarz_controller.lambda_acce[coupled_index] =
                relaxation_parameter * interp_acce +
                (1 - relaxation_parameter) * lambda_acceᵖʳᵉᵛ
    else
        bc.coupled_subsim.integrator.displacement = interp_disp
        bc.coupled_subsim.integrator.velocity = interp_velo
        bc.coupled_subsim.integrator.acceleration = interp_acce
    end
    copy_solution_source_targets(
        bc.coupled_subsim.integrator,
        bc.coupled_subsim.solver,
        bc.coupled_subsim.model,
    )
    apply_bc_detail(model, bc)
    bc.coupled_subsim.integrator.displacement = saved_disp
    bc.coupled_subsim.integrator.velocity = saved_velo
    bc.coupled_subsim.integrator.acceleration = saved_acce
    bc.coupled_subsim.model.internal_force = saved_∂Ω_f
    copy_solution_source_targets(
        bc.coupled_subsim.integrator,
        bc.coupled_subsim.solver,
        bc.coupled_subsim.model,
    )
end

function transfer_normal_component(
    source::Vector{Float64},
    target::Vector{Float64},
    normal::Vector{Float64},
)
    normal_projection = normal * normal'
    tangent_projection = I(length(normal)) - normal_projection
    return tangent_projection * target + normal_projection * source
end

function apply_sm_schwarz_contact_dirichlet(model::SolidMechanics, bc::SMContactSchwarzBC)
    side_set_node_indices = unique(bc.side_set_node_indices)
    for node_index ∈ side_set_node_indices
        point = model.current[:, node_index]
        point_new, ξ, _, closest_face_node_indices, closest_normal, _ = find_and_project(
            point,
            bc.coupled_mesh,
            bc.coupled_side_set_id,
            bc.coupled_subsim.model,
        )
        model.current[:, node_index] = point_new
        num_nodes = length(closest_face_node_indices)
        element_type = get_element_type(2, num_nodes)
        N, _, _ = interpolate(element_type, ξ)
        source_velo = bc.coupled_subsim.model.velocity[:, closest_face_node_indices] * N
        source_acce = bc.coupled_subsim.model.acceleration[:, closest_face_node_indices] * N
        model.velocity[:, node_index] = transfer_normal_component(
            source_velo,
            model.velocity[:, node_index],
            closest_normal,
        )
        model.acceleration[:, node_index] = transfer_normal_component(
            source_acce,
            model.acceleration[:, node_index],
            closest_normal,
        )
        dof_index = [3 * node_index - 2]
        model.free_dofs[dof_index] .= false
    end
end

function apply_naive_stabilized_bcs(subsim::SingleDomainSimulation)
    bcs = subsim.model.boundary_conditions
    for bc ∈ bcs
        if typeof(bc) == SMContactSchwarzBC
            side_set_node_indices = unique(bc.side_set_node_indices)
            for node_index ∈ side_set_node_indices
                subsim.model.acceleration[:, node_index] = zeros(3)
            end
        end
    end
    copy_solution_source_targets(subsim.model, subsim.integrator, subsim.solver)
end

function apply_sm_schwarz_contact_neumann(model::SolidMechanics, bc::SMContactSchwarzBC)
    schwarz_tractions = get_dst_traction(bc)
    normals = compute_normal(model.mesh, bc.side_set_id, model)
    local_to_global_map = get_side_set_local_to_global_map(model.mesh, bc.side_set_id)
    num_local_nodes = length(local_to_global_map)
    for local_node ∈ 1:num_local_nodes
        global_node = local_to_global_map[local_node]
        node_tractions = schwarz_tractions[3*local_node-2:3*local_node]
        normal = normals[:, local_node]
        model.boundary_force[3*global_node-2:3*global_node] += transfer_normal_component(
            node_tractions,
            model.boundary_force[3*global_node-2:3*global_node],
            normal,
        )
    end
end

function reduce_traction(
    mesh::ExodusDatabase,
    side_set_id::Integer,
    global_traction::Vector{Float64},
)
    local_to_global_map = get_side_set_local_to_global_map(mesh, side_set_id)
    num_local_nodes = length(local_to_global_map)
    local_traction = zeros(3 * num_local_nodes)
    for local_node ∈ 1:num_local_nodes
        global_node = local_to_global_map[local_node]
        local_traction[3*local_node-2:3*local_node] =
            global_traction[3*global_node-2:3*global_node]
    end
    return local_traction
end

function compute_transfer_operator(dst_model::SolidMechanics, bc::SMContactSchwarzBC)
    src_mesh = bc.coupled_subsim.model.mesh
    src_side_set_id = bc.coupled_side_set_id
    src_model = bc.coupled_subsim.model
    dst_mesh = dst_model.mesh
    dst_side_set_id = bc.side_set_id
    square_projection_matrix =
        get_square_projection_matrix(src_mesh, src_model, src_side_set_id)
    rectangular_projection_matrix = get_rectangular_projection_matrix(
        dst_mesh,
        dst_model,
        dst_side_set_id,
        src_mesh,
        src_model,
        src_side_set_id,
    )
    bc.transfer_operator = rectangular_projection_matrix * inv(square_projection_matrix)
end

function get_dst_traction(bc::SMContactSchwarzBC)
    src_mesh = bc.coupled_subsim.model.mesh
    src_side_set_id = bc.coupled_side_set_id
    src_global_traction = -bc.coupled_subsim.model.internal_force
    src_local_traction = reduce_traction(src_mesh, src_side_set_id, src_global_traction)
    src_traction_x = src_local_traction[1:3:end]
    src_traction_y = src_local_traction[2:3:end]
    src_traction_z = src_local_traction[3:3:end]
    dst_traction_x = bc.transfer_operator * src_traction_x
    dst_traction_y = bc.transfer_operator * src_traction_y
    dst_traction_z = bc.transfer_operator * src_traction_z
    dst_traction = zeros(3 * length(dst_traction_x))
    dst_traction[1:3:end] = dst_traction_x
    dst_traction[2:3:end] = dst_traction_y
    dst_traction[3:3:end] = dst_traction_z
    return dst_traction
end

function node_set_id_from_name(node_set_name::String, mesh::ExodusDatabase)
    node_set_names = Exodus.read_names(mesh, NodeSet)
    num_names = length(node_set_names)
    node_set_index = 0
    for index ∈ 1:num_names
        if (node_set_name == node_set_names[index])
            node_set_index = index
            break
        end
    end
    if (node_set_index == 0)
        error("node set ", node_set_name, " cannot be found in mesh")
    end
    node_set_ids = Exodus.read_ids(mesh, NodeSet)
    node_set_id = node_set_ids[node_set_index]
    return Int64(node_set_id)
end

function side_set_id_from_name(side_set_name::String, mesh::ExodusDatabase)
    side_set_names = Exodus.read_names(mesh, SideSet)
    num_names = length(side_set_names)
    side_set_index = 0
    for index ∈ 1:num_names
        if (side_set_name == side_set_names[index])
            side_set_index = index
            break
        end
    end
    if (side_set_index == 0)
        error("side set ", side_set_name, " cannot be found in mesh")
    end
    side_set_ids = Exodus.read_ids(mesh, SideSet)
    side_set_id = side_set_ids[side_set_index]
    return Int64(side_set_id)
end

function block_id_from_name(block_name::String, mesh::ExodusDatabase)
    block_names = Exodus.read_names(mesh, Block)
    num_names = length(block_names)
    block_index = 0
    for index ∈ 1:num_names
        if (block_name == block_names[index])
            block_index = index
            break
        end
    end
    if (block_index == 0)
        error("block ", block_name, " cannot be found in mesh")
    end
    block_ids = Exodus.read_ids(mesh, Block)
    block_id = block_ids[block_index]
    return Int64(block_id)
end

function component_offset_from_string(name::String)
    offset = 0
    if name == "x"
        offset = 1
    elseif name == "y"
        offset = 2
    elseif name == "z"
        offset = 3
    else
        error("invalid component name ", name)
    end
    return offset
end

function extract_value(value::Real)
    return value
end

function extract_value(symbol::Num)
    return symbol.val
end

function create_bcs(params::Dict{Any,Any})
    boundary_conditions = Vector{BoundaryCondition}()
    if haskey(params, "boundary conditions") == false
        return boundary_conditions
    end
    input_mesh = params["input_mesh"]
    bc_params = params["boundary conditions"]
    for (bc_type, bc_type_params) ∈ bc_params
        for bc_setting_params ∈ bc_type_params
            if bc_type == "Dirichlet"
                boundary_condition = SMDirichletBC(input_mesh, bc_setting_params)
                push!(boundary_conditions, boundary_condition)
            elseif bc_type == "Neumann"
                boundary_condition = SMNeumannBC(input_mesh, bc_setting_params)
                push!(boundary_conditions, boundary_condition)
            elseif bc_type == "Schwarz contact"
                sim = params["global_simulation"]
                sim.schwarz_controller.schwarz_contact = true
                coupled_subsim_name = bc_setting_params["source"]
                coupled_subdomain_index = sim.subsim_name_index_map[coupled_subsim_name]
                coupled_subsim = sim.subsims[coupled_subdomain_index]
                boundary_condition =
                    SMContactSchwarzBC(coupled_subsim, input_mesh, bc_setting_params)
                push!(boundary_conditions, boundary_condition)
            elseif bc_type == "Schwarz Dirichlet"
                sim = params["global_simulation"]
                subsim_name = params["name"]
                subdomain_index = sim.subsim_name_index_map[subsim_name]
                subsim = sim.subsims[subdomain_index]
                coupled_subsim_name = bc_setting_params["source"]
                coupled_subdomain_index = sim.subsim_name_index_map[coupled_subsim_name]
                coupled_subsim = sim.subsims[coupled_subdomain_index]
                boundary_condition =
                    SMSchwarzDBC(subsim, coupled_subsim, input_mesh, bc_setting_params)
                push!(boundary_conditions, boundary_condition)
            else
                error("Unknown boundary condition type : ", bc_type)
            end
        end
    end
    return boundary_conditions
end

function apply_bcs(model::SolidMechanics)
    _, num_nodes = size(model.reference)
    model.boundary_force = zeros(3 * num_nodes)
    model.free_dofs = trues(3 * num_nodes)
    for boundary_condition ∈ model.boundary_conditions
        apply_bc(model, boundary_condition)
    end
end

function apply_ics(params::Dict{Any,Any}, model::SolidMechanics)
    if haskey(params, "initial conditions") == false
        return
    end
    input_mesh = params["input_mesh"]
    ic_params = params["initial conditions"]
    for (ic_type, ic_type_params) ∈ ic_params
        for ic ∈ ic_type_params
            node_set_name = ic["node set"]
            expression = ic["function"]
            component = ic["component"]
            offset = component_offset_from_string(component)
            node_set_id = node_set_id_from_name(node_set_name, input_mesh)
            node_set_node_indices = Exodus.read_node_set_nodes(input_mesh, node_set_id)
            # expression is an arbitrary function of t, x, y, z in the input file
            ic_expr = Meta.parse(expression)
            ic_eval = eval(ic_expr)
            for node_index ∈ node_set_node_indices
                values = Dict(
                    t => model.time,
                    x => model.reference[1, node_index],
                    y => model.reference[2, node_index],
                    z => model.reference[3, node_index],
                )
                ic_sym = substitute(ic_eval, values)
                ic_val = extract_value(ic_sym)
                if ic_type == "displacement"
                    model.current[offset, node_index] =
                        model.reference[offset, node_index] + ic_val
                elseif ic_type == "velocity"
                    model.velocity[offset, node_index] = ic_val
                end
            end
        end
    end
end

function pair_schwarz_bcs(sim::MultiDomainSimulation)
    for subsim ∈ sim.subsims
        model = subsim.model
        name = subsim.name
        bcs = model.boundary_conditions
        for bc ∈ bcs
            pair_bc(name, bc)
        end
    end
end

function pair_bc(_::String, _::RegularBoundaryCondition) end

function pair_bc(_::String, _::SchwarzBoundaryCondition) end

function pair_bc(name::String, bc::ContactSchwarzBoundaryCondition)
    coupled_model = bc.coupled_subsim.model
    coupled_bcs = coupled_model.boundary_conditions
    for coupled_bc ∈ coupled_bcs
        if is_coupled_to_current(name, coupled_bc) == true
            coupled_bc.is_dirichlet = !bc.is_dirichlet
        end
    end
end

function is_coupled_to_current(_::String, _::RegularBoundaryCondition)
    return false
end

function is_coupled_to_current(_::String, _::SchwarzBoundaryCondition)
    return false
end

function is_coupled_to_current(name::String, coupled_bc::ContactSchwarzBoundaryCondition)
    return name == coupled_bc.coupled_subsim.name
end
