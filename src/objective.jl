# objective.jl

"""
AbstractObjective is the supertype for all objectives in XCSP3.
"""
abstract type AbstractObjective end

"""
Represents the type of an objective function.
"""
@enum ObjectiveType begin
    Expression  # Default type
    Sum
    Minimum
    Maximum
    NValues
    Lex
end

"""
Represents a minimization objective in XCSP3.
"""
struct MinimizeObjective{T} <: AbstractObjective
    id::String  # Optional ID, empty string if not provided
    type::ObjectiveType
    variables::Vector{T}  # Variables involved (can be strings or VariableRefs)
    coefficients::Vector{Int}  # Optional coefficients, empty if not needed
    expression::String  # For Expression type, empty if not used
end

"""
Represents a maximization objective in XCSP3.
"""
struct MaximizeObjective{T} <: AbstractObjective
    id::String  # Optional ID, empty string if not provided
    type::ObjectiveType
    variables::Vector{T}  # Variables involved (can be strings or VariableRefs)
    coefficients::Vector{Int}  # Optional coefficients, empty if not needed
    expression::String  # For Expression type, empty if not used
end

# Simplified constructors with sensible defaults

"""
    MinimizeObjective(id, expr::String)

Create a minimization objective with an expression.

# Arguments
- `id`: Optional identifier for the objective, can be nothing
- `expr`: Expression string (e.g., "add(x,y)")
"""
function MinimizeObjective(id, expr::String)
    MinimizeObjective{String}(string(id), Expression, String[], Int[], expr)
end

"""
    MinimizeObjective(id, type::ObjectiveType, vars::Vector{T}) where {T}

Create a minimization objective with a specific type and variables.

# Arguments
- `id`: Optional identifier for the objective, can be nothing
- `type`: Type of the objective (Sum, Minimum, Maximum, NValues, Lex)
- `vars`: Vector of variables
"""
function MinimizeObjective(id, type::ObjectiveType, vars::Vector{T}) where {T}
    MinimizeObjective{T}(string(id), type, vars, Int[], "")
end

"""
    MinimizeObjective(id, type::ObjectiveType, vars)

Create a minimization objective with a specific type and variables (collection conversion).

# Arguments
- `id`: Optional identifier for the objective, can be nothing
- `type`: Type of the objective (Sum, Minimum, Maximum, NValues, Lex)
- `vars`: Collection of variables (will be converted to a vector)
"""
function MinimizeObjective(id, type::ObjectiveType, vars)
    MinimizeObjective(string(id), type, collect(vars), Int[], "")
end

"""
    MinimizeObjective(id, type::ObjectiveType, vars::Vector{T}, coeffs::Vector{Int}) where {T}

Create a minimization objective with a specific type, variables, and coefficients.

# Arguments
- `id`: Optional identifier for the objective, can be nothing
- `type`: Type of the objective (Sum, Minimum, Maximum, NValues, Lex)
- `vars`: Vector of variables
- `coeffs`: Vector of coefficients
"""
function MinimizeObjective(
        id, type::ObjectiveType, vars::Vector{T}, coeffs::Vector{Int},) where {T}
    MinimizeObjective{T}(string(id), type, vars, coeffs, "")
end

"""
    MinimizeObjective(id, type::ObjectiveType, vars, coeffs)

Create a minimization objective with a specific type, variables, and coefficients (collection conversion).

# Arguments
- `id`: Optional identifier for the objective, can be nothing
- `type`: Type of the objective (Sum, Minimum, Maximum, NValues, Lex)
- `vars`: Collection of variables (will be converted to a vector)
- `coeffs`: Collection of coefficients (will be converted to a vector)
"""
function MinimizeObjective(id, type::ObjectiveType, vars, coeffs)
    MinimizeObjective(string(id), type, collect(vars), collect(Int, coeffs), "")
end

"""
    MinimizeObjective(; id="", type=Expression, variables=[], coefficients=Int[], expression="")

Create a minimization objective with keyword arguments.

# Arguments
- `id`: Identifier for the objective, defaults to empty string
- `type`: Type of the objective, defaults to Expression
- `variables`: Collection of variables, defaults to empty vector
- `coefficients`: Collection of coefficients, defaults to empty vector
- `expression`: Expression string, defaults to empty string
"""
function MinimizeObjective(;
        id::Union{String, Nothing} = "",
        type::ObjectiveType = Expression,
        variables::Union{Vector, AbstractVector} = [],
        coefficients::Union{Vector{Int}, AbstractVector{<:Integer}} = Int[],
        expression::String = "",)
    id_str = id === nothing ? "" : string(id)
    vars = variables isa Vector ? variables : collect(variables)
    coeffs = coefficients isa Vector{Int} ? coefficients : collect(Int, coefficients)

    if type == Expression && !isempty(expression)
        return MinimizeObjective{String}(id_str, type, String[], Int[], expression)
    else
        return MinimizeObjective{eltype(vars)}(id_str, type, vars, coeffs, "")
    end
