function barycentricD2N3(ξ::Vector{Float64})
    N = [1.0 - ξ[1] - ξ[2], ξ[1], ξ[2]]
    dN = [-1 1 0;
          -1 0 1] / 1.0
    return N, dN
end

function barycentricD2N3G1()
    w = 0.5 * ones(1)
    N = zeros(3, 1)
    dN = zeros(2, 3, 1)
    ξ = ones(2) / 3
    N, dN[:, :, 1] = barycentricD2N3(ξ)
    return N, dN, w
end

function barycentricD2N3G3()
    w = ones(3) / 6.0
    N = zeros(3, 3)
    dN = zeros(2, 3, 3)
    ξ = [4 1 1 1;
         1 4 1 1;
         1 1 4 1] / 6
    for p ∈ 1:3
        N[:, p], dN[:, :, p] = barycentricD2N3(ξ[:, p])
    end
    return N, dN, w
end

function barycentricD3N4(ξ::Vector{Float64})
    N = [1 - ξ[1] - ξ[2] - ξ[3],
        ξ[1],
        ξ[2],
        ξ[3]]
    dN = [-1 1 0 0;
          -1 0 1 0;
          -1 0 0 1] / 1.0
    return N, dN
end

function barycentricD3N10(ξ::Vector{Float64})
    t1 = 1 - ξ[1] - ξ[2] - ξ[3]
    t2 = ξ[1]
    t3 = ξ[2]
    t4 = ξ[3]
    N = [t1 * (2 * t1 - 1),
        t2 * (2 * t2 - 1),
        t3 * (2 * t3 - 1),
        t4 * (2 * t4 - 1),
        4 * t1 * t2,
        4 * t3 * t3,
        4 * t3 * t1,
        4 * t1 * t4,
        4 * t2 * t4,
        4 * t3 * t4]
    dN = [1-4*t1 4*t2-1 0 0 4*(t1-t2) 4*t3 -4*t3 -4*t4 4*t4 0;
          1-4*t1 0 4*t3-1 0 -4*t2 4*t2 4*(t1-t3) -4*t4 0 4*t4;
          1-4*t1 0 0 4*t4-1 -4*t2 0 -4*t3 4*(t1-t4) 4*t2 4*t3]
    return N, dN
end

function barycentricD3N4G1()
    w = ones(1) / 6.0
    N = zeros(4, 1)
    dN = zeros(3, 4, 1)
    ξ = 0.25 * ones(3)
    N, dN[:, :, 1] = barycentricD3N4(ξ)
    return N, dN, w
end

function barycentricD3N4G4()
    w = ones(4) / 24.0
    N = zeros(4, 4)
    dN = zeros(3, 4, 4)
    s = sqrt(5.0)
    a = 5.0 + 3.0 * s
    b = 5.0 - s
    ξ = [b a b b
         b b a b
         b b b a] / 20.0
    for p ∈ 1:4
        N[:, p], dN[:, :, p] = barycentricD3N4(ξ[:, p])
    end
    return N, dN, w
end

function barycentricD3N10G4()
    w = ones(4) / 24.0
    N = zeros(10, 4)
    dN = zeros(3, 10, 4)
    s = sqrt(5.0)
    a = 5.0 + 3.0 * s
    b = 5.0 - s
    ξ = [b a b b
         b b a b
         b b b a] / 20.0
    for p ∈ 1:4
        N[:, p], dN[:, :, p] = barycentricD3N4(ξ[:, p])
    end
    return N, dN, w
end

function barycentricD3N10G5()
    a = -2/15
    b = 3/40
    w = [a b b b b]
    N = zeros(10, 5)
    dN = zeros(3, 10, 5)
    ξ = [1/4 1/6 1/6 1/6 1/2
         1/4 1/6 1/6 1/2 1/6
         1/4 1/6 1/2 1/6 1/6]
    for p ∈ 1:5
        N[:, p], dN[:, :, p] = barycentricD3N4(ξ[:, p])
    end
    return N, dN, w
end

