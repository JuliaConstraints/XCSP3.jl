"""
    Instance

Represents an XCSP3 instance with variables, constraints, objectives, and annotations.

# Fields
- `format`: The format of the instance (e.g., "XCSP3")
- `type`: The framework type of the instance
- `variables`: Collection of variables in the instance
- `constraints`: Collection of constraints in the instance
- `objectives`: Optional collection of objectives (minimize/maximize)
- `annotations`: Optional annotations information
"""
struct Instance
    format::String
    type::String
    variables::Vector{AbstractVariable}
    constraints::Vector{AbstractConstraint}
    objectives::Union{Vector{AbstractObjective}, Nothing}
    annotations::Union{Dict{String, Any}, Nothing}

    # Inner constructor with all fields
    function Instance(format::String, type::String,
            variables::Vector{AbstractVariable},
            constraints::Vector{AbstractConstraint},
            objectives::Union{Vector{AbstractObjective}, Nothing},
            annotations::Union{Dict{String, Any}, Nothing},)
        new(format, type, variables, constraints, objectives, annotations)
    end

    # Inner constructor with required fields only
    function Instance(format::String, type::String,
            variables::Vector{AbstractVariable},
            constraints::Vector{AbstractConstraint},)
        new(format, type, variables, constraints, nothing, nothing)
    end
end

# Outer constructor with keyword arguments
"""
    Instance(; format="XCSP3", type="", variables=AbstractVariable[],
              constraints=AbstractConstraint[], objectives=nothing, annotations=nothing)

Create an XCSP3 instance with the specified parameters.

# Arguments
- `format`: The format of the instance, defaults to "XCSP3"
- `type`: The framework type of the instance
- `variables`: Collection of variables in the instance
- `constraints`: Collection of constraints in the instance
- `objectives`: Optional collection of objectives (minimize/maximize)
- `annotations`: Optional annotations information
"""
function Instance(;
        format::String = "XCSP3",
        type::String = "",
        variables::Vector{<:AbstractVariable} = AbstractVariable[],
        constraints::Vector{<:AbstractConstraint} = AbstractConstraint[],
        objectives::Union{Vector{<:AbstractObjective}, Nothing} = nothing,
        annotations::Union{Dict{String, Any}, Nothing} = nothing,)
    Instance(format, type, variables, constraints, objectives, annotations)
end

# Convenience constructor for creating an instance with variables only
function Instance(format::String, type::String, variables::Vector{AbstractVariable})
    Instance(format, type, variables, AbstractConstraint[])
end

#SECTION - Test items # FIXME - constructor and types
# @testitem "Instance creation" tags=[:instance] begin
#     import XCSP3: Instance, IntegerVariable, AbstractVariable, AbstractConstraint,
#                   AbstractObjective

#     # Test creating an instance with required fields only
#     @test begin
#         vars = [IntegerVariable("x", [1, 2, 3]), IntegerVariable("y", [(1, 5)])]
#         instance = Instance("XCSP3", "CSP", vars, AbstractConstraint[])

#         instance.format == "XCSP3" &&
#             instance.type == "CSP" &&
#             length(instance.variables) == 2 &&
#             isempty(instance.constraints) &&
#             instance.objectives === nothing &&
#             instance.annotations === nothing
#     end

#     # Test creating an instance with keyword arguments
#     @test begin
#         vars = [IntegerVariable("x", [1, 2, 3])]
#         instance = Instance(
#             format = "XCSP3",
#             type = "COP",
#             variables = vars,
#             constraints = AbstractConstraint[],
#         )

#         instance.format == "XCSP3" &&
#             instance.type == "COP" &&
#             length(instance.variables) == 1 &&
#             isempty(instance.constraints)
#     end

#     # Test creating an instance with all fields
#     @test begin
#         vars = [IntegerVariable("x", [1, 2, 3])]
#         objectives = Vector{AbstractObjective}()  # Empty but typed vector
#         annotations = Dict("source" => "test", "date" => "2023-01-01")

#         instance = Instance(
#             format = "XCSP3",
#             type = "COP",
#             variables = vars,
#             constraints = AbstractConstraint[],
#             objectives = objectives,
#             annotations = annotations,
#         )

#         instance.format == "XCSP3" &&
#             instance.type == "COP" &&
#             length(instance.variables) == 1 &&
#             isempty(instance.constraints) &&
#             instance.objectives === objectives &&
#             instance.annotations === annotations
#     end

#     # Test convenience constructor with variables only
#     @test begin
#         vars = [IntegerVariable("x", [1, 2, 3])]
#         instance = Instance("XCSP3", "CSP", vars)

#         instance.format == "XCSP3" &&
#             instance.type == "CSP" &&
#             length(instance.variables) == 1 &&
#             isempty(instance.constraints)
#     end
# end