end

# Similar constructors for MaximizeObjective

"""
    MaximizeObjective(id, expr::String)

Create a maximization objective with an expression.

# Arguments
- `id`: Optional identifier for the objective, can be nothing
- `expr`: Expression string (e.g., "add(x,y)")
"""
function MaximizeObjective(id, expr::String)
    MaximizeObjective{String}(string(id), Expression, String[], Int[], expr)
end

"""
    MaximizeObjective(id, type::ObjectiveType, vars::Vector{T}) where {T}

Create a maximization objective with a specific type and variables.

# Arguments
- `id`: Optional identifier for the objective, can be nothing
- `type`: Type of the objective (Sum, Minimum, Maximum, NValues, Lex)
- `vars`: Vector of variables
"""
function MaximizeObjective(id, type::ObjectiveType, vars::Vector{T}) where {T}
    MaximizeObjective{T}(string(id), type, vars, Int[], "")
end

"""
    MaximizeObjective(id, type::ObjectiveType, vars)

Create a maximization objective with a specific type and variables (collection conversion).

# Arguments
- `id`: Optional identifier for the objective, can be nothing
- `type`: Type of the objective (Sum, Minimum, Maximum, NValues, Lex)
- `vars`: Collection of variables (will be converted to a vector)
"""
function MaximizeObjective(id, type::ObjectiveType, vars)
    MaximizeObjective(string(id), type, collect(vars), Int[], "")
end

"""
    MaximizeObjective(id, type::ObjectiveType, vars::Vector{T}, coeffs::Vector{Int}) where {T}

Create a maximization objective with a specific type, variables, and coefficients.

# Arguments
- `id`: Optional identifier for the objective, can be nothing
- `type`: Type of the objective (Sum, Minimum, Maximum, NValues, Lex)
- `vars`: Vector of variables
- `coeffs`: Vector of coefficients
"""
function MaximizeObjective(
        id, type::ObjectiveType, vars::Vector{T}, coeffs::Vector{Int},) where {T}
    MaximizeObjective{T}(string(id), type, vars, coeffs, "")
end

"""
    MaximizeObjective(id, type::ObjectiveType, vars, coeffs)

Create a maximization objective with a specific type, variables, and coefficients (collection conversion).

# Arguments
- `id`: Optional identifier for the objective, can be nothing
- `type`: Type of the objective (Sum, Minimum, Maximum, NValues, Lex)
- `vars`: Collection of variables (will be converted to a vector)
- `coeffs`: Collection of coefficients (will be converted to a vector)
"""
function MaximizeObjective(id, type::ObjectiveType, vars, coeffs)
    MaximizeObjective(string(id), type, collect(vars), collect(Int, coeffs), "")
end

"""
    MaximizeObjective(; id="", type=Expression, variables=[], coefficients=Int[], expression="")

Create a maximization objective with keyword arguments.

# Arguments
- `id`: Identifier for the objective, defaults to empty string
- `type`: Type of the objective, defaults to Expression
- `variables`: Collection of variables, defaults to empty vector
- `coefficients`: Collection of coefficients, defaults to empty vector
- `expression`: Expression string, defaults to empty string
"""
function MaximizeObjective(;
        id::Union{String, Nothing} = "",
        type::ObjectiveType = Expression,
        variables::Union{Vector, AbstractVector} = [],
        coefficients::Union{Vector{Int}, AbstractVector{<:Integer}} = Int[],
        expression::String = "",)
    id_str = id === nothing ? "" : string(id)
    vars = variables isa Vector ? variables : collect(variables)
    coeffs = coefficients isa Vector{Int} ? coefficients : collect(Int, coefficients)

    if type == Expression && !isempty(expression)
        return MaximizeObjective{String}(id_str, type, String[], Int[], expression)
    else
        return MaximizeObjective{eltype(vars)}(id_str, type, vars, coeffs, "")
    end
end

## SECTION - Test items

