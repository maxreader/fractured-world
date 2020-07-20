local mgp = data.raw["map-gen-presets"].default
mgp["fractured-world-default"] = {
    order = "h",
    basic_settings = {
        property_expression_names = {
            elevation = "voronoi-border",
            moisture = "voronoi-value-circles",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0}
    }
}
mgp["fractured-world-circles"] = {
    order = "i",
    basic_settings = {
        property_expression_names = {
            elevation = "fractured-world-circles",
            moisture = "voronoi-value-circles",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0}
    }
}

mgp["fractured-world-squares"] = {
    order = "j",
    basic_settings = {
        property_expression_names = {
            elevation = "voronoi-squares",
            moisture = "voronoi-value-squares",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0}
    }
}
mgp["fractured-world-brick"] = {
    order = "k",
    basic_settings = {
        property_expression_names = {
            elevation = "brick",
            moisture = "value-brick",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0}
    }
}

mgp["fractured-world-diamonds"] = {
    order = "l",
    basic_settings = {
        property_expression_names = {
            elevation = "voronoi-diamonds",
            moisture = "voronoi-value-diamonds",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0}
    }
}

mgp["fractured-world-spiral"] = {
    order = "m",
    basic_settings = {
        property_expression_names = {
            elevation = "spiral",
            moisture = "voronoi-value-squares",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0}
    }
}

mgp["fractured-world-waves"] = {
    order = "n",
    basic_settings = {
        property_expression_names = {
            elevation = "waves",
            moisture = "voronoi-value-squares",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0}
    }
}
mgp["fractured-world-hexagons"] = {
    order = "n",
    basic_settings = {
        property_expression_names = {
            elevation = "hexagons",
            moisture = "value-hexagons",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0}
    }
}

--[[mgp["hilbert"] = {
    name = "hilbert",
    order = "l",
    basic_settings = {
        property_expression_names = {
            elevation = "hilbert",
            moisture = "voronoi-value-squares",
            temperature = "new-temperature",
            aux = "new-aux",
            ["entity:iron-ore:richness"] = "hilbert",
            ["entity:iron-ore:probability"] = 10
        },
        cliff_settings = {richness = 0}
    }
}]]
