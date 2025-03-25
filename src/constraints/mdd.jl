# constraints/mdd.jl

"""
    MDDConstraint{T}

Represents an MDD (Multi-valued Decision Diagram) constraint in XCSP3, which ensures that
the sequence of values taken by a list of variables corresponds to a path in a multi-valued
decision diagram.

XML Structure:
```xml
<mdd>
    <list> x1 x2 x3 </list>
    <transitions>
        (r,0,n1)(r,1,n2)
        (n1,0,n3)(n1,1,n4)
        (n2,0,n4)(n2,1,n5)
        (n3,0,t)(n3,1,t)
        (n4,0,t)(n4,1,t)
        (n5,0,t)(n5,1,t)
    </transitions>
    <root> r </root>
    <terminal> t </terminal>
</mdd>
```

The constraint defines a Multi-valued Decision Diagram (MDD) where:
- transitions: list of triples (source_node, value, destination_node)
- root: starting node of the MDD
- terminal: ending node of the MDD

Each path from root to terminal represents a valid assignment to the variables.

Example:
```julia
# Define an MDD for a simple binary constraint
MDDConstraint(
    variables = ["x", "y"],
    transitions = [
        ("r", 0, "n1"),   # From root, on value 0 go to n1
        ("r", 1, "n2"),   # From root, on value 1 go to n2
        ("n1", 0, "t"),   # From n1, on value 0 go to terminal
        ("n2", 1, "t"),   # From n2, on value 1 go to terminal
    ],
    root = "r",
    terminal = "t"
)
```
"""
struct MDDConstraint{T} <: AbstractConstraint
    id::String  # Optional ID, empty string if not provided
    variables::Vector{T}  # Variables involved
    transitions::Vector{Tuple{String, Int, String}}  # (source_node, value, destination_node)
    root::String  # Root node
    terminal::String  # Terminal node
end

"""
    validate_mdd(transitions, root, terminal)

Validates that the MDD definition follows XCSP3 specifications:
- All nodes in transitions must be valid strings
- All values in transitions must be integers
- Root node must exist as a source node in transitions
- Terminal node must exist as a destination node in transitions
- Each node level must have consistent variable domains
"""
function validate_mdd(
        transitions::Vector{Tuple{String, Int, String}}, root::String, terminal::String,)
    # Collect all nodes and their roles
    source_nodes = Set{String}()
    dest_nodes = Set{String}()
    node_values = Dict{String, Set{Int}}()  # Values leaving each node

    for (src, val, dst) in transitions
        push!(source_nodes, src)
        push!(dest_nodes, dst)
        if !haskey(node_values, src)
            node_values[src] = Set{Int}()
        end
        push!(node_values[src], val)
    end

    # Validate root node
    @assert root in source_nodes "Root node '$root' not found as a source in transitions"
    @assert !(root in dest_nodes) "Root node '$root' cannot be a destination node"

    # Validate terminal node
    @assert terminal in dest_nodes "Terminal node '$terminal' not found as a destination in transitions"
    @assert !(terminal in source_nodes) "Terminal node '$terminal' cannot be a source node"

    # Validate node levels have consistent domains
    # Each node at the same level should have the same set of possible values
    level_nodes = Dict{Int, Set{String}}()
    level_values = Dict{Int, Set{Int}}()

    # Start with root at level 0
    level_nodes[0] = Set([root])
    current_level = 0

    while !isempty(level_nodes[current_level])
        next_nodes = Set{String}()
        level_values[current_level] = Set{Int}()

        # Collect all values and destinations for current level
        for node in level_nodes[current_level]
            if haskey(node_values, node)
                union!(level_values[current_level], node_values[node])
                for (src, val, dst) in transitions
                    if src == node && dst != terminal
                        push!(next_nodes, dst)
                    end
                end
            end
        end

        # Validate consistent values at this level
        for node in level_nodes[current_level]
            if haskey(node_values, node)
                @assert node_values[node]==level_values[current_level] "Node '$node' has inconsistent values with other nodes at same level"
            end
        end

        # Set up next level
        if !isempty(next_nodes)
            current_level += 1
            level_nodes[current_level] = next_nodes
        else
            break
        end
    end
end

