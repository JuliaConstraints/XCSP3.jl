using XCSP3
using Test
using Aqua
using JET

@testset "XCSP3.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(XCSP3)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(XCSP3; target_defined_modules = true)
    end
    # Write your tests here.
end
