require("raw-data.distance-modifiers")
noise = require('noise')

require("raw-data.point-types")
--[[for k, v in pairs(pointTypes) do
    fractured_world:add_point_type(k, v)
end]]

require("raw-data.cartesian-functions")

local presets = require("raw-data.preset-data")
if settings.startup["fractured-world-use-quick-startup"].value then
    local quick_preset =
        settings.startup["fractured-world-quick-startup-preset"].value
    fractured_world:add_preset_data(quick_preset, presets[quick_preset])
    if quick_preset == "fractured-resources" then
        for k, v in pairs({
            "fractured-resources", "circles", "squares", "diamonds"
        }) do fractured_world:add_preset_data(v, presets[v]) end
    end
else
    for k, v in pairs(presets) do fractured_world:add_preset_data(k, v) end
end

require("raw-data.resource-data")

--[[local resource_autoplace = require("resource-autoplace")
local new_ore = table.deepcopy(data.raw.tree["tree-01"])
new_ore.name = "new-ore"

local has_starting_area_placement = true

resource_autoplace.initialize_patch_set("new-ore", has_starting_area_placement)

data:extend{
    {
        type = "autoplace-control",
        name = "new-ore",
        localised_name = {"", "[entity=new-ore] ", {"entity-name.new-ore"}},
        richness = true,
        order = "b-a",
        category = "resource"
    }
}

local noise = require("noise")
local new_autoplace = resource_autoplace.resource_autoplace_settings({
    name = "new-ore",
    -- order = nil,
    base_density = 2,
    has_starting_area_placement = has_starting_area_placement,
    candidate_spot_count = 500, -- 22
    -- random_probability = 1, -- 1
    base_spots_per_km2 = 300, -- 2.5
    random_spot_size_minimum = 5, -- 0.25
    random_spot_size_maximum = 20, -- 2
    regular_blob_amplitude_multiplier = 8, -- 1
    starting_blob_amplitude_multiplier = 4, -- 1
    -- additional_richness = 0, -- 0
    minimum_richness = 10, -- 0
    regular_rq_factor = 20, -- 1
    starting_rq_factor = 5 -- 1
})
new_ore.autoplace = new_autoplace
new_ore.autoplace.probability_expression = new_ore.autoplace.probability_expression *
                                               (noise.var("moisture") - 0.5)
new_ore.map_color = {1, 1, 0}
data:extend{new_ore}--]]
