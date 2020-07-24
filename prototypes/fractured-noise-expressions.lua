local noise = require("noise")
local tne = noise.to_noise_expression

local fnp = require("prototypes.fractured-noise-programs")
local functions = require('prototypes.functions')
local get_closest_point_and_value = fnp.get_closest_point_and_value
local get_closest_two_points = fnp.get_closest_two_points
local small_noise_factor = fnp.small_noise_factor

local floorDiv = functions.floorDiv
local modulo = functions.modulo
local distance = functions.distance

local temperatureRange = 60
local temperatureFloor = -25
if mods["alien-biomes"] then
    temperatureRange = 170
    temperatureFloor = -20
end

local function make_voronoi_preset(name, args)
    local params = args.voronoi or {}
    local class = params.class or "one-point"
    local distanceType = params.distanceType or "euclidean"
    local pointType = params.pointType or "random"
    local waterInfluence = params.waterInfluence or 6
    local waterOffset = params.waterOffset or 100
    local aspectRatio = params.aspectRatio or 1
    local width = functions.size
    local elevation
    local value
    local pointDistance

    local scale = noise.var("segmentation_multiplier")
    local x = noise.var("x")
    local y = noise.var("y") * aspectRatio
    local waterSlider = noise.var("wlc_elevation_offset")

    if class == "one-point" then
        local point = get_closest_point_and_value(x, y, width, distanceType, pointType)
        elevation = (waterSlider * waterInfluence - 2 * point.distance * scale +
                        noise.var("fw_default_size") / 2 + noise.var("small-noise") / 15 *
                        small_noise_factor + waterOffset)
        value = point.value
        pointDistance = point.distance
    elseif class == "two-point" then
        local points = get_closest_two_points(x, y, functions.size, distanceType, pointType)
        local d1 = points.distance
        local d2 = points.secondDistance
        elevation = (waterInfluence * waterSlider - (d1 - d2) * scale) -
                        noise.var("fw_default_size") / 2 + noise.var("small-noise") / 15 *
                        small_noise_factor + waterOffset
        value = points.value
        pointDistance = points.distance
    end

    data:extend{
        {
            type = "noise-expression",
            name = "fractured-world-" .. name,
            order = "4000",
            intended_property = "elevation",
            expression = elevation
        }, {
            type = "noise-expression",
            name = "fractured-world-value-" .. name,
            order = "4000",
            intended_property = "moisture",
            expression = value
        }, {
            type = "noise-expression",
            name = "fractured-world-point-distance-" .. name,
            order = "4000",
            intended_property = "fw_distance",
            expression = pointDistance
        }
    }
end

local function make_cartesian_preset(name, args)
    local size = functions.size
    local generating_function = args.cartesian
    data:extend{
        {
            type = "noise-expression",
            name = "fractured-world-" .. name,
            intended_property = "elevation",
            order = "4000",
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
        expression = modulo(noise.var("moisture")) * temperatureRange + temperatureFloor
    }, {
        type = "noise-expression",
        name = "fractured-world-aux",
        order = "4000",
        expression = modulo(noise.var("moisture") * 631)
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
    }, --[[{
        type = "noise-expression",
        name = "ridges",
        order = "4000",
        intended_property = "elevation",
        expression = (fnp.make_ridges(4, 10, 0.5, 0.5) * 100 - 50) * functions.rof ^ 0.5 +
            (size - fnp.make_grid() + 25.6) * (1 - functions.rof ^ 0.5) / 51.2 + 5
    },]] {
        type = "noise-expression",
        name = "fw_distance",
        intended_property = "fw_distance",
        expression = tne(0)
    }, {
        type = "noise-expression",
        name = "fw_default_size",
        intended_property = "fw_default_size",
        expression = tne(256)
    }
}

return {
    make_voronoi_preset = make_voronoi_preset,
    make_cartesian_preset = make_cartesian_preset
}
