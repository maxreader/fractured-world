local tne = require("noise").to_noise_expression
local preset_data = require('prototypes.preset-data')
local fne = require("prototypes.fractured-noise-expressions")
local make_cartesian_preset = fne.make_cartesian_preset
local make_voronoi_preset = fne.make_voronoi_preset
local make_preset = require("prototypes.map-gen-presets")

local function make_world(name, args)
    if args.cartesian then
        make_cartesian_preset(name, args)
    elseif not args.special then
        make_voronoi_preset(name, args)
    end
    make_preset(name, args)
end

for name, args in pairs(preset_data) do make_world(name, args) end
