local noise = require("noise")
local tne = noise.to_noise_expression
local pi = tne(math.pi)
local temperatureRange = 60
local temperatureFloor = -25






if mods["alien-biomes"] then
    temperatureRange = 170
    temperatureFloor = -20
end

local function reduce(reducer, list)
    local result = list[1]
    for i=2,#list do
      result = reducer(result, list[i])
    end
    return result
  end

local function floorDiv(val, divisor)
    divisor = divisor or 1
    return noise.terrace(val / divisor, 0, 1, 1)
end
local function modulo(val, range)
    range = range or 1
    return val - noise.terrace(val, 0, range, 1)
end

local function smoothStep(val, edge0, edge1)
    local t = noise.clamp((val - edge0) / (edge1 - edge0), 0.0, 1.0);
    return t * t * (3.0 - 2.0 * t);
end

local function sin(val)
    val = modulo(val, pi*4)
    local factor = noise.clamp((val-2*pi)*math.huge,-1,1)
    val = val/2 
    return (-0.417698 * val ^ 2 + 1.312236 * val - 0.050465) * factor
end


local function pseudo_random(x, y, seed)
    local scale = 128 * noise.var("segmentation_multiplier")
    x = x or 1
    y = y or 1
    local x0 = noise.var("map_seed") / 2 ^ 32
    local y0 = tne(0.51413)
    local angle = (x * x0 + y * y0)
    return modulo(sin(angle*43900))
end



---@param width integer
local function get_random_point(x, y, width)
    width = width or 1
    local value = pseudo_random(x, y)
    local scaledValue = value * width * width
    local newX = modulo(scaledValue, width)
    local newY = floorDiv(scaledValue, width)
    return {x = newX, y = newY, val = value}
end

local function distance(x, y)
    x = noise.absolute_value(x)
    y = noise.absolute_value(y)
    return (x ^ 2 + y ^ 2) ^ 0.5
end

local function scale_table(values, scalar)
    local returnTable = {}
    if type(values) ~= "table" then return nil end
    for k, v in pairs(values) do returnTable[k] = v * scalar end
    return returnTable
end

local function get_extremum(func, values)
    if func == "max" then
        return reduce(function(a,b)
            return noise.clamp(a, b, math.huge)
          end, values)
    elseif func == "min" then
        return reduce(function(a,b)
            return noise.clamp(a, -math.huge, b)
          end, values)
    end
end
local function get_closest_point(x, y, size)
    size = size or 1
    local distances = {}
    local count = 1
    local cX = floorDiv(x, size)
    local cY = floorDiv(y, size)
    for v = -1, 1, 1 do
        local t = tne(v) + cY
        for u = -1, 1, 1 do
            local s = tne(u) + cX
            local point = get_random_point(s, t, size)
            local relativeX = size * (s) + point.x - x
            local relativeY = size * (t) + point.y - y
            local pDistance = distance(relativeX, relativeY)
            distances[count] = pDistance
            count = count + 1
        end
    end
    distances[10] = distance(x, y)
    local minDistance = get_extremum("min", distances)

    return {distance = minDistance}
end

local function get_closest_two_points_curved(x, y, size)
    size = size or 1
    local distances = {}
    local loc = {}
    local count = 1
    local cX = floorDiv(x, size)
    local cY = floorDiv(y, size)
    local minDistance = distance(x, y)
    local secondDistance = minDistance
    local value = 0
    for v = -1, 1, 1 do
        local t = tne(v) + cY
        for u = -1, 1, 1 do
            local s = tne(u) + cX
            local point = get_random_point(s, t, size)
            local relativeX = size * (s) + point.x - x
            local relativeY = size * (t) + point.y - y
            local pDistance = distance(relativeX, relativeY)
            distances[count] = pDistance
            loc[count] = point.val
            count = count + 1
        end
    end
    distances[10] = distance(x, y)
    local minDistance = noise.min(distances[1], distances[2], distances[3],
                                  distances[4], distances[5], distances[6],
                                  distances[7], distances[8], distances[9],
                                  distances[10])
    local newDistances = {}
    for k, v in pairs(distances) do
        newDistances[k] = (1 / (v - minDistance - 0.0000001))
    end -- ]]

    secondDistance = 1 /
                         noise.max(newDistances[1], newDistances[2],
                                   newDistances[3], newDistances[4],
                                   newDistances[5], newDistances[6],
                                   newDistances[7], newDistances[8],
                                   newDistances[9], newDistances[10])
    return {
        distance = minDistance,
        secondDistance = secondDistance,
        value = value
    }
