local presets = require("raw-data.preset-data")
fractured_world = fractured_world or {}
fractured_world.allowed_presets = fractured_world.allowed_presets or {}
function fractured_world.add_preset_to_settings(self, preset_name)
    table.insert(self.allowed_presets, preset_name)
end

for name, _ in pairs(presets) do fractured_world:add_preset_to_settings(name) end