# Computes the nodes x and weights w
# for n-point Gauss-Legendre quadrature.
# Reference:
# G. H. Golub and J. H. Welsch, Calculation of Gauss quadrature
# rules, Math. Comp., 23(106):221-230, 1969.
function gauss_legendre(n::Int64)
    if n == 1
        return zeros(1), 2.0 * ones(1)
    elseif n == 2
        g = sqrt(3.0 / 3.0)
        return [-g, g], ones(2)
    elseif n == 3
        w = [5.0, 8.0, 5.0] / 9.0
        g = sqrt(3.0 / 5.0)
        ξ = [-g, 0, g]
        return ξ, w
    elseif n == 4
        a = sqrt(3.0 / 7.0 + 2.0 * sqrt(6.0 / 5.0) / 7.0)
        b = sqrt(3.0 / 7.0 - 2.0 * sqrt(6.0 / 5.0) / 7.0)
        c = (18.0 - sqrt(30.0)) / 36.0
        d = (18.0 + sqrt(30.0)) / 36.0
        w = [c, d, d, c]
        ξ = [-a, -b, b, a]
        return ξ, w
    end
    i = 1:n-1
    v = i ./ sqrt.(4.0 .* i .* i .- 1.0)
    vv = eigen(diagm(1=>v, -1=>v))
    ξ = vv.values
    w = 2.0 * vv.vectors[1, :].^2
    return ξ, w
end

function gauss_legendreD1(n::Int64)
    return gauss_legendre(n)
end

function gauss_legendreD2(n::Int64)
    if n ∉ [1, 4, 9]
        error("Order must be in [1,4,9] : ", n)
    end
    if n == 1
        return zeros(2, 1), 4.0 * ones(1)
    elseif n == 4
        w = ones(4)
        g = sqrt(3.0) / 3.0
        ξ = g * [-1  1  1 -1;
                 -1 -1  1  1]
        return ξ, w
    elseif n == 9    
        x, ω = gauss_legendreD1(3)
        ξ = [x[1] x[3] x[3] x[1] x[2] x[3] x[2] x[1] x[2];
             x[1] x[1] x[3] x[3] x[1] x[2] x[3] x[2] x[2]]
        w = [ω[1]*ω[1], ω[3]*ω[1], ω[3]*ω[3], ω[1]*ω[3], ω[2]*ω[1], ω[3]*ω[2], ω[2]*ω[3], ω[1]*ω[2], ω[2]*ω[2]]
    end
end

function gauss_legendreD1(n::Int64)
    return gauss_legendre(n)
end

function lagrangianD1N2(ξ::Float64)
    N = [0.5 * (1.0 - ξ), 0.5 * (1.0 + ξ)]
    dN = [-0.5, 0.5]
    return N, dN
end

function lagrangianD1N2G1()
    N = zeros(2, 1)
    dN = zeros(1, 2, 1)
    ξ, w = gauss_legendreD1(1)
    N, dN[:, :, 1] = lagrangianD1N2(ξ[1])
    return N, dN, w
end

function lagrangianD1N2G2()
    N = zeros(2, 2)
    dN = zeros(1, 2, 2)
    ξ, w = gauss_legendreD1(2)
    for p ∈ 1:2
        N[:, p], dN[:, :, p] = lagrangianD1N2(ξ[p])
    end
    return N, dN, w
end

function lagrangianD1N2G3()
    N = zeros(2, 3)
    dN = zeros(1, 2, 3)
    ξ, w = gauss_legendreD1(3)
    for p ∈ 1:3
        N[:, p], dN[:, :, p] = lagrangianD1N2(ξ[p])
    end
    return N, dN, w
end

function lagrangianD1N2G4()
    N = zeros(2, 4)
    dN = zeros(1, 2, 4)
    ξ, w = gauss_legendreD1(4)
    for p ∈ 1:4
        N[:, p], dN[:, :, p] = lagrangianD1N2(ξ[p])
    end
    return N, dN, w
end

function lagrangianD2N4(ξ::Vector{Float64})
    r = ξ[1]
    s = ξ[2]
    ra = [-1 1 1 -1] / 1.0
    sa = [-1 -1 1 1] / 1.0
    N = zeros(4)
    dN = zeros(2, 4)
    for p ∈ 1:4
        N[p] = 0.25 * (1.0 + ra[p] * r) * (1.0 + sa[p] * s)
        dN[1, p] = 0.25 * ra[p] * (1 + sa[p] * s)
        dN[2, p] = 0.25 * (1 + ra[p] * r) * sa[p]
    end
    return N, dN
end

