local fnp = require("prototypes.fractured-noise-programs")
return {
    ["default"] = {
        presetDefaults = {
            frequency = 1,
            size = 1,
            water = 0.5
        },
        voronoi = {
            class = "two-point",
            waterInfluence = 3
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
        presetDefaults = {
            frequency = 6,
            size = 3 / 4,
            water = 1 / 4
        },
        voronoi = {
            class = "two-point",
            pointType = "hexagon",
            waterInfluence = 3,
            aspectRatio = math.sqrt(3 / 4),
            waterOffset = 100,
            offsetFactor = 0
        }
    },
    ["spiral"] = {
        defaultSize = 64,
        presetDefaults = {frequency = 6},
        cartesian = fnp.on_spiral
    },
    ["waves"] = {
        defaultSize = 64,
        presetDefaults = {frequency = 6, size = 6},
        cartesian = fnp.waves
    },
    ["random-squares"] = {
        defaultSize = 64,
        presetDefaults = {frequency = 6},
        cartesian = fnp.is_random_square
    },
    ["polytopic"] = {
        defaultSize = 64,
        cartesian = fnp.is_polytopic_square
    }
}
