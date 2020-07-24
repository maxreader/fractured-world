local mgp = data.raw["map-gen-presets"].default

--[[mgp["fw-debug"] = {
    order = "h",
    basic_settings = {
        property_expression_names = {
            ["entity:iron-ore:richness"] = "ridges",
            ["entity:iron-ore:probability"] = 10,
            elevation = 10
        }
    }
}]]

local count = 0
local function make_preset(name, args)
    local presetDefaults = args.presetDefaults or {}
    local frequency = (presetDefaults.frequency) or (1 / 6)
    local size = presetDefaults.size or 3
    local water = presetDefaults.water or 1
    local elevation = "fractured-world-" .. name
    local fw_distance = "fractured-world-point-distance-" .. name
    local moisture = "fractured-world-value-" .. name
    if args.cartesian then
        moisture = "fractured-world-value-squares"
        fw_distance = "fractured-world-point-distance-squares"
    end
    local defaultSize = "fw_default_size"
    if args.defaultSize then defaultSize = "fw_default_size_" .. name end

    mgp["fractured-world-" .. name] = {
        order = "h-" .. count,
        basic_settings = {
            property_expression_names = {
                elevation = elevation,
                moisture = moisture,
                temperature = "fractured-world-temperature",
                aux = "fractured-world-aux",
                fw_distance = fw_distance,
                fw_default_size = defaultSize
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
return make_preset
