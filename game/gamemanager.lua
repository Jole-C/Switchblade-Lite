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

    options = {
        enableBackground = 1,
        fadingPercentage = 50,
        speedPercentage = 50,
        musicVolPercentage = 70,
        sfxVolPercentage = 100
    },
    unlocks = {
        level1beaten = false,
        level2beaten = false,
        level3beaten = false,
        shipUnlocks = {

        },
    },

    isTransitioning = false,
    isPaused = false,
    pauseManager,

    optionsFile = "options.txt",

    init = function(self)
        -- Set up the player definitions
        self.playerDefinitions = {
            ["default definition"] = playerDefinition("default", playerDefault, ""),
            ["light definition"] = playerDefinition("light", playerLight, ""),
            ["heavy definition"] = playerDefinition("heavy", playerHeavy, "")
        }

        self.currentPlayerDefinition = self.playerDefinitions["default definition"]

        -- Set up the options
        love.filesystem.setIdentity("switchblade")
        local info = love.filesystem.getInfo(self.optionsFile)

        if info then
            print("file exists")

            local loadedOptions = {}

            for line in love.filesystem.lines(self.optionsFile) do
                table.insert(loadedOptions, tonumber(line))
                print(line)
            end
            
            self.options = {
                enableBackground = loadedOptions[1],
                fadingPercentage = loadedOptions[2],
                speedPercentage = loadedOptions[3],
                musicVolPercentage = loadedOptions[4],
                sfxVolPercentage = loadedOptions[5]
            }
        else
            local file = love.filesystem.newFile(self.optionsFile)
            local bool, err = file:open("w")
            print(err)

            file:write(self.options.enableBackground.."\n")
            file:write(self.options.fadingPercentage.."\n")
            file:write(self.options.speedPercentage.."\n")
            file:write(self.options.musicVolPercentage.."\n")
            file:write(self.options.sfxVolPercentage.."\n")

            file:close()
        end
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
        
    end,

    saveOptions = function(self)
        local file = love.filesystem.newFile(self.optionsFile)
        local bool, err = file:open("w")
        print(err)

        file:write(self.options.enableBackground.."\n")
        file:write(self.options.fadingPercentage.."\n")
        file:write(self.options.speedPercentage.."\n")
        file:write(self.options.musicVolPercentage.."\n")
        file:write(self.options.sfxVolPercentage.."\n")

        file:close()
    end
}

return gameManager