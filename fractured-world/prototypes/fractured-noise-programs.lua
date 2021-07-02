local noise = require("noise")
local tne = noise.to_noise_expression
local functions = require("prototypes.functions")
local floorDiv = functions.floorDiv
local modulo = functions.modulo
local distance = functions.distance
local get_extremum = functions.get_extremum
local small_noise_factor = noise.get_control_setting("island-randomness").size_multiplier
local waterLevel = -(noise.var("wlc_elevation_offset"))
local landDensity = noise.delimit_procedure(75.17 * waterLevel ^ 2 - 18503 * waterLevel + 451000)

local function get_point_data(x, y, args)
    local width = args.size or 128
    local pointType = args.pointType or "random"
    local startingArea = args.startingArea
    local aspectRatio = args.aspectRatio or 1
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
    end

    -- Iterate through neighboring cells, and put point data into tables
    for v = -1, 1, 1 do
        local t = noise.delimit_procedure(tne(v) + cY)
        for u = -1, 1, 1 do
            local s = noise.delimit_procedure(tne(u) + cX)
            local factor = 1
            if startingArea and pointType ~= "hexagon" then
                factor = 1 + modulo(u + v, 2) * (math.sqrt(2) - 1)
            end

            local point = fractured_world:get_point_type(pointType)(s, t, width)

            -- subtracting a small amount to break ties when comparing otherwise equal distances
            -- putting coordinates into "local" coordinates
            local relativeX = width * u * factor + point.x - lX - 0.001
            local relativeY = width * v * factor + point.y - lY - 0.001
            relativeX = relativeX / aspectRatio

            local pDistance = distance(relativeX, relativeY, args.distanceType)
            local angle = noise.atan2(relativeY, relativeX) + 2 * math.pi
            local value = point.val

            if args.distanceModifier then
                pDistance = fractured_world:get_distance_modifier(args.distanceModifier)(pDistance,
                                                                                         angle,
                                                                                         value)
            end

            -- add data for this point to tables
            distances[count] = pDistance
            angles[count] = angle
            values[count] = value

            count = count + 1
        end
    end
    if startingArea then
        table.remove(distances, 5)
        table.remove(angles, 5)
        table.remove(values, 5)
    end
    return {distances = distances, angles = angles, values = values}
end

--- Used for "basic" presets like circle, square, and diamond
local function get_closest_point_and_value(x, y, args)

    -- Get all pointData for adjacent cells
    local pointData = get_point_data(x, y, args)
    local distances = pointData.distances
    local values = pointData.values
    local angles = pointData.angles
    if args.class == "vanilla-islands" then
        x = noise.var("x")
        y = noise.var("y")

        table.insert(distances, distance(x, y))
        table.insert(values, functions.pseudo_random(0, 0))
        table.insert(angles, noise.atan2(y, x))
    end

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

    return {distance = minDistance, angle = angle, value = value}
end

-- Used for more complex presets that need the two closest points: Default
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
    return {distance = minDistance, secondDistance = secondDistance, angle = angle, value = value}
end

local function get_closest_two_points_3(x, y, args)
    local pointData = get_point_data(x, y, args)
    local distances = pointData.distances
    local values = pointData.values
    local angles = pointData.angles

    local minDistance = get_extremum("min", distances)
    local newDistances = {}
    local minAngles = {}
    for k, v in pairs(distances) do
        -- magic function to get second minimum
        newDistances[k] = (1 / (v - minDistance - 0.0001))
        local factor = noise.clamp((minDistance - v) * 1000000, -1, 0) + 1
        values[k] = factor * values[k]
        minAngles[k] = factor * angles[k]
    end
    local secondDistanceI = get_extremum("max", newDistances)
    local secondAngles = {}
    local value = get_extremum("max", values)
    local angle = get_extremum("max", minAngles)
    local secondDistance = 1 / secondDistanceI + minDistance + 0.0001
    for k, v in pairs(distances) do
        local factor = 1 - noise.clamp(noise.absolute_value((secondDistance - v) * 1000), 0, 1)
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
    local waterInfluence = args.waterInfluence or 3
    local waterOffset = args.waterOffset or 100
    return (waterInfluence * waterSlider - effectiveDistance * scale) + waterOffset +
               noise.var("fw-scaling-noise") / 25 * small_noise_factor
end

local defaultSize = functions.defaultSize
local startingAreaOuterRadius = 3 * defaultSize

local function create_voronoi_starting_area(elevation, value, pointDistance, args)
    local smallNoise = noise.var("fw-large-noise") * small_noise_factor / 15
    args.size = startingAreaOuterRadius * 0.8
    local offset = args.size / 2 * (args.offsetFactor or 1)
    local rotatedCoordinates = functions.rotate_map()
    local x = rotatedCoordinates.x
    local y = rotatedCoordinates.y
    local distanceToOrigin = functions.distance(x, y, args.distanceType)
    local scaledDistance = distanceToOrigin
    local distanceForOres = distanceToOrigin
    local startingValue = functions.pseudo_random()
    local fadeOutFactor = 0.65

    if args.distanceModifier then
        local angle = noise.atan2(y, x) + 2 * math.pi
        scaledDistance = fractured_world:get_distance_modifier(args.distanceModifier)(
                             scaledDistance, angle, startingValue)
    end

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
    else
        scaledDistance = scaledDistance / 1.5
    end

    local starting_factor = (defaultSize / scaledDistance - fadeOutFactor) / (1 - fadeOutFactor)
    starting_factor = noise.min(starting_factor, 1)
    -- To fix weird holes in the center on the default preset
    local absolute_starting_factor = noise.min(defaultSize -
                                                   functions.distance(x - offset, y - offset,
                                                                      args.distanceType), 1)
    local startingElevation = noise.max(starting_factor, absolute_starting_factor) * 100 +
                                  smallNoise
    local regular_factor = noise.delimit_procedure(
                               noise.clamp((scaledDistance * 4 / 3 + smallNoise -
                                               startingAreaOuterRadius + 1) * math.huge, 0, 1))
    local finalElevation = elevation * regular_factor + startingElevation * (1 - regular_factor)
    local finalValue = value * regular_factor + startingValue * (1 - regular_factor)
    local finalPointDistance = pointDistance * regular_factor + distanceForOres *
                                   (regular_factor - 1)

    --[[local starting_area_factor = functions.sharp_step(-scaledDistance, -1, -1.5)
    local everything_else_factor = functions.sharp_step(scaledDistance, 1.5, 2)
    return (10 * (starting_area_factor) + elevation * everything_else_factor)--]]

    return {elevation = finalElevation, value = finalValue, pointDistance = finalPointDistance}
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
    get_closest_point_and_value = get_closest_point_and_value,
    get_closest_two_points = get_closest_two_points,
    get_closest_two_points_3 = get_closest_two_points_3,
    is_bridge = is_bridge,
    is_border = is_border,
    small_noise_factor = small_noise_factor,
    make_ridges = make_ridges,
    landDensity = landDensity,
    create_elevation = create_elevation,
    create_voronoi_starting_area = create_voronoi_starting_area
}
