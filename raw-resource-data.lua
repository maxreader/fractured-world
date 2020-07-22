-- base density
-- frequency default = 2.5 spots/km
-- randmin default = 0.25
-- randmax default = 2
-- add-richness
-- randProb
return {
    base = {
        ["iron-ore"] = {density = 10},
        ["copper-ore"] = {density = 8},
        ["coal"] = {density = 8},
        ["stone"] = {density = 4},
        ["uranium-ore"] = {
            density = 0.9,
            frequency = 1.25,
            randmin = 2,
            randmax = 4
        },
        ["crude-oil"] = {
            density = 8.2,
            frequency = 1.8,
            randmin = 1,
            randmax = 1,
            addRich = 220000,
            randProb = 1 / 48
        }
    },
    bobplates = {
        ["bauxite-ore"] = {density = 8},
        ["cobalt-ore"] = {density = 4},
        ["ground-water"] = {density = 4},
        ["lithia-water"] = {
            density = 8.2,
            frequency = 1.8,
            randmin = 1,
            randmax = 1,
            addRich = 220000,
            randProb = 1 / 48
        },
        ["gem-ore"] = {density = 0.1},
        ["gold-ore"] = {density = 4},
        ["lead-ore"] = {density = 8},
        ["nickel-ore"] = {density = 5},
        ["quartz"] = {density = 4},
        ["rutile-ore"] = {density = 8},
        ["silver-ore"] = {density = 4},
        ["sulfur"] = {density = 8},
        ["thorium-ore"] = {
            density = 0.9,
            frequency = 1.25,
            randmin = 2,
            randmax = 4
        },
        ["tin-ore"] = {density = 8},
        ["tungsten-ore"] = {density = 8},
        ["zinc-ore"] = {density = 4}

    },
    angelsrefining = {
        ["angels-fissure"] = {
            density = 3,
            frequency = 1.8,
            randmin = 1,
            randmax = 1,
            addRich = 2500,
            randProb = 1 / 48
        },
        ["angels-ore1"] = {density = 10},
        ["angels-ore2"] = {density = 7},
        ["angels-ore3"] = {density = 10},
        ["angels-ore4"] = {density = 7},
        ["angels-ore5"] = {density = 8},
        ["angels-ore6"] = {density = 8},
        ["coal"] = {density = 8},
        ["crude-oil"] = {
            density = 8,
            frequency = 1.8,
            randmin = 1,
            randmax = 1,
            addRich = 10000,
            randProb = 1 / 48
        }
    },
    angelspetrochem = {
        ["angels-natural-gas"] = {
            density = 8,
            frequency = 1.8,
            randmin = 1,
            randmax = 1,
            addRich = 10000,
            randProb = 1 / 48,
            postMult = 0.03
        }
    },
    angelsinfiniteores = {
        ["infinite-angels-ore1"] = {density = 5},
        ["infinite-angels-ore2"] = {density = 5},
        ["infinite-angels-ore3"] = {density = 5},
        ["infinite-angels-ore4"] = {density = 5},
        ["infinite-angels-ore5"] = {density = 5},
        ["infinite-angels-ore6"] = {density = 5}
    },
    Krastorio2 = {
        ["immersite"] = {
            density = 1,
            frequency = 0.2,
            randmin = 0.01,
            randmax = 0.1,
            addRich = 350000
        },
        ["mineral-water"] = {
            density = 2,
            frequency = 0.5,
            randmin = 1,
            randmax = 1,
            addRich = 50000,
            randProb = 1 / 50
        },
        ["rare-metals"] = {
            density = 1,
            frequency = 0.75,
            randmin = 0.25,
            randmax = 3
        }
    },
    DyWorld = {
        ["stone"] = {density = 24},
        ["coal"] = {density = 12},
        ["iron-ore"] = {density = 15},
        ["copper-ore"] = {density = 13},
        ["nickel-ore"] = {density = 12},
        ["silver-ore"] = {density = 8},
        ["tin-ore"] = {density = 9},
        ["gold-ore"] = {density = 5},
        ["lead-ore"] = {density = 12},
        ["cobalt-ore"] = {density = 10},
        ["arditium-ore"] = {density = 15},
        ["titanium-ore"] = {density = 11},
        ["tungsten-ore"] = {density = 12},
        ["neutronium-ore"] = {density = 25}
    }
}
