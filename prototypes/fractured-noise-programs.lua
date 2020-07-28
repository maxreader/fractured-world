local noise = require("noise")
local tne = noise.to_noise_expression
local functions = require("prototypes.functions")
local floorDiv = functions.floorDiv
local modulo = functions.modulo
local greater_than = functions.greater_than
local equal_to = functions.equal_to
local rof = functions.rof
local get_random_point = functions.get_random_point
local distance = functions.distance
local get_extremum = functions.get_extremum
local small_noise_factor = noise.get_control_setting("island-randomness").size_multiplier
local ssnf = functions.slider_to_scale("control-setting:island-randomness:size:multiplier")
local waterLevel = -(noise.var("wlc_elevation_offset"))
local landDensity = noise.delimit_procedure(145 * waterLevel ^ 2 - 10660 * waterLevel + 212200)
-- TODO: Create functions to make starting areas. First, make single island map type, then transition between the two

local function waves(x, y)
    x = modulo(x, 4) * (1 - ssnf) + modulo(y, 4) * ssnf
    y = modulo(y, 4) * (1 - ssnf) + modulo(x, 4) * ssnf
    return 1 - noise.clamp(greater_than(y, 0) - modulo(x, 2) * (1 - equal_to(y, x)), 0, 1)
end

local function get_brick_point(x, y, width)
    local val = get_random_point(x, y, width).val
    local oddY = modulo(y, 2)
    local oddX = modulo(x, 2)
    local scale = rof * 2
    local xShift = 1 - noise.clamp(scale, 0, 1)
    local yShift = noise.clamp(scale, 1, 2) - 1
    x = width * oddY / 2 * xShift
    y = width * oddX / 2 * yShift
    return {x = x, y = y, val = val}
end

local function get_hexagon_point(x, y, width)
    local randPoint = get_random_point(x, y, width)
    local val = randPoint.val
    local oddX = modulo(x, 2)
    y = width * oddX / 2
    y = y * (1 - rof) + rof * randPoint.y
    x = x * (1 - rof) + rof * randPoint.x
    return {x = x, y = y, val = val}
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

local function is_maze_square(x, y)

    local maxNeighbors = floorDiv((1 - rof) * 8)
    local cellsToBeBorn = floorDiv(small_noise_factor * 8)
    local neighbors = 0
    for v = -1, 1 do for u = -1, 1 do neighbors = neighbors + is_random_square(x + v, y + u) end end
    neighbors = neighbors - is_random_square(x, y)
    local alive = greater_than(functions.less_than(neighbors, maxNeighbors), 0.1)
    return noise.max(alive, functions.less_than(noise.absolute_value(neighbors - cellsToBeBorn), 1))

end

local function get_closest_point_and_value(x, y, width, distanceType, pointType)
    pointType = pointType or "random"
    local distances = {}
    local loc = {}
    local count = 1
    local cX = floorDiv(x, width)
    local cY = floorDiv(y, width)
    for v = -1, 1, 1 do
        local t = tne(v) + cY
        for u = -1, 1, 1 do
            local s = tne(u) + cX
            local point
            local point_x
            local point_y
            if pointType == "random" then
                point = get_random_point(s, t, width)
                point_x = point.x * rof + width / 2 * (1 - rof)
                point_y = point.y * rof + width / 2 * (1 - rof)
            elseif pointType == "brick" then
                point = get_brick_point(s, t, width)
                point_x = point.x
                point_y = point.y
            elseif pointType == "hexagon" then
                point = get_hexagon_point(s, t, width)
                point_x = point.x
                point_y = point.y
            end
            -- subtracting a small amount to break ties when comparing otherwise equal distances
            -- putting coordinates into "local" coordinates
            local relativeX = width * (s) + point_x - x - 0.01
            local relativeY = width * (t) + point_y - y - 0.01
            local pDistance = distance(relativeX, relativeY, distanceType)

            -- add data for this point to tables
            distances[count] = pDistance
            loc[count] = point.val
            count = count + 1
        end
    end
    local minDistance = get_extremum("min", distances)
    local values = {}
    loc[10] = 0.5
    for k, v in pairs(distances) do
        local factor = noise.clamp((minDistance - v) * width, -1, 0) + 1
        values[k] = factor * loc[k]
    end
    local value = get_extremum("max", values)
    return {distance = minDistance, value = value}
