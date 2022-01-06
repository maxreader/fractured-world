return {
    ["default"] = {
        fracturedControls = {size = 1},
        basic_settings = {water = 1 / 3},
        voronoi = {
            class = "two-point",
            waterOffset = 125
            -- waterOffset = math.log(1 / 6, 2)
        }
    },
    ["vanilla-islands"] = {
        voronoi = {class = "vanilla-islands", vanillaIslands = true},
        fracturedResources = false,
        fracturedEnemies = false
    },
    ["gears"] = {
        fracturedControls = {size = 0.5},
        voronoi = {distanceModifier = "gear"}
    },
    ["circles"] = {voronoi = {}},
    ["squares"] = {
        fracturedControls = {frequency = 6},
        voronoi = {distanceType = "chessboard"}
    },
    ["diamonds"] = {voronoi = {distanceType = "rectilinear"}},
    ["bricks"] = {
        fracturedControls = {frequency = 6, size = 3 / 2},
        voronoi = {distanceType = "chessboard", pointType = "brick"}
    },
    ["hexagons"] = {
        fracturedControls = {frequency = 6, size = 3 / 4},
        voronoi = {
            pointType = "hexagon",
            aspectRatio = math.sqrt(3) / 2,
            waterInfluence = 2.5,
            offsetFactor = 0,
            distanceModifier = "hexagon"
        }
    },
    ["flowers"] = {
        fracturedControls = {size = 0.5},
        voronoi = {distanceModifier = "flower"}
    }, --[[,
    ["web"] = {
        voronoi = {class = "two-point", use_web = true}
    },]]
    ["spiral"] = {
        defaultSize = "fw_half_default_size",
        fracturedControls = {frequency = 6},
        cartesian = "on_spiral",
        land_density = 0.5
    },
    ["waves"] = {
        defaultSize = "fw_half_default_size",
        fracturedControls = {frequency = 6, size = 6},
        cartesian = "waves",
        basic_settings = {
            autoplace_controls = {["overall-resources"] = {size = 0.5}}
        }
    },
    ["trellis"] = {
        defaultSize = "fw_half_default_size",
        rotation = {1, 2},
        cartesian = "is_trellis_square",
        basic_settings = {
            autoplace_controls = {["overall-resources"] = {size = 0.5}}
        },
        land_density = 0.75
    },
    ["chessboard"] = {
        defaultSize = "fw_half_default_size",
        cartesian = "is_chessboard_square",
        basic_settings = {
            autoplace_controls = {["overall-resources"] = {size = 0.5}}
        },
        land_density = 0.5
    },
    ["random-squares"] = {
        defaultSize = "fw_half_default_size",
        fracturedControls = {frequency = 6},
        cartesian = "is_random_square",
        basic_settings = {
            autoplace_controls = {["overall-resources"] = {size = 0.5}}
        }
    },
    ["polytopic"] = {
        defaultSize = "fw_half_default_size",
        fracturedControls = {frequency = 2 / 3},
        cartesian = "is_polytopic_square",
        basic_settings = {
            autoplace_controls = {["overall-resources"] = {size = 0.5}}
        }
    },
    ["maze"] = {
        defaultSize = "fw_half_default_size",
        cartesian = "is_maze_square",
        basic_settings = {
            autoplace_controls = {
                ["overall-resources"] = {frequency = 2, size = 0.5},
                ["island-randomness"] = {frequency = 3 / 4}

            }
        }
        -- fracturedResources = false
    },
    ["infinite-coastline"] = {
        basic_settings = {
            property_expression_names = {
                elevation = "fractured-world-infinite-coastline"
            }
        },
        fracturedResources = false,
        fracturedEnemies = false
    },
    --[[["gridworld"] = {
        mapGrid = true,
        fracturedResources = false,
        fracturedEnemies = false
    },]]
    ["fractured-resources"] = {
        fracturedControls = {frequency = 6, size = 3 / 2},
        fracturedEnemies = false,
        basic_settings = {
            property_expression_names = {
                ["fw_value"] = "fractured-world-value-diamonds",
                ["fw_distance"] = "fractured-world-point-distance-circles"
            },
            autoplace_controls = {
                ["overall-resources"] = {frequency = 1 / 6, size = 0.5}
            }
        }
    }
}
