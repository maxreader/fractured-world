local noise = require("noise")
local tne = noise.to_noise_expression
local util = require("util")

local fnp = require("prototypes.fractured-noise-programs")
local functions = require('prototypes.functions')
local get_closest_point_and_value = fnp.get_closest_point_and_value
local get_closest_two_points = fnp.get_closest_two_points
local create_vanilla_islands = require("prototypes.create-vanilla-islands")
local size = functions.size
local waterLevel = -(noise.var("wlc_elevation_offset"))

local floorDiv = functions.floorDiv
local modulo = functions.modulo
local distance = functions.distance
local count_to_order = functions.count_to_order

--[[
    Defaults to add as settings
    Default Size - 256
]]

local temperatureRange = 60
local temperatureFloor = -25
if mods["alien-biomes"] then
    temperatureRange = 170
    temperatureFloor = -20
end

noise.equals = function(lhs, rhs)
    -- return 1 - noise.clamp((noise.absolute_value(lhs - rhs) - 0.1) * math.huge, 0, 1)
    return noise.less_than(noise.absolute_value(lhs - rhs), 0.001)
end

local count = 0
local function make_voronoi_noise_expressions(name, presetData)
    local args = presetData.voronoi or {}
    local class = args.class or "one-point"
    local aspectRatio = args.aspectRatio or 1
    if class == "vanilla-islands" then
        args.size = (functions.defaultSize * 6 + 2048) / noise.var("segmentation_multiplier")
    else
        args.size = size
    end
    local elevation
    local value
    local pointDistance

    local rotatedCoordinates = functions.rotate_map()
    local x = rotatedCoordinates.x
    local y = rotatedCoordinates.y
    local offsetFactor = args.offsetFactor or 1
    local offset = offsetFactor * args.size / 2

    x = (x + offset) * aspectRatio
    y = (y + offset)

    if class == "one-point" then
        local point = get_closest_point_and_value(x, y, args)
        elevation = fnp.create_elevation(2 * point.distance, args) -- + noise.var("fw_default_size") / 2
        value = point.value
        pointDistance = point.distance
    elseif class == "two-point" then
        local points = get_closest_two_points(x, y, args)
        local d1 = points.distance
        local d2 = points.secondDistance
        elevation = fnp.create_elevation((d1 - d2), args)
        elevation = elevation - functions.defaultSize * 3 / 2 -- ]]
        if args.use_web then elevation = -elevation - functions.defaultSize / 2 end
        pointDistance = points.distance
        value = points.value
    elseif class == "vanilla-islands" then

        x = noise.var("x") * noise.var("segmentation_multiplier") / 4 + 10000
        y = noise.var("y") * noise.var("segmentation_multiplier") / 4
        local points = get_closest_point_and_value(x, y, args)
        local point_distance = points.distance
        elevation = create_vanilla_islands(x, y, point_distance)
        value = points.value
        pointDistance = points.distance
    end

    --[[local isBridge = fnp.is_bridge(d1, d2, points.hypot, points.angle)
        local bridge = 10 - isBridge / functions.size * 500]]
    -- elevation = border / functions.size * 1000 - 100
    --[[
        local points = fnp.get_closest_two_points_3(x, y, args)
        local border = fnp.is_border(d1, d2, points.hypot)
        local percentFromBorder = border / points.hypot
        elevation = 100 * percentFromBorder - 50 + waterSlider
        --]]

    if not args.vanillaIslands then
        local final = fnp.create_voronoi_starting_area(elevation, value, pointDistance, args)
        elevation = final.elevation
        value = final.value
        pointDistance = final.pointDistance
    end

    data:extend{
        {
            type = "noise-expression",
            name = "fractured-world-" .. name,
            order = "40" + count_to_order(count),
            -- intended_property = "elevation",
            expression = elevation
        }, {
            type = "noise-expression",
            name = "fractured-world-value-" .. name,
            order = "40" + count_to_order(count),
            intended_property = "fw_value",
            expression = value
        }, {
            type = "noise-expression",
            name = "fractured-world-point-distance-" .. name,
            order = "40" + count_to_order(count),
            -- intended_property = "fw_distance",
            expression = pointDistance
        }
    }
    count = count + 1
end

