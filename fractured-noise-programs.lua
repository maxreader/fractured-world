local noise = require("noise")
local tne = noise.to_noise_expression
local functions = require("functions")
local floorDiv = functions.floorDiv
local modulo = functions.modulo
local greaterThan = functions.greaterThan
local equalTo = functions.equalTo
local rof = functions.rof
local get_random_point = functions.get_random_point
local distance = functions.distance
local get_extremum = functions.get_extremum
local defaultSize = 256

local size = defaultSize / noise.var("segmentation_multiplier")
local small_noise_factor = noise.get_control_setting("island-randomness").size_multiplier

local function waves(x, y)
    x = modulo(x, 4) * (1 - small_noise_factor) + modulo(y, 4) * small_noise_factor
    y = modulo(y, 4) * (1 - small_noise_factor) + modulo(x, 4) * small_noise_factor
    return noise.clamp(greaterThan(y, 0) - modulo(x, 2) * (1 - equalTo(y, x)), 0, 1)
end

local function get_brick_point(x, y, width)
    local val = get_random_point(x, y, size).val
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
    local randPoint = get_random_point(x, y, size)
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

local function get_closest_point(x, y, distanceType, pointType)
    pointType = pointType or "random"
    local distances = {}
    local count = 1
    local cX = floorDiv(x, size)
    local cY = floorDiv(y, size)
    for v = -1, 1, 1 do
        local t = tne(v) + cY
        for u = -1, 1, 1 do
            local s = tne(u) + cX
            local point
            local point_x
            local point_y
            if pointType == "random" then
                point = get_random_point(s, t, size)
                point_x = point.x * rof + size / 2 * (1 - rof)
                point_y = point.y * rof + size / 2 * (1 - rof)
            elseif pointType == "brick" then
                point = get_brick_point(s, t, size)
                point_x = point.x
                point_y = point.y
            elseif pointType == "hexagon" then
                point = get_hexagon_point(s, t, size)
                point_x = point.x
                point_y = point.y
            end
            -- shift due to randomness
            local relativeX = size * (s) + point_x - x
            local relativeY = size * (t) + point_y - y
            local pDistance = distance(relativeX, relativeY, distanceType)
            distances[count] = pDistance
            count = count + 1
        end
    end
    local minDistance = get_extremum("min", distances)
    return {distance = minDistance}
end

local function get_closest_point_and_value(x, y, distanceType, pointType)
    pointType = pointType or "random"
    local distances = {}
    local loc = {}
    local count = 1
    local cX = floorDiv(x, size)
    local cY = floorDiv(y, size)
    for v = -1, 1, 1 do
        local t = tne(v) + cY
        for u = -1, 1, 1 do
            local s = tne(u) + cX
            local point
            local point_x
            local point_y
            if pointType == "random" then
                point = get_random_point(s, t, size)
                point_x = point.x * rof + size / 2 * (1 - rof)
                point_y = point.y * rof + size / 2 * (1 - rof)
            elseif pointType == "brick" then
                point = get_brick_point(s, t, size)
                point_x = point.x
                point_y = point.y
            elseif pointType == "hexagon" then
                point = get_hexagon_point(s, t, size)
                point_x = point.x
                point_y = point.y
            end
            -- subtracting a small amount to break ties when comparing otherwise equal distances
            -- putting coordinates into "local" coordinates
            local relativeX = size * (s) + point_x - x - 0.01
            local relativeY = size * (t) + point_y - y - 0.01
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
        local factor = noise.clamp((minDistance - v) * size, -1, 0) + 1
        values[k] = factor * loc[k]
    end
    local value = get_extremum("max", values)
    return {distance = minDistance, value = value}
end

local function get_closest_two_points(x, y, distanceType, pointType)
    pointType = pointType or "random"
    local distances = {}
    local loc = {}
    local points = {}
    local count = 1
    local cX = floorDiv(x, size)
    local cY = floorDiv(y, size)
    for v = -1, 1, 1 do
        local t = tne(v) + cY
        for u = -1, 1, 1 do
            local s = tne(u) + cX
            local point
            local point_x
            local point_y
            if pointType == "random" then
                point = get_random_point(s, t, size)
                point_x = point.x * rof + size / 2 * (1 - rof)
                point_y = point.y * rof + size / 2 * (1 - rof)
            elseif pointType == "brick" then
                point = get_brick_point(s, t, size)
                point_x = point.x
                point_y = point.y
            elseif pointType == "hexagon" then
                point = get_hexagon_point(s, t, size)
                point_x = point.x
                point_y = point.y
            end
            -- subtracting a small amount to break ties when comparing otherwise equal distances
            -- putting coordinates into "local" coordinates
            local relativeX = size * (s) + point_x - x - 0.01
            local relativeY = size * (t) + point_y - y - 0.01
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
        local factor = noise.clamp((minDistance - v) * size, -1, 0) + 1
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

return {
    waves = waves,
    on_spiral = on_spiral,
    get_closest_point = get_closest_point,
    get_closest_point_and_value = get_closest_point_and_value,
    get_closest_two_points = get_closest_two_points,
    defaultSize = defaultSize,
    size = size,
    small_noise_factor = small_noise_factor
}
