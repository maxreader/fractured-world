local noise = require("noise")
local tne = noise.to_noise_expression
local functions = require("functions")
local fnp = require("fractured-noise-programs")

local resources = data.raw["resource"]

local radius = noise.var("fw_distance")
local scaledRadius = (radius / functions.size)
local aux = noise.var("fw_value")

local startingAreaRadius = functions.defaultSize
local starting_factor =
    noise.delimit_procedure(noise.clamp(-noise.min(radius, 0) * math.huge, 0, 1))
local startingPatchScaleFactor = (startingAreaRadius / 128) ^ 0.5, 1
local startingPatchDefaultRadius = 15 * startingPatchScaleFactor

local function probSearch(tab)
    if tab.function_name == "random-penalty" then
        return tab.arguments.amplitude.literal_value
    elseif tab.arguments == nil then
        return nil
    else
        local result = nil
        for k, v in pairs(tab.arguments) do
            result = result or probSearch(v)
            if result ~= nil then break end
        end
        return result
    end
end

local currentResourceData = {}

--[[for k, v in pairs(resources) do
    if v.autoplace and not v.autoplace.probability_expression then
        log(serpent.line(k))
        log(serpent.block(v.autoplace))
    end
end]]
for k, v in pairs(fractured_world.raw_resource_data) do
    for ore, oreData in pairs(v) do
        if resources[ore] and resources[ore].autoplace then
            currentResourceData[ore] = oreData
        end
    end
end

local starting_patches = resource_autoplace__patch_metasets.starting.patch_set_indexes
local regular_patches = resource_autoplace__patch_metasets.regular.patch_set_indexes

-- pick up any ores not in the raw dataset and give them a default
for name, ore in pairs(resources) do
    local needsDefault =
        (ore.autoplace and ore.autoplace ~= {} and not currentResourceData[name]) and true or false
    if needsDefault then
        local oreData = {base_density = 8}
        local probExp = ore.autoplace and ore.autoplace.probability_expression
        if type(probExp == "table") then
            local random_probability = 1 / (probSearch(probExp) or 1)
            if random_probability < 1 then
                oreData = {
                    base_density = 8.2,
                    base_spots_per_km2 = 1.8,
                    random_spot_size_minimum = 1,
                    random_spot_size_maximum = 1,
                    additional_richness = 220000,
                    random_probability = random_probability
                }
            end
        end
        currentResourceData[name] = oreData
    end
end

--[[
    1. See if ore has infinite in the name, and is infinite
    2. Check if there's another ore with the same name minus the infinite bit
    3. If so, wipe out the infinite ore from the list, tag it in the parent resource
    4. Check if the ore is in the starting area, if so, add a flag
    5. This flag will later be used to tell which "slice" of the starting island to place the ore
]]
local infiniteOreData = {}
local doInfiniteOres = settings.startup["fractured-world-enable-infinite-parenting"].value
local startingOreCount = 0
for ore, oreData in pairs(currentResourceData) do
    local isInfinite = doInfiniteOres and resources[ore].infinite and
                           string.find(ore, "^infinite%-") and true or false
    if isInfinite then
        local parentOreName = string.sub(ore, 10)
        if resources[parentOreName] then
            infiniteOreData[ore] = {parentOreName = parentOreName}
            currentResourceData[ore] = nil
            currentResourceData[parentOreName].has_infinite_version = true
        end
    end
    local is_starting_patch = (starting_patches[ore] or resources[ore].autoplace.starting_area ==
                                  true or currentResourceData[ore].has_starting_area_placement ==
                                  true) and true or false
    if is_starting_patch then
        startingOreCount = startingOreCount + 1
        currentResourceData[ore].starting_patch = startingOreCount
    end
end
--[[
generate locations for starting ores
divide circle into n slices
for each slice, generate a point from 0-0.5 of the slice angle,
    0.25 to 0.75 the "total" distance to the edge
]]
local smallRotationFactor = 1 -
                                functions.slider_to_scale(
                                    "control-setting:map-rotation:size:multiplier")
