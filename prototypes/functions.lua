local noise = require("noise")
local tne = noise.to_noise_expression
local pi = tne(math.pi)

local function slider_to_scale(autoplaceControlName, range)
    range = range or 6
    return (1 - noise.log2(noise.var(autoplaceControlName)) / (noise.log2(range, 2))) / 2
end

local function floorDiv(val, divisor)
    divisor = divisor or 1
    return noise.floor(val / divisor)
end
local function modulo(val, range)
    range = noise.absolute_value(range or 1)
    local quotient = val / range
    return (quotient - noise.floor(quotient)) * range -- noise.fmod(val, range)
end

---Is a > b?
local function greater_than(a, b) return noise.less_than(b, a) end

local function dot(vec1, vec2)
    local result = 0
    if not vec2 then vec2 = vec1 end
    if #vec1 ~= #vec2 then error("Vectors of different dimesion cannot be multiplied") end
    for i = 1, #vec1 do result = result + vec1[i] * vec2[i] end
    return result
end

local function reduce(reducer, list)
    local result = list[1]
    for i = 2, #list do result = reducer(result, list[i]) end
    return result
end

local function get_extremum(func, values)
    if func == "max" then
        return reduce(function(a, b) return noise.clamp(a, b, math.huge) end, values)
    elseif func == "min" then
        return reduce(function(a, b) return noise.clamp(a, -math.huge, b) end, values)
    end
end

local function sum_table(values) return reduce(function(a, b) return a + b end, values) end

local function scale_table(values, scalar)
    local returnTable = {}
    if type(values) ~= "table" then return nil end
    for k, v in pairs(values) do returnTable[k] = v * scalar end
    return returnTable
end

---Multiply together the elements of a table
---@param probabilities table
---@return number
local function multiply_probabilities(probabilities)
    return reduce(function(a, b) return a * b end, probabilities)
end

---Make a function to interpolate between two points
---@param x0 number
local function make_interpolation(x0, y0, x1, y1)
    if not (x0 and y0) then
        error("Error: function make_interpolation() needs at least one point")
    end
    x1 = x1 or 0
    y1 = y1 or 0
    return function(x) return (x - x0) / (x1 - x0) * (y0 - y1) + y1 end
end

local function rotate_coordinates(x, y, angle)
    local newX = x * noise.cos(angle) - y * noise.sin(angle)
    local newY = x * noise.sin(angle) + y * noise.cos(angle)
    return {x = newX, y = newY}
end

local function rotate_map(x, y)
    x = x or noise.var("x")
    y = y or noise.var("y")
    local smallRotationFactor = 1 - slider_to_scale("control-setting:map-rotation:size:multiplier")
    local largeRotationFactor = slider_to_scale("control-setting:map-rotation:frequency:multiplier")
    local rotationFactor = largeRotationFactor * 2 * math.pi + smallRotationFactor * math.pi / 6
    return (rotate_coordinates(x, y, rotationFactor * math.pi / 2))
end

---Get the distance to a point
---@param x number
---@param y number
---@param metric string|nil "euclidean, rectilinear
---@return number distance
local function distance(x, y, metric)
    metric = metric or "euclidean"
    x = noise.absolute_value(x) or 0
    y = noise.absolute_value(y) or 0
    if metric == "euclidean" then
        return (x ^ 2 + y ^ 2) ^ 0.5
    elseif metric == "rectilinear" then
        return x + y
    elseif metric == "chessboard" then
        return noise.max(x, y)
    else
        return error("metric: " .. metric .. ", is not a valid distance metric")
    end
end

---Smoothly transition between two values
---@param val number @The value to be smoothed
---@param edge0 number @The lower value
---@param edge1 number @The upper value
---@return number
local function smooth_step(val, edge0, edge1)
    local t = noise.clamp((val - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t);
end

local function medium_step(val, edge0, edge1)
    local t = noise.clamp((val - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t ^ 4 * (3 - 2 * t)
end
local function sharp_step(val, edge0, edge1)
    local t = noise.clamp((val - edge0) / (edge1 - edge0), 0.0, 1.0)
    return (1 / (1 - t / 2) - 1) ^ 3
end
---Get a random point for a given coordinate pair.
---@param x number
---@param y number
---@return number
local function pseudo_random(x, y)
    x = x or 1
    y = y or 1
    local x0 = noise.var("map_seed") / 2 ^ 34
    local y0 = tne(0.534561)
    local angle = (x * x0 + y * y0)
    return modulo(noise.sin(angle * 49300))
end

--- Get a random point within a cell.
---@param x integer x coordinate of seed/cell
---@param y integer y coordinate of seed/cell
---@param width integer|nil size of square cell
---@return integer x
---@return integer y
---@return number value
local function get_random_point(x, y, width)
    width = width or 1
    local value = pseudo_random(x, y)
    local scaledValue = value * width * width
    local newX = modulo(scaledValue, width)
    local newY = floorDiv(scaledValue, width)
    return {x = newX, y = newY, val = value}
end

-- For a given coordinate, used to seed a random value generator,
-- this will return two coordinates of a new point within the bounds
-- of a square defined by width
-- It also returns the random value, so that the random value generator
-- does not need to be called multiple times

local function count_to_order(count)
    if count < 10 then
        return "0" .. tostring(count)
    else
        return tostring(count)
    end
end
local random_offset_factor = slider_to_scale(
                                 "control-setting:island-randomness:frequency:multiplier")
local size = noise.var("fw_default_size") / noise.var("segmentation_multiplier")
return {
    slider_to_scale = slider_to_scale,
    floorDiv = floorDiv,
    modulo = modulo,
    greater_than = greater_than,
    reduce = reduce,
    get_extremum = get_extremum,
    sum_table = sum_table,
    scale_table = scale_table,
    multiply_probabilities = multiply_probabilities,
    make_interpolation = make_interpolation,
    rotate_coordinates = rotate_coordinates,
    rotate_map = rotate_map,
    distance = distance,
    smooth_step = smooth_step,
    medium_step = medium_step,
    sharp_step = sharp_step,
    pseudo_random = pseudo_random,
    get_random_point = get_random_point,
    count_to_order = count_to_order,
    rof = random_offset_factor,
    size = size
}
