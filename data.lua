fractured_world = fractured_world or {}
fractured_world.distance_modifiers = {}
fractured_world.point_types = {}
fractured_world.cartesian_fuctions = {}
fractured_world.presets = {}
fractured_world.raw_resource_data = {}

--- Adds a distance modifier to Fractured World.
-- Distance Modifiers work on voronoi-type presets
-- Each distance modifier takes the parameters distance, angle, and value
-- Distance - Distance from the point of interest
-- Angle - Angle from the point of interest
-- Value - The random "value" of the point of interest
-- @param name The name of the modifier
-- @param func The function
local function add_distance_modifier(name, func) fractured_world.distance_modifiers[name] = func end

local function add_point_type(name, func) fractured_world.point_types[name] = func end
local function add_cartesian_function(name, func) fractured_world.cartesian_fuctions[name] = func end
local function add_preset(name, parameters) fractured_world.presets[name] = parameters end
local function add_resource_data(modname, resources)
    fractured_world.raw_resource_data[modname] = resources
end
fractured_world.add_distance_modifier = add_distance_modifier
fractured_world.add_point_type = add_point_type
fractured_world.add_cartesian_function = add_cartesian_function
fractured_world.add_preset = add_preset
fractured_world.add_resource_data = add_resource_data
require("raw-data.distance-modifiers")
require("raw-data.point-types")
require("raw-data.cartesian-functions")
require("raw-data.preset-data")
require("raw-data.resource-data")
