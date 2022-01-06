local mgp = data.raw["map-gen-presets"].default
local functions = require("prototypes.functions")
local fne = require("prototypes.fractured-noise-expressions")
local make_cartesian_noise_expressions = fne.make_cartesian_noise_expressions
local make_voronoi_noise_expressions = fne.make_voronoi_noise_expressions

local include_void_tiles = settings.startup["fractured-world-use-void-tiles"]
                               .value

if include_void_tiles then data.raw.tile["out-of-map"].autoplace = {} end

local noise = require("noise")
local radius = noise.absolute_value(noise.var(
                                        "fractured-world-point-distance-diamonds"))

local scaledRadius = (1 - radius / functions.size) * 100 - 50

data:extend({
    {
        type = "noise-expression",
        name = "scaled-radius",
        expression = scaledRadius
    }, {
        type = "noise-expression",
        name = "void-probability",
        expression = -noise.var("elevation") * 100
    }
})

local count_to_order = functions.count_to_order

local count = 0
local function make_preset(name, args)
    local fracturedControls = args.fracturedControls or {}
    local frequency = (fracturedControls.frequency) or (1 / 6)
    local size = fracturedControls.size or 1
    local mapRotation = args.rotation or {6, 1 / 6}
    local property_expression_names = {}
    if args.cartesian or args.voronoi then
        if args.cartesian then
            make_cartesian_noise_expressions(name, args)
        else
            make_voronoi_noise_expressions(name, args)
        end
        local elevation = "fractured-world-" .. name
        local fw_distance = "fractured-world-point-distance-" .. name
        local fw_value = "fractured-world-value-" .. name
        if args.cartesian then
            fw_value = "fractured-world-cartesian-value"
            fw_distance = "fractured-world-chessboard-distance"
        end
        if not (args.voronoi and args.voronoi and args.voronoi.class ==
            "vanilla-islands") then
            property_expression_names = {
                elevation = elevation,
                moisture = "fractured-world-moisture",
                temperature = "fractured-world-temperature",
                aux = "fractured-world-aux",
                fw_value = fw_value,
                fw_distance = fw_distance
            }
        else
            property_expression_names = {
                elevation = elevation,
                fw_value = fw_value,
                fw_distance = fw_distance
            }
        end
    end

    if include_void_tiles then
        property_expression_names["tile:out-of-map:probability"] =
            "void-probability"
    end

    local genericBasicSettings = {
        property_expression_names = property_expression_names,
        cliff_settings = {richness = 0},
        autoplace_controls = {
            ["island-randomness"] = {frequency = frequency, size = size},
            ["map-rotation"] = {
                frequency = mapRotation[1],
                size = mapRotation[2]
            },
            ["overall-resources"] = {richness = 6}
        }
    }
    local mgs = args.basic_settings or {}
    mgs = util.merge {genericBasicSettings, mgs}
    if args.fracturedResources ~= false then
        for k, v in pairs(fractured_world.property_expressions.resource) do
            if not mgs.property_expression_names[k] then
                mgs.property_expression_names[k] = v
            end
        end
    end
    if args.fracturedEnemies ~= false then
        for k, v in pairs(fractured_world.property_expressions.enemy) do
            if not mgs.property_expression_names[k] then
                mgs.property_expression_names[k] = v
            end
        end
    end
    if args.mapGrid == true then
        mgs.property_expression_names["tile:lab-dark-1:probability"] =
            "fractured-world-land-grid"
        mgs.property_expression_names["tile:deepwater-green:probability"] =
            "fractured-world-water-grid"
    end

    mgp["fractured-world-" .. name] = {
        order = "h-" .. count_to_order(count),
        basic_settings = mgs
    }
    count = count + 1
end
for name, args in pairs(fractured_world.preset_data) do make_preset(name, args) end

mgp.default.default = false

--[[mgp["fw-debug"] = {
    order = "h",
    basic_settings = {
        property_expression_names = {
            ["entity:angels-ore1:richness"] = "scaled-radius",
            ["entity:angels-ore1:probability"] = 10,
            elevation = 10
        }
    }   
} -- ]]

--[[data:extend{
    {
        type = "noise-expression",
        name = "debug",
        expression = noise.var("finite_water_level") * 100
    }
}]]
