local mgp = data.raw["map-gen-presets"].default
local preset_properties = {
    ["default"] = {},
    ["circles"] = {},
    ["squares"] = {},
    ["diamonds"] = {},
    ["bricks"] = {frequency = 6, size = 3 / 2},
    ["hexagons"] = {
        frequency = 6,
        size = 1 / 6,
        water = 1 / 4
    },
    ["spiral"] = {
        frequency = 6,
        size = 3,
        moisture = "squares"
    },
    ["waves"] = {
        frequency = 1,
        size = 6,
        moisture = "squares"
    }
}
local count = 1
for name, properties in pairs(preset_properties) do
    local frequency = (properties.frequency) or (1 / 6)
    local size = properties.size or 3
    local water = properties.water or 1
    local elevation = "fractured-world-" .. name
    local moisture
    if properties.moisture == "square" then
        moisture = "fractured-world-value-squares"
    else
        moisture = "fractured-world-value-" .. name
    end

    mgp["fractured-world-" .. name] = {
        order = "h-" .. count,
        basic_settings = {
            property_expression_names = {
                elevation = elevation,
                moisture = moisture,
                temperature = "new-temperature",
                aux = "new-aux"
            },
            cliff_settings = {richness = 0},
            autoplace_controls = {
                ["island-randomness"] = {
                    frequency = frequency,
                    size = size
                }
            },
            water = water
        }
    }
    count = count + 1
end

--[[mgp["fractured-world-default"] = {
    order = "h",
    basic_settings = {
        property_expression_names = {
            elevation = "fractured-world-default",
            moisture = "fractured-world-value-default",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0},
        autoplace_controls = {
            ["island-randomness"] = {
                frequency = 1 / 6,
                size = 3
            }
        }
    }
}
mgp["fractured-world-circles"] = {
    order = "i",
    basic_settings = {
        property_expression_names = {
            elevation = "fractured-world-circles",
            moisture = "fractured-world-value-circles",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0},
        autoplace_controls = {
            ["island-randomness"] = {
                frequency = 1 / 6,
                size = 3
            }
        }
    }
}

mgp["fractured-world-squares"] = {
    order = "j",
    basic_settings = {
        property_expression_names = {
            elevation = "fractured-world-squares",
            moisture = "fractured-world-value-squares",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0},
        autoplace_controls = {
            ["island-randomness"] = {
                frequency = 1 / 6,
                size = 3
            }
        }
    }
}
mgp["fractured-world-bricks"] = {
    order = "k",
    basic_settings = {
        property_expression_names = {
            elevation = "fractured-world-bricks",
            moisture = "fractured-world-value-bricks",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0},
        autoplace_controls = {
            ["island-randomness"] = {
                frequency = 6,
                size = 3 / 2
            }
        }
    }
}

mgp["fractured-world-diamonds"] = {
    order = "l",
    basic_settings = {
        property_expression_names = {
            elevation = "fractured-world-diamonds",
            moisture = "fractured-world-value-diamonds",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0},
        autoplace_controls = {
            ["island-randomness"] = {
                frequency = 1 / 6,
                size = 3
            }
        }
    }
}

mgp["fractured-world-spiral"] = {
    order = "m",
    basic_settings = {
        property_expression_names = {
            elevation = "fractured-world-spiral",
            moisture = "fractured-world-value-squares",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0},
        autoplace_controls = {
            ["island-randomness"] = {
                frequency = 6,
                size = 3
            }
        }
    }
}

mgp["fractured-world-waves"] = {
    order = "n",
    basic_settings = {
        property_expression_names = {
            elevation = "fractured-world-waves",
            moisture = "fractured-world-value-squares",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0},
        autoplace_controls = {
            ["island-randomness"] = {
                frequency = 1,
                size = 6
            }
        }
    }
}
mgp["fractured-world-hexagons"] = {
    order = "n",
    basic_settings = {
        property_expression_names = {
            elevation = "fractured-world-hexagons",
            moisture = "fractured-world-value-hexagons",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0},
        autoplace_controls = {
            ["island-randomness"] = {
                frequency = 6,
                size = 1 / 6
            }
        },
        water = 1 / 4
    }
}]]
