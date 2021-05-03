local noise = require("noise")
local tne = noise.to_noise_expression
local functions = require("prototypes.functions")
local distance = noise.max(noise.var("distance") - noise.var("starting_area_radius") - 120, 0)
local frequencySlider = functions.slider_to_scale("control-setting:enemy-base:frequency:multiplier")
local sizeSlider = 1 - functions.slider_to_scale("control-setting:enemy-base:size:multiplier")
local radius = noise.absolute_value(noise.var("fw_distance"))
--[[local starting_factor =
    tne(noise.delimit_procedure(noise.min(-noise.min(radius, 0) * math.huge, 1)))
radius = radius + starting_factor * functions.size * 2]]

local scaledRadius = (1 - radius / functions.size)

--[[
    Defaults:
    chunks distance for maximum intensity
    starting hole radius

    minimum near frequency - 0.001
    maximum near frequency - 0.1
    minimum far frequency - 0.01
    maximum far frequency - 1

    minimum near size - 0.01
    maximum near size - 0.3
    minimum far size - 0.5
    maximum far size - 1

]]

local thisIntensity = noise.min(distance / (32 * 100), 1) -- based on vanilla values
local thisSize
local thisFrequency
do
    local minFrequencyNear = 0.001
    local maxFrequencyNear = 0.1
    local minFrequencyFar = 0.01
    local maxFrequencyFar = 1

    local get_near_frequency =
        functions.make_interpolation(0, minFrequencyNear, 1, maxFrequencyNear)
    local frequencyNear = get_near_frequency(frequencySlider)
    local get_far_frequency = functions.make_interpolation(0, minFrequencyFar, 1, maxFrequencyFar)
    local frequencyFar = get_far_frequency(frequencySlider)
    local get_frequency = functions.make_interpolation(0, frequencyNear, 1, frequencyFar)
    thisFrequency = noise.delimit_procedure(get_frequency(thisIntensity))
end
do
    local minSizeNear = 0.01
    local maxSizeNear = 0.3
    local minSizeFar = 0.5
    local maxSizeFar = 1

    local get_near_size = functions.make_interpolation(0, minSizeNear, 1, maxSizeNear)
    local sizeNear = get_near_size(sizeSlider)
    local get_far_size = functions.make_interpolation(0, minSizeFar, 1, maxSizeFar)
    local sizeFar = get_far_size(sizeSlider)
    local get_size = functions.make_interpolation(0, sizeNear, 1, sizeFar)
    thisSize = noise.delimit_procedure(get_size(thisIntensity))
end

-- get islands that should have biters
data:extend{
    {
        type = "noise-expression",
        name = "fractured-world-biter-islands",
        expression = noise.less_than(noise.var("fw_value"), thisFrequency)
    }
}
local islandsWithBiters = noise.var("fractured-world-biter-islands")
local spawnerCircle = noise.delimit_procedure(noise.less_than(thisSize, scaledRadius / 1.45))
local wormCircle = noise.delimit_procedure(noise.less_than(thisSize, scaledRadius / 1.3))

local count = 0
local function make_enemy_autoplace(type, prototypeData, penalty_multiplier)
    -- Prototypes are scraped here
    local prototypes = data.raw[type]
    local totalWeight = 0
    penalty_multiplier = penalty_multiplier or 1
    for name, prototype in pairs(prototypes) do
        local autoplace = prototype.autoplace
        if autoplace and (autoplace.force == "enemy") then
            if not prototypeData[name] then prototypeData[name] = {} end
            local thisPrototypeData = prototypeData[name]
            thisPrototypeData.weight = thisPrototypeData.weight or 1
            thisPrototypeData.distance_factor = thisPrototypeData.distance_factor or 0
            totalWeight = totalWeight + thisPrototypeData.weight
        end
    end
    for name, prototype in pairs(prototypes) do
        local autoplace = prototype.autoplace
        if prototypeData[name] and autoplace and (autoplace.force == "enemy") then
            local distance_factor = (prototypeData[name] and prototypeData[name].distance_factor) or
                                        0
            local placeAtThisDistance = functions.greater_than(distance, distance_factor * 256)
            local penalty = tne {
                type = "function-application",
                function_name = "random-penalty",
                arguments = {
                    source = tne(1),
                    x = noise.var("x") + count,
                    y = noise.var("y"),
                    amplitude = tne(totalWeight * penalty_multiplier)
                }
            }

            local factors = {
                (prototypeData[name].weight / totalWeight), placeAtThisDistance, thisSize,
                islandsWithBiters, penalty
            }
            if type == "unit-spawner" then
                table.insert(factors, spawnerCircle)
            elseif type == "turret" then
                table.insert(factors, wormCircle)
            end
            prototypeData[name].probability_expression = functions.multiply_probabilities(factors)
            data:extend{
                {
                    type = "noise-expression",
                    name = "fractured-world-" .. name .. "-probability",
                    expression = tne(0)
                }
            }
            count = count + 1
        end
    end
end

local turretData = {
    ["small-worm-turret"] = {distance_factor = 0},
    ["medium-worm-turret"] = {distance_factor = 2},
    ["big-worm-turret"] = {distance_factor = 5},
    ["behemoth-worm-turret"] = {distance_factor = 8}
}

-- Why is this empty?
local spawnerData = {}
make_enemy_autoplace("unit-spawner", spawnerData)
make_enemy_autoplace("turret", turretData)

return {spawnerData, turretData}
