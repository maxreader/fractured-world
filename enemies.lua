local noise = require("noise")
local tne = noise.to_noise_expression
local functions = require("functions")
local distance = noise.var("distance")
local frequencySlider = functions.sliderToScale("control-setting:enemy-base:frequency:multiplier")
local sizeSlider = functions.sliderToScale("control-setting:enemy-base:size:multiplier")

local thisIntensity = noise.min(distance / (32 * 75), 1) -- based on vanilla values

local minFrequencyNear = 0.001
local maxFrequencyNear = 0.1
local minFrequencyFar = 0.1
local maxFrequencyFar = 1

local get_near_frequency = functions.make_interpolation(0, minFrequencyNear, 1, maxFrequencyNear)
local frequencyNear = get_near_frequency(frequencySlider)
local get_far_frequency = functions.make_interpolation(0, minFrequencyFar, 1, maxFrequencyFar)
local frequencyFar = get_far_frequency(frequencySlider)
local get_frequency = functions.make_interpolation(0, frequencyNear, 1, frequencyFar)
local thisFrequency = get_frequency(thisIntensity)

local minSizeNear = 0.001
local maxSizeNear = 0.1
local minSizeFar = 0.1
local maxSizeFar = 1

local get_near_size = functions.make_interpolation(0, minSizeNear, 1, maxSizeNear)
local sizeNear = get_near_size(sizeSlider)
local get_far_size = functions.make_interpolation(0, minSizeFar, 1, maxSizeFar)
local sizeFar = get_far_size(sizeSlider)
local get_size = functions.make_interpolation(0, sizeNear, 1, sizeFar)
local thisSize = get_size(thisIntensity)

local spawnerData = {}
local totalWeight = 0

local spawners = data.raw["unit-spawner"]
for name, spawner in pairs(data.raw["unit-spawner"]) do
    if not spawnerData[name] then spawnerData[name] =
        {weight = 1} end
    totalWeight = totalWeight + spawnerData[name].weight
end

-- get islands that should have biters
local moisture = noise.var("moisture")
local islandsWithBiters = functions.lessThan(moisture, thisFrequency)

for name, spawner in pairs(spawners) do
    local weight = spawnerData[name].weight
    local randProb = tne(thisSize * weight / totalWeight)
    local autoplace = spawner.autoplace
    if autoplace then
        autoplace.probability_expression = islandsWithBiters * randProb * tne {
            type = "function-application",
            function_name = "random-penalty",
            arguments = {
                source = tne(1),
                x = noise.var("x"),
                y = noise.var("y"),
                amplitude = tne(totalWeight)
            }
        }
    end
end

