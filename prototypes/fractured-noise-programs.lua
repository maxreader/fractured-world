local noise = require("noise")
local tne = noise.to_noise_expression
local functions = require("prototypes.functions")
local floorDiv = functions.floorDiv
local modulo = functions.modulo
local greater_than = functions.greater_than
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
    return 1 - noise.clamp(greater_than(y, 0) - modulo(x, 2) * (1 - noise.equals(y, x)), 0, 1)
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
    local cellsToBeBorn = floorDiv(ssnf * 8)
    local neighbors = 0
    for v = -1, 1 do for u = -1, 1 do neighbors = neighbors + is_random_square(x + v, y + u) end end
    neighbors = neighbors - is_random_square(x, y)
    local alive = noise.less_than(neighbors, maxNeighbors)
    return noise.max(alive, noise.equals(cellsToBeBorn, neighbors))
end

local function get_point_data(x, y, args)
    local width = args.size or 128
    local pointType = args.pointType or "random"
    local startingArea = args.startingArea
    local distances = {}
    local values = {}
    local angles = {}
    local count = 1

    -- Get parent cell coordinates for that point
    local cX = floorDiv(x, width)
    local cY = floorDiv(y, width)
    local lX = modulo(x, width)
    local lY = modulo(y, width)
    if startingArea then
        cX = 0
        cY = 0
        lX = x
        lY = y
        if pointType ~= "hexagon" then rof = rof / 2 end
    end

    -- Iterate through neighboring cells, and put point data into tables
    for v = -1, 1, 1 do
        local t = noise.delimit_procedure(tne(v) + cY)
        for u = -1, 1, 1 do
            local s = noise.delimit_procedure(tne(u) + cX)
            local factor = 1
            -- if startingArea then factor = 1 + modulo(u + v, 2) * (math.sqrt(2) - 1) end

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
            local relativeX = width * u * factor + point_x - lX - 0.001
            local relativeY = width * v * factor + point_y - lY - 0.001

            -- add data for this point to tables
            distances[count] = distance(relativeX, relativeY, args.distanceType)
            angles[count] = noise.atan2(relativeY, relativeX) + 2 * math.pi
            values[count] = point.val

            count = count + 1
        end
    end
    if startingArea then
        table.remove(distances, 5)
        table.remove(angles, 5)
        table.remove(values, 5)
    end
    return {
        distances = distances,
        angles = angles,
        values = values
    }
end

--- Used for "basic" presets like circle, square, and diamond
local function get_closest_point_and_value(x, y, args)

    -- Get all pointData for adjacent cells
    local pointData = get_point_data(x, y, args)
    local distances = pointData.distances
    local values = pointData.values
    local angles = pointData.angles

    -- Find the minimum distance, and use it to flatten undesired values and angles
    local minDistance = get_extremum("min", distances)
    for k, v in pairs(distances) do
        local factor = noise.clamp((minDistance - v) * 1000, -1, 0) + 1
        values[k] = factor * values[k]
        angles[k] = factor * angles[k]
    end

    -- Choose the remaining value and angle
    local value = get_extremum("max", values)
    local angle = get_extremum("max", angles)
    return {
        distance = minDistance,
        angle = angle,
        value = value
    }
end

-- Used for more complex presets that need the two closest points: Default, Hexagon
local function get_closest_two_points(x, y, args)
    -- Get all pointData for adjacent cells
    local pointData = get_point_data(x, y, args)
    local distances = pointData.distances
    local values = pointData.values
    local angles = pointData.angles

    -- Find the minimum distance, and use it to flatten undesired values and angles
    local minDistance = get_extremum("min", distances)
    local newDistances = {}
    for k, v in pairs(distances) do
        -- magic function to get second minimum
        newDistances[k] = (1 / (v - minDistance - 0.0001))
        local factor = noise.clamp((minDistance - v) * 1000, -1, 0) + 1
        values[k] = factor * values[k]
        angles[k] = factor * angles[k]
    end

    -- Flip second distance back into correct format
    local secondDistance = 1 / get_extremum("max", newDistances) + minDistance

    -- Choose the remaining value and angle
    local value = get_extremum("max", values)
    local angle = get_extremum("max", angles)
    return {
        distance = minDistance,
        secondDistance = secondDistance,
        angle = angle,
        value = value
    }
end

