local noise = require("noise")
local tne = noise.to_noise_expression


local resources = data.raw['resource']

-- base density
-- frequency default = 2.5 spots/km
-- randmin default = 0.25
-- randmax default = 2
-- add-richness
-- randProb
local rawResourceData = {
    base = {
        ["iron-ore"] = {density = 10},
        ["copper-ore"] = {density = 8},
        ["coal"] = {density = 8},
        ["stone"] = {density = 4},
        ["uranium-ore"] = {
            density = 0.9,
            frequency = 1.25,
            randmin = 2,
            randmax = 4
        },
        ["crude-oil"] = {
            density = 8.2,
            frequency = 1.8,
            randmin = 1,
            randmax = 1,
            addRich = 220000,
            randProb = 1 / 48
        }
    },
    bobplates = {
        ["bauxite-ore"] = {density = 8},
        ["cobalt-ore"] = {density = 4},
        ["ground-water"] = {density = 4},
        ["lithia-water"] = {
            density = 8.2,
            frequency = 1.8,
            randmin = 1,
            randmax = 1,
            addRich = 220000,
            randProb = 1 / 48
        },
        ["gem-ore"] = {density = 0.1},
        ["gold-ore"] = {density = 4},
        ["lead-ore"] = {density = 8},
        ["nickel-ore"] = {density = 5},
        ["quartz"] = {density = 4},
        ["rutile-ore"] = {density = 8},
        ["silver-ore"] = {density = 4},
        ["sulfur"] = {density = 8},
        ["thorium-ore"] = {
            density = 0.9,
            frequency = 1.25,
            randmin = 2,
            randmax = 4
        },
        ["tin-ore"] = {density = 8},
        ["tungsten-ore"] = {density = 8},
        ["zinc-ore"] = {density = 4}

    },
    angelsrefining = {
        ["angels-fissure"] = {
            density = 3,
            frequency = 1.8,
            randmin = 1,
            randmax = 1,
            addRich = 2500,
            randProb = 1 / 48
        },
        ["angels-ore1"] = {density = 10},
        ["angels-ore2"] = {density = 7},
        ["angels-ore3"] = {density = 10},
        ["angels-ore4"] = {density = 7},
        ["angels-ore5"] = {density = 8},
        ["angels-ore6"] = {density = 8},
        ["coal"] = {density = 8},
        ["crude-oil"] = {
            density = 8,
            frequency = 1.8,
            randmin = 1,
            randmax = 1,
            addRich = 10000,
            randProb = 1 / 48
        }
    },
    angelspetrochem = {
        ["angels-natural-gas"] = {
            density = 8,
            frequency = 1.8,
            randmin = 1,
            randmax = 1,
            addRich = 10000,
            randProb = 1 / 48,
            postMult = 0.03
        }
    },
    --[[angelsinfiniteore = {
        ["infinite-angels-ore1"] = {density = 5},
        ["infinite-angels-ore2"] = {density = 5},
        ["infinite-angels-ore3"] = {density = 5},
        ["infinite-angels-ore4"] = {density = 5},
        ["infinite-angels-ore5"] = {density = 5},
        ["infinite-angels-ore6"] = {density = 5}
    },]]
    Krastorio2 = {
        ["immersite"] = {
            density = 1,
            frequency = 0.2,
            randmin = 0.01,
            randmax = 0.1,
            addRich = 350000
        },
        ["mineral-water"] = {
            density = 2,
            frequency = 0.5,
            randmin = 1,
            randmax = 1,
            addRich = 50000,
            randProb = 1 / 50
        },
        ["rare-metals"] = {
            density = 1,
            frequency = 0.75,
            randmin = 0.25,
            randmax = 3
        }
    },
    DyWorld = {
        ["stone"] = {density = 24},
        ["coal"] = {density = 12},
        ["iron-ore"] = {density = 15},
        ["copper-ore"] = {density = 13},
        ["nickel-ore"] = {density = 12},
        ["silver-ore"] = {density = 8},
        ["tin-ore"] = {density = 9},
        ["gold-ore"] = {density = 5},
        ["lead-ore"] = {density = 12},
        ["cobalt-ore"] = {density = 10},
        ["arditium-ore"] = {density = 15},
        ["titanium-ore"] = {density = 11},
        ["tungsten-ore"] = {density = 12},
        ["neutronium-ore"] = {density = 25}
    }
}
local currentResourceData = {}
for k, v in pairs(rawResourceData) do
    if mods[k] then
        for ore, oreData in pairs(v) do
            if resources[ore] then
                currentResourceData[ore] = oreData
            end
        end
    end
end

local starting_patches = resource_autoplace__patch_metasets.starting
                             .patch_set_indexes
local regular_patches = resource_autoplace__patch_metasets.regular
                            .patch_set_indexes
--[[
default settings: approx 64 islands/km2
we want at most 1/2 of the islands to have ore by default
sum up spots/km2 for current ores, if over 32, multiply richness by #ores/32
get weighted sum of ore spots/km2 * frequency,


]]
local oreCount = 0
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
local oreCountMultiplier = noise.max(1, oreCount / maxPatchesPerKm2)
for ore, oreData in pairs(currentResourceData) do
    oreData.startLevel = oreData.startLevel / (oreCountMultiplier) *
                             overallFrequency
    oreData.endLevel = oreData.endLevel / (oreCountMultiplier) *
                           overallFrequency
end

local aux = noise.var("new-aux")
local function get_probability(ore)
    local oreData = currentResourceData[ore]
    local randProb = oreData.randProb or 1
    local aboveMinimum = noise.max(0, aux - oreData.startLevel)
    local belowMaximum = noise.max(0, oreData.endLevel - aux)
    local probability_expression = noise.clamp(
                                       aboveMinimum * belowMaximum * math.huge,
                                       0, 1)
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

-- todo: get randmin and randmax included
local landDensity = 0.303542 * 1000000
local function get_richness(ore)
    local oreData = currentResourceData[ore]
    local density = oreData.density or 8
    local addRich = oreData.addRich or 0
    local postMult = oreData.postMult or 1
    local minimumRichness = oreData.minRich or 0
    local randProb = oreData.randProb or 1
    randProb = noise.max(1, randProb)
    local settings = noise.get_control_setting(ore)
    local thisVariance = (aux - oreData.startLevel) /
                             (oreData.endLevel - oreData.startLevel) *
                             oreData.variance + (oreData.randmin)
    local resDensity = noise.max(((770 * noise.var("distance") + 1000000) *
                                     density * settings.size_multiplier *
                                     settings.richness_multiplier *
                                     oreCountMultiplier * thisVariance /
                                     randProb / landDensity + addRich) *
                                     postMult, minimumRichness)
    return resDensity
end

for ore, _ in pairs(currentResourceData) do
        resources[ore].autoplace.probability_expression = get_probability(ore)
        resources[ore].autoplace.richness_expression = get_richness(ore)
end
