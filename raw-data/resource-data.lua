-- base base_density
-- base_spots_per_km2 default = 2.5 spots/km
-- random_spot_size_minimum default = 0.25
-- random_spot_size_maximum default = 2
-- add-richness
-- random_probability
local pyRockFreq = 1 / 120
local pyRock = {
    base_density = 800 / 3,
    base_spots_per_km2 = 0.12,
    additional_richness = 8000000,
    random_probability = 1 / 120
}
local rawResourceData = {
    base = {
        ["iron-ore"] = {
            base_density = 10,
            starting_rq_factor_multiplier = 1.5
        },
        ["copper-ore"] = {
            base_density = 8,
            starting_rq_factor_multiplier = 1.2
        },
        ["coal"] = {
            base_density = 8,
            starting_rq_factor_multiplier = 1.1
        },
        ["stone"] = {
            base_density = 4,
            starting_rq_factor_multiplier = 1.1
        },
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
    },
    bobplates = {
        ["bauxite-ore"] = {base_density = 8},
        ["cobalt-ore"] = {base_density = 4},
        ["ground-water"] = {base_density = 4},
        ["lithia-water"] = {
            base_density = 8.2,
            base_spots_per_km2 = 1.8,
            random_spot_size_minimum = 1,
            random_spot_size_maximum = 1,
            additional_richness = 220000,
            random_probability = 1 / 48
        },
        ["gem-ore"] = {base_density = 0.1},
        ["gold-ore"] = {base_density = 4},
        ["lead-ore"] = {base_density = 8},
        ["nickel-ore"] = {base_density = 5},
        ["quartz"] = {base_density = 4},
        ["rutile-ore"] = {base_density = 8},
        ["silver-ore"] = {base_density = 4},
        ["sulfur"] = {base_density = 8},
        ["thorium-ore"] = {
            base_density = 0.9,
            base_spots_per_km2 = 1.25,
            random_spot_size_minimum = 2,
            random_spot_size_maximum = 4
        },
        ["tin-ore"] = {
            base_density = 8,
            starting_rq_factor_multiplier = 1.2
        },
        ["tungsten-ore"] = {base_density = 8},
        ["zinc-ore"] = {base_density = 4}

    },
    angelsrefining = {
        ["angels-fissure"] = {
            base_density = 3,
            base_spots_per_km2 = 1.8,
            random_spot_size_minimum = 1,
            random_spot_size_maximum = 1,
            additional_richness = 2500,
            random_probability = 1 / 48
        },
        ["angels-ore1"] = {
            base_density = 10,
            starting_rq_factor_multiplier = 1.5
        },
        ["angels-ore2"] = {
            base_density = 7,
            starting_rq_factor_multiplier = 1.1
        },
        ["angels-ore3"] = {base_density = 10},
        starting_rq_factor_multiplier = 1.5,
        ["angels-ore4"] = {
            base_density = 7,
            starting_rq_factor_multiplier = 1.1
        },
        ["angels-ore5"] = {
            base_density = 8,
            starting_rq_factor_multiplier = 1.2
        },
        ["angels-ore6"] = {
            base_density = 8,
            starting_rq_factor_multiplier = 1.2
        },
        ["coal"] = {
            base_density = 8,
            starting_rq_factor_multiplier = 1.1
        },
        ["crude-oil"] = {
            base_density = 8,
            base_spots_per_km2 = 1.8,
            random_spot_size_minimum = 1,
            random_spot_size_maximum = 1,
            additional_richness = 10000,
            random_probability = 1 / 48
        }
    },
    angelspetrochem = {
        ["angels-natural-gas"] = {
            base_density = 8,
            base_spots_per_km2 = 1.8,
            random_spot_size_minimum = 1,
            random_spot_size_maximum = 1,
            additional_richness = 10000,
            random_probability = 1 / 48,
            richness_post_multiplier = 0.03
        }
    },
    angelsinfiniteores = {
        ["infinite-angels-ore1"] = {base_density = 5},
        ["infinite-angels-ore2"] = {base_density = 5},
        ["infinite-angels-ore3"] = {base_density = 5},
        ["infinite-angels-ore4"] = {base_density = 5},
        ["infinite-angels-ore5"] = {base_density = 5},
        ["infinite-angels-ore6"] = {base_density = 5}
    },
    Krastorio2 = {
        ["immersite"] = {
            base_density = 1,
            base_spots_per_km2 = 0.2,
            random_spot_size_minimum = 0.01,
            random_spot_size_maximum = 0.1,
            additional_richness = 350000
        },
        ["mineral-water"] = {
            base_density = 2,
            base_spots_per_km2 = 0.5,
            random_spot_size_minimum = 1,
            random_spot_size_maximum = 1,
            additional_richness = 50000,
            random_probability = 1 / 50
        },
        ["rare-metals"] = {
            base_density = 1,
            base_spots_per_km2 = 0.75,
            random_spot_size_minimum = 0.25,
            random_spot_size_maximum = 3
        }
    },
    DyWorld = {
        ["stone"] = {
            base_density = 24,
            starting_rq_factor_multiplier = 1.35
        },
        ["coal"] = {
            base_density = 12,
            starting_rq_factor_multiplier = 1.25
        },
        ["iron-ore"] = {
            base_density = 15,
            starting_rq_factor_multiplier = 1.5
        },
        ["copper-ore"] = {
            base_density = 13,
            starting_rq_factor_multiplier = 1.45
        },
        ["nickel-ore"] = {
            base_density = 12,
            starting_rq_factor_multiplier = 1.32
        },
        ["silver-ore"] = {
            base_density = 8,
            starting_rq_factor_multiplier = 1.2
        },
        ["tin-ore"] = {
            base_density = 9,
            starting_rq_factor_multiplier = 1.27
        },
        ["gold-ore"] = {
            base_density = 5,
            starting_rq_factor_multiplier = 1.41
        },
        ["lead-ore"] = {base_density = 12},
        ["cobalt-ore"] = {base_density = 10},
        ["arditium-ore"] = {base_density = 15},
        ["titanium-ore"] = {base_density = 11},
        ["tungsten-ore"] = {base_density = 12},
        ["neutronium-ore"] = {base_density = 25}
    },
    pyrawores = {
        borax = {
            base_density = (20 / 3),
            base_spots_per_km2 = 3,
            additional_richness = 10
        },
        ["ore-quartz"] = {
            base_density = 15,
            base_spots_per_km2 = 2.5,
            additional_richness = 300
        },
        ["raw-coal"] = {
            base_density = 15,
            base_spots_per_km2 = 2.5,
            additional_richness = 300
        },
        ["ore-tin"] = {
            base_density = 15,
            base_spots_per_km2 = 2.5,
            additional_richness = 300
        },
        ["ore-titanium"] = {
            base_density = 15,
            base_spots_per_km2 = 2.5,
            additional_richness = 300
        },
        niobium = {
            base_density = 15,
            base_spots_per_km2 = 1.875,
            additional_richness = 500
        },
        ["ore-lead"] = {
            base_density = 15,
            base_spots_per_km2 = 1.625,
            additional_richness = 300
        },
        ["ore-aluminum"] = {
            base_density = 10,
            base_spots_per_km2 = 0.1875,
            additional_richness = 10
        },
        ["ore-chromium"] = {
            base_density = 10,
            base_spots_per_km2 = 0.1875,
            additional_richness = 10
        },
        ["ore-nickel"] = {
            base_density = 10,
            base_spots_per_km2 = 0.1875,
            additional_richness = 10
        },
        ["ore-zinc"] = {
            base_density = 10,
            base_spots_per_km2 = 0.1875,
            additional_richness = 10
        },

        ["salt-rock"] = {
            base_density = 800 / 3,
            base_spots_per_km2 = 2.4,
            additional_richness = 1000000,
            random_probability = 1 / 120
        },
        ["uranium-rock"] = {
            base_density = 800 / 3,
            base_spots_per_km2 = 0.09,
            additional_richness = 8000000,
            random_probability = 1 / 120
        },
        ["iron-rock"] = pyRock,
        ["copper-rock"] = pyRock,
        ["zinc-rock"] = pyRock,
        ["aluminium-rock"] = pyRock,
        ["chromium-rock"] = pyRock,
        ["coal-rock"] = pyRock,
        ["lead-rock"] = pyRock,
        ["nexelit-rock"] = pyRock,
        ["nickel-rock"] = pyRock,
        ["phosphate-rock-02"] = pyRock,
        ["quartz-rock"] = pyRock,
        ["tin-rock"] = pyRock,
        ["titanium-rock"] = pyRock,
        ["volcanic-pipe"] = {
            random_probability = pyRockFreq
        },
        ["regolites"] = {random_probability = pyRockFreq},
        ["rare-earth-bolide"] = {
            random_probability = pyRockFreq
        },
        ["phosphate-rock"] = {
            random_probability = pyRockFreq
        },
        ["sulfur-patch"] = {random_probability = pyRockFreq},
        ["oil-mk01"] = {random_probability = pyRockFreq},
        ["oil-mk02"] = {random_probability = pyRockFreq},
        ["oil-mk03"] = {random_probability = pyRockFreq},
        ["oil-mk04"] = {random_probability = pyRockFreq},
        ["tar-patch"] = {random_probability = pyRockFreq}
    }
}
for k, v in pairs(rawResourceData) do fractured_world.set_resource_data_data(k, v) end

--[[
coverage = 0.004 -> base_spots_per_km2 = 2.5
richness_base = 300 -> 1000000
richness_multiplier = 1500 -> richness_post_multiplier = 1
richness_multiplier_distance_bonus = 30
]]
