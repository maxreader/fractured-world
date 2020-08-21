local noise = require("noise")
local presetData = require('prototypes.preset-data')
local enemyData = require("prototypes.enemies")
local ores = require("prototypes.ores")
local get_probability = ores.get_probability
local get_richness = ores.get_richness
local currentResourceData = ores.currentResourceData
local get_infinite_probability = ores.get_infinite_probability
local get_infinite_richness = ores.get_infinite_richness
local infiniteOreData = ores.infiniteOreData

local fw_property_expressions = {}
for ore, _ in pairs(currentResourceData) do
    local probName = "fractured-world-" .. ore .. "-probability"
    local richName = "fractured-world-" .. ore .. "-richness"
    local probability_expression = get_probability(ore)
    data:extend{
        {
            type = "noise-expression",
            name = probName,
            expression = probability_expression
        }, {
            type = "noise-expression",
            name = richName,
            expression = get_richness(ore)
        }
    }
    fw_property_expressions["entity:" .. ore .. ":probability"] = probName
    fw_property_expressions["entity:" .. ore .. ":richness"] = richName
end

for ore, _ in pairs(infiniteOreData) do
    local probName = "fractured-world-" .. ore .. "-probability"
    local richName = "fractured-world-" .. ore .. "-richness"
    data:extend{
        {
            type = "noise-expression",
            name = probName,
            expression = get_infinite_probability(ore)
        }, {
            type = "noise-expression",
            name = richName,
            expression = get_infinite_richness(ore)
        }
    }
    fw_property_expressions["entity:" .. ore .. ":probability"] = probName
    fw_property_expressions["entity:" .. ore .. ":richness"] = richName
end

--[[local overhaulBiters = (not mods["angelsrefining"]) or mods["angelsexploration"] or
                           settings.startup["angels-enable-biters"].value]]

for _, enemyType in pairs(enemyData) do
    for name, v in pairs(enemyType) do
        if v.probability_expression then
            local probName = "fractured-world-" .. name .. "-probability"
            data:extend{
                {
                    type = "noise-expression",
                    name = probName,
                    expression = v.probability_expression
                }
            }
            fw_property_expressions["entity:" .. name .. ":probability"] = probName
        end
    end
end

for name, preset in pairs(data.raw["map-gen-presets"].default) do
    if string.match(name, "^fractured%-world") then
        for k, v in pairs(fw_property_expressions) do
            preset.basic_settings.property_expression_names[k] = v
        end
    end
end

