# constraints/extension.jl

"""
    ExtensionConstraint{T1, T2}

Represents an extension constraint in XCSP3, defined by a list of variables and tuples.

XML Structure for non-unary positive table constraints:
```xml
<extension>
<list> (intVar wspace)2+ </list>
<supports> ("(" intVal ("," intVal)+ ")")* </supports>
</extension>
```

XML Structure for non-unary negative table constraints:
```xml
<extension>
<list> (intVar wspace)2+ </list>
<conflicts> ("(" intVal ("," intVal)+ ")")* </conflicts>
</extension>
```

XML Structure for unary positive table constraints:
```xml
<extension>
<list> intVar </list>
<supports> ((intVal | intIntvl) wspace)* </supports>
</extension>
```

XML Structure for unary negative table constraints:
```xml
<extension>
<list> intVar </list>
<conflicts> ((intVal | intIntvl) wspace)* </conflicts>
</extension>
```

Examples:
```julia
# Ternary constraint with supports (Example 26 from XCSP3 spec)
# <extension id="c1">
# <list> x1 x2 x3 </list>
# <supports> (0,1,0)(1,0,0)(1,1,0)(1,1,1) </supports>
# </extension>
ExtensionConstraint(
    id = "c1",
    list = ["x1", "x2", "x3"],
    supports = [[0, 1, 0], [1, 0, 0], [1, 1, 0], [1, 1, 1]]
)

# Quaternary constraint with conflicts (Example 26 from XCSP3 spec)
# <extension id="c2">
# <list> y1 y2 y3 y4 </list>
# <conflicts> (1,2,3,4)(3,1,3,4) </conflicts>
# </extension>
ExtensionConstraint(
    id = "c2",
    list = ["y1", "y2", "y3", "y4"],
    conflicts = [[1, 2, 3, 4], [3, 1, 3, 4]]
)

# Unary constraint with supports (Example 27 from XCSP3 spec)
# <extension id="c3">
# <list> x </list>
# <supports> 1 2 4 8..10 </supports>
# </extension>
ExtensionConstraint(
    id = "c3",
    list = ["x"],
    supports = [1, 2, 4, 8, 9, 10]  # Note: Intervals expanded to individual values
)

# Short table constraint (Example 28 from XCSP3 spec)
# <extension id="c4">
# <list> z1 z2 z3 z4 </list>
# <supports> (1,*,1,2)(2,1,*,*) </supports>
# </extension>
ExtensionConstraint(
    id = "c4",
    list = ["z1", "z2", "z3", "z4"],
    supports = [[1, "*", 1, 2], [2, 1, "*", "*"]]  # "*" represents any value
)
```
"""
struct ExtensionConstraint{T1, T2, T3} <: AbstractConstraint
    id::String  # Optional ID, empty string if not provided
    list::Vector{T1}  # Variables involved
    supports::Vector{T2}  # List of support tuples (can be empty)
    conflicts::Vector{T3}  # List of conflict tuples (can be empty)
end

# Constructor for non-unary constraints with supports
function ExtensionConstraint(;
        id::AbstractString = "",
        list::Vector,
        supports = Vector{Vector{Number}}(),
        conflicts = Vector{Vector{Number}}(),
)
    sup = supports isa Vector ? supports : Vector(supports)
    conf = conflicts isa Vector ? conflicts : Vector(conflicts)
    T1, T2, T3 = eltype(list), eltype(sup), eltype(conf)
    return ExtensionConstraint{T1, T2, T3}(id, list, sup, conf)
end

## SECTION - Test items

@testitem "ExtensionConstraint" tags=[:constraints, :extension] begin
    import XCSP3: ExtensionConstraint

    # Test examples from XCSP3 specification

    # Example 26: Ternary constraint with supports
    # <extension id="c1">
    # <list> x1 x2 x3 </list>
    # <supports> (0,1,0)(1,0,0)(1,1,0)(1,1,1) </supports>
    # </extension>
    @test begin
        ctr = ExtensionConstraint(;
            id = "c1",
            list = ["x1", "x2", "x3"],
            supports = [[0, 1, 0], [1, 0, 0], [1, 1, 0], [1, 1, 1]],
        )
        ctr.id == "c1" &&
            ctr.list == ["x1", "x2", "x3"] &&
            length(ctr.supports) == 4 &&
            isempty(ctr.conflicts)
    end

    # Example 26: Quaternary constraint with conflicts
    # <extension id="c2">
    # <list> y1 y2 y3 y4 </list>
    # <conflicts> (1,2,3,4)(3,1,3,4) </conflicts>
    # </extension>
    @test begin
        ctr = ExtensionConstraint(;
            id = "c2",
            list = ["y1", "y2", "y3", "y4"],
            conflicts = [[1, 2, 3, 4], [3, 1, 3, 4]],
        )
        ctr.id == "c2" &&
            ctr.list == ["y1", "y2", "y3", "y4"] &&
            isempty(ctr.supports) &&
            length(ctr.conflicts) == 2
    end

    # Example 27: Unary constraint with supports
    # <extension id="c3">
    # <list> x </list>
    # <supports> 1 2 4 8..10 </supports>
    # </extension>
    @test begin
        ctr = ExtensionConstraint(;
            id = "c3",
            list = ["x"],
            supports = [1, 2, 4, 8, 9, 10],  # Note: Intervals expanded to individual values
        )
        ctr.id == "c3" &&
            ctr.list == ["x"] &&
            length(ctr.supports) == 6 &&
            isempty(ctr.conflicts)
    end

    # Example 28: Short table constraint
    # <extension id="c4">
    # <list> z1 z2 z3 z4 </list>
    # <supports> (1,*,1,2)(2,1,*,*) </supports>
    # </extension>
    @test begin
        ctr = ExtensionConstraint(;
            id = "c4",
            list = ["z1", "z2", "z3", "z4"],
            supports = [[1, "*", 1, 2], [2, 1, "*", "*"]],  # "*" represents any value
        )
        ctr.id == "c4" &&
            ctr.list == ["z1", "z2", "z3", "z4"] &&
            length(ctr.supports) == 2 &&
            isempty(ctr.conflicts)
    end
end
