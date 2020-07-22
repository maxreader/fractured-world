local noise = require("noise")
local tne = noise.to_noise_expression

local fnp = require("fractured-noise-programs")
local get_closest_point_and_value = fnp.get_closest_point_and_value
local get_closest_two_points = fnp.get_closest_two_points
local small_noise_factor = fnp.small_noise_factor
local defaultSize = fnp.defaultSize
local size = fnp.size

local functions = require("functions")
local floorDiv = functions.floorDiv
local modulo = functions.modulo
local distance = functions.distance

local temperatureRange = 60
local temperatureFloor = -25
if mods["alien-biomes"] then
    temperatureRange = 170
    temperatureFloor = -20
end

local fracturedWorlds = {
    ["default"] = {class = "two-point", waterInfluence = 4},
    ["circles"] = {},
    ["squares"] = {distanceType = "chessboard"},
    ["diamonds"] = {distanceType = "rectilinear"},
    ["bricks"] = {
        distanceType = "chessboard",
        pointType = "brick"
    },
    ["hexagons"] = {
        class = "two-point",
        pointType = "hexagon",
        waterOffset = 150,
        aspectRatio = math.sqrt(3 / 4)
    }
}

local function make_fractured_world(name, params)
    local class = params.class or "one-point"
    local distanceType = params.distanceType or "euclidean"
    local pointType = params.pointType or "random"
    local waterInfluence = params.waterInfluence or 6
    local waterOffset = params.waterOffset or 100
    local aspectRatio = params.aspectRatio or 1
    local elevation
    local value
    local pointDistance

    local scale = noise.var("segmentation_multiplier")
    local x = noise.var("x")
    local y = noise.var("y") * aspectRatio
    local waterSlider = noise.var("wlc_elevation_offset")

    if class == "one-point" then
        local point = get_closest_point_and_value(x, y, distanceType, pointType)
        elevation = (waterSlider * waterInfluence - 2 * point.distance * scale + defaultSize / 2 +
                        noise.var("small-noise") / 15 * small_noise_factor + waterOffset)
        value = point.value
        pointDistance = point.distance
    elseif class == "two-point" then
        local points = get_closest_two_points(x, y, distanceType, pointType)
        local d1 = points.distance
        local d2 = points.secondDistance
        elevation = (waterInfluence * waterSlider - (d1 - d2) * scale) - defaultSize / 2 +
                        noise.var("small-noise") / 15 * small_noise_factor + waterOffset
        value = points.value
        pointDistance = points.distance
    end

    data:extend{
        {
            type = "noise-expression",
            name = "fractured-world-" .. name,
            intended_property = "elevation",
            expression = elevation
        }, {
            type = "noise-expression",
            name = "fractured-world-value-" .. name,
            intended_property = "moisture",
            expression = value
        }, {
            type = "noise-expression",
            name = "fractured-world-point-distance-" .. name,
            intended_property = "fw-distance",
            expression = pointDistance
        }
    }
end
for name, params in pairs(fracturedWorlds) do make_fractured_world(name, params) end

local cellularWorlds = {
    ["spiral"] = fnp.on_spiral,
    ["waves"] = fnp.waves
}
for name, generating_function in pairs(cellularWorlds) do
    data:extend{
        {
            type = "noise-expression",
            name = "fractured-world-" .. name,
            intended_property = "elevation",
            expression = noise.define_noise_function(
                function(x, y, tile, map)
                    local cellX = floorDiv(x, size)
                    local cellY = floorDiv(y, size)
                    local localX = noise.absolute_value(modulo(x, size) - size / 2) - 1
                    local localY = noise.absolute_value(modulo(y, size) - size / 2) - 1
                    local height = size / 2 - distance(localX, localY, "chessboard")
                    return generating_function(cellX, cellY) * height * -2 + height - 1
                end)
        }
    }
end

data:extend{
    {
        type = "autoplace-control",
        name = "island-randomness",
        richness = false,
        order = "d-a",
        category = "terrain",
        localised_description = {
            "autoplace-control-description.island-randomness"
        }
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
        name = "fractured-world-concentric-circles",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local voronoi = noise.var("fractured-world-circles")
            return noise.ridge(voronoi, -10, 20)
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-temperature",
        expression = modulo(noise.var("moisture")) * temperatureRange + temperatureFloor
    }, {
        type = "noise-expression",
        name = "fractured-world-aux",
        expression = modulo(noise.var("moisture") * 134)
    }, {
        type = "noise-expression",
        name = "small-noise",
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
        name = "ridges",
        intended_property = "elevation",
        expression = (fnp.make_ridges(4, 10, 0.5, 0.5) * 100 - 50) * functions.rof ^ 0.5 +
            (size - fnp.make_grid() + 25.6) * (1 - functions.rof ^ 0.5) / 51.2 + 5
    }
}
