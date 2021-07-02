require("fractured-world-loader")
local resource_autoplace = require("resource-autoplace")
local initialize_patch_set = resource_autoplace.initialize_patch_set
local resource_autoplace_settings = resource_autoplace.resource_autoplace_settings

local function fractured_world_resource_autoplace_settings(params)
    fractured_world:set_resource_data(params.name, params)
    resource_autoplace_settings(params)
end

local is_resource_autoplace = {
    ["resource_autoplace"] = true,
    ["resource_autoplace.lua"] = true,
    ["__core__/lualib/resource_autoplace"] = true,
    ["__core__/lualib/resource_autoplace.lua"] = true,
    ["__core__.lualib.resource_autoplace"] = true,
    ["__core__.lualib.resource_autoplace.lua"] = true
}

-- Replace require
local old_require = require

function require(filename)
    if is_resource_autoplace[filename] then
        return {
            initialize_patch_set = initialize_patch_set,
            resource_autoplace_settings = fractured_world_resource_autoplace_settings
        }
    else
        old_require(filename)
    end
end

