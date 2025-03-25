# constraints/intension.jl

"""
    IntensionConstraint

Represents an intension constraint in XCSP3, defined by a Boolean expression.

XML Structure:
```xml
<intension>
<function> boolExpr </function>
</intension>
```

Note that the opening and closing tags for <function> are optional, which gives:
```xml
<intension> boolExpr </intension>
```

The function expression must follow XCSP3 functional notation:
- Operators: eq, ne, lt, le, gt, ge, not, and, or, xor, iff, imp
- Functions: add, sub, mul, div, mod, sqr, neg, abs, min, max, dist
- Variables: referenced directly by name
- Constants: integers

Example:
```julia
# Using the _function keyword (matching full XML syntax)
IntensionConstraint(id="c1", _function="eq(add(x,y),z)")  # x + y = z with ID "c1"

# Using direct expression (matching simplified XML syntax)
IntensionConstraint("c2", "lt(x,y)")  # x < y with ID "c2"

# Without ID
IntensionConstraint(nothing, "eq(add(x,y),z)")  # x + y = z without ID
```
"""
struct IntensionConstraint <: AbstractConstraint
    id::String  # Optional ID, empty string if not provided
    expression::String  # Boolean expression in functional form

    # Inner constructor
    function IntensionConstraint(id::String, expression::String)
        @assert !isempty(expression) "Function expression cannot be empty"
        return new(id, expression)
    end
end

# Constructor for simplified syntax (direct expression)
function IntensionConstraint(id::Union{String, Nothing}, expression::String)
    # Create the constraint
    return IntensionConstraint(isnothing(id) ? "" : string(id), expression)
end

# External constructor with keyword arguments matching XML structure
function IntensionConstraint(;
        id::Union{String, Nothing} = nothing,
        _function::String,  # Parameter matching XML tag (with underscore)
)
    # Call the constructor
    return IntensionConstraint(id, _function)
end

## SECTION - Test items

@testitem "IntensionConstraint" tags=[:constraints, :intension] begin
    import XCSP3: IntensionConstraint

    # Test examples from XCSP3 specification

    # Example with function tag:
    # <intension id="c1">
    # <function> eq(add(x,y),z) </function>
    # </intension>
    @test begin
        ctr = IntensionConstraint(id = "c1", _function = "eq(add(x,y),z)")
        ctr.id == "c1" && ctr.expression == "eq(add(x,y),z)"
    end

    # Example with function tag:
    # <intension id="c2">
    # <function> ge(w,z) </function>
    # </intension>
    @test begin
        ctr = IntensionConstraint(id = "c2", _function = "ge(w,z)")
        ctr.id == "c2" && ctr.expression == "ge(w,z)"
    end

    # Example in simplified form:
    # <intension id="c1"> eq(add(x,y),z) </intension>
    @test begin
        ctr = IntensionConstraint("c1", "eq(add(x,y),z)")
        ctr.id == "c1" && ctr.expression == "eq(add(x,y),z)"
    end

    # Example in simplified form:
    # <intension id="c2"> ge(w,z) </intension>
    @test begin
        ctr = IntensionConstraint("c2", "ge(w,z)")
        ctr.id == "c2" && ctr.expression == "ge(w,z)"
    end
end
