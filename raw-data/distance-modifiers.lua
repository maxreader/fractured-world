local noise = require("noise")
noise["abs"] = noise.absolute_value
local functions = require("prototypes.functions")
local pi = math.pi

local function make_gear(minDistance, angle, value)
    angle = angle + value * 2 * math.pi
    local toothNumber = 8
    local isTooth = noise.sin(toothNumber * angle)
    return noise.max(minDistance * (1 + 0.35 * functions.smooth_step(isTooth, -0.5, 0.8)), 0)
end

local function make_hexagon(distance, angle, value)
    local n = 6
    local factor = noise.cos(pi / n) /
                       (noise.cos(angle - 2 * pi / n * noise.floor((n * angle + pi) / (2 * pi))))
    return distance / factor
end

local function make_flower(distance, angle, value)
    angle = angle + value * 2 * math.pi
    local n = 6
    local h = noise.abs(noise.sin(angle * n / 2)) * 2
    local j = noise.abs(noise.sin(angle * n)) * 4
    local factor = 1 + (1 - h) / (1 + j) / 2
    return distance / factor
end

local distanceModifiers = {
    ["gear"] = make_gear,
    ["hexagon"] = make_hexagon,
    ["flower"] = make_flower
}
for k, v in pairs(distanceModifiers) do fractured_world:add_distance_modifier(k, v) end
