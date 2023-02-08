using MakieRepel
using Makie, CairoMakie, RDatasets
using Makie.GeometryBasics
using GeometryBasics: origin, widths
using Test

@testset "MakieRepel.jl" begin
    # Write your tests here.
end


boxes = Rect2f.(randn(Point2f, 40), Point2f.(rand(40) .* 5, rand(40))./ 4)

using BenchmarkTools

TimerOutputs.reset_timer!(to)
@benchmark repel_from_points($(origin.(boxes)), boxes, 2000)
to


f, a1, p1 = poly(boxes; color = 1:length(boxes), colormap = cgrad(:rainbow1; alpha = 0.4))
a2, p2 = poly(f[1, 2], repel_from_points(origin.(boxes), boxes, 3000; padding = 0.05); color = 1:length(boxes), colormap = cgrad(:rainbow1; alpha = 0.4))
scatter!(a1, origin.(boxes); markersize = 5, color = :black)
scatter!(a2, origin.(boxes); markersize = 5, color = :black)
linkaxes!(a1, a2)
title = Label(f[0, 1:2], text = "Iteration 1")
f


@time record(f, "repel.mp4", 1:10:5000) do i
    global p2
    delete!(a2.scene, p2)
    p2 = poly!(a2, repel_from_points(origin.(boxes), boxes, i; padding = 0.05); color = 1:length(boxes), colormap = cgrad(:rainbow1; alpha = 0.4))
    autolimits!(a2)
    title.text = "Iteration $i"
end

@time record(f, "repel_x.mp4", 1:10:5000) do i
    global p2
    delete!(a2.scene, p2)
    p2 = poly!(a2, repel_from_points(origin.(boxes), boxes, i; padding = 0.05, x = true, y = false); color = 1:length(boxes), colormap = cgrad(:rainbow1; alpha = 0.4))
    autolimits!(a2)
    title.text = "Iteration $i"
end

@time record(f, "repel_y.mp4", 1:10:5000) do i
    global p2
    delete!(a2.scene, p2)
    p2 = poly!(a2, repel_from_points(origin.(boxes), boxes, i; padding = 0.05, x = false, y = true); color = 1:length(boxes), colormap = cgrad(:rainbow1; alpha = 0.4))
    autolimits!(a2)
    title.text = "Iteration $i"
end

using RDatasets
fig = Figure()
mtcars = RDatasets.dataset("datasets", "mtcars")
mtpoints = Point2f.(mtcars.WT, mtcars.MPG)
ax, sc = scatter(fig[1, 1], mtpoints)

tp = text!(ax, mtcars.Model; position = mtpoints)

fig

pixel_mtpoints = Point2f.(Makie.project.((Makie.camera(ax.scene),), :data, :pixel, mtpoints))# .- (origin(ax.scene.px_area[]),)

boxes = Makie.boundingbox.(tp.plots[1].plots[1][1][], Makie.to_ndim.(Point3f, tp.plots[1].plots[1].position[], 0), fill(Quaternionf(0,0,0,0), length(tp.plots[1].plots[1][1][]))) .|> Rect2f

repellable_boxes = Rect2f.(origin.(boxes) .+ pixel_mtpoints, widths.(boxes))

scatter!(ax, pixel_mtpoints; space=:pixel, color = :red)


fig

poly!(ax.scene, repellable_boxes; space = :pixel, color = (:black, 0.1))

fig


fig

TimerOutputs.reset_timer!(to)
@benchmark repel_from_points(mtpoints, repellable_boxes, 2000)
to

poly(repellable_boxes; axis = (aspect = DataAspect(),))

poly!(ax, new_boxes; color = (:black, 0.3))
fig

new_boxes = repel_from_points(mtpoints, repellable_boxes, 5000; padding = 4)

f2 = Figure()
a1, p1 = poly(f2[1, 1], repellable_boxes; color = 1:length(repellable_boxes), colormap = cgrad(:rainbow, alpha=0.2))
a2, p2 = poly(f2[1, 2], new_boxes; color = 1:length(repellable_boxes), colormap = cgrad(:rainbow, alpha=0.2))
linkaxes!(a1, a2)

f2