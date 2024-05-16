local pauseManager = require "game.pausemanager"
local playerDefault = require "game.objects.player.playerships.playerdefault"
local playerLight = require "game.objects.player.playerships.playerlight"
local playerHeavy = require "game.objects.player.playerships.playerheavy"
local playerDefinition = require "game.objects.player.playerdefinition"

local gameManager = class{
    palettes = {},
    currentPalette = {},

    playerDefinitions = {},
    currentPlayerDefinition = {},

    isTransitioning = false,
    isPaused = false,
    pauseManager,

    init = function(self)
        self.playerDefinitions = {
            ["default definition"] = playerDefinition("default", playerDefault, ""),
            ["light definition"] = playerDefinition("light", playerLight, ""),
            ["heavy definition"] = playerDefinition("heavy", playerHeavy, "")
        }

        self.currentPlayerDefinition = self.playerDefinitions["default definition"]
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

    changePlayerDefinition = function(self, definitionName)
        local chosenDefinition = self.playerDefinitions[definitionName]

        if chosenDefinition == nil then
            chosenDefinition = self.playerDefinitions["default definition"]
        end

        self.currentPlayerDefinition = chosenDefinition
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