local function make_cartesian_noise_expressions(name, args)
    local generating_function = fractured_world:get_cartesian_function(args.cartesian)
    data:extend{
        {
            type = "noise-expression",
            name = "fractured-world-" .. name,
            -- intended_property = "elevation",
            order = "40" + count_to_order(count),
            expression = noise.define_noise_function(
                function(x, y, tile, map)
                    local rotatedCoordinates = functions.rotate_map()
                    x = rotatedCoordinates.x
                    y = rotatedCoordinates.y
                    x = x + size / 2
                    y = y + size / 2
                    local cellX = floorDiv(x, size)
                    local cellY = floorDiv(y, size)
                    local localX = noise.absolute_value(modulo(x, size) - size / 2) - 1
                    local localY = noise.absolute_value(modulo(y, size) - size / 2) - 1
                    local height = size / 2 - distance(localX, localY, "chessboard")
                    local isOrigin = 1 -
                                         noise.min(1, noise.absolute_value(cellX) +
                                                       noise.absolute_value(cellY))
                    return generating_function(cellX, cellY) * height * -2 + height - 1 + isOrigin *
                               size / 2
                end)
        }
    }
    count = count + 1
end

local elevation = noise.var("elevation")
local prototypes = {
    {
        type = "autoplace-control",
        name = "island-randomness",
        richness = false,
        order = "d-a",
        category = "terrain",
        localised_description = {"autoplace-control-description.island-randomness"}
    }, {
        type = "autoplace-control",
        name = "map-rotation",
        richness = false,
        order = "d-a",
        category = "terrain",
        localised_description = {"autoplace-control-description.map-rotation"}
    }, {
        type = "autoplace-control",
        name = "overall-resources",
        richness = false,
        order = "a",
        category = "resource",
        localised_description = {"autoplace-control-description.overall-resources"}
    }, {
        type = "noise-expression",
        name = "control-setting:island-randomness:frequency:multiplier",
        expression = noise.to_noise_expression(1)
    }, {
        type = "noise-expression",
        name = "control-setting:island-randomness:bias",
        expression = noise.to_noise_expression(0)
    }, {
        type = "noise-expression",
        name = "control-setting:map-rotation:frequency:multiplier",
        expression = noise.to_noise_expression(1 / 6)
    }, {
        type = "noise-expression",
        name = "control-setting:map-rotation:bias",
        expression = noise.to_noise_expression(-1)
    }, {
        type = "noise-expression",
        name = "control-setting:overall-resources:frequency:multiplier",
        expression = noise.to_noise_expression(1)
    }, {
        type = "noise-expression",
        name = "control-setting:overall-resources:size:multiplier",
        expression = noise.to_noise_expression(0)
    }, {
        type = "noise-expression",
        name = "fractured-world-concentric-circles",
        order = "4000",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local voronoi = noise.var("fractured-world-circles")
            return noise.ridge(voronoi, -10, 20)
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-temperature",
        order = "4000",
        expression = modulo(noise.var("fw_value") * 47) * temperatureRange + temperatureFloor
    }, {
        type = "noise-expression",
        name = "fractured-world-aux",
        order = "4000",
        expression = modulo(noise.var("fw_value") * 631)
    }, {
        type = "noise-expression",
        name = "fractured-world-moisture",
        order = "4000",
        expression = noise.var("fw_value")
    }, {
        type = "noise-expression",
        name = "fractured-world-cartesian-value",
        intended_property = "fw_value",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local rotatedCoordinates = functions.rotate_map()
            x = rotatedCoordinates.x
            y = rotatedCoordinates.y
            x = x + size / 2
            y = y + size / 2
            return functions.get_random_point(floorDiv(x, size), floorDiv(y, size), functions.size)
                       .val
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-chessboard-distance",
        -- intended_property = "fw_distance",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local rotatedCoordinates = functions.rotate_map()
            x = rotatedCoordinates.x
            y = rotatedCoordinates.y

            local distanceToOrigin = functions.distance(x, y, "chessboard")
            local starting_factor = noise.clamp((distanceToOrigin - size) * math.huge, -1, 1)
            x = modulo(x + size / 2, size) - size / 2
            y = modulo(y + size / 2, size) - size / 2
            return functions.distance(x, y, "chessboard") * starting_factor
        end)
    }, {
        type = "noise-expression",
        name = "fw-scaling-noise",
        expression = {
            type = "function-application",
            function_name = "factorio-quick-multioctave-noise",
            arguments = {
                x = noise.var("x"),
                y = noise.var("y"),
                seed0 = tne(004),
                seed1 = noise.var("map_seed"),
                input_scale = tne(1 / 10 * noise.var("segmentation_multiplier")),
                output_scale = tne(10),
                octaves = tne(4),
                octave_output_scale_multiplier = tne(2),
                octave_input_scale_multiplier = tne(0.8)
            }
        }
    }, {
        type = "noise-expression",
        name = "fw-large-noise",
        expression = {
            type = "function-application",
            function_name = "factorio-quick-multioctave-noise",
            arguments = {
                x = noise.var("x"),
                y = noise.var("y"),
                seed0 = tne(004),
                seed1 = noise.var("map_seed"),
                input_scale = tne(1 / 10 *
                                      noise.var("control-setting:overall-resources:size:multiplier")),
                output_scale = tne(10),
                octaves = tne(4),
                octave_output_scale_multiplier = tne(2),
                octave_input_scale_multiplier = tne(0.8)
            }
        }
    }, {
        type = "noise-expression",
        name = "fw-small-noise",
        expression = {
            type = "function-application",
            function_name = "factorio-quick-multioctave-noise",
            arguments = {
                x = noise.var("x"),
                y = noise.var("y"),
                seed0 = tne(004),
                seed1 = noise.var("map_seed"),
                input_scale = tne(2 / 10),
                output_scale = tne(10),
                octaves = tne(4),
                octave_output_scale_multiplier = tne(2),
                octave_input_scale_multiplier = tne(0.8)
            }
        }
    }, --[[{
        type = "noise-expression",
        name = "ridges",
        order = "4000",
        intended_property = "elevation",
        expression = (fnp.make_ridges(4, 10, 0.5, 0.5) * 100 - 50)
    }, ]] {
        type = "noise-expression",
        name = "fw_distance",
        intended_property = "fw_distance",
        expression = tne(0)
    }, {
        type = "noise-expression",
        name = "fw_value",
        intended_property = "fw_value",
        expression = noise.var("fractured-world-value-default")
    }, {
        type = "noise-expression",
        name = "fw_land_density",
        expression = (75.17 * waterLevel ^ 2 - 18503 * waterLevel + 451000)
    },
    {type = "noise-expression", name = "fw_rotated_x", expression = tne(functions.rotate_map().x)},
    {type = "noise-expression", name = "fw_rotated_y", expression = tne(functions.rotate_map().y)},
    {
        type = "noise-expression",
        name = "fractured-world-infinite-coastline",
        expression = tne(functions.rotate_map().x + 120)
    }, {
        type = "noise-expression",
        name = "fractured-world-land-grid",
        expression = noise.define_noise_function(function(x, y, tile, map)
            x = noise.floor(x)
            y = noise.floor(y)
            local isLand = noise.clamp(noise.clamp(elevation, -1, 1) * math.huge, 0, 1)
            x = modulo(x, 32)
            y = modulo(y, 32)
            local isGrid = 1 - noise.clamp(x * y, 0, 1)
            local isLand = noise.less_than(-elevation, 0)
            local isGrid = noise.equals(x * y, 0)
            return 1000 * (isGrid) * (isLand) - 500
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-water-grid",
        expression = noise.define_noise_function(function(x, y, tile, map)
            x = noise.floor(x)
            y = noise.floor(y)
            --[[local isWater = noise.clamp(noise.clamp(-elevation, -1, 1) * math.huge, 0, 1)]]
            x = modulo(x, 32)
            y = modulo(y, 32)
            --[[local isGrid = 1 - noise.clamp(x * y, 0, 1)]]
            local isWater = noise.less_than(elevation, 0)
            local isGrid = noise.equals(x * y, 0)
            return 10000 * isGrid * (isWater) - 500
        end)
    }
    --[[{type = "noise-expression", name = "fractured-world-web", intended_property = "elevation"}]]
}
data:extend(prototypes)
data.raw.tile["lab-dark-1"].autoplace = {probability_expression = tne(-math.huge)}
data.raw.tile["deepwater-green"].autoplace = {probability_expression = tne(-math.huge)}

return {
    make_voronoi_noise_expressions = make_voronoi_noise_expressions,
    make_cartesian_noise_expressions = make_cartesian_noise_expressions
}
