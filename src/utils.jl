
__euclid_distance(x0, y0, x1, y1) = sqrt((x1-x0)^2 + (y1-y0)^2)

"""
    _distance(p0::Makie.VecTypes{2, T}, p1::Makie.VecTypes{2, T}, p2::Makie.VecTypes{2, T})
Distance from p0 to the line segment formed by p1 and p2.  Implementation from Turf.jl.
"""
function _distance(p0::Makie.VecTypes{2, T}, p1::Makie.VecTypes{2, T}, p2::Makie.VecTypes{2, T}) where T
    x0, y0 = p0
    x1, y1 = p1
    x2, y2 = p2

    if x1 < x2
        xfirst, yfirst = x1, y1
        xlast, ylast = x2, y2
    else
        xfirst, yfirst = x2, y2
        xlast, ylast = x1, y1
    end

    v = (xlast - xfirst, ylast - yfirst)
    w = (x0 - xfirst, y0 - yfirst)

    c1 = sum(w .* v)
    if c1 <= 0
        return __euclid_distance(x0, y0, xfirst, yfirst)
    end

    c2 = sum(v .* v)

    if c2 <= c1
        return __euclid_distance(x0, y0, xlast, ylast)
    end

    b2 = c1 / c2

    return __euclid_distance(x0, y0, xfirst + (b2 * v[1]), yfirst + (b2 * v[2]))
end

_distance(p0::Makie.VecTypes{2}, p12::Tuple{<: Makie.VecTypes{2}, <: Makie.VecTypes{2}}) = _distance(p0, p12[1], p12[2])



function project((x1, y1), (x2, y2), (x3, y3)) 
    x21 = x2 - x1
    y21 = y2 - y1
    x31 = x3 - x1
    y31 = y3 - y1
    return (x31 * x21 + y31 * y21) / (x21 * x21 + y21 * y21);
end
  

function closest_point(rect::Rect{2, T1}, xy::Makie.VecTypes{2, T2}) where {T1, T2}
    mindist = typemax(Float64)

    p1 = rect.origin
    p2 = p1 + rect.widths .* (true, false)
    p3 = p2 + rect.widths .* (false, true)
    p4 = p1 + rect.widths .* (false, true)

    possible_lines = ((p1, p2), (p2, p3), (p4, p3), (p1, p4))

    mindist, minind = findmin(x -> _distance(xy, x), possible_lines)

    pstart, pend = possible_lines[minind]

    t = clamp(project(pstart, pend, xy), 0, 1)

    return pstart .+ (pend .- pstart) .* t
end

function closest_anchor_point(rect::Rect{2, T1}, xy::Makie.VecTypes{2, T2}) where {T1, T2}
    p1 = rect.origin
    p2 = p1 + rect.widths .* (true, false)
    p3 = p2 + rect.widths .* (false, true)
    p4 = p1 + rect.widths .* (false, true)

    possible_lines = ((p1, p2), (p2, p3), (p4, p3), (p1, p4))

    mindist, minind = findmin(x -> _distance(xy, x), possible_lines)

    return sum(possible_lines[minind]) ./ 2
end