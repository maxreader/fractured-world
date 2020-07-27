local noise = require("noise")
local tne = noise.to_noise_expression
local functions = require("functions")
local fnp = require("fractured-noise-programs")

local resources = data.raw['resource']
local rawResourceData = require("prototypes.raw-resource-data")
local currentResourceData = {}

for k, v in pairs(rawResourceData) do
    if mods[k] then
        for ore, oreData in pairs(v) do
            if resources[ore] then currentResourceData[ore] = oreData end
        end
    end
end

local starting_patches = resource_autoplace__patch_metasets.starting.patch_set_indexes
local regular_patches = resource_autoplace__patch_metasets.regular.patch_set_indexes

-- pick up any ores not in the raw dataset and give them a default
for ore, index in pairs(regular_patches) do
    if resources[ore] and not currentResourceData[ore] then
        currentResourceData[ore] = {density = 4}
    end
end

-- TODO: add mod setting for infinite ores being "normal" ores or on their main patch

--[[
    1. See if ore has infinite in the name, and is infinite
    2. Check if there's another ore with the same name minus the infinite bit
    3. If so, wipe out the infinite ore from the list, tag it in the parent resource
    4. Check if the ore is in the starting area, if so, add a flag
]]
local infiniteOreData = {}
for ore, oreData in pairs(currentResourceData) do
    if resources[ore].infinite and string.find(ore, "^infinite%-") then
        local parentOreName = string.sub(ore, 10)
        if resources[parentOreName] then
            infiniteOreData[ore] = {
                parentOreName = parentOreName
            }
            currentResourceData[ore] = nil
            currentResourceData[parentOreName].has_infinite_version = true
        end
    end
    if starting_patches[ore] then currentResourceData[ore].starting_patch = true end
end

--[[
default settings: approx 64 islands/km2
we want at most 1/16 of the islands to have ore by default
sum up spots/km2 for current ores, if over 4, multiply richness by #ores/4
get weighted sum of ore spots/km2 * frequency,
]]
local oreCount = 0

-- startLevel, endLevel: what aux values to place this ore at
for ore, oreData in pairs(currentResourceData) do
    local control_setting = noise.get_control_setting(ore)
    local frequency_multiplier = control_setting.frequency_multiplier or 1
    local base_frequency = oreData.frequency or 2.5
    local thisFrequency = frequency_multiplier * base_frequency
    oreData.startLevel = oreCount
    oreCount = oreCount + thisFrequency
    oreData.endLevel = oreCount
    local randmin = oreData.randmin or 0.25
    local randmax = oreData.randmax or 2
    oreData.variance = randmax - randmin
    oreData.randmin = randmin
end

local maxPatchesPerKm2 = 4
local overallFrequency = maxPatchesPerKm2 / 64
local oreCountMultiplier = noise.delimit_procedure(noise.max(1, oreCount / maxPatchesPerKm2))

-- scale startLevel and endLevel so that the desired overall frequency of islands have ore
for ore, oreData in pairs(currentResourceData) do
    oreData.startLevel = tne(oreData.startLevel) / (oreCountMultiplier) * overallFrequency
    oreData.endLevel = tne(oreData.endLevel) / (oreCountMultiplier) * overallFrequency
end

local radius = noise.var("fw_distance")
local scaledRadius = (radius / functions.size)
local aux = 1 - noise.var("fractured-world-aux")
local function get_infinite_probability(ore)
    local parentOreName = infiniteOreData[ore].parentOreName
    local parentOreData = currentResourceData[parentOreName]
    local parentProbability = data.raw["noise-expression"]["fractured-world-" .. parentOreName ..
                                  "-probability"].expression

    local minRadius = 1 / 8
    local maxRadius = 1 / 4
    local get_radius = functions.make_interpolation(parentOreData.startLevel, minRadius,
                                                    parentOreData.endLevel, maxRadius)

    local thisRadius = get_radius(aux)
    data:extend{
        {
            type = "noise-expression",
            name = "fractured-world-" .. ore .. "radial-multiplier",
            expression = noise.max(thisRadius - scaledRadius, 0)
        }
    }
    local moistureFactor = noise.max(functions.less_than(noise.var("moisture"), tne(0.5)),
                                     noise.var("fractured-world-biter-islands"))
    local sizeMultiplier = noise.get_control_setting(ore).size_multiplier
    local randomness = noise.clamp(noise.var("small-noise"), 1, 10)
    local probabilities = {
        tne(10), parentProbability, moistureFactor,
        noise.var("fractured-world-" .. ore .. "radial-multiplier"),
        sizeMultiplier, randomness
    }
    return functions.multiply_probabilities(probabilities)
end

local function get_infinite_richness(ore)

    local oreData = currentResourceData[infiniteOreData[ore].parentOreName]
    local addRich = oreData.addRich or 0
    local postMult = oreData.postMult or 1
    local minimumRichness = oreData.minRich or 0
    local settings = noise.get_control_setting(ore)
    local variance = (aux - oreData.startLevel) / (oreData.endLevel - oreData.startLevel) *
                         oreData.variance + (oreData.randmin)

    local factors = {
        oreData.density or 8,
        770 * noise.var("distance") + 1000000,
        settings.richness_multiplier,
        1 / noise.max(oreData.randProb or 1, 1),
        oreCountMultiplier, variance,
        1 / tne(fnp.landDensity),
        noise.max(noise.var("fractured-world-" .. ore .. "radial-multiplier"), 1),
        tne(10)
    }
    return noise.max((functions.multiply_probabilities(factors) + addRich) * postMult,
                     minimumRichness)
end

local function get_probability(ore)
    local oreData = currentResourceData[ore]
    local randProb = oreData.randProb or 1
    local aboveMinimum = noise.max(0, aux - oreData.startLevel)
    local belowMaximum = noise.max(0, oreData.endLevel - aux)
    local probability_expression = noise.clamp(aboveMinimum * belowMaximum * math.huge, 0, 1)
    if randProb < 1 then
        probability_expression = probability_expression * tne {
            type = "function-application",
            function_name = "random-penalty",
            arguments = {
                source = tne(1),
                x = noise.var("x"),
                y = noise.var("y"),
                amplitude = tne(1 / randProb) -- put random_probability points with probability < 0
            }
        }
    end
    return probability_expression
end

local function get_richness(ore)
    -- Get params for calculations
    local oreData = currentResourceData[ore]
    local addRich = oreData.addRich or 0
    local postMult = oreData.postMult or 1
    local minimumRichness = oreData.minRich or 0
    local settings = noise.get_control_setting(ore)

    local variance = (aux - oreData.startLevel) / (oreData.endLevel - oreData.startLevel) *
                         oreData.variance + (oreData.randmin)
    local factors = {
        oreData.density or 8,
        770 * noise.var("distance") + 1000000,
        settings.richness_multiplier,
        settings.size_multiplier,
        1 / noise.max(oreData.randProb or 1, 1),
        oreCountMultiplier, variance,
        1 / tne(fnp.landDensity)
    }
    return noise.max((functions.multiply_probabilities(factors) + addRich) * postMult,
                     minimumRichness)
end

return {
    get_probability = get_probability,
    get_richness = get_richness,
    currentResourceData = currentResourceData,
    get_infinite_probability = get_infinite_probability,
    get_infinite_richness = get_infinite_richness,
    infiniteOreData = infiniteOreData
}
