local noise = require("noise")
local functions = require("prototypes.functions")
local modulo = functions.modulo
local floorDiv = functions.floorDiv
local distance = functions.distance
local greater_than = functions.greater_than
local ssnf = functions.slider_to_scale("control-setting:island-randomness:size:multiplier")
local rof = functions.rof
local function waves(x, y)
    y = y - 1
    x = modulo(x, 4) * (1 - ssnf) + modulo(y, 4) * ssnf
    y = modulo(y, 4) * (1 - ssnf) + modulo(x, 4) * ssnf
    return 1 - noise.clamp(greater_than(y, 0) - modulo(x, 2) * (1 - noise.equals(y, x)), 0, 1)
end

local function on_spiral(x, y)
    local isYNegative = -noise.clamp(y, -1, 0)
    local specialFactor = (noise.clamp(noise.absolute_value(y - x) * math.huge, 0, 1) - 1) *
                              isYNegative
    return modulo(distance(x, y - isYNegative, "chessboard") + specialFactor, 2)
end

local function get_coverage_for_random()
    return noise.var("wlc_elevation_offset") * 0.9 / 20 / noise.log2(6) + 0.55
end

local function is_random_square(x, y)
    local value = functions.pseudo_random(x, y)
    value = modulo(value * 13)
    local probability = get_coverage_for_random()
    return (greater_than(value, probability))
end

local function is_polytopic_square(x, y)
    local maxNeighbors = floorDiv((1 - rof) * 8)
    local cellsToBeBorn = floorDiv(ssnf * 8)
    local neighbors = 0
    for v = -1, 1 do for u = -1, 1 do neighbors = neighbors + is_random_square(x + v, y + u) end end
    neighbors = neighbors - is_random_square(x, y)
    local alive = noise.less_than(neighbors, maxNeighbors)
    return noise.max(alive, noise.equals(cellsToBeBorn, neighbors))
end

local function is_trellis_square(x, y)
    x = modulo(x, 2)
    y = modulo(y, 2)
    return noise.min(x, y)
end

local function is_chessboard_square(x, y) return modulo(x + y, 2) end

local cartesianFunctions = {
    ["waves"] = waves,
    ["on_spiral"] = on_spiral,
    ["is_random_square"] = is_random_square,
    ["is_polytopic_square"] = is_polytopic_square,
    ["is_trellis_square"] = is_trellis_square,
    ["is_chessboard_square"] = is_chessboard_square
}
for k, v in pairs(cartesianFunctions) do fractured_world:add_cartesian_function(k, v) end