# Constructor with proper type parameters
function MDDConstraint(
        id::Union{String, Nothing}, vars::Vector{T},
        transitions::Vector{Tuple{String, Int, String}},
        root::AbstractString, terminal::AbstractString,) where {T}
    # Basic validation
    @assert !isempty(vars) "Variables list cannot be empty"
    @assert !isempty(transitions) "Transitions list cannot be empty"

    # Validate MDD structure
    validate_mdd(transitions, string(root), string(terminal))

    # Create the constraint
    return MDDConstraint{T}(
        isnothing(id) ? "" : string(id),
        vars,
        transitions,
        string(root),
        string(terminal),
    )
end

# Constructor with collection conversion
function MDDConstraint(
        id::Union{String, Nothing}, vars, transitions::Vector{<:Tuple},
        root::AbstractString, terminal::AbstractString,)
    # Convert variables to vector
    vars_vec = collect(vars)

    # Convert transitions to the right format
    trans = Vector{Tuple{String, Int, String}}()
    for t in transitions
        @assert length(t)==3 "Each transition must be a triple (source_node, value, destination_node)"
        push!(trans, (string(t[1]), Int(t[2]), string(t[3])))
    end

    # Call the typed constructor
    return MDDConstraint(id, vars_vec, trans, root, terminal)
end

# Constructor with keyword arguments matching XML structure
function MDDConstraint(;
        id::Union{String, Nothing} = nothing,
        variables::Union{Vector, AbstractVector},
        transitions::Vector{<:Tuple},
        root::AbstractString,
        terminal::AbstractString,)
    # Call the collection conversion constructor
    return MDDConstraint(id, variables, transitions, root, terminal)
end

## SECTION - Test items

@testitem "MDDConstraint" tags=[:constraints, :mdd] begin
    import XCSP3: MDDConstraint

    # Test basic constraint
    @test begin
        ctr = MDDConstraint(
            variables = ["x", "y", "z"],
            transitions = [
                ("r", 0, "n1"), ("r", 1, "n2"),
                ("n1", 0, "n3"), ("n1", 1, "n4"),
                ("n2", 0, "n4"), ("n2", 1, "n5"),
                ("n3", 0, "t"), ("n3", 1, "t"),
                ("n4", 0, "t"), ("n4", 1, "t"),
                ("n5", 0, "t"), ("n5", 1, "t"),
            ],
            root = "r",
            terminal = "t",
        )
        ctr.id == "" &&
            length(ctr.variables) == 3 &&
            length(ctr.transitions) == 12 &&
            ctr.root == "r" &&
            ctr.terminal == "t"
    end

    # Test with ID
    @test begin
        ctr = MDDConstraint(
            id = "c1",
            variables = ["x", "y"],
            transitions = [
                ("r", 0, "n1"),
                ("r", 1, "n2"),
                ("n1", 0, "t"),
                ("n2", 1, "t"),
            ],
            root = "r",
            terminal = "t",
        )
        ctr.id == "c1" &&
            length(ctr.variables) == 2 &&
            length(ctr.transitions) == 4 &&
            ctr.root == "r" &&
            ctr.terminal == "t"
    end

    # Test validation errors
    @test_throws AssertionError MDDConstraint(
        variables = String[],  # Empty variables
        transitions = [("r", 0, "t")],
        root = "r",
        terminal = "t",
    )

    @test_throws AssertionError MDDConstraint(
        variables = ["x"],
        transitions = Vector{Tuple{String, Int, String}}(),  # Empty transitions
        root = "r",
        terminal = "t",
    )

    @test_throws AssertionError MDDConstraint(
        variables = ["x"],
        transitions = [("r", 0, "t")],
        root = "invalid",  # Invalid root node
        terminal = "t",
    )

    @test_throws AssertionError MDDConstraint(
        variables = ["x"],
        transitions = [("r", 0, "t")],
        root = "r",
        terminal = "invalid",  # Invalid terminal node
    )

    @test_throws AssertionError MDDConstraint(
        variables = ["x", "y"],
        transitions = [
            ("r", 0, "n1"),
            ("r", 1, "n2"),
            ("n1", 0, "t"),
            ("n2", 2, "t"),  # Inconsistent values at same level
        ],
        root = "r",
        terminal = "t",
    )

    @test_throws AssertionError MDDConstraint(
        variables = ["x"],
        transitions = [
            ("r", 0, "t"),
            ("t", 1, "r"),  # Terminal cannot be a source
        ],
        root = "r",
        terminal = "t",
    )
end
