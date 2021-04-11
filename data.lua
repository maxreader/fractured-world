require("prototypes.fractured-world-loader")

require("raw-data.distance-modifiers")

require("raw-data.point-types")
--[[for k, v in pairs(pointTypes) do
    fractured_world:add_point_type(k, v)
end]]

require("raw-data.cartesian-functions")

local presets = require("raw-data.preset-data")
if settings.startup["fractured-world-use-quick-startup"]
    .value then
    local quick_preset =
        settings.startup["fractured-world-quick-startup-preset"]
            .value
    fractured_world:add_preset_data(quick_preset,
                                    presets[quick_preset])
else

    for k, v in pairs(presets) do
        fractured_world:add_preset_data(k, v)
    end
end

require("raw-data.resource-data")
