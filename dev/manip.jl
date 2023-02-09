using Pkg; 
Pkg.activate(joinpath(pwd(), "code"))
using GLMakie, MakieRepel, RDatasets
using GLMakie.Makie.GeometryBasics: origin, widths
fig = Figure(resolution = (1000, 1000))
mtcars = RDatasets.dataset("datasets", "mtcars")
mtpoints = Point2f.(mtcars.WT, mtcars.MPG)

ax, sc = scatter(fig[1, 1], mtpoints)
# NB: always set `xautolimits = false, yautolimits = false` in plots.
tp = text!(ax, mtcars.Model; position = mtpoints, align = (:center, :center), xautolimits = false, yautolimits = false)

sg = SliderGrid(fig[2, 1],
    (label = "Attraction", range = LinRange(0f0, 1f-2, 100), startvalue = 2f-3),
    (label = "Box repulsion", range = LinRange(0f0, 1f-2, 100), startvalue = 5f-3),
    (label = "Point repulsion", range = LinRange(0f0, 1f-2, 100), startvalue = 5f-3),
    (label = "Data point radius", range = LinRange(0, 20, 20), startvalue = 5f-3),
    (label = "Iterations", range = LinRange(1000, 11000, 100), startvalue = 5000),
    ;
    tellheight= true,
    tellwidth = false
)


new_boxes = lift(getproperty.(sg.sliders, :value)..., ax.scene.px_area, tp.plots[1].plots[1][1]) do attraction, box_repulsion, point_repulsion, data_radius, niters, pxarea, text_glyphcollections
    pixel_mtpoints = Point2f.(Makie.project.((Makie.camera(ax.scene),), :data, :pixel, mtpoints))# .- (origin(ax.scene.px_area[]),)
    boxes = Makie.boundingbox.(text_glyphcollections, Makie.to_ndim.(Point3f, tp.plots[1].plots[1].position[], 0), fill(Quaternionf(0,0,0,0), length(tp.plots[1].plots[1][1][]))) .|> Rect2f
    repellable_boxes = Rect2f.(origin.(boxes) .+ pixel_mtpoints, widths.(boxes))
    repel_from_points(pixel_mtpoints, repellable_boxes, Rect2f(Point2f(0), widths(pxarea)), niters; padding = 15, attraction, box_repulsion, point_repulsion, data_radius)
end

fig

on(new_boxes) do new_boxes
    tp.position[] = Point2f.(Makie.project.((Makie.camera(ax.scene),), :pixel, :data, new_boxes))
end
notify(new_boxes)

linesegments!(ax, @lift(collect(Iterators.flatten(zip(mtpoints, $(tp.position))))), inspectable = false, xautolimits = false, yautolimits = false)

fig