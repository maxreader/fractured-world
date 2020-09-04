local noise = require("noise")
local functions = require("prototypes.functions")
local modulo = functions.modulo
local get_random_point = functions.get_random_point
local rof = functions.rof

local function get_raw_random_point(x, y, width)
    point = get_random_point(x, y, width)
    x = point.x * rof + width / 2 * (1 - rof)
    y = point.y * rof + width / 2 * (1 - rof)
    local val = point.val
    return {x = x, y = y, val = val}

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
    local oddY = modulo(y, 2)
    x = width * oddY / 2
    y = y * (1 - rof) + rof * randPoint.y
    x = x * (1 - rof) + rof * randPoint.x
    return {x = x, y = y, val = val}
end

local pointTypes = {
    ["random"] = get_raw_random_point,
    ["brick"] = get_brick_point,
    ["hexagon"] = get_hexagon_point
}
for k, v in pairs(pointTypes) do fractured_world:add_point_type(k, v) end
