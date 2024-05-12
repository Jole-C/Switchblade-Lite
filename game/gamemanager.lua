local gameManager = class{
    palettes = {},
    currentPalette = {},

    isTransitioning = false,

    init = function(self)

    end,

    update = function(self)

    end,

    draw = function(self)

    end,

    addPalette = function(self, palette)
        table.insert(self.palettes, palette)
    end,

    swapPalette = function(self)
        local paletteIndex = love.math.random(1, #self.palettes)
        self.currentPalette = self.palettes[paletteIndex]
    end,

    transitionGamestate = function(self, gamestate)
        
    end
}

return gameManager