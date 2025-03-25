# variable.jl

"""
AbstractVariable is the supertype for all variables in XCSP3.
"""
abstract type AbstractVariable end

"""
Represents a single value or interval in a domain.
"""
const DomainValue = Union{Int, Tuple{Int, Int}}  # Single value or interval

"""
Represents a domain as a collection of values and/or intervals.
"""
const Domain = Vector{DomainValue}

"""
Represents an integer variable in XCSP3.
"""
struct IntegerVariable <: AbstractVariable
    id::String
    domain::Domain
end

"""
Represents an array of variables in XCSP3.
"""
struct VariableArray <: AbstractVariable
    id::String
    size::Vector{Int}  # Dimensions: [n] for 1D, [n, m] for 2D, etc.
    domains::Dict{String, Domain}  # Maps variable specifiers to domains
    default_domain::Union{Domain, Nothing}  # Domain for "others"
end

"""
Represents a reference to a variable in an array.
"""
struct VariableRef
    array_id::String
    indices::Vector{Int}
end

## SECTION - Test items

@testitem "IntegerVariable" tags=[:variables, :integer] begin
    import XCSP3: IntegerVariable

    # Test IntegerVariable with individual values
    @test begin
        var = IntegerVariable("x", [1, 2, 3])
        var.id == "x" && var.domain == [1, 2, 3]
    end

    # Test IntegerVariable with interval
    @test begin
        var = IntegerVariable("y", [(1, 5)])
        var.id == "y" && var.domain == [(1, 5)]
    end

    # Test IntegerVariable with mixed domain
    @test begin
        var = IntegerVariable("z", [1, (3, 5), 7])
        var.id == "z" && var.domain == [1, (3, 5), 7]
    end
end

@testitem "VariableArray" tags=[:variables, :array] begin
    import XCSP3: VariableArray, Domain

    # Test 1D array with specific domains for each element
    @test begin
        arr = VariableArray("arr1", [3],
            Dict("arr1[0]" => [1, 2, 3],
                "arr1[1]" => [4, 5, 6],
                "arr1[2]" => [7, 8, 9],),
            Domain[],)
        arr.id == "arr1" &&
            arr.size == [3] &&
            arr.domains["arr1[0]"] == [1, 2, 3] &&
            arr.domains["arr1[1]"] == [4, 5, 6] &&
            arr.domains["arr1[2]"] == [7, 8, 9] &&
            isempty(arr.default_domain)
    end

    # Test 2D array with only default domain
    @test begin
        arr = VariableArray("arr2", [2, 2], Dict(), [(1, 10)])
        arr.id == "arr2" &&
            arr.size == [2, 2] &&
            isempty(arr.domains) &&
            arr.default_domain == [(1, 10)]
    end

    # Test 2D array with row-specific domains
    @test begin
        arr = VariableArray("arr3", [2, 3],
            Dict("arr3[0][]" => [1, 2, 3], "arr3[1][]" => [4, 5, 6]),
            Domain[],)
        arr.id == "arr3" &&
            arr.size == [2, 3] &&
            arr.domains["arr3[0][]"] == [1, 2, 3] &&
            arr.domains["arr3[1][]"] == [4, 5, 6] &&
            isempty(arr.default_domain)
    end
end

@testitem "VariableRef" tags=[:variables, :ref] begin
    import XCSP3: VariableRef

    # Test reference to 1D array
    @test begin
        ref = VariableRef("arr", [0])
        ref.array_id == "arr" && ref.indices == [0]
    end

    # Test reference to 2D array
    @test begin
        ref = VariableRef("matrix", [1, 2])
        ref.array_id == "matrix" && ref.indices == [1, 2]
    end

    # Test reference to 3D array
    @test begin
        ref = VariableRef("cube", [0, 1, 2])
        ref.array_id == "cube" && ref.indices == [0, 1, 2]
    end
end
