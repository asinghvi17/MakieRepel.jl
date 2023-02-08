# helper functions

"""
    dist(a::VecTypes{2}, b::VecTypes{2})

Returns the Euclidean distance (2-distance) between the points in an efficient way.
"""
Base.@propagate_inbounds function dist(a::VecTypes{2}, b::VecTypes{2})
    return sqrt((a[1] - b[1])^2 + (a[2] - b[2])^2)
end

"""
    intersects(origin::VecTypes{N}, widths::VecTypes{N}, point::VecTypes{N}) where N

Tests whether the point lies within the rectangle specified by `origin` and `widths`; returns a boolean.
Edges are considered to be within the rectangle.
"""
function intersects(origin::VecTypes{N}, widths::VecTypes{N}, point::VecTypes{N}, radius = 0) where N
    return all((&).(point .≥ origin .- radius, point .≤ origin .+ widths .+ radius))
end

"""
    intersects(a_origin::VecTypes{2}, a_widths::VecTypes{2}, b_origin::VecTypes{2}, b_widths::VecTypes{2})

Tests whether the two rectangles `a` and `b` intersect, returns boolean.
Edges are considered to be within the rectangle.
"""
Base.@propagate_inbounds function intersects(a_origin::VecTypes{2}, a_widths::VecTypes{2}, b_origin::VecTypes{2}, b_widths::VecTypes{2})
    aleft, abottom = a_origin
    aright, atop = a_origin[1] + a_widths[1], a_origin[2] + a_widths[2]

    bleft, bbottom = b_origin
    bright, btop = b_origin[1] + b_widths[1], b_origin[2] + b_widths[2]

    return aleft ≤ bright && aright ≥ bleft && atop ≥ bbottom && abottom ≤ btop

end

"""
    spring_repel(a::VecTypes{2}, b::VecTypes{2}; k = 0.01, x = true, y = true)

Returns the repulsive force exerted on a by b, using Hooke's law: `F = k⋅(a⃗-b⃗)`.

`x` and `y` represent whether to move in the x or y directions.
"""
Base.@propagate_inbounds spring_repel(a::Makie.VecTypes{2}, b::Makie.VecTypes{2}; k = 0.01, x = true, y = true) = Vec2f((a - b) .* (x, y) .* k)

"""
    spring_repel(
        a_origin::VecTypes{2}, a_widths::VecTypes{2}, 
        b_origin::VecTypes{2}, b_widths::VecTypes{2}; 
        k = 10000, x = true, y = true, halign = 0.5, valign = 0.5
    )

Repels the centroids of the two given rectangle specifications `a` and `b` away from each other by Hooke's law.
Returns the repulsion exerted by b on a.

If the rectangles intersect, their repulsion is multiplied by 5.  If they do not intersect, it is muttiplied by 0.01.

`halign` and `valign` control the alignment of the centroid within the rectangle.
"""
Base.@propagate_inbounds function spring_repel(a_origin::VecTypes{2}, a_widths::VecTypes{2}, b_origin::VecTypes{2}, b_widths::VecTypes{2}; k = 10000, x = true, y = true, halign = 0.5, valign = 0.5) # returns Vec2f of displacement caused by B to A.

    # do_boxes_intersect = intersects(a_origin, a_widths, b_origin, b_widths)
    a_center = a_origin .+ a_widths .* (halign, valign)
    b_center = b_origin .+ b_widths .* (halign, valign)

    return spring_repel(a_center, b_center; k, x, y) #.* (do_boxes_intersect ? 5.0 : 0.01)
end

"""
    spring_repel(a_origin::VecTypes{2}, a_widths::VecTypes{2}, point::VecTypes{2})

Returns the spring-force repulsion between the centroid of the given rectangle and the point.

`halign` and `valign` control the alignment of the centroid within the rectangle.
"""
Base.@propagate_inbounds function spring_repel(a_origin::VecTypes{2}, a_widths::VecTypes{2}, point::VecTypes{2}; k = 10000, x = true, y = true, halign = 0.5, valign = 0.5) # returns Vec2f of displacement caused by B to A.

    a_center = a_origin .+ a_widths .* (halign, valign)

    return spring_repel(a_center, point; k, x, y)
end

# main function


# TODOS:
# - still allocates a lot, find a way to make the origin vector at least
#   into a mutable structarray to cut down on allocations
# - change to how ggrepel does it - only intersecting elements repel.  
#   this should cut allocs down by a lot.
function repel_from_points(points::AbstractVector{<: Makie.VecTypes{2}}, boxes::AbstractVector{<: Rect2}, axisbbox::Rect2, niters = 10000; padding = 4, x = true, y = true, halign = 0.5, valign = 0.5, data_radius = 5, selfpoint_radius = 3)
    @assert length(points) == length(boxes)
    @timeit to "accumulating origin and width" begin
    origin_vec = #=StructArray(=#origin.(boxes) .- (Vec2f(padding),)#)
    width_vec = #=StructArray(=#widths.(boxes) .+ (Vec2f(padding),)#)
    end

    @timeit to "Main loop" begin
    # loop through all iterations
    @inbounds for i in 1:niters
        # loop through all boxes to apply this
        for j in 1:length(boxes)
            jitter = rand(Point2f) .* 0.00000001f0
            current_origin = origin_vec[j]

            @timeit to "Repulsion between boxes" begin
                origin_vec[j] += sum(
                        spring_repel.(
                            (current_origin .+ jitter,), (width_vec[j] .+ jitter,),
                            origin_vec, width_vec;
                            k = 5e-3, x, y, halign, valign
                        ) .* intersects.((current_origin,), (width_vec[j],), origin_vec, width_vec)
                    )
            end
            @timeit to "Repulsion between boxes and points" begin
                origin_vec[j] += sum(
                        spring_repel.(
                            (current_origin .+ jitter,), (width_vec[j] .+ jitter,),
                            points;
                            k = 4e-3, x, y, halign, valign
                        ) .* intersects.((current_origin,), (width_vec[j],), points, data_radius)
                    )
            end

            # distances_to_boxes = dist.((origin_vec[j],), origin_vec)
            
        end
        # attract origin to the base point
        # distances_to_basepoints = dist.(origin_vec, points)
        @timeit to "Attraction to origin points" begin
            origin_vec .-= spring_repel.(origin_vec, width_vec, points; k = 2.5e-3, x, y, halign, valign) .* ifelse.(intersects.(origin_vec, width_vec, points, selfpoint_radius), -10, 1)#ifelse.(distances_to_basepoints .< 50, 1, distances_to_basepoints)
        end

    end
    end

    return origin_vec .+ Vec2f(padding, padding)
end
