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
    ["spiral"] = {frequency = 6, moisture = "squares"},
    ["waves"] = {
        frequency = 6,
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
    local fw_distance = "fractured-world-point-distance-" .. name
    local moisture = "fractured-world-value-" .. name
    if properties.moisture == "squares" then
        moisture = "fractured-world-value-squares"
        fw_distance = "fractured-world-point-distance-squares"
    end

    mgp["fractured-world-" .. name] = {
        order = "h-" .. count,
        basic_settings = {
            property_expression_names = {
                elevation = elevation,
                moisture = moisture,
                temperature = "fractured-world-temperature",
                aux = "fractured-world-aux",
                fw_distance = fw_distance
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

mgp["fw-debug"] = {
    order = "h",
    basic_settings = {
        property_expression_names = {
            ["entity:iron-ore:richness"] = "ridges",
            ["entity:iron-ore:probability"] = 10,
            elevation = 10
        }
    }
}