local largeRotationFactor = functions.slider_to_scale(
                                "control-setting:map-rotation:frequency:multiplier")
local rotationFactor = largeRotationFactor * 2 * math.pi + smallRotationFactor * math.pi / 6
local sliceSize = 2 * math.pi / startingOreCount
local startingPoints = {}
for i = 1, startingOreCount do
    local random = functions.get_random_point(i, i, startingAreaRadius)
    local radius = (random.y) / 2 + startingAreaRadius / 4
    local angle = random.x / startingAreaRadius * sliceSize / 2 + i * sliceSize + rotationFactor
    local point_x = radius * noise.cos(angle)
    local point_y = radius * noise.sin(angle)
    startingPoints[i] = {x = point_x, y = point_y}
end

--[[
default settings: approx 64 islands/km2
we want at most 1/16 of the islands to have ore by default
sum up spots/km2 for current ores, if over 4, multiply richness by #ores/4
get weighted sum of ore spots/km2 * base_spots_per_km2,
]]
local oreCount = 0

-- startLevel, endLevel: what aux values to place this ore at
for ore, oreData in pairs(currentResourceData) do
    local control_setting = noise.get_control_setting(ore)
    local frequency_multiplier = control_setting.frequency_multiplier or 1
    local base_spots_per_km2 = oreData.base_spots_per_km2 or 2.5
    local thisFrequency = frequency_multiplier * base_spots_per_km2
    oreData.startLevel = oreCount
    oreCount = oreCount + thisFrequency
    oreData.endLevel = oreCount
    local random_spot_size_minimum = oreData.random_spot_size_minimum or 0.25
    local random_spot_size_maximum = oreData.random_spot_size_maximum or 2
    oreData.variance = random_spot_size_maximum - random_spot_size_minimum
    oreData.random_spot_size_minimum = random_spot_size_minimum
    oreData.starting_rq_factor_multiplier_multiplier =
        1 + ((oreData.starting_rq_factor_multiplier or 1) - 1) * tne(starting_factor)
end

local overallFrequency = settings.startup["fractured-world-overall-resource-frequency"].value *
                             noise.var("control-setting:overall-resources:frequency:multiplier") ^ 2
local maxPatchesPerKm2 = overallFrequency * 64
local oreCountMultiplier = noise.delimit_procedure(noise.max(1, oreCount / maxPatchesPerKm2))

-- scale startLevel and endLevel so that the desired overall frequency of islands have ore
for ore, oreData in pairs(currentResourceData) do
    oreData.startLevel = tne(oreData.startLevel) / (oreCountMultiplier) * overallFrequency
    oreData.endLevel = tne(oreData.endLevel) / (oreCountMultiplier) * overallFrequency
end

local function get_infinite_probability(ore)
    local parentOreName = infiniteOreData[ore].parentOreName
    local parentOreData = currentResourceData[parentOreName]
    local parentProbability = data.raw["noise-expression"]["fractured-world-" .. parentOreName ..
                                  "-probability"].expression

    local minRadius = 1 / 8
    local maxRadius = 1 / 2
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
    -- if the island is dry, *or* if it has biters on it, place the infinite ore
    local moistureFactor = noise.max(noise.less_than(noise.var("moisture"), tne(0.5)),
                                     noise.var("fractured-world-biter-islands"))
    local sizeMultiplier = noise.get_control_setting(ore).size_multiplier
    local randomness = noise.clamp(noise.var("fw-scaling-noise"), 1, 10)
    local probabilities = {
        tne(10), parentProbability, moistureFactor,
        noise.var("fractured-world-" .. ore .. "radial-multiplier"), sizeMultiplier, randomness
    }
    return functions.multiply_probabilities(probabilities)
end

