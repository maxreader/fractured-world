local mgp = data.raw["map-gen-presets"].default
local functions = require("prototypes.functions")

--[[data:extend{
    {
        type = "noise-expression",
        name = "debug",
        expression = noise.var("finite_water_level") * 100
    }
}

mgp["fw-debug"] = {
    order = "h",
    basic_settings = {
        property_expression_names = {
            ["entity:iron-ore:richness"] = "debug",
            ["entity:iron-ore:probability"] = 10,
            elevation = 10
        }
    }
} -- ]]

local count_to_order = functions.count_to_order
local function make_special_preset(name, args, count)
    local mapRotation = args.rotation or {6, 1 / 6}
    if name == "infinite-coastline" then
        mgp["special-fractured-world-" .. name] = {
            order = "h-" .. count_to_order(count),
            basic_settings = {
                property_expression_names = {
                    elevation = "fw_rotated_x"
                },
                autoplace_controls = {
                    ["map-rotation"] = {
                        frequency = mapRotation[1],
                        size = mapRotation[2]
                    }
                }
            }
        }
    end
end

local count = 0
local function make_preset(name, args)
    if args.special then
        make_special_preset(name, args, count)
        count = count + 1
        return
    end
    local presetDefaults = args.presetDefaults or {}
    local frequency = (presetDefaults.frequency) or (1 / 6)
    local size = presetDefaults.size or 1
    local water = presetDefaults.water or 1
    local elevation = "fractured-world-" .. name
    local fw_distance = "fractured-world-point-distance-" .. name
    local moisture = "fractured-world-value-" .. name
    if args.cartesian then
        moisture = "fractured-world-cartesian-value"
        fw_distance = "fractured-world-chessboard-distance"
    end
    local defaultSize = args.defaultSize or "fw_default_size"
    local mapRotation = args.rotation or {6, 1 / 6}

    mgp["fractured-world-" .. name] = {
        order = "h-" .. count_to_order(count),
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
                },
                ["map-rotation"] = {
                    frequency = mapRotation[1],
                    size = mapRotation[2]
                }
            },
            water = water
        }
    }
    count = count + 1
end
return make_preset