end -- ]]

local function get_closest_two_points(x, y, size)
    size = size or 1
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
            local point = get_random_point(s, t, size)
            --subtracting a small amount to break ties when comparing otherwise equal distances
            --putting coordinates into "local" coordinates
            local relativeX = size * (s) + point.x - x - 0.01
            local relativeY = size * (t) + point.y - y - 0.01
            local pDistance = distance(relativeX, relativeY)

            --add data for this point to tables
            distances[count] = pDistance
            loc[count] = point.val
            count = count + 1
        end
    end

    distances[10] = distance(x, y)
    local minDistance = get_extremum("min", distances)
    local newDistances = {}
    local values = {}
    loc[10] = 0.5
    for k, v in pairs(distances) do
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
end -- ]]

local function get_closest_two_points_new(x, y, size)
    size = size or 1
    local distances = {}
    local loc = {}
    local points = {}
    local count = 1
    local cX = floorDiv(x, size)
    local cY = floorDiv(y, size)
    local mX = modulo(x, size)
    for v = -1, 1, 1 do
        local t = tne(v) + cY
        for u = -1, 1, 1 do
            local s = tne(u) + cX
            local point = get_random_point(s, t, size)
            --subtracting a small amount to break ties when comparing otherwise equal distances
            --putting coordinates into "local" coordinates
            local relativeX = size * (s) + point.x - x - 0.01
            local relativeY = size * (t) + point.y - y - 0.01
            local pDistance = distance(relativeX, relativeY)

            --add data for this point to tables
            points[count] = {d = pDistance, x = relativeX, y = relativeY, v = point.val}
            distances[count] = pDistance
            count = count + 1
        end
    end

    distances[10] = distance(x, y)
    local minDistance = get_extremum("min", distances)
    local newDistances = {}
    local values = {}
    local minXs = {}
    local minYs = {}

    points[10] = {
        d = distance(x,y),
        x = x,
        y = y,
        v = tne(0.5)
    }

    --
    for k, v in pairs(points) do
        local d = v.d
        newDistances[k] = (1 / (d - minDistance - 0.0001))
        local factor = noise.clamp((minDistance - d) * size, -1, 0) + 1
        factor = factor or 0
        values[k] = factor * v.v
        minXs[k] = factor * v.x
        minYs[k] = factor * v.y
    end
    local secondDistance = 1 / get_extremum("max", newDistances)
    local value = get_extremum("max", values)
    local minX = get_extremum("max", minXs)
    local minY = get_extremum("max", minYs)

    local secXs = {}
    local secYs = {}
    for k, v in pairs(newDistances) do
        local factor = noise.clamp((v - 1/secondDistance - 0.0001)*size, -1, 0) + 1
        factor = factor or 0
        secXs[k] = factor * (points[k].x)
        secYs[k] = factor * (points[k].y)
    end
    
    local secX = get_extremum("max", secXs)
    local secY = get_extremum("max", secYs)
    local returnDistance = ((minX + secX)/2 *(secY - minY)/noise.absolute_value(secY-minY))


    --loop to find

    return {
        distance = returnDistance,
        value = value
    }
end -- ]]



