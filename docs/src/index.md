```@meta
CurrentModule = MakieRepel
```

# MakieRepel

MakieRepel is a re-implementation of [ggrepel](https://github.com/slowkow/ggrepel) in Julia, for Makie!  Basically, it repels text from its associated point, the rest of the points in the axis, and from the axis sides.  

![download-9](https://user-images.githubusercontent.com/32143268/217616625-7b6ba4f3-c846-4470-a2f5-602b175f2cc0.png)

See the `Finding good parameters` page to see how this works!

Eventually, this will all be wrapped in a recipe, but for now you need to do this by hand.


```@index
MakieRepel.repel_from_points
```