local function get_infinite_richness(ore)
    local oreData = currentResourceData[infiniteOreData[ore].parentOreName]
    local additional_richness = oreData.additional_richness or 0
    local richness_post_multiplier = oreData.richness_post_multiplier or 1
    local minimumRichness = oreData.minRich or 0
    local settings = noise.get_control_setting(ore)
    local variance = (aux - oreData.startLevel) / (oreData.endLevel - oreData.startLevel) *
                         oreData.variance + (oreData.random_spot_size_minimum)

    local factors = {
        oreData.base_density or 8, 770 * noise.var("distance") + 1000000,
        settings.richness_multiplier, 1 / noise.min(oreData.random_probability or 1, 1),
        oreCountMultiplier, variance, 1 / tne(fnp.landDensity),
        noise.max(noise.var("fractured-world-" .. ore .. "radial-multiplier"), 1), tne(10)
    }
    return noise.max((functions.multiply_probabilities(factors) + additional_richness) *
                         richness_post_multiplier, minimumRichness)
end

local function get_probability(ore)
    local oreData = currentResourceData[ore]

    local settings = noise.get_control_setting(ore)
    local aboveMinimum = noise.max(0, aux - oreData.startLevel)
    local belowMaximum = noise.max(0, oreData.endLevel - aux)
    local probability_expression = noise.clamp(aboveMinimum * belowMaximum * math.huge, 0, 1)
    probability_expression = probability_expression * (tne(1) - starting_factor)
    if oreData.starting_patch then
        local startingPatchRadius = startingPatchDefaultRadius * settings.size_multiplier ^ 0.5 *
                                        (oreData.starting_rq_factor_multiplier_multiplier or 1)
        local startingPoint = startingPoints[oreData.starting_patch]
        local point_x = startingPoint.x
        local point_y = startingPoint.y
        local x = noise.var("x")
        local y = noise.var("y")
        local distanceFromPoint = functions.distance(point_x - x, point_y - y)
        probability_expression = probability_expression +
                                     noise.less_than(distanceFromPoint, startingPatchRadius +
                                                         (noise.var("fw-small-noise") / 25))
    end
    local random_probability = oreData.random_probability or 1
    if random_probability < 1 then
        -- Adjustment so there isn't a ridiculous number of patches on an island
        random_probability = random_probability / 2
        probability_expression = probability_expression * tne {
            type = "function-application",
            function_name = "random-penalty",
            arguments = {
                source = tne(1),
                x = noise.var("x"),
                y = noise.var("y"),
                amplitude = tne(1 / random_probability) -- put random_probability points with probability < 0
            }
        }
    end
    return noise.clamp(probability_expression, -1, 1)
end

local function get_richness(ore)
    -- Get params for calculations
    local oreData = currentResourceData[ore]
    local additional_richness = oreData.additional_richness or 0
    local richness_post_multiplier = oreData.richness_post_multiplier or 1
    local minimumRichness = oreData.minRich or 0
    local random_probability = oreData.random_probability
    if random_probability then random_probability = random_probability / 4 end
    local settings = noise.get_control_setting(ore)

    local variance = (aux - oreData.startLevel) / (oreData.endLevel - oreData.startLevel) *
                         oreData.variance + (oreData.random_spot_size_minimum)
    local factors = {
        oreData.base_density or 8, 770 * noise.var("distance") + 1000000,
        settings.richness_multiplier, settings.size_multiplier,
        1 / noise.min(oreData.random_probability or 1, 1), oreCountMultiplier, variance,
        1 / tne(fnp.landDensity), noise.max(1 / startingPatchScaleFactor, 1),
        noise.clamp(noise.absolute_value(noise.var("fw-small-noise") / 25 + 2), 0.5, 2),
        1 / oreData.starting_rq_factor_multiplier_multiplier
    }
    local richness_expression = noise.max((functions.multiply_probabilities(factors) +
                                              additional_richness) * richness_post_multiplier,
                                          minimumRichness)

    return richness_expression
end

return {
    get_probability = get_probability,
    get_richness = get_richness,
    currentResourceData = currentResourceData,
    get_infinite_probability = get_infinite_probability,
    get_infinite_richness = get_infinite_richness,
    infiniteOreData = infiniteOreData
}
