# constraints/regular.jl

"""
    RegularConstraint{T}

Represents a regular constraint in XCSP3, which ensures that the sequence of values
taken by a list of variables belongs to a regular language.

XML Structure:
```xml
<regular>
    <list> x1 x2 x3 </list>
    <transitions>
        (q0,0,q1)(q0,1,q2)
        (q1,0,q2)(q1,1,q1)
        (q2,0,q0)(q2,1,q2)
    </transitions>
    <start> q0 </start>
    <final> q1 q2 </final>
</regular>
```

The constraint defines a deterministic finite automaton (DFA) where:
- transitions: list of triples (start_state, value, end_state)
- start: initial state
- final: list of accepting states

Example:
```julia
# Define a DFA accepting strings where no two consecutive 1's appear
RegularConstraint(
    variables = ["x", "y", "z"],
    transitions = [
        ("q0", 0, "q0"),  # Stay in q0 on 0
        ("q0", 1, "q1"),  # Go to q1 on 1
        ("q1", 0, "q0"),  # Back to q0 on 0
        ("q1", 1, "q2"),  # Go to trap state q2 on 1
        ("q2", 0, "q2"),  # Stay in trap state
        ("q2", 1, "q2"),  # Stay in trap state
    ],
    start = "q0",
    final = ["q0", "q1"]  # Accept if not in trap state
)
```
"""
struct RegularConstraint{T} <: AbstractConstraint
    id::String  # Optional ID, empty string if not provided
    variables::Vector{T}  # Variables involved
    transitions::Vector{Tuple{String, Int, String}}  # (start_state, value, end_state)
    start::String  # Start state
    final::Vector{String}  # Final states
end

"""
    validate_automaton(transitions, start, final)

Validates that the automaton definition follows XCSP3 specifications:
- All states in transitions must be valid strings
- All values in transitions must be integers
- Start state must exist in transitions
- Final states must exist in transitions
- Automaton must be deterministic (no duplicate (state, value) pairs)
"""
function validate_automaton(transitions::Vector{Tuple{String, Int, String}},
        start::String, final::Vector{String},)
    # Collect all states
    states = Set{String}()
    for (s1, _, s2) in transitions
        push!(states, s1, s2)
    end

    # Validate start state
    @assert start in states "Start state '$start' not found in transitions"

    # Validate final states
    for state in final
        @assert state in states "Final state '$state' not found in transitions"
    end

    # Check determinism
    seen = Set{Tuple{String, Int}}()
    for (s1, val, _) in transitions
        key = (s1, val)
        @assert !(key in seen) "Non-deterministic transition found: state='$s1', value=$val"
        push!(seen, key)
    end
end

# Constructor with proper type parameters
function RegularConstraint(
        id::Union{String, Nothing}, vars::Vector{T},
        transitions::Vector{Tuple{String, Int, String}},
        start::AbstractString, final::Vector{String},) where {T}
    # Basic validation
    @assert !isempty(vars) "Variables list cannot be empty"
    @assert !isempty(transitions) "Transitions list cannot be empty"
    @assert !isempty(final) "Final states list cannot be empty"

    # Validate automaton structure
    validate_automaton(transitions, string(start), final)

    # Create the constraint
    return RegularConstraint{T}(
        isnothing(id) ? "" : string(id),
        vars,
        transitions,
        string(start),
        final,
    )
end

# Constructor with collection conversion
function RegularConstraint(
        id::Union{String, Nothing}, vars, transitions::Vector{<:Tuple},
        start::AbstractString, final,)
    # Convert variables to vector
    vars_vec = collect(vars)

    # Convert transitions to the right format
    trans = Vector{Tuple{String, Int, String}}()
    for t in transitions
        @assert length(t)==3 "Each transition must be a triple (start_state, value, end_state)"
        push!(trans, (string(t[1]), Int(t[2]), string(t[3])))
    end

    # Convert final states to vector of strings
    final_vec = [string(f) for f in final]

    # Call the typed constructor
    return RegularConstraint(id, vars_vec, trans, start, final_vec)
end

# Constructor with keyword arguments matching XML structure
function RegularConstraint(;
        id::Union{String, Nothing} = nothing,
        variables::Union{Vector, AbstractVector},
        transitions::Vector{<:Tuple},
        start::AbstractString,
        final::Union{Vector, AbstractVector},)
    # Call the collection conversion constructor
    return RegularConstraint(id, variables, transitions, start, final)
end

## SECTION - Test items

@testitem "RegularConstraint" tags=[:constraints, :regular] begin
    import XCSP3: RegularConstraint

    # Test basic constraint
    @test begin
        ctr = RegularConstraint(
            variables = ["x", "y", "z"],
            transitions = [
                ("q0", 0, "q1"), ("q0", 1, "q2"),
                ("q1", 0, "q2"), ("q1", 1, "q1"),
                ("q2", 0, "q0"), ("q2", 1, "q2"),
            ],
            start = "q0",
            final = ["q1", "q2"],
        )
        ctr.id == "" &&
            length(ctr.variables) == 3 &&
            length(ctr.transitions) == 6 &&
            ctr.start == "q0" &&
            ctr.final == ["q1", "q2"]
    end

    # Test with ID
    @test begin
        ctr = RegularConstraint(
            id = "c1",
            variables = ["x", "y", "z"],
            transitions = [("q0", 0, "q1"), ("q0", 1, "q2")],
            start = "q0",
            final = ["q1"],
        )
        ctr.id == "c1" &&
            length(ctr.variables) == 3 &&
            length(ctr.transitions) == 2 &&
            ctr.start == "q0" &&
            ctr.final == ["q1"]
    end

    # Test validation errors
    @test_throws AssertionError RegularConstraint(
        variables = String[],  # Empty variables
        transitions = [("q0", 0, "q1")],
        start = "q0",
        final = ["q1"],
    )

    @test_throws AssertionError RegularConstraint(
        variables = ["x"],
        transitions = Vector{Tuple{String, Int, String}}(),  # Empty transitions
        start = "q0",
        final = ["q1"],
    )

    @test_throws AssertionError RegularConstraint(
        variables = ["x"],
        transitions = [("q0", 0, "q1")],
        start = "q0",
        final = String[],  # Empty final states
    )

    @test_throws AssertionError RegularConstraint(
        variables = ["x"],
        transitions = [("q0", 0, "q1")],
        start = "invalid",  # Invalid start state
        final = ["q1"],
    )

    @test_throws AssertionError RegularConstraint(
        variables = ["x"],
        transitions = [("q0", 0, "q1")],
        start = "q0",
        final = ["invalid"],  # Invalid final state
    )

    @test_throws AssertionError RegularConstraint(
        variables = ["x"],
        transitions = [
            ("q0", 0, "q1"),
            ("q0", 0, "q2"),  # Non-deterministic
        ],
        start = "q0",
        final = ["q1", "q2"],
    )
end
