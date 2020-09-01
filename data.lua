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
function fractured_world.add_distance_modifier(name, func)
    fractured_world.distance_modifiers[name] = func
end

--- Adds a point type to Fractured World.
-- Point types work on voronoi-type presets
-- Each distance modifier takes the parameters x, y, width, and returns a table of x, y, and val
-- x - The X coordinate of the cell
-- y - The Y coordinate of the cell
-- width - The maximum x or y value to be returned
-- @param name The name of the modifier
-- @param func The function
function fractured_world.add_point_type(name, func) fractured_world.point_types[name] = func end
function fractured_world.add_cartesian_function(name, func)
    fractured_world.cartesian_fuctions[name] = func
end
function fractured_world.add_preset(name, parameters) fractured_world.presets[name] = parameters end
function fractured_world.set_resource_data_data(modname, resources)
    fractured_world.raw_resource_data[modname] = resources
end

function fractured_world.get_resource_data(modname)
    return table.deep_copy(fractured_world.raw_resource_data[modname])
end

require("raw-data.distance-modifiers")
require("raw-data.point-types")
require("raw-data.cartesian-functions")
require("raw-data.preset-data")
require("raw-data.resource-data")
