local mgp = data.raw["map-gen-presets"].default
mgp["fractured-preset"] = {
    name = "fractured-world-default",
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
mgp["circles"] = {
    name = "fractured-world-circles",
    order = "i",
    basic_settings = {
        property_expression_names = {
            elevation = "voronoi-circles",
            moisture = "voronoi-value-circles",
            temperature = "new-temperature",
            aux = "new-aux"
        },
        cliff_settings = {richness = 0}
    }
}

mgp["squares"] = {
    name = "fractured-world-squares",
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

mgp["diamonds"] = {
    name = "fractured-world-diamonds",
    order = "j",
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

mgp["spiral"] = {
    name = "fractured-world-spiral",
    order = "k",
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

-- mgp["waves"] = {}

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