data:extend{
    {
        type = "noise-expression",
        name = "voronoi-circles",
        intended_property = "elevation",
        expression = noise.define_noise_function(
            function(x, y, tile, map)
                local scale = 128 / map.segmentation_multiplier
                local point = get_closest_point(x, y, scale)

                return (map.wlc_elevation_offset * 3 * map.segmentation_multiplier - point.distance + 10 + 100/map.segmentation_multiplier)
            end)
    }, {
        type = "noise-expression",
        name = "ridged-voronoi",
        intended_property = "elevation",
        expression = noise.define_noise_function(
            function(x, y, tile, map)
                local voronoi = noise.var("voronoi-circles")
                return noise.ridge(voronoi, -10, 20)
            end)
    }, {
        type = "noise-expression",
        name = "voronoi-value",
        intended_property = "moisture",
        expression = noise.define_noise_function(
            function(x, y, tile, map)
                local scale = 128 / map.segmentation_multiplier
                local points = get_closest_two_points(x, y, scale)
                local value = points.value
                return noise.absolute_value(value)
            end)
    }, --[[{
        type = "noise-expression",
        name = "voronoi-border",
        intended_property = "elevation",
        expression = noise.define_noise_function(
            function(x, y, tile, map)
                local scale = 128 / map.segmentation_multiplier
                local result = get_closest_two_points(x, y, scale)
                local d1 = result.distance
                local d2 = result.secondDistance
                return (map.wlc_elevation_offset * 2 *map.segmentation_multiplier^2) - ((d1 - d2) + 75) / map.segmentation_multiplier + noise.var("small-noise")/20
            end)
    }, --]]{
        type = "noise-expression",
        name = "voronoi-border-2",
        intended_property = "elevation",
        expression = noise.define_noise_function(
            function(x, y, tile, map)
                local scale = 128 / map.segmentation_multiplier
                local result = get_closest_two_points(x, y, scale)
                local d1 = result.distance
                local d2 = result.secondDistance
                return (map.wlc_elevation_offset * 200 * map.segmentation_multiplier - (d1 ^ 2 - d2 ^ 2) + 10) + noise.var("small-noise")
            end)
    }, --[[{
        type = "noise-expression",
        name = "voronoi-edges",
        intended_property = "elevation",
        expression = noise.define_noise_function(
            function(x, y, tile, map)
                local scale = 128 / map.segmentation_multiplier
                local result = get_closest_two_points_new(x, y, scale)
                return map.wlc_elevation_offset * 20 * map.segmentation_multiplier - (result.distance) + 10
            end)
    },--]] {
        type = "noise-expression",
        name = "new-temperature",
        expression = modulo(noise.var("voronoi-value")) * temperatureRange +
            temperatureFloor
    }, {
        type = "noise-expression",
        name = "new-aux",
        expression = modulo(noise.var("voronoi-value") * 134)
    },{
        type = "noise-expression",
        name = "small-noise",
        expression = {
            type = "function-application",
            function_name = "factorio-quick-multioctave-noise",
            arguments =
            {
              x = noise.var("x"),
              y = noise.var("y"),
              seed0 = tne(004),
              seed1 = noise.var("map_seed"),
              input_scale = tne(1/20*noise.var("segmentation_multiplier")),
              output_scale = tne(200/noise.var("segmentation_multiplier")),
              octaves = tne(3),
              octave_output_scale_multiplier = tne(2),
              octave_input_scale_multiplier = tne(0.8)
            }
          }
    },


}

-- local expression_to_ascii_math = require("noise.expression-to-ascii-math")

-- log(tostring(expression_to_ascii_math(data.raw["noise-expression"]["voronoi"].expression)))

local mgp = data.raw["map-gen-presets"].default
mgp["fractured-preset"] = {
    name = "fractured-preset",
    order = "z",
    basic_settings = {
        property_expression_names = {
            elevation = "voronoi-border",
            moisture = "voronoi-value",
            temperature = "new-temperature",
            aux = "new-aux",
        }
    }
}