function lagrangianD2N4G4()
    N = zeros(4, 4)
    dN = zeros(2, 4, 4)
    ξ, w = gauss_legendreD2(4)
    for p ∈ 1:4
        N[:, p], dN[:, :, p] = lagrangianD2N4(ξ[:, p])
    end
    return N, dN, w
end

function lagrangianD2N4G9()
    N = zeros(4, 9)
    dN = zeros(2, 4, 9)
    ξ, w = gauss_legendreD2(9)
    for p ∈ 1:4
        N[:, p], dN[:, :, p] = lagrangianD2N4(ξ[:, p])
    end
    return N, dN, w
end

function lagrangianD3N8(ξ::Vector{Float64})
    r = ξ[1]
    s = ξ[2]
    t = ξ[3]
    ra = [-1 1 1 -1 -1 1 1 -1] / 1.0
    sa = [-1 -1 1 1 -1 -1 1 1] / 1.0
    ta = [-1 -1 -1 -1 1 1 1 1] / 1.0
    N = zeros(8)
    dN = zeros(3, 8)
    for p ∈ 1:8
        N[p] = 0.125 * (1.0 + ra[p] * r) * (1.0 + sa[p] * s) * (1.0 + ta[p] * t)
        dN[1, p] = 0.125 * ra[p] * (1.0 + sa[p] * s) * (1.0 + ta[p] * t)
        dN[2, p] = 0.125 * (1.0 + ra[p] * r) * sa[p] * (1.0 + ta[p] * t)
        dN[3, p] = 0.125 * (1.0 + ra[p] * r) * (1.0 + sa[p] * s) * ta[p]
    end
    return N, dN
end

function lagrangianD3N8G8()
    w = ones(8)
    N = zeros(8, 8)
    dN = zeros(3, 8, 8)
    g = sqrt(3.0) / 3.0
    ξ = g * [-1 1 1 -1 -1 1 1 -1
        -1 -1 1 1 -1 -1 1 1
        -1 -1 -1 -1 1 1 1 1]
    for p ∈ 1:8
        N[:, p], dN[:, :, p] = lagrangianD3N8(ξ[:, p])
    end
    return N, dN, w
end

function default_num_int_pts(element_type)
    if element_type == "BAR2"
        return 1
    elseif element_type == "TRI3"
        return 1
    elseif element_type == "QUAD4"
        return 4
    elseif element_type == "TETRA4"
        return 1
    elseif element_type == "TETRA10"
        return 4
    elseif element_type == "HEX8"
        return 8
    else
        error("Invalid element type: ", element_type)
    end
end

function get_element_type(dim::Int64, num_nodes::Int64)
    if dim == 1 && num_nodes == 2
        return "BAR2"
    elseif dim == 2 && num_nodes == 3
        return "TRI3"
    elseif dim == 2 && num_nodes == 4
        return "QUAD4"
    elseif dim == 3 && num_nodes == 4
        return "TETRA4"
    elseif dim == 3 && num_nodes == 10
        return "TETRA10"
    elseif dim == 3 && num_nodes == 8
        return "HEX8"
    else
        error("Invalid dimension : ", dim, " and number of nodes : ", num_nodes)
    end
end

#
# Compute isoparametric interpolation functions, their parametric
# derivatives and integration weights.
#
function isoparametric(element_type::String, num_int::Int64)
    msg1 = "Invalid number of integration points: "
    msg2 = " for element type: "
    if element_type == "BAR2"
        if num_int == 1
            return lagrangianD1N2G1()
        elseif num_int == 2
            return lagrangianD1N2G2()
        else
            error(msg1, num_int, msg2, element_type)
        end
    elseif element_type == "TRI3"
        if num_int == 1
            return barycentricD2N3G1()
        elseif num_int == 3
            return barycentricD2N3G3()
        else
            error(msg1, num_int, msg2, element_type)
        end
    elseif element_type == "QUAD4"
        if num_int == 4
            return lagrangianD2N4G4()
        elseif num_int == 9
            return lagrangianD2N4G9()
        else
            error(msg1, num_int, msg2, element_type)
        end
    elseif element_type == "TETRA4"
        if num_int == 1
            return barycentricD3N4G1()
        elseif num_int == 4
            return barycentricD3N4G4()
        else
            error(msg1, num_int, msg2, element_type)
        end
    elseif element_type == "TETRA10"
        if num_int == 4
            return barycentricD3N10G4()
        elseif num_int == 5
            return barycentricD3N10G5()
        else
            error(msg1, num_int, msg2, element_type)
        end
    elseif element_type == "HEX8"
        if num_int == 8
            return lagrangianD3N8G8()
        else
            error(msg1, num_int, msg2, element_type)
        end
    else
        error("Invalid element type: ", element_type)
    end
end

function gradient_operator(dNdX::Matrix{Float64})
    dim, nen = size(dNdX)
    B = zeros(dim * dim, nen * dim)
    for i ∈ 1:dim
        for j ∈ 1:dim
            p = dim * (i - 1) + j
            for a ∈ 1:nen
                for k ∈ 1:dim
                    q = dim * (a - 1) + k
                    B[p, q] = I[i, k] * dNdX[j, a]
                end
            end
        end
    end
    return B
end

function surface_3D_to_2D(vertices::Matrix{Float64})
    _, num_nodes = size(vertices)
    if num_nodes == 3
        return triangle_3D_to_2D(vertices[:, 1], vertices[:, 2], vertices[:, 3])
    elseif num_nodes == 4
        return quadrilateral_3D_to_2D(vertices[:, 1], vertices[:, 2], vertices[:, 3], vertices[:, 4])
    else
        error("Unknown surface type with number of nodes : ", num_nodes)
    end
end

function triangle_3D_to_2D(A::Vector{Float64}, B::Vector{Float64}, C::Vector{Float64})
    AB = B - A
    Bx = norm(AB)
    AC = C - A
    AC2 = AC ⋅ AC
    n = AB / Bx
    Cx = AC ⋅ n
    Cy = sqrt(AC2 - Cx * Cx)
    coordinates = zeros(2, 3)
    coordinates[1, 2] = Bx
    coordinates[1, 3] = Cx
    coordinates[2, 3] = Cy
    return coordinates
end

function quadrilateral_3D_to_2D(A::Vector{Float64}, B::Vector{Float64}, C::Vector{Float64}, D::Vector{Float64})
    AB = A - B
    AC = A - C
    AD = A - D
    V = cross(AB, AC)
    v = V / norm(V)
    u = AD ⋅ v
    if abs(u) / norm(AD) >= 1.0e-04
        error("Curved quadrilaterals are not supported")
    end
    Bx = norm(AB)
    AC2 = AC ⋅ AC
    AD2 = AD ⋅ AD
    n = AB / Bx
    Cx = AC ⋅ n
    Cy = sqrt(AC2 - Cx * Cx)
    Dx = AD ⋅ n
    Dy = sqrt(AD2 - Dx * Dx)
    coordinates = zeros(2, 4)
    coordinates[1, 2] = Bx
    coordinates[1, 3] = Cx
    coordinates[1, 4] = Dx
    coordinates[2, 3] = Cy
    coordinates[2, 4] = Dy
    return coordinates
end

using Symbolics
@variables t, x, y, z

function get_side_set_nodal_forces(nodal_coord::Matrix{Float64}, traction_num::Num, time::Float64)
    _, num_side_nodes = size(nodal_coord)
    if num_side_nodes == 3
        A = nodal_coord[:, 1]
        B = nodal_coord[:, 2]
        C = nodal_coord[:, 3]
        centroid = (A + B + C) / 3.0
        two_dim_coord = triangle_3D_to_2D(A, B, C)
        g = 0.0
    elseif num_side_nodes == 4
        A = nodal_coord[:, 1]
        B = nodal_coord[:, 2]
        C = nodal_coord[:, 3]
        D = nodal_coord[:, 4]
        centroid = (A + B + C + D) / 4.0
        two_dim_coord = quadrilateral_3D_to_2D(A, B, C, D)
        g = sqrt(3.0) / 3.0
    else
        error("Unknown side topology with number of nodes: ", num_side_nodes)
    end
    element_type = get_element_type(2, num_side_nodes)
    num_int_points = default_num_int_pts(element_type)
    N, dNdξ, w = isoparametric(element_type, num_int_points)
    nodal_force_component = zeros(num_side_nodes)
    for point ∈ 1:num_int_points
        Nₚ = N[:, point]
        dNdξₚ = dNdξ[:, :, point]
        dXdξ = dNdξₚ * two_dim_coord'
        j = det(dXdξ)
        wₚ = w[point]
        point_coord = g * nodal_coord[:, point] + (1.0 - g) * centroid
        values = Dict(t=>time, x=>point_coord[1], y=>point_coord[2], z=>point_coord[3])
        traction_sym = substitute(traction_num, values)
        traction_val = extract_value(traction_sym)
        nodal_force_component += traction_val * Nₚ * j * wₚ
    end
    return nodal_force_component
end

function map_to_parametric(element_type::String, vertices::Matrix{Float64}, point::Vector{Float64})
    tol = 1.0e-08
    dim = length(point)
    ξ = zeros(dim)
    hessian = zeros(dim, dim)
    while true
        N, dN = interpolate(element_type, ξ)
        trial_point = vertices * N
        residual = trial_point - point
        hessian = vertices * dN'
        δ = - hessian \ residual
        ξ = ξ + δ
        error = norm(δ)
        if error <= tol
          break
        end
    end
    return ξ
end

function interpolate(element_type::String, ξ::Vector{Float64})
    if element_type == "BAR2"
        return lagrangianD1N2(ξ)
    elseif element_type == "TRI3"
        return barycentricD2N3(ξ)
    elseif element_type == "QUAD4"
        return lagrangianD2N4(ξ)
    elseif element_type == "TETRA4"
        return barycentricD3N4(ξ)
    elseif element_type == "TETRA10"
        return barycentricD3N10(ξ)
    elseif element_type == "HEX8"
        return lagrangianD3N8(ξ)
    else
        error("Invalid element type: ", element_type)
    end
end

function is_inside_parametric(element_type::String, ξ::Vector{Float64})
    if element_type == "BAR2"
        return -1.0 ≤ ξ ≤ 1.0
    elseif element_type == "TRI3"
        return reduce(*, zeros(2) .≤ ξ .≤ ones(2))
    elseif element_type == "QUAD4"
        return reduce(*, -ones(2) .≤ ξ .≤ ones(2))
    elseif element_type == "TETRA4" || element_type == "TETRA10"
        return reduce(*, zeros(3) .≤ ξ .≤ ones(3))
    elseif element_type == "HEX8"
        return reduce(*, -ones(3) .≤ ξ .≤ ones(3))
    else
        error("Invalid element type: ", element_type)
    end
end

function is_inside(element_type::String, vertices::Matrix{Float64}, point::Vector{Float64})
    ξ = map_to_parametric(element_type, vertices, point)
    return is_inside_parametric(element_type, ξ)
end

function find_and_project(point::Vector{Float64}, coupled_mesh::PyObject, coupled_block_id::Int64, coupled_side_set_id::Int64, model::SolidMechanics)
    elem_blk_conn, num_blk_elems, num_elem_nodes = coupled_mesh.get_elem_connectivity(coupled_block_id)
    elem_type = coupled_mesh.elem_type(blk_id)
    point_new = point
    inside = false
    for blk_elem_index ∈ 1:num_blk_elems
        conn_indices = (blk_elem_index-1)*num_elem_nodes+1:blk_elem_index*num_elem_nodes
        node_indices = elem_blk_conn[conn_indices]
        vertices = model.current[:, node_indices]
        inside = is_inside(elem_type, vertices, point)
        #if a point is inside an element, we will move it on the contact side
        if inside == true
            #call a function wich projects the point onto the contact boundary
            point_new = project_onto_contact_surface(point, coupled_side_set_id, coupled_mesh, model)
            break
        end        
    end
    if inside == false
        error("Point : ", point, " not in contact")
    end
    return point_new, node_indices
end

function project_onto_contact_surface(point::Vector{Float64}, coupled_side_set_id::Int64, coupled_mesh::PyObject, model::SolidMechanics)
    #we assume that we know the contact surfaces in advance 
    num_nodes_per_side, side_set_node_indices = coupled_mesh.get_side_set_node_list(coupled_side_set_id)
    coupled_ss_node_index = 1
    minimum_distance = Inf
    point_new = point
    for coupled_side ∈ num_nodes_per_side
        coupled_side_nodes = side_set_node_indices[coupled_ss_node_index:coupled_ss_node_index+coupled_side-1]
        coupled_side_coordinates = model.current[:, coupled_side_nodes]
        #plane 
        coordinates_A = coupled_side_coordinates[:, 1]
        coordinates_B = coupled_side_coordinates[:, 2]
        coordinates_C = coupled_side_coordinates[:, 3]
        BA = coordinates_B - coordinates_A
        CA = coordinates_C - coordinates_A
        N = cross(BA, CA)
        n = N / norm(N)
        distance = (point - coordinates_A) ⋅ n
        #store the new point if the distance is min
        if abs(distance) < minimum_distance
            point_new = point - distance * n   
        end    
        minimum_distance = min(minimum_distance, abs(distance))
        coupled_ss_node_index += coupled_side
    end
    #point_new: new points position
    return point_new
end

function get_side_set_global_to_local_map(mesh::PyObject, side_set_id::Int64)
    num_nodes_sides, side_set_node_indices = mesh.get_side_set_node_list(side_set_id)
    unique_node_indices = unique(side_set_node_indices)
    num_nodes = length(unique_node_indices)
    global_to_local_map = Dict{Int64,Int64}()
    for i ∈ 1:num_nodes
        global_to_local_map[Int64(unique_node_indices[i])] = i
    end
    return global_to_local_map, num_nodes_sides, side_set_node_indices
end

function get_square_projection_matrix(mesh::PyObject, side_set_id::Int64)
    global_to_local_map, num_nodes_sides, side_set_node_indices = Norma.get_side_set_global_to_local_map(mesh, side_set_id)
    num_nodes = length(global_to_local_map)
    coords = mesh.get_coords()
    square_projection_matrix = zeros(num_nodes, num_nodes)
    side_set_node_index = 1
    for num_nodes_side ∈ num_nodes_sides
        side_nodes = side_set_node_indices[side_set_node_index:side_set_node_index+num_nodes_side-1]
        side_coordinates = [coords[1][side_nodes]'; coords[2][side_nodes]'; coords[3][side_nodes]']
        two_dim_coord = Norma.surface_3D_to_2D(side_coordinates)
        element_type = Norma.get_element_type(2, Int64(num_nodes_side))
        num_int_points = Norma.default_num_int_pts(element_type)
        N, dNdξ, w = Norma.isoparametric(element_type, num_int_points)
        side_matrix = zeros(num_nodes_side, num_nodes_side)
        for point ∈ 1:num_int_points
            Nₚ = N[:, point]
            dNdξₚ = dNdξ[:, :, point]
            dXdξ = dNdξₚ * two_dim_coord'
            j = det(dXdξ)
            wₚ = w[point]
            side_matrix += Nₚ * Nₚ' * j * wₚ
        end
        local_indices = get.(Ref(global_to_local_map), side_nodes, 0)
        square_projection_matrix[local_indices, local_indices] += side_matrix
        side_set_node_index += num_nodes_side
    end
    return square_projection_matrix
end

function get_rectangular_projection_matrix(src_mesh::PyObject, src_side_set_id::Int64, dst_mesh::PyObject, dst_side_set_id::Int64)
    src_global_to_local_map, src_num_nodes_sides, src_side_set_node_indices = Norma.get_side_set_global_to_local_map(src_mesh, src_side_set_id)
    src_num_nodes = length(src_global_to_local_map)
    src_coords = src_mesh.get_coords()
    dst_global_to_local_map, dst_num_nodes_sides, dst_side_set_node_indices = Norma.get_side_set_global_to_local_map(dst_mesh, dst_side_set_id)
    dst_num_nodes = length(dst_global_to_local_map)
    dst_coords = dst_mesh.get_coords()
    dst_side_set_elems, _ = dst_mesh.get_side_set(dst_side_set_id)
    rectangular_projection_matrix = zeros(dst_num_nodes, src_num_nodes)
    rectangular_side_matrix = zeros(dst_num_nodes, src_num_nodes)
    src_side_set_node_index = 1
    for src_num_nodes_side ∈ src_num_nodes_sides
        src_side_nodes = src_side_set_node_indices[src_side_set_node_index:src_side_set_node_index+src_num_nodes_side-1]
        src_side_coordinates = [src_coords[1][src_side_nodes]'; src_coords[2][src_side_nodes]'; src_coords[3][src_side_nodes]']
        src_two_dim_coord = Norma.surface_3D_to_2D(src_side_coordinates)
        src_element_type = Norma.get_element_type(2, Int64(src_num_nodes_side))
        src_num_int_points = Norma.default_num_int_pts(src_element_type)
        src_N, src_dNdξ, src_w = Norma.isoparametric(src_element_type, src_num_int_points)
        for src_point ∈ 1:src_num_int_points
            src_Nₚ = src_N[:, src_point]
            src_dNdξₚ = src_dNdξ[:, :, src_point]
            src_dXdξ = src_dNdξₚ * src_two_dim_coord'
            src_j = det(src_dXdξ)
            src_wₚ = src_w[src_point]
            # find the physical coordinates of the integration point of the source sides
            if src_num_nodes_side == 3
                A = src_side_coordinates[:, 1]
                B = src_side_coordinates[:, 2]
                C = src_side_coordinates[:, 3]
                centroid = (A + B + C) / 3.0
                g = 0.0
            elseif src_num_nodes_side == 4
                A = src_side_coordinates[:, 1]
                B = src_side_coordinates[:, 2]
                C = src_side_coordinates[:, 3]
                D = src_side_coordinates[:, 4]
                centroid = (A + B + C + D) / 4.0
                g = sqrt(3.0) / 3.0
            end
            src_int_point_coord = g * src_side_coordinates[:, src_point] + (1.0 - g) * centroid
            # loop over the sides of the destination side set
            dst_side_set_elems, _ = dst_mesh.get_side_set(dst_side_set_id)
            dst_side_set_node_index = 1
            dst_side_set_index = 1
            inside = false
            for dst_num_nodes_side ∈ dst_num_nodes_sides
                dst_side_nodes = dst_side_set_node_indices[dst_side_set_node_index:dst_side_set_node_index+dst_num_nodes_side-1]
                dst_side_coordinates = [dst_coords[1][dst_side_nodes]'; dst_coords[2][dst_side_nodes]']
                dst_side_element_type = Norma.get_element_type(2, Int64(dst_num_nodes_side))
                dst_side_set_elem = dst_side_set_elems[dst_side_set_index]
                dst_blk_id = dst_mesh.elem_to_blk_map[dst_side_set_elem]
                dst_element_type = dst_mesh.elem_type(dst_blk_id)
                dst_elem_blk_conn, _, dst_num_elem_nodes = dst_mesh.get_elem_connectivity(dst_blk_id)
                side_set_elem_conn_indices = (dst_side_set_elem-1)*dst_num_elem_nodes+1:dst_side_set_elem*dst_num_elem_nodes
                dst_node_indices = dst_elem_blk_conn[side_set_elem_conn_indices]
                dst_side_set_elem_coordinates = [dst_coords[1][dst_node_indices]'; dst_coords[2][dst_node_indices]'; dst_coords[3][dst_node_indices]']
                inside = Norma.is_inside(dst_element_type, dst_side_set_elem_coordinates, src_int_point_coord)
                if inside == true
                    #dst_ξ_1 = map_to_parametric(dst_element_type, dst_side_set_elem_coordinates, src_int_point_coord)
                    #dst_ξ = zeros(2)
                    #dst_ξ[1] = dst_ξ_1[2]
                    #dst_ξ[2] = dst_ξ_1[3]
                    src_int_point_coord_2D = zeros(2)
                    src_int_point_coord_2D[1] = src_int_point_coord[1]
                    src_int_point_coord_2D[2] = src_int_point_coord[2]
                    dst_ξ = map_to_parametric(dst_side_element_type, dst_side_coordinates, src_int_point_coord_2D)
                    dst_Nₚ, _ = interpolate(dst_side_element_type, dst_ξ)
                    src_local_indices = get.(Ref(src_global_to_local_map), src_side_nodes, 0)
                    dst_local_indices = get.(Ref(dst_global_to_local_map), dst_side_nodes, 0)
                    rectangular_side_matrix[dst_local_indices, src_local_indices] += src_Nₚ * dst_Nₚ' * src_j * src_wₚ 
                    break
                end
                dst_side_set_index += 1
                dst_side_set_node_index += dst_num_nodes_side
            end
            if inside == false
                error("Point : ", src_point, " not in contact")
            end
        end
        rectangular_projection_matrix = rectangular_side_matrix
        src_side_set_node_index += src_num_nodes_side
    end
    return rectangular_projection_matrix
end

function get_rectangular_projection_matrix_orig(src_mesh::PyObject, src_side_set_id::Int64, dst_mesh::PyObject, dst_side_set_id::Int64)
    src_global_to_local_map, src_num_nodes_sides, src_side_set_node_indices = get_side_set_global_to_local_map(src_mesh, src_side_set_id)
    src_num_nodes = length(src_global_to_local_map)
    src_coords = src_mesh.get_coords()
    dst_global_to_local_map, dst_num_nodes_sides, dst_side_set_node_indices = get_side_set_global_to_local_map(dst_mesh, dst_side_set_id)
    dst_num_nodes = length(dst_global_to_local_map)
    dst_coords = dst_mesh.get_coords()
    rectangular_projection_matrix = zeros(dst_num_nodes, src_num_nodes)
    src_side_set_node_index = 1
    for src_num_nodes_side ∈ src_num_nodes_sides
        src_side_nodes = src_side_set_node_indices[src_side_set_node_index:src_side_set_node_index+src_num_nodes_side-1]
        src_side_coordinates = [src_coords[1][src_side_nodes]'; src_coords[2][src_side_nodes]'; src_coords[3][src_side_nodes]']
        src_two_dim_coord = surface_3D_to_2D(src_side_coordinates)
        src_element_type = get_element_type(2, Int64(src_num_nodes_side))
        src_num_int_points = default_num_int_pts(src_element_type)
        src_N, src_dNdξ, src_w = isoparametric(src_element_type, src_num_int_points)
        side_matrix = zeros(src_num_nodes_side, src_num_nodes_side)
        for src_point ∈ 1:src_num_int_points
            src_Nₚ = src_N[:, src_point]
            src_dNdξₚ = src_dNdξ[:, :, src_point]
            src_dXdξ = src_dNdξₚ * src_two_dim_coord'
            src_j = det(src_dXdξ)
            src_wₚ = src_w[src_point]
            #find the reql coordinqtes of the integration point of the source sides
            if src_num_nodes_side == 3
                A = src_two_dim_coord[:, 1]
                B = src_two_dim_coord[:, 2]
                C = src_two_dim_coord[:, 3]
                centroid = (A + B + C) / 3.0
                g = 0.0
            elseif src_num_nodes_side == 4
                A = src_two_dim_coord[:, 1]
                B = src_two_dim_coord[:, 2]
                C = src_two_dim_coord[:, 3]
                D = src_two_dim_coord[:, 4]
                centroid = (A + B + C + D) / 4.0
                g = sqrt(3.0) / 3.0
            end
            #from get_side_set_nodal_forces
            src_point_coord = g * src_two_dim_coord[:, src_point] + (1.0 - g) * centroid
            #loop over the sides of the destination side set
            dst_side_set_node_index = 1
            inside = false
            for dst_num_nodes_side ∈ dst_num_nodes_sides
                dst_element_type = get_element_type(2, Int64(dst_num_nodes_side))
                dst_side_nodes = dst_side_set_node_indices[dst_side_set_node_index:dst_side_set_node_index+dst_num_nodes_side-1]
                dst_side_coordinates = [dst_coords[1][dst_side_nodes]'; dst_coords[2][dst_side_nodes]'; dst_coords[3][dst_side_nodes]']
                dst_two_dim_coord = surface_3D_to_2D(dst_side_coordinates)
                inside = is_inside(dst_element_type, dst_two_dim_coord, src_point_coord)
                if inside == true
                    dst_num_int_points = default_num_int_pts(dst_element_type)
                    dst_N, dst_Na, dst_w = isoparametric(dst_element_type, dst_num_int_points)
                    break
                end
                dst_side_set_node_index += dst_num_nodes_side    
            end
            if inside == false
                error("Point : ", src_point, " not in contact")
            end
            side_matrix += src_Nₚ * src_Nₚ' * src_j * src_wₚ
        end
        src_local_indices = get.(Ref(src_global_to_local_map), src_side_nodes, 0)
        dst_local_indices = get.(Ref(dst_global_to_local_map), dst_side_nodes, 0)
        rectangular_projection_matrix[dst_local_indices, src_local_indices] += side_matrix
        src_side_set_node_index += src_num_nodes_side
    end
    return rectangular_projection_matrix
end

function interpolate(tᵃ::Float64, tᵇ::Float64, xᵃ::Vector{Float64}, xᵇ::Vector{Float64}, t::Float64)
    Δt = tᵇ - tᵃ
    if Δt == 0.0
        return 0.5 * (xᵃ + xᵇ)
    end
    p = (tᵇ - t) / Δt
    q = 1.0 - p
    return p * xᵃ + q * xᵇ
end