end

local function get_closest_two_points(x, y, width, distanceType, pointType)
    pointType = pointType or "random"
    local distances = {}
    local loc = {}
    local count = 1
    local cX = floorDiv(x, width)
    local cY = floorDiv(y, width)
    for v = -1, 1, 1 do
        local t = tne(v) + cY
        for u = -1, 1, 1 do
            local s = tne(u) + cX
            local point
            local point_x
            local point_y
            if pointType == "random" then
                point = get_random_point(s, t, width)
                point_x = point.x * rof + width / 2 * (1 - rof)
                point_y = point.y * rof + width / 2 * (1 - rof)
            elseif pointType == "brick" then
                point = get_brick_point(s, t, width)
                point_x = point.x
                point_y = point.y
            elseif pointType == "hexagon" then
                point = get_hexagon_point(s, t, width)
                point_x = point.x
                point_y = point.y
            end
            -- subtracting a small amount to break ties when comparing otherwise equal distances
            -- putting coordinates into "local" coordinates
            local relativeX = width * (s) + point_x - x - 0.01
            local relativeY = width * (t) + point_y - y - 0.01
            local pDistance = distance(relativeX, relativeY, distanceType)

            -- add data for this point to tables
            distances[count] = pDistance
            loc[count] = point.val
            count = count + 1
        end
    end
    local minDistance = get_extremum("min", distances)
    local newDistances = {}
    local values = {}
    for k, v in pairs(distances) do
        -- magic function to get second minimum
        newDistances[k] = (1 / (v - minDistance - 0.0001))
        local factor = noise.clamp((minDistance - v) * width, -1, 0) + 1
        values[k] = factor * loc[k]
    end
    local secondDistance = 1 / get_extremum("max", newDistances)
    local value = get_extremum("max", values)
    return {
        distance = minDistance,
        secondDistance = secondDistance,
        value = value
    }
end
-- TODO:create noise program to return closest two distances and angles
-- TODO:create noise program to return border points
-- TODO:create noise program to return bridge points
--[[local function make_ridges(octaves, baseAmplitude, persistence, amplitudeScaling)
    local result = 0
    octaves = octaves or 1
    local amplitude = baseAmplitude or 1
    local scale = size
    persistence = persistence or 0.5
    amplitudeScaling = amplitudeScaling or 0.5
    local maximum = amplitude * octaves
    for i = 0, octaves do
        local expression = tne {
            type = "function-application",
            function_name = "factorio-basis-noise",
            arguments = {
                x = tne(noise.var("x") + i * scale * 1000),
                y = tne(noise.var("y")),
                seed0 = tne(noise.var("map_seed")),
                seed1 = tne(142),
                input_scale = tne(1 / scale),
                output_scale = tne(1)
            }
        }
        result = result + amplitude * noise.absolute_value(expression)
        amplitude = amplitude * amplitudeScaling
        scale = scale / persistence
    end
    return (1 - 2 * result / maximum) ^ 2
end

local function make_grid()
    return noise.min(noise.ridge(noise.var("x") * noise.var("segmentation_multiplier"), 0,
                                 defaultSize) *
                         noise.ridge(noise.var("y") * noise.var("segmentation_multiplier"), 0,
                                     defaultSize))
end]]

return {
    waves = waves,
    on_spiral = on_spiral,
    is_random_square = is_random_square,
    is_maze_square = is_maze_square,
    get_closest_point_and_value = get_closest_point_and_value,
    get_closest_two_points = get_closest_two_points,
    small_noise_factor = small_noise_factor, --[[
    make_ridges = make_ridges,
    make_grid = make_grid,]]
    landDensity = landDensity
}
