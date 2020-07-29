local noise = require("noise")
local tne = noise.to_noise_expression
local pi = tne(math.pi)

local function slider_to_scale(autoplaceControlName, range)
    range = range or 6
    return (1 - noise.log2(noise.var(autoplaceControlName)) / (noise.log2(range, 2))) / 2
end

local function floorDiv(val, divisor)
    divisor = divisor or 1
    return noise.terrace(val / divisor, 0, 1, 1)
end
local function modulo(val, range)
    range = range or 1
    return val - noise.terrace(val, 0, range, 1)
end

local function bitwiseAND(x1, x2)
    -- assume x1 and x2 are both integers
    if not (x1 and x2) then return 0 end
    x1 = floorDiv(x1)
    x2 = floorDiv(x2)
    local result = 0
    for bit = 0, 15 do
        result = result + modulo(x1, 2) * modulo(x2, 2) * 2 ^ bit
        x1 = floorDiv(x1, 2)
        x2 = floorDiv(x2, 2)
    end
    return result
end

local function bitwiseXOR(x1, x2)
    -- assume x1 and x2 are both integers
    if not (x1 and x2) then return 0 end
    x1 = floorDiv(x1)
    x2 = floorDiv(x2)
    local result = 0
    for bit = 0, 15 do
        result = result + modulo(x1 + x2, 2) * 2 ^ bit
        x1 = floorDiv(x1, 2)
        x2 = floorDiv(x2, 2)
    end
    return result
end
---Is a > b?
local function greater_than(a, b) return noise.clamp((a - b) * math.huge, 0, 1) end
---Is a < b?
local function less_than(a, b) return noise.clamp((b - a) * math.huge, 0, 1) end
local function equal_to(a, b) return 1 - greater_than(a, b) - less_than(a, b) end

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

local function pseudo_sin(val)
    val = modulo(val, pi * 4)
    local factor = noise.clamp((val - 2 * pi) * math.huge, -1, 1)
    val = val / 2
    return ( --[[-0.417698 * val ^ 2 + ]] 1.312236 * val - 0.050465) * factor
end

---Get a random point for a given coordinate pair.
---@param x number
---@param y number
---@return number
local function pseudo_random(x, y)
    x = ( --[[97 * --]] x) or 1
    y = ( --[[43 * --]] y) or 1
    local x0 = noise.var("map_seed") / 2 ^ 32
    local y0 = tne(0.234561)
    local angle = (x * x0 + y * y0)
    return modulo(pseudo_sin(angle * 49300))
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

local random_offset_factor = slider_to_scale(
                                 "control-setting:island-randomness:frequency:multiplier")
local size = noise.var("fw_default_size") / noise.var("segmentation_multiplier")
return {
    slider_to_scale = slider_to_scale,
    floorDiv = floorDiv,
    modulo = modulo,
    bitwiseAND = bitwiseAND,
    bitwiseXOR = bitwiseXOR,
    greater_than = greater_than,
    less_than = less_than,
    equal_to = equal_to,
    reduce = reduce,
    get_extremum = get_extremum,
    scale_table = scale_table,
    multiply_probabilities = multiply_probabilities,
    make_interpolation = make_interpolation,
    distance = distance,
    smooth_step = smooth_step,
    medium_step = medium_step,
    sharp_step = sharp_step,
    pseudo_random = pseudo_random,
    get_random_point = get_random_point,
    rof = random_offset_factor,
    size = size
}
