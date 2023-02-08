# Figuring out good values

To figure out good values, you can use the provided, interactive interface:


```@example
using CairoMakie, MakieRepel
# to interact, use GLMakie or WGLMakie instead
fig = Figure(resolution = (1300, 1300))
mtcars = RDatasets.dataset("datasets", "mtcars")
mtpoints = Point2f.(mtcars.WT, mtcars.MPG)

ax, sc = scatter(fig[1, 1], mtpoints)
# NB: always set `xautolimits = false, yautolimits = false` in plots.
tp = text!(ax, mtcars.Model; position = mtpoints, align = (:center, :center), xautolimits = false, yautolimits = false)

sg = SliderGrid(fig[2, 1],
    (label = "Attraction", range = LinRange(0f0, 1f-2, 100), startvalue = 2f-3),
    (label = "Box repulsion", range = LinRange(0f0, 1f-2, 100), startvalue = 5f-3),
    (label = "Point repulsion", range = LinRange(0f0, 1f-2, 100), startvalue = 5f-3),
    (label = "Iterations", range = LinRange(1000, 11000, 100), startvalue = 5000),
    ;
    tellheight= true,
    tellwidth = false
)

new_boxes = lift(getproperty.(sg.sliders, :value)..., ax.scene.px_area) do attraction, box_repulsion, point_repulsion, niters, pxarea
    pixel_mtpoints = Point2f.(Makie.project.((Makie.camera(ax.scene),), :data, :pixel, mtpoints))# .- (origin(ax.scene.px_area[]),)
    repel_from_points(pixel_mtpoints, repellable_boxes, ax.scene.px_area[], niters; padding = 5, attraction, box_repulsion, point_repulsion)
end

fig


boxes = Makie.boundingbox.(tp.plots[1].plots[1][1][], Makie.to_ndim.(Point3f, tp.plots[1].plots[1].position[], 0), fill(Quaternionf(0,0,0,0), length(tp.plots[1].plots[1][1][]))) .|> Rect2f

repellable_boxes = Rect2f.(origin.(boxes) .+ pixel_mtpoints, widths.(boxes))

on(new_boxes) do new_boxes
    tp.position[] = Point2f.(Makie.project.((Makie.camera(ax.scene),), :pixel, :data, new_boxes))
end
notify(new_boxes)

linesegments!(ax, @lift(collect(Iterators.flatten(zip(mtpoints, $(tp.position))))), inspectable = false, xautolimits = false, yautolimits = false)

fig
```