local function get_closest_two_points_3(x, y, width, distanceType, pointType)
    local pointData = get_point_data(x, y, width, distanceType, pointType)
    local distances = pointData.distances
    local values = pointData.values
    local angles = pointData.angles

    local minDistance = get_extremum("min", distances)
    local newDistances = {}
    local minAngles = {}
    for k, v in pairs(distances) do
        -- magic function to get second minimum
        newDistances[k] = (1 / (v - minDistance - 0.0001))
        local factor = noise.clamp((minDistance - v) * width, -1, 0) + 1
        values[k] = factor * values[k]
        minAngles[k] = factor * angles[k]
    end
    local secondDistanceI = get_extremum("max", newDistances)
    local secondAngles = {}
    local value = get_extremum("max", values)
    local angle = get_extremum("max", minAngles)
    local secondDistance = 1 / secondDistanceI + minDistance + 0.0001
    for k, v in pairs(distances) do
        local factor = 1 -
                           noise.clamp(noise.absolute_value((secondDistance - v) * width * 1000), 0,
                                       1)
        secondAngles[k] = factor * angles[k]
    end
    local secondAngle = get_extremum("max", secondAngles)
    local totalAngle = secondAngle - angle
    local hypot = (minDistance ^ 2 + secondDistance ^ 2 - 2 * minDistance * secondDistance *
                      noise.cos(totalAngle)) ^ 0.5
    return {
        distance = minDistance,
        secondDistance = secondDistance,
        hypot = hypot,
        angle = totalAngle,
        value = value
    }
end
local function is_bridge(d1, d2, hypot, angle)
    return noise.absolute_value(d1 * d2 * noise.sin(angle) / hypot)
end

local function is_border(d1, d2, hypot) return noise.absolute_value(d2 ^ 2 - d1 ^ 2) / (2 * hypot) end

local function create_elevation(effectiveDistance, args)
    local waterSlider = noise.var("wlc_elevation_offset")
    local scale = noise.var("segmentation_multiplier")
    local waterInfluence = args.waterInfluence or 6
    local waterOffset = args.waterOffset or 100
    return (waterInfluence * waterSlider - effectiveDistance * scale) + waterOffset +
               noise.var("small-noise") / 25 * small_noise_factor
end

local startingAreaInnerRadius = 120
local startingAreaOuterRadius = 300

local function create_starting_area(elevation, value, pointDistance, args)
    local smallNoise = noise.var("small-noise") * small_noise_factor / 15
    args.size = startingAreaOuterRadius
    if args.class == "two-point" and args.pointType ~= "hexagon" then
        args.size = args.size * 3 / 4
    end
    local offset = args.size / 2 * (args.offsetFactor or 1)
    local x = noise.var("x")
    local y = noise.var("y")
    local distanceToOrigin = functions.distance(x, y, args.distanceType)
    local scaledDistance = distanceToOrigin
    local distanceForOres = distanceToOrigin
    local startingValue = functions.pseudo_random()
    local fadeOutFactor = 0.65
    x = x + offset
    y = y + offset

    if args.class == "two-point" then
        args.startingArea = true
        local point = get_closest_point_and_value(x, y, args)
        local angle = point.angle
        local point_x = x + point.distance * noise.cos(angle)
        local point_y = y + point.distance * noise.sin(angle)
        local hypot = distance(point_x, point_y, args.distanceType)
        distanceForOres = distanceToOrigin * startingAreaOuterRadius / hypot

        scaledDistance = ((distanceToOrigin - point.distance) / startingAreaOuterRadius + 1) *
                             startingAreaOuterRadius / 2
    end

    local starting_factor = (startingAreaInnerRadius / scaledDistance - fadeOutFactor) /
                                (1 - fadeOutFactor)
    starting_factor = noise.min(starting_factor, 1)
    local startingElevation = starting_factor * 100 + smallNoise
    local regular_factor = noise.delimit_procedure(
                               noise.clamp(
                                   (distanceToOrigin + smallNoise - startingAreaOuterRadius + 1) *
                                       math.huge, 0, 1))
    local finalElevation = elevation * regular_factor + startingElevation * (1 - regular_factor)
    local finalValue = value * regular_factor + startingValue * (1 - regular_factor)
    local finalPointDistance = pointDistance * regular_factor + distanceForOres *
                                   (regular_factor - 1)
    --[[local starting_area_factor = functions.sharp_step(-scaledDistance, -1, -1.5)
    local everything_else_factor = functions.sharp_step(scaledDistance, 1.5, 2)
    return (10 * (starting_area_factor) + elevation * everything_else_factor)--]]
    return {
        elevation = finalElevation,
        value = finalValue,
        pointDistance = finalPointDistance
    }
end

local function make_ridges(octaves, baseAmplitude, persistence, amplitudeScaling)
    local result = 0
    octaves = octaves or 1
    local amplitude = baseAmplitude or 1
    local scale = functions.size
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
end -- ]]

return {
    waves = waves,
    on_spiral = on_spiral,
    is_random_square = is_random_square,
    is_maze_square = is_maze_square,
    get_closest_point_and_value = get_closest_point_and_value,
    get_closest_two_points = get_closest_two_points,
    is_bridge = is_bridge,
    is_border = is_border,
    small_noise_factor = small_noise_factor,
    make_ridges = make_ridges,
    landDensity = landDensity,
    create_elevation = create_elevation,
    create_starting_area = create_starting_area
}
