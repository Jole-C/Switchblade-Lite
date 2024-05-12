local gameManager = class{
    timeDilation = 1,
    palettes = {},
    currentPalette = {},

    init = function(self)

    end,

    addPalette = function(self, palette)
        table.insert(self.palettes, palette)
    end,

    swapPalette = function(self)
        local paletteIndex = love.math.random(1, #self.palettes)
        self.currentPalette = self.palettes[paletteIndex]
    end,

    setTimeDilation = function(self, percentage)
        self.timeDilation = percentage
    end
}

return gameManager