@testitem "MinimizeObjective" tags=[:objectives, :minimize] begin
    import XCSP3: MinimizeObjective, Expression, Sum, Minimum, VariableRef

    # Test expression form
    @test begin
        obj = MinimizeObjective(nothing, "add(x,y)")
        obj.type == Expression && obj.expression == "add(x,y)"
    end

    # Test sum form
    @test begin
        obj = MinimizeObjective(nothing, Sum, ["x", "y", "z"], [2, 4, 1])
        obj.type == Sum && length(obj.variables) == 3 && obj.coefficients == [2, 4, 1]
    end

    # Test minimum form without coefficients
    @test begin
        obj = MinimizeObjective(nothing, Minimum, ["x", "y", "z"])
        obj.type == Minimum && length(obj.variables) == 3 && isempty(obj.coefficients)
    end

    # Test with variable references
    @test begin
        obj = MinimizeObjective(
            "obj1", Sum, [VariableRef("arr", [0]), VariableRef("arr", [1])], [1, 2],)
        obj.id == "obj1" && obj.type == Sum && length(obj.variables) == 2 &&
            obj.coefficients == [1, 2]
    end

    # Test keyword argument constructor with expression
    @test begin
        obj = MinimizeObjective(
            id = "obj2",
            type = Expression,
            expression = "add(x,y,z)",
        )
        obj.id == "obj2" &&
            obj.type == Expression &&
            obj.expression == "add(x,y,z)" &&
            isempty(obj.variables) &&
            isempty(obj.coefficients)
    end

    # Test keyword argument constructor with variables and coefficients
    @test begin
        obj = MinimizeObjective(
            id = "obj3",
            type = Sum,
            variables = ["x", "y", "z"],
            coefficients = [1, 2, 3],
        )
        obj.id == "obj3" &&
            obj.type == Sum &&
            obj.variables == ["x", "y", "z"] &&
            obj.coefficients == [1, 2, 3] &&
            obj.expression == ""
    end

    # Test keyword argument constructor with nothing id
    @test begin
        obj = MinimizeObjective(
            id = nothing,
            type = Minimum,
            variables = ["a", "b"],
        )
        obj.id == "" &&
            obj.type == Minimum &&
            obj.variables == ["a", "b"] &&
            isempty(obj.coefficients)
    end
end

@testitem "MaximizeObjective" tags=[:objectives, :maximize] begin
    import XCSP3: MaximizeObjective, Expression, Sum, Maximum, VariableRef

    # Test expression form
    @test begin
        obj = MaximizeObjective(nothing, "add(x,y)")
        obj.type == Expression && obj.expression == "add(x,y)"
    end

    # Test sum form
    @test begin
        obj = MaximizeObjective(nothing, Sum, ["x", "y", "z"], [2, 4, 1])
        obj.type == Sum && length(obj.variables) == 3 && obj.coefficients == [2, 4, 1]
    end

    # Test maximum form without coefficients
    @test begin
        obj = MaximizeObjective(nothing, Maximum, ["x", "y", "z"])
        obj.type == Maximum && length(obj.variables) == 3 && isempty(obj.coefficients)
    end

    # Test with variable references
    @test begin
        obj = MaximizeObjective(
            "obj1", Sum, [VariableRef("arr", [0]), VariableRef("arr", [1])], [1, 2],)
        obj.id == "obj1" && obj.type == Sum && length(obj.variables) == 2 &&
            obj.coefficients == [1, 2]
    end

    # Test keyword argument constructor with expression
    @test begin
        obj = MaximizeObjective(
            id = "obj2",
            type = Expression,
            expression = "add(x,y,z)",
        )
        obj.id == "obj2" &&
            obj.type == Expression &&
            obj.expression == "add(x,y,z)" &&
            isempty(obj.variables) &&
            isempty(obj.coefficients)
    end

    # Test keyword argument constructor with variables and coefficients
    @test begin
        obj = MaximizeObjective(
            id = "obj3",
            type = Sum,
            variables = ["x", "y", "z"],
            coefficients = [1, 2, 3],
        )
        obj.id == "obj3" &&
            obj.type == Sum &&
            obj.variables == ["x", "y", "z"] &&
            obj.coefficients == [1, 2, 3] &&
            obj.expression == ""
    end

    # Test keyword argument constructor with variable references
    @test begin
        obj = MaximizeObjective(
            id = "obj4",
            type = Maximum,
            variables = [VariableRef("arr", [0]), VariableRef("arr", [1])],
        )
        obj.id == "obj4" &&
            obj.type == Maximum &&
            length(obj.variables) == 2 &&
            isempty(obj.coefficients)
    end
end
