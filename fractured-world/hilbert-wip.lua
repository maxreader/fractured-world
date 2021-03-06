local noise = require("noise")
local functions = require("prototypes.functions")
local modulo = functions.modulo
local floorDiv = functions.floorDiv

local n = 2 ^ 7
local function magicHilbert(number, n) return modulo(floorDiv(number, n), 2) end

local function on_hilbert(x, y)
    x = noise.ridge(x, -1, 3)
    y = noise.ridge(y, 0, 4)
    -- x = modulo(x, 4)
    -- y = modulo(y, 4)
    return noise.clamp(noise.less_than(0, y) - modulo(x, 2) * (1 - noise.equals(y, x)), 0, 1)
end

local function my_hilbert(x, y, n)
    n = n / 2
    if n < 2 then
        return on_hilbert(x, y)
    else
        local m = 2 ^ n
        return (my_hilbert(n - 1 - x, x, n))
    end
end
