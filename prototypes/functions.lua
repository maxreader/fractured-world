local noise = require("noise")
local tne = noise.to_noise_expression
local pi = tne(math.pi)

local function sliderToScale(autoplaceControlName, range)
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

local function greaterThan(a, b) return noise.clamp((a - b) * math.huge, 0, 1) end
local function lessThan(a, b) return noise.clamp((b - a) * math.huge, 0, 1) end
local function equalTo(a, b) return 1 - greaterThan(a, b) - lessThan(a, b) end

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

local function multiply_probabilities(probabilities)
    return reduce(function(a, b) return a * b end, probabilities)
end

local function make_interpolation(x0, y0, x1, y1)
    if not (x0 and y0) then error("Error: function make_interpolation() given invalid input") end
    x1 = x1 or 0
    y1 = y1 or 0
    return function(x) return (x - x0) / (x1 - x0) * (y0 - y1) + y1 end
end

---@param type string: "euclidean" "rectilinear" "chessboard"
local function distance(x, y, type)
    type = type or "euclidean"
    x = noise.absolute_value(x) or 0
    y = noise.absolute_value(y) or 0
    if type == "euclidean" then return (x ^ 2 + y ^ 2) ^ 0.5 end
    if type == "rectilinear" then return x + y end
    if type == "chessboard" then return noise.max(x, y) end
end

local function smoothStep(val, edge0, edge1)
    local t = noise.clamp((val - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
end

local function pseudo_sin(val)
    val = modulo(val, pi * 4)
    local factor = noise.clamp((val - 2 * pi) * math.huge, -1, 1)
    val = val / 2
    return ( --[[-0.417698 * val ^ 2 + ]] 1.312236 * val - 0.050465) * factor
end

local function pseudo_random(x, y)
    x = (97 * x) or 1
    y = (43 * y) or 1
    local x0 = noise.var("map_seed") / 2 ^ 32
    local y0 = tne(0.234561)
    local angle = (x * x0 + y * y0)
    return modulo(pseudo_sin(angle * 5000))
end

---@param width integer
local function get_random_point(x, y, width)
    width = width or 1
    local value = pseudo_random(x, y)
    -- value = value * random_offset_factor + 0.5 * (1 - random_offset_factor)
    local scaledValue = value * width * width
    local newX = modulo(scaledValue, width)
    local newY = floorDiv(scaledValue, width)
    return {x = newX, y = newY, val = value}
end

local random_offset_factor = sliderToScale("control-setting:island-randomness:frequency:multiplier")
local size = noise.var("fw_default_size") / noise.var("segmentation_multiplier")
return {
    sliderToScale = sliderToScale,
    floorDiv = floorDiv,
    modulo = modulo,
    bitwiseAND = bitwiseAND,
    bitwiseXOR = bitwiseXOR,
    greaterThan = greaterThan,
    lessThan = lessThan,
    equalTo = equalTo,
    reduce = reduce,
    get_extremum = get_extremum,
    scale_table = scale_table,
    multiply_probabilities = multiply_probabilities,
    make_interpolation = make_interpolation,
    distance = distance,
    smoothStep = smoothStep,
    pseudo_random = pseudo_random,
    get_random_point = get_random_point,
    rof = random_offset_factor,
    size = size
}
