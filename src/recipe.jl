using Makie: inherit

"""
    repulsivelabels(text::Vector{<: AbstractString}, positions::Vector{Point2f})

Implements repulsive labels a la ggrepel.

## Attributes to tune repulsion
- `padding`: The padding around each box (usually in pixels).
- `x`: Whether to repel in the x direction.
- `y`: Whether to repel in the y direction.
- `halign`: The horizontal alignment of the centroid of a box.
- `valign`: The vertical alignment of the centroid of a box.
- `data_radius`: The radius around each data point to be kept clear.
- `selfpoint_radius`: The radius around the data point associated with the annotation to be kept clear.  Usually less than `data_radius`.
- `attraction`: The attractive force between a box and its associated point.
- `box_repulsion`: The repulsive force between boxes.
- `point_repulsion`: The repulsive force between boxes and data points.

# Extended help

## Available attributes and their defaults

$(Makie.ATTRIBUTES)

"""
@recipe(RepulsiveLabels, text, positions) do scene
    markersize = to_value(inherit(scene, :markersize, 5))
    return Attributes(
        fonts = inherit(scene, :fonts, (; :regular => Makie.defaultfont())),
        font = :regular,
        fontsize = inherit(scene, :fontsize, 14),
        textcolor = inherit(scene, :color, :black),
        textalign = (:left, :bottom),
        textrotation = 0f0,
        marker = inherit(scene, :marker, :square),
        markersize = markersize,
        markercolor = inherit(scene, :color, :black),
        cycle = [:color],
        linewidth = inherit(scene, :linewidth, 1.0),
        linecolor = inherit(scene, :color, :black),
        linestyle = inherit(scene, :linestyle, :solid),
        linevisible = true,
        niters = 10_000,
        padding = 10,
        x = true,
        y = true,
        halign = 0.5,
        valign = 0.5,
        data_radius = markersize * 1,
        selfpoint_radius = markersize * 1.5,
        attraction = 7f-2,#1.3e-2,
        box_repulsion = 7.2f-2,
        point_repulsion = 5.1f-2,
    )
end

function Makie.plot!(plot::RepulsiveLabels)

    # Extract the plot's parent scene, and its 
    scene = Makie.parent_scene(plot)
    
    scatterplot = scatter!(plot, plot[2]; marker = plot.marker, markersize = plot.markersize, color = plot.markercolor)

    # Plot the text at the given points which it corresponds to.
    textplot = text!(
        plot, 
        plot[1]; 
        position = plot[2][], 
        rotations = plot.textrotation, align = plot.textalign, font = plot.font, 
        fonts = plot.fonts, fontsize = plot.fontsize, color = plot.textcolor, 
        xautolimits = false, yautolimits = false # these last two kwargs ensure that the axis limits don't change when the text does, which would trigger an infinite loop.
    )

    pixelspace_positions_obs = lift(plot[2], scene.camera.projectionview, scene.px_area) do positions, _, __
        Point2f.(Makie.project.((Makie.camera(scene),), :data, :pixel, positions))
    end

    text_bbox_obs = @lift(
        Rect2f.(
            Makie.boundingbox.(
                $(textplot.plots[1].plots[1][1]),                           # glyph collections - these are already in pixelspace, since we specified `space = :pixel`
                Makie.to_ndim.(Point3f, $pixelspace_positions_obs, 0),      # positions - these must be converted to pixelspace.
                Makie.to_rotation.($(textplot.plots[1].plots[1].rotations)) # rotations - these need to be Quaternionf, so we pass them through `to_rotation`.
            ),
        ),
    ) # this is all in pixel space

    new_positions = lift(text_bbox_obs, plot.niters, plot.padding, plot.x, plot.y, plot.halign, plot.valign, plot.data_radius, plot.selfpoint_radius, plot.attraction, plot.box_repulsion, plot.point_repulsion) do text_boxes, niters, padding, x, y, halign, valign, data_radius, selfpoint_radius, attraction, box_repulsion, point_repulsion
        return Makie.project.((Makie.camera(scene),), :pixel, :data, repel_from_points(pixelspace_positions_obs[], text_boxes, Rect2f(Point2f(0), scene.px_area[].widths), niters; padding, x, y, halign, valign, data_radius, selfpoint_radius, attraction, box_repulsion, point_repulsion))
    end

    on(new_positions) do np
        textplot.position[] = np
    end

    linesegs = linesegments!(plot, @lift(collect(Iterators.flatten(zip(Point2f.($(new_positions)), $(plot[2]))))); xautolimits = false, yautolimits = false,)

    # trigger the pipeline once
    notify(scene.px_area)

    return plot
end

function _nearest_point(neworigins, widths, points)

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
