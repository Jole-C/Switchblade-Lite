local pauseManager = require "game.pausemanager"

local gameManager = class{
    palettes = {},
    currentPalette = {},

    isTransitioning = false,
    isPaused = false,
    pauseManager,

    init = function(self)

    end,

    update = function(self, dt)
        if self.isPaused == true and self.pauseManager == nil then
            self.pauseManager = pauseManager()
        end
        
        if self.isPaused == false and self.pauseManager ~= nil then
            self.pauseManager:destroy()
            self.pauseManager = nil
        end

        if self.pauseManager then
            self.pauseManager:update(dt)
        end
    end,

    draw = function(self)
    end,

    togglePausing = function(self)
        self.isPaused = not self.isPaused
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