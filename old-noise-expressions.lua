--[[{
        type = "noise-expression",
        name = "fractured-world-default",
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
        name = "fractured-world-value-circles",
        intended_property = "moisture",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local points = get_closest_point_and_value(x, y)
            local value = points.value
            return noise.absolute_value(value)
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-value-squares",
        intended_property = "moisture",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local points = get_closest_point_and_value(x, y, "chessboard")
            local value = points.value
            return noise.absolute_value(value)
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-value-bricks",
        intended_property = "moisture",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local points = get_closest_point_and_value(x, y, "chessboard", "brick")
            local value = points.value
            return noise.absolute_value(value)
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-value-hexagons",
        intended_property = "moisture",
        expression = noise.define_noise_function(function(x, y, tile, map)
            y = y * math.sqrt(3 / 4)
            local points = get_closest_point_and_value(x, y, "euclidean", "hexagon")
            local value = points.value
            return noise.absolute_value(value)
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-value-diamonds",
        intended_property = "moisture",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local points = get_closest_point_and_value(x, y, "rectilinear")
            local value = points.value
            return noise.absolute_value(value)
        end)
    },]] --[[{
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
        name = "fractured-world-squares",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local point = get_closest_point(x, y, "chessboard")
            return
                (map.wlc_elevation_offset * 6 - 2 * point.distance * map.segmentation_multiplier +
                    defaultSize / 2 + noise.var("small-noise") / 15 * small_noise_factor + 100)
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-diamonds",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local point = get_closest_point(x, y, "rectilinear")
            return
                (map.wlc_elevation_offset * 6 - 2 * point.distance * map.segmentation_multiplier +
                    defaultSize / 2 + noise.var("small-noise") / 15 * small_noise_factor + 100)
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-bricks",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            local point = get_closest_point(x, y, "chessboard", "brick")
            return
                (map.wlc_elevation_offset * 6 - 2 * point.distance * map.segmentation_multiplier +
                    defaultSize / 2 + noise.var("small-noise") / 15 * small_noise_factor + 100)
        end)
    }, {
        type = "noise-expression",
        name = "fractured-world-hexagons",
        intended_property = "elevation",
        expression = noise.define_noise_function(function(x, y, tile, map)
            y = y * math.sqrt(3 / 4)
            local result = get_closest_two_points(x, y, "euclidean", "hexagon")
            local d1 = result.distance
            local d2 = result.secondDistance
            return (6 * map.wlc_elevation_offset - (d1 - d2) * map.segmentation_multiplier) -
                       defaultSize / 2 + noise.var("small-noise") / 15 * small_noise_factor + 150
        end)
    },]] 
