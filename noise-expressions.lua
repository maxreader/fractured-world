local noise = require("noise")
local tne = noise.to_noise_expression

local fnp = require("fractured-noise-programs")
local get_closest_point = fnp.get_closest_point
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

data:extend{
    {
        type = "autoplace-control",
        name = "island-randomness",
        richness = false,
        order = "d-a",
        category = "terrain"
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
        name = "fractured-world-circles",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local point = get_closest_point(x, y)
            return
                (map.wlc_elevation_offset * 6 - 2 * point.distance * map.segmentation_multiplier +
                    defaultSize / 2 + noise.var("small-noise") / 15 * small_noise_factor + 100)
        end)
    }, {
        type = "noise-expression",
        name = "voronoi-squares",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local point = get_closest_point(x, y, "chessboard")
            return
                (map.wlc_elevation_offset * 6 - 2 * point.distance * map.segmentation_multiplier +
                    defaultSize / 2 + noise.var("small-noise") / 15 * small_noise_factor + 100)
        end)
    }, {
        type = "noise-expression",
        name = "brick",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local point = get_closest_point(x, y, "chessboard", "brick")
            return
                (map.wlc_elevation_offset * 6 - 2 * point.distance * map.segmentation_multiplier +
                    defaultSize / 2 + noise.var("small-noise") / 15 * small_noise_factor + 100)
        end)
    }, {
        type = "noise-expression",
        name = "hexagons",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            y = y * math.sqrt(3 / 4)
            local result = get_closest_two_points(x, y, "euclidean", "hexagon")
            local d1 = result.distance
            local d2 = result.secondDistance
            return (7 * map.wlc_elevation_offset - (d1 - d2) * map.segmentation_multiplier) -
                       defaultSize / 2 + noise.var("small-noise") / 15 * small_noise_factor + 150
        end)
    }, {
        type = "noise-expression",
        name = "voronoi-diamonds",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local point = get_closest_point(x, y, "rectilinear")
            return
                (map.wlc_elevation_offset * 6 - 2 * point.distance * map.segmentation_multiplier +
                    defaultSize / 2 + noise.var("small-noise") / 15 * small_noise_factor + 100)
        end)
    }, {
        type = "noise-expression",
        name = "ridged-voronoi",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local voronoi = noise.var("fractured-world-circles")
            return noise.ridge(voronoi, -10, 20)
        end)
    }, {
        type = "noise-expression",
        name = "voronoi-border",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local result = get_closest_two_points(x, y)
            local d1 = result.distance
            local d2 = result.secondDistance
            return (4 * map.wlc_elevation_offset - (d1 - d2) * map.segmentation_multiplier) -
                       defaultSize / 2 + noise.var("small-noise") / 15 * small_noise_factor + 100
        end)
    }, {
        type = "noise-expression",
        name = "voronoi-value-circles",
        intended_property = "moisture",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local points = get_closest_point_and_value(x, y)
            local value = points.value
            return noise.absolute_value(value)
        end)
    }, {
        type = "noise-expression",
        name = "voronoi-value-squares",
        intended_property = "moisture",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local points = get_closest_point_and_value(x, y, "chessboard")
            local value = points.value
            return noise.absolute_value(value)
        end)
    }, {
        type = "noise-expression",
        name = "value-brick",
        intended_property = "moisture",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local points = get_closest_point_and_value(x, y, "chessboard", "brick")
            local value = points.value
            return noise.absolute_value(value)
        end)
    }, {
        type = "noise-expression",
        name = "value-hexagons",
        intended_property = "moisture",
        expression = noise.define_noise_function(function(x, y, tile, map)
            y = y * math.sqrt(3 / 4)
            local points = get_closest_point_and_value(x, y, "euclidean", "hexagon")
            local value = points.value
            return noise.absolute_value(value)
        end)
    }, {
        type = "noise-expression",
        name = "voronoi-value-diamonds",
        intended_property = "moisture",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local points = get_closest_point_and_value(x, y, "rectilinear")
            local value = points.value
            return noise.absolute_value(value)
        end)
    }, {
        type = "noise-expression",
        name = "new-temperature",
        expression = modulo(noise.var("moisture")) * temperatureRange + temperatureFloor
    }, {
        type = "noise-expression",
        name = "new-aux",
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
        name = "spiral",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local cellX = floorDiv(x, size)
            local cellY = floorDiv(y, size)
            local localX = modulo(x, size)
            local localY = modulo(y, size)
            local height = size / 2 - distance(localX - size / 2, localY - size / 2, "chessboard")
            height = -5
            return fnp.on_spiral(cellX, cellY) * height * -2 + height
        end)
    }, {
        type = "noise-expression",
        name = "waves",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local cellX = floorDiv(x, size)
            local cellY = floorDiv(y, size)
            local localX = modulo(x, size)
            local localY = modulo(y, size)
            local height = size / 2 - distance(localX - size / 2, localY - size / 2, "chessboard")
            height = -5

            return 10 * fnp.waves(cellX, cellY) - 5
        end)
    } --[[{
        type = "noise-expression",
        name = "hilbert",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            y = 0 - y
            return 10 * my_hilbert(floorDiv(x, size) + n / 2, floorDiv(y, size) + n / 2, n) - 5
        end)
    }]]

}
