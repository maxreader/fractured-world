local fnp = require("prototypes.fractured-noise-programs")
return {
    ["default"] = {
        voronoi = {class = "two-point", waterInfluence = 4}
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
            size = 1 / 6,
            water = 1 / 4
        },
        voronoi = {
            class = "two-point",
            pointType = "hexagon",
            waterOffsset = 150,
            aspectRatio = math.sqrt(3 / 4)
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
    }
}
