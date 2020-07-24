local noise = require("noise")
local tne = noise.to_noise_expression
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

for ore, index in pairs(regular_patches) do
    if resources[ore] and not currentResourceData[ore] then
        currentResourceData[ore] = {density = 4}
    end
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

local aux = 1 - noise.var("fractured-world-aux")
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

local landDensity = require("fractured-noise-programs").landDensity
local function get_richness(ore)
    -- Get params for calculations
    local oreData = currentResourceData[ore]
    local density = oreData.density or 8
    local addRich = oreData.addRich or 0
    local postMult = oreData.postMult or 1
    local minimumRichness = oreData.minRich or 0
    local randProb = oreData.randProb or 1
    randProb = noise.max(1, randProb)
    local settings = noise.get_control_setting(ore)

    local thisVariance = (aux - oreData.startLevel) / (oreData.endLevel - oreData.startLevel) *
                             oreData.variance + (oreData.randmin)
    return noise.max(
               ((770 * noise.var("distance") + 1000000) * density * settings.size_multiplier *
                   settings.richness_multiplier * oreCountMultiplier * thisVariance / randProb /
                   landDensity + addRich) * postMult, minimumRichness)
end

return {
    get_probability = get_probability,
    get_richness = get_richness,
    currentResourceData = currentResourceData
}
