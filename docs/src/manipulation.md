# Figuring out good values

To figure out good values, you can use the provided, interactive interface:


```@example
using CairoMakie # hide
CairoMakie.activate!(type="svg") # hide
using CairoMakie, MakieRepel, RDatasets
# to interact, use GLMakie or WGLMakie instead

mtcars = RDatasets.dataset("datasets", "mtcars")
mtpoints = Point2f.(mtcars.WT, mtcars.MPG)

fig = Figure(resolution = (1000, 1000))
ax, sc = scatter(fig[1, 1], mtpoints)
# NB: always set `xautolimits = false, yautolimits = false` in the text plot, so that it doesn't cause an infinite loop.
tp = text!(ax, mtcars.Model; position = mtpoints, align = (:left, :bottom), xautolimits = false, yautolimits = false)
# slider grid for 
sg = SliderGrid(fig[2, 1],
    (label = "Attraction", range = LinRange(0f0, 2f-2, 100), startvalue = 7f-3),
    (label = "Box repulsion", range = LinRange(0f0, 2f-2, 100), startvalue = 9f-3),
    (label = "Point repulsion", range = LinRange(0f0, 2f-2, 100), startvalue = 10f-3),
    (label = "Data point radius", range = 0:50, startvalue = 15),
    (label = "Iterations", range = LinRange(1000, 11000, 100), startvalue = 7000),
    ;
    tellheight= true,
    tellwidth = false
)

# project to pixel space, calculate repulsions, project back
new_boxes = lift(getproperty.(sg.sliders, :value)..., ax.scene.px_area, tp.plots[1].plots[1][1]) do attraction, box_repulsion, point_repulsion, data_radius, niters, pxarea, text_glyphcollections
    # first, project the data points to pixel space.
    pixel_mtpoints = Point2f.(Makie.project.((Makie.camera(ax.scene),), :data, :pixel, mtpoints))# .- (origin(ax.scene.px_area[]),)
    # operate solely in pixel space, since the text widths are in pixel space
    boxes = Makie.boundingbox.(text_glyphcollections, Makie.to_ndim.(Point3f, pixel_mtpoints, 0), fill(Quaternionf(0,0,0,0), length(tp.plots[1].plots[1][1][]))) .|> Rect2f
    repellable_boxes = Rect2f.(boxes)
    # do repulsion.
    # Note: since we're acting in the pixelspace of `ax.scene`, the origin of the pixel boundingbox is 0.  
    # However, the axis px_area is relative to the window, so we simply re-create an appropriate bbox for the axis, a box that originates at 0.
    return repel_from_points(pixel_mtpoints, repellable_boxes, Rect2f(Point2f(0), widths(pxarea)), niters; padding = 15, attraction, box_repulsion, point_repulsion, data_radius)
end

# update texts
on(new_boxes) do new_boxes
    tp.position[] = Point2f.(Makie.project.((Makie.camera(ax.scene),), :pixel, :data, new_boxes))
end
notify(new_boxes)
# draw linesegments connecting the origin of the textbox to the point.
# TODO: make this connect to the closest point on the textbox, by computing it!
linesegments!(ax, @lift(collect(Iterators.flatten(zip(mtpoints, $(tp.position))))), inspectable = false, xautolimits = false, yautolimits = false)

fig

```