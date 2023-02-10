module MakieRepel

using StructArrays, Makie

using Makie: Rect2, Rect2f, VecTypes, GeometryBasics
using Makie.GeometryBasics: origin, widths
# benchmarking stuff
using BenchmarkTools, TimerOutputs
const to = TimerOutput()
TimerOutputs.reset_timer!(to)

include("utils.jl")
include("repel.jl")
include("recipe.jl")

export repel_from_points

# what the hell is happening?!

# loop:
# ──────────────────────────────────────────────────────────────────────────────────────────────────────
# Time                    Allocations      
# ───────────────────────   ────────────────────────
# Tot / % measured:                       77.6s /  32.2%            101MiB /   0.1%    

# Section                                     ncalls     time    %tot     avg     alloc    %tot      avg
# ──────────────────────────────────────────────────────────────────────────────────────────────────────
# Main loop                                      118    25.0s  100.0%   212ms   2.20KiB    2.3%    19.1B
#   Repulsion between boxes                    73.3M    5.34s   21.3%  72.8ns     0.00B    0.0%    0.00B
#   Repulsion between boxes and data points    73.3M    5.12s   20.5%  69.9ns     0.00B    0.0%    0.00B
#   Attraction to origin points                47.0k   9.70ms    0.0%   206ns     0.00B    0.0%    0.00B
# accumulating origin and width                  118   78.8μs    0.0%   668ns   92.2KiB   97.7%     800B
# ──────────────────────────────────────────────────────────────────────────────────────────────────────

# 1 broadcast:
# ──────────────────────────────────────────────────────────────────────────────────────────────────────
#                                                               Time                    Allocations      
#                                                      ───────────────────────   ────────────────────────
#                   Tot / % measured:                        146s /   8.3%            851MiB /  78.9%    

#  Section                                     ncalls     time    %tot     avg     alloc    %tot      avg
#  ──────────────────────────────────────────────────────────────────────────────────────────────────────
#  Main loop                                       23    12.2s  100.0%   530ms    671MiB  100.0%  29.2MiB
#    Repulsion between boxes and data points    68.6M    5.71s   46.9%  83.2ns      752B    0.0%    0.00B
#      Compute time                             3.28M    257ms    2.1%  78.4ns     0.00B    0.0%    0.00B
#    Repulsion between boxes                    1.76M    564ms    4.6%   321ns    671MiB  100.0%     400B
#    Attraction to origin points                44.0k   8.78ms    0.1%   200ns     0.00B    0.0%    0.00B
#  accumulating origin and width                   23   24.7μs    0.0%  1.07μs   18.0KiB    0.0%     800B
#  ──────────────────────────────────────────────────────────────────────────────────────────────────────

# all broadcasts:
# ─────────────────────────────────────────────────────────────────────────────────────────────────
# Time                    Allocations      
# ───────────────────────   ────────────────────────
# Tot / % measured:                    12.7s /  86.2%           10.4GiB /  99.1%    

# Section                                ncalls     time    %tot     avg     alloc    %tot      avg
# ─────────────────────────────────────────────────────────────────────────────────────────────────
# Main loop                                 173    10.9s  100.0%  63.0ms   10.3GiB  100.0%  61.0MiB
# Repulsion between boxes               13.8M    4.28s   39.2%   309ns   5.16GiB   50.0%     400B
# Repulsion between boxes and points    13.8M    3.76s   34.5%   272ns   5.16GiB   50.0%     400B
# Attraction to origin points            346k   69.9ms    0.6%   202ns     0.00B    0.0%    0.00B
# accumulating origin and width             173    125μs    0.0%   720ns    135KiB    0.0%     800B
# ─────────────────────────────────────────────────────────────────────────────────────────────────


end
