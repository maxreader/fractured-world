local enemyData = require("prototypes.enemies")
local ores = require("prototypes.ores")
local get_probability = ores.get_probability
local get_richness = ores.get_richness
local currentResourceData = ores.currentResourceData
local get_infinite_probability = ores.get_infinite_probability
local get_infinite_richness = ores.get_infinite_richness
local infiniteOreData = ores.infiniteOreData

for resource, _ in pairs(currentResourceData) do
    local probability_expression = get_probability(resource)
    local richness_expression = get_richness(resource)
    fractured_world:add_property_expression(resource, "resource", "probability",
                                            probability_expression)
    fractured_world:add_property_expression(resource, "resource", "richness", richness_expression)
end

for resource, _ in pairs(infiniteOreData) do
    local probability_expression = get_infinite_probability(resource)
    local richness_expression = get_infinite_richness(resource)
    fractured_world:add_property_expression(resource, "resource", "probability",
                                            probability_expression)
    fractured_world:add_property_expression(resource, "resource", "richness", richness_expression)
end

for _, enemyType in pairs(enemyData) do
    for name, v in pairs(enemyType) do
        local probability_expression = v.probability_expression
        if probability_expression then
            fractured_world:add_property_expression(name, "enemy", "probability",
                                                    probability_expression)
        end
    end
end
