fractured_world = {}
fractured_world.raw_resource_data = {}
--[[{["iron-ore"] = {base_density = 10, starting_rq_factor_multiplier = 1.5},
    ["copper-ore"] = {base_density = 8, starting_rq_factor_multiplier = 1.2},
    ["coal"] = {base_density = 8, starting_rq_factor_multiplier = 1.1},
    ["stone"] = {base_density = 4, starting_rq_factor_multiplier = 1.1},
    ["uranium-ore"] = {
        base_density = 0.9,
        base_spots_per_km2 = 1.25,
        random_spot_size_minimum = 2,
        random_spot_size_maximum = 4
    },
    ["crude-oil"] = {
        base_density = 8.2,
        base_spots_per_km2 = 1.8,
        random_spot_size_minimum = 1,
        random_spot_size_maximum = 1,
        additional_richness = 220000,
        random_probability = 1 / 48
    }
}]]

local function checkString(v)
    if type(v) ~= "string" then error(tostring(v) .. " must be a string") end
end
--- Adds a distance modifier to Fractured World.
-- Distance Modifiers work on voronoi-type presets
-- Each distance modifier takes the parameters distance, angle, and value
-- Distance - Distance from the point of interest
-- Angle - Angle from the point of interest
-- Value - The random "value" of the point of interest
-- @param name The name of the modifier
-- @param func The function
function fractured_world.add_distance_modifier(self, name, func)
    if type(name) ~= "string" or type(func) ~= "function" then
        error("Invalid distance modifier specification: " .. name)
    end
    if not self.distance_modifiers then self.distance_modifiers = {} end
    self.distance_modifiers[name] = func
end

function fractured_world.get_distance_modifier(self, name)
    local func = self.distance_modifiers[name]
    if func then
        return func
    else
        error("Distance modifier " .. name .. " is not defined")
    end
end

--- Adds a point type to Fractured World.
-- Point types work on voronoi-type presets
-- Each distance modifier takes the parameters x, y, width, and returns a table of x, y, and val
-- x - The X coordinate of the cell
-- y - The Y coordinate of the cell
-- width - The maximum x or y value to be returned
-- @param name The name of the function
-- @param func The function
function fractured_world.add_point_type(self, name, func)
    if type(name) ~= "string" or type(func) ~= "function" then
        error("Invalid point type specification: " .. name)
    end
    if not self.point_types then self.point_types = {} end
    fractured_world.point_types[name] = func
end

--- Returns the point type function identified by the given name
-- @param name The name of the function
function fractured_world.get_point_type(self, name)
    local func = self.point_types[name]
    if func then
        return func
    else
        error("Point type " .. name .. " is not defined")
    end
end

--- Adds a cartesian function to Fractured World.
-- Cartesian functions are used in cartesian-type presets
-- Each cartesian function takes the cell coordinates
-- x - The X coordinate of the cell
-- y - The Y coordinate of the cell
-- Each function returns a boolean (1 or 0 value) that determines whether a cell should have land or not
-- @param name The name of the function
-- @param func The function
function fractured_world.add_cartesian_function(self, name, func)
    if type(name) ~= "string" or type(func) ~= "function" then
        error("Invalid cartesian function specification: " .. name)
    end
    if not self.cartesian_functions then self.cartesian_functions = {} end
    fractured_world.cartesian_functions[name] = func
end

--- Returns the cartesian function identified by the given name
-- @param name The name of the function
function fractured_world.get_cartesian_function(self, name)
    local func = self.cartesian_functions[name]
    if func then
        return func
    else
        error("Cartesian function " .. name .. " is not properly defined")
    end
end

--- Adds a preset to Fractured World.
-- Parameters:
-- * basic_settings - table of MapGenSettings
-- * fracturedControls - type of MapGenSize
-- * defaultSize - name of default cell size expression to use
-- * rotation
-- * fracturedResources
-- * fracturedEnemies
-- * voronoi - table of voronoi preset settings
-- * * class
-- * * distanceType
-- * * pointType
-- * * distanceModifier
-- * * waterInfluence
-- * * offsetFactor
-- * cartesian - name of cartesian function to use
-- @param name The name of the modifier
-- @param parameters A table defining the preset
function fractured_world.add_preset_data(self, name, parameters)
    if type(name) ~= "string" or type(parameters) ~= "table" then
        error("Invalid preset specification: " .. name)
    end
    if not self.preset_data then self.preset_data = {} end
    fractured_world.preset_data[name] = parameters
end

--- Gets specifications for a preset
-- @param name The name of the preset to retrieve
function fractured_world.get_preset_data(self, name)
    local preset = self.preset_data[name]
    if preset then
        return preset
    else
        error(tostring(name) .. " is not a registered preset")
    end
end

--- Sets resource data for a given mod
-- @param modname The name of the mod. Changes will only be used if this mod is present and active
-- @param resources Table of resource-name -> resource specification
function fractured_world.set_resource_data(self, resource, params)
    fractured_world.raw_resource_data[resource] = params
end

--[[function fractured_world.set_resource_data(self, modname, resources)
    if type(modname) ~= "string" or type(resources) ~= "table" then
        error("Invalid resource data: " .. modname)
    end
    if not self.raw_resource_data then self.raw_resource_data = {} end
    fractured_world.raw_resource_data[modname] = resources
end--]]

local allowed_class2 = {probability = true, richness = true}
local allowed_class1 = {resource = true, enemy = true}
function fractured_world.add_property_expression(self, name, class1, class2,
                                                 expression)
    checkString(name)
    checkString(class1)
    checkString(class2)
    if not allowed_class1[class1] then
        error(tostring(class2) .. " is not a valid property expression type.")
    end
    if not allowed_class2[class2] then
        error(tostring(class2) .. " is not a valid property expression type.")
    end
    if not self.property_expressions then
        self.property_expressions = {resource = {}, enemy = {}}
    end
    local noiseExpName = "fractured-world-" .. name .. "-" .. tostring(class2)
    local propExpName = "entity:" .. name .. ":" .. tostring(class2)
    data:extend{
        {
            type = "noise-expression",
            name = noiseExpName,
            expression = expression
        }
    }
    if class1 == "resource" then
        self.property_expressions.resource[propExpName] = noiseExpName
    elseif class1 == "enemy" then
        self.property_expressions.enemy[propExpName] = noiseExpName
    end

end
