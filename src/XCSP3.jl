module XCSP3

#SECTION - Imports
import DataStructures
import EzXML
import TestItems: @testitem

#SECTION - Exports
export AbstractObjective, ObjectiveType, MinimizeObjective, MaximizeObjective
export Expression, Sum, Minimum, Maximum, NValues, Lex
export AbstractConstraint, IntensionConstraint, ExtensionConstraint
export RegularConstraint, MDDConstraint
export Instance

#SECTION - Includes
include("variable.jl")
include("objective.jl")
include("constraint.jl")
include("constraints/intension.jl")
include("constraints/extension.jl")
include("constraints/regular.jl")
include("constraints/mdd.jl")
include("instance.jl")

#SECTION - Main function (optional)

end
