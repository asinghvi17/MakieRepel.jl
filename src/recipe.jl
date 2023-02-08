# """
# """
# @recipe(RepulsiveLabels, text, positions, other_datapoints) do scene
#     return Attributes(
#         fonts = inherit(scene, :fonts, (; :regular => Makie.defaultfont())),
#         font = :regular,
#         fontsize = inherit(scene, :fontsize, 14),
#         color = inherit(scene, :color, :black),
#         text_align = (0.5, 0.5),
#         linewidth = inherit(scene, :linewidth, 1.0),
#         linecolor = inherit(scene, :color, :black),
#         linestyle = inherit(scene, :linestyle, :solid),
#         linevisible = true,
#         k = 1e-3,
#         repel_x = true,
#         repel_y = true,
#         textbox_align = (0.5, 0.5),
#     )
# end

