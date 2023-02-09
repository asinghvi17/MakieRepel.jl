using Makie: inherit

# """
# """
@recipe(RepulsiveLabels, text, positions, other_datapoints) do scene
    return Attributes(
        fonts = inherit(scene, :fonts, (; :regular => Makie.defaultfont())),
        font = :regular,
        fontsize = inherit(scene, :fontsize, 14),
        textcolor = inherit(scene, :color, :black),
        text_align = (0.5, 0.5),
        marker = inherit(scene, (:Scatter, :marker), :square),
        markersize = inherit(scene, (:Scatter, :markersize), 5),
        markercolor = inherit(scene, :color, :black),
        linewidth = inherit(scene, :linewidth, 1.0),
        linecolor = inherit(scene, :color, :black),
        linestyle = inherit(scene, :linestyle, :solid),
        linevisible = true,
        attraction = 1e-3,
        box_repulsion = 1e-3,
        point_repulsion = 1e-3,
        datapoint_radius = 5, # in px units
        niters = 3000,
        repel_x = true,
        repel_y = true,
        textbox_align = (0.5, 0.5),
        rotations = 0f0
    )
end

function Makie.plot!(plot::RepulsiveLabels)

    scene = Makie.parent_scene(plot)
    camera = Makie.camera(scene)

    textplot = text!(plot, plot[1]; position = plot[2][], rotations = plot.rotations, align = plot.text_align, font = plot.font, fonts = plot.fonts, fontsize = plot.fontsize, color = plot.textcolor, xautolimits = false, yautolimits = false)

    text_bbox_obs = @lift(
        Rect2f.(
            Makie.boundingbox.(
                $(textplot.plots[1].plots[1][1]),
                Makie.to_ndim.(Point3f, $(textplot.plots[1].plots[1].position), 0), 
                Makie.to_rotation.($(textplot.plots[1].plots[1].rotations))
            ),
        ),
    ) # this exists in pixel space

    scatterplot = scatter!(plot, plot[2]; marker = plot.marker, markersize = plot.markersize, color = plot.markercolor,)

    new_positions = lift(scene.px_area, text_bbox_obs, plot[2], plot.attraction, plot.box_repulsion, plot.point_repulsion, plot.datapoint_radius, plot.niters) do axis_bbox, text_boxes, positions, attraction, box_repulsion, point_repulsion, datapoint_radius, niters

        pixel_positions = Point2f.(Makie.project.((camera,), :data, :pixel, positions))

        positioned_boxes = Rect2f.(origin.(text_boxes) .+ pixel_positions, widths.(text_boxes))

        return Point2f.(Makie.project.((camera,), :pixel, :data, repel_from_points(pixel_positions, positioned_boxes, axis_bbox, niters; padding = 5, attraction, box_repulsion, point_repulsion)))
    end

    on(new_positions) do np
        textplot.position[] = np
    end

    linesegs = linesegments!(plot, @lift(collect(Iterators.flatten(zip($(new_positions), $(plot[2]))))))

    return plot
end


# improvements to Makie
Makie.inherit(scene, attr::NTuple{1, <: Symbol}, default_value) where N = Makie.inherit(scene, attr[begin], default_value)


function Makie.inherit(scene, attr::NTuple{N, <: Symbol}, default_value) where N
    current_dict = scene.theme
    for i in 1:(N-1)
        if haskey(current_dict, attr[i])
            current_dict = current_dict[attr[i]]
        else
            break
        end
    end

    if haskey(current_dict, attr[N])
        return lift(identity, current_dict[attr[N]])
    else
        return Makie.inherit(scene.parent, attr, default_value)
    end
end

function Makie.inherit(::Nothing, attr::NTuple{N, Symbol}, default_value::T) where {N, T}
    default_value
end
