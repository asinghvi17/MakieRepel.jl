using MakieRepel
using MakieRepel: to
using Makie, CairoMakie, RDatasets
using Makie.GeometryBasics
using GeometryBasics: origin, widths
using Test
using RDatasets
using BenchmarkTools, TimerOutputs

# TODO: test basic functionality
# eg distance, intersection, spring force


@testset "Basic" begin
    # Basic test
    boxes = Rect2f.(randn(Point2f, 40), Point2f.(rand(40) .* 5, rand(40))./ 4)

    TimerOutputs.reset_timer!(to)
    display(@benchmark repel_from_points($(origin.(boxes)), boxes, Rect2f(-100, -100, 200, 200), 2000))
    display(to)


    f, a1, p1 = poly(boxes; color = 1:length(boxes), colormap = cgrad(:rainbow1; alpha = 0.4))
    @test_nowarn begin
        newpoints = repel_from_points(origin.(boxes), boxes, Rect2f(-100, -100, 200, 200), 9000; padding = 0.05)
    end
    a2, p2 = poly(f[1, 2], Rect2f.(newpoints, widths.(boxes)); color = 1:length(boxes), colormap = cgrad(:rainbow1; alpha = 0.4))
    ls = linesegments!(a2, collect(Iterators.flatten(zip(origin.(boxes), newpoints))))
    scatter!(a1, origin.(boxes); markersize = 5, color = :black)
    scatter!(a2, origin.(boxes); markersize = 5, color = :black)
    linkaxes!(a1, a2)
    title = Label(f[0, 1:2], text = "9,000 iterations")
    save("basic_test.png", f; px_per_unit = 3)
end


@time record(f, "repel.mp4", 1:10:5000) do i
    global p2
    delete!(a2.scene, p2)
    newpoints = repel_from_points(origin.(boxes), boxes, i; padding = 0.05)
    ls[1][] = collect(Iterators.flatten(zip(origin.(boxes), newpoints)))
    p2 = poly!(a2, Rect2f.(newpoints, widths.(boxes)); color = 1:length(boxes), colormap = cgrad(:rainbow1; alpha = 0.4))
    autolimits!(a2)
    title.text = "Iteration $i"
end

# @time record(f, "repel_x.mp4", 1:10:5000) do i
#     global p2
#     delete!(a2.scene, p2)
#     newpoints = repel_from_points(origin.(boxes), boxes, i; padding = 0.05, x = true, y = false)
#     p2 = poly!(a2, Rect2f.(newpoints, widths.(boxes)); color = 1:length(boxes), colormap = cgrad(:rainbow1; alpha = 0.4))
#     autolimits!(a2)
#     title.text = "Iteration $i"
# end

# @time record(f, "repel_y.mp4", 1:10:5000) do i
#     global p2
#     delete!(a2.scene, p2)
#     newpoints = repel_from_points(origin.(boxes), boxes, i; padding = 0.05, x = false, y = true)
#     p2 = poly!(a2, Rect2f.(newpoints, widths.(boxes)); color = 1:length(boxes), colormap = cgrad(:rainbow1; alpha = 0.4))
#     autolimits!(a2)
#     title.text = "Iteration $i"
# end

@testset "mtcars" begin

    fig = Figure()
    mtcars = RDatasets.dataset("datasets", "mtcars")
    mtpoints = Point2f.(mtcars.WT, mtcars.MPG)
    pixel_mtpoints = Point2f.(Makie.project.((Makie.camera(ax.scene),), :data, :pixel, mtpoints))# .- (origin(ax.scene.px_area[]),)

    ax, sc = scatter(fig[1, 1], mtpoints)
    # NB: always set `xautolimits = false, yautolimits = false` in plots.
    tp = text!(ax, mtcars.Model; position = mtpoints, align = (:center, :center), xautolimits = false, yautolimits = false)
    fig


    boxes = Makie.boundingbox.(tp.plots[1].plots[1][1][], Makie.to_ndim.(Point3f, tp.plots[1].plots[1].position[], 0), fill(Quaternionf(0,0,0,0), length(tp.plots[1].plots[1][1][]))) .|> Rect2f

    repellable_boxes = Rect2f.(origin.(boxes) .+ pixel_mtpoints, widths.(boxes))

    new_boxes = repel_from_points(pixel_mtpoints, repellable_boxes, ax.scene.px_area[], 10000; padding = 5)

    tp.position[] = Point2f.(Makie.project.((Makie.camera(ax.scene),), :pixel, :data, new_boxes))

    linesegments!(ax, @lift(collect(Iterators.flatten(zip(mtpoints, $(tp.position))))), inspectable = false, xautolimits = false, yautolimits = false)

    fig

    # record(fig, 1:10:1000)

    # pr = poly!(ax.scene, repellable_boxes; space = :pixel, color = (:black, 0.1))

    # translate!(pr, 0, -20, 0)

    # fig


    # fig

    # TimerOutputs.reset_timer!(to)
    # @benchmark repel_from_points(mtpoints, repellable_boxes, 2000)
    # to

    # poly(repellable_boxes; axis = (aspect = DataAspect(),))

    # poly(Rect2f.(new_boxes, widths.(repellable_boxes)); color = (:black, 0.3))
    # fig

    # new_boxes = repel_from_points(pixel_mtpoints, repellable_boxes, 5000; padding = 4)

    # f2 = Figure()
    # a1, p1 = poly(f2[1, 1], repellable_boxes; color = 1:length(repellable_boxes), colormap = cgrad(:rainbow, alpha=0.2))
    # a2, p2 = poly(f2[1, 2], new_boxes; color = 1:length(repellable_boxes), colormap = cgrad(:rainbow, alpha=0.2))
    # linkaxes!(a1, a2)

    # f2

    @test true
end
