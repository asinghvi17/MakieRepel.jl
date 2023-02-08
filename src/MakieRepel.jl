module MakieRepel

using StructArrays, Makie

using Makie: Rect2, Rect2f, VecTypes, GeometryBasics
using Makie.GeometryBasics: origin, widths
# benchmarking stuff
using BenchmarkTools, TimerOutputs
const to = TimerOutput()
TimerOutputs.reset_timer!(to)

include("repel.jl")
include("recipe.jl")

export repel_from_points


end
