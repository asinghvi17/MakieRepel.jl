var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = MakieRepel","category":"page"},{"location":"#MakieRepel","page":"Home","title":"MakieRepel","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"MakieRepel is a re-implementation of ggrepel in Julia, for Makie!  Basically, it ","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [MakieRepel]","category":"page"},{"location":"#MakieRepel.dist-Tuple{Union{Tuple{T, T}, StaticArraysCore.StaticArray{Tuple{2}, T, 1}} where T, Union{Tuple{T, T}, StaticArraysCore.StaticArray{Tuple{2}, T, 1}} where T}","page":"Home","title":"MakieRepel.dist","text":"dist(a::VecTypes{2}, b::VecTypes{2})\n\nReturns the Euclidean distance (2-distance) between the points in an efficient way.\n\n\n\n\n\n","category":"method"},{"location":"#MakieRepel.intersects-NTuple{4, Union{Tuple{T, T}, StaticArraysCore.StaticArray{Tuple{2}, T, 1}} where T}","page":"Home","title":"MakieRepel.intersects","text":"intersects(a_origin::VecTypes{2}, a_widths::VecTypes{2}, b_origin::VecTypes{2}, b_widths::VecTypes{2})\n\nTests whether the two rectangles a and b intersect, returns boolean. Edges are considered to be within the rectangle.\n\n\n\n\n\n","category":"method"},{"location":"#MakieRepel.intersects-Union{Tuple{N}, Tuple{Union{Tuple{Vararg{T, N}}, StaticArraysCore.StaticArray{Tuple{N}, T, 1}} where T, Union{Tuple{Vararg{T, N}}, StaticArraysCore.StaticArray{Tuple{N}, T, 1}} where T, Union{Tuple{Vararg{T, N}}, StaticArraysCore.StaticArray{Tuple{N}, T, 1}} where T}} where N","page":"Home","title":"MakieRepel.intersects","text":"intersects(origin::VecTypes{N}, widths::VecTypes{N}, point::VecTypes{N}) where N\n\nTests whether the point lies within the rectangle specified by origin and widths; returns a boolean. Edges are considered to be within the rectangle.\n\n\n\n\n\n","category":"method"},{"location":"#MakieRepel.spring_repel-NTuple{4, Union{Tuple{T, T}, StaticArraysCore.StaticArray{Tuple{2}, T, 1}} where T}","page":"Home","title":"MakieRepel.spring_repel","text":"spring_repel(\n    a_origin::VecTypes{2}, a_widths::VecTypes{2}, \n    b_origin::VecTypes{2}, b_widths::VecTypes{2}; \n    k = 10000, x = true, y = true, halign = 0.5, valign = 0.5\n)\n\nRepels the centroids of the two given rectangle specifications a and b away from each other by Hooke's law. Returns the repulsion exerted by b on a.\n\nIf the rectangles intersect, their repulsion is multiplied by 5.  If they do not intersect, it is muttiplied by 0.01.\n\nhalign and valign control the alignment of the centroid within the rectangle.\n\n\n\n\n\n","category":"method"},{"location":"#MakieRepel.spring_repel-Tuple{Union{Tuple{T, T}, StaticArraysCore.StaticArray{Tuple{2}, T, 1}} where T, Union{Tuple{T, T}, StaticArraysCore.StaticArray{Tuple{2}, T, 1}} where T, Union{Tuple{T, T}, StaticArraysCore.StaticArray{Tuple{2}, T, 1}} where T}","page":"Home","title":"MakieRepel.spring_repel","text":"spring_repel(a_origin::VecTypes{2}, a_widths::VecTypes{2}, point::VecTypes{2})\n\nReturns the spring-force repulsion between the centroid of the given rectangle and the point.\n\nhalign and valign control the alignment of the centroid within the rectangle.\n\n\n\n\n\n","category":"method"},{"location":"#MakieRepel.spring_repel-Tuple{Union{Tuple{T, T}, StaticArraysCore.StaticArray{Tuple{2}, T, 1}} where T, Union{Tuple{T, T}, StaticArraysCore.StaticArray{Tuple{2}, T, 1}} where T}","page":"Home","title":"MakieRepel.spring_repel","text":"spring_repel(a::VecTypes{2}, b::VecTypes{2}; k = 0.01, x = true, y = true)\n\nReturns the repulsive force exerted on a by b, using Hooke's law: F = k⋅(a⃗-b⃗).\n\nx and y represent whether to move in the x or y directions.\n\n\n\n\n\n","category":"method"}]
}
