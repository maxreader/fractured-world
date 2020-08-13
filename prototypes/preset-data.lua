local fnp = require("prototypes.fractured-noise-programs")
return {
    ["default"] = {
        presetDefaults = {size = 1, water = 1 / 3},
        voronoi = {
            class = "two-point",
            waterOffset = 125
            -- waterOffset = math.log(1 / 6, 2)
        }
    },
    ["circles"] = {},
    ["squares"] = {voronoi = {distanceType = "chessboard"}},
    ["diamonds"] = {
        voronoi = {distanceType = "rectilinear"}
    },
    ["bricks"] = {
        presetDefaults = {frequency = 6, size = 3 / 2},
        voronoi = {
            distanceType = "chessboard",
            pointType = "brick"
        }
    },
    ["hexagons"] = {
        presetDefaults = {frequency = 6, size = 3 / 4},
        voronoi = {
            -- class = "two-point",
            pointType = "hexagon",
            distanceType = "hexagonal",
            aspectRatio = math.sqrt(3) / 2,
            waterInfluence = 2.5,
            offsetFactor = 0
        }
    },
    ["spiral"] = {
        defaultSize = "fw_half_default_size",
        presetDefaults = {frequency = 6},
        cartesian = fnp.on_spiral
    },
    ["waves"] = {
        defaultSize = "fw_half_default_size",
        presetDefaults = {frequency = 6, size = 6},
        cartesian = fnp.waves
    },
    ["random-squares"] = {
        defaultSize = "fw_half_default_size",
        presetDefaults = {frequency = 6},
        cartesian = fnp.is_random_square
    },
    ["polytopic"] = {
        defaultSize = "fw_half_default_size",
        cartesian = fnp.is_polytopic_square
    },
    ["trellis"] = {
        defaultSize = "fw_half_default_size",
        rotation = {0, 1},
        cartesian = fnp.is_trellis_square
    }
}
