local pauseManager = require "src.pausemanager"
local playerDefault = require "src.objects.player.playerships.playerdefault"
local playerLight = require "src.objects.player.playerships.playerlight"
local playerHeavy = require "src.objects.player.playerships.playerheavy"
local playerDefinition = require "src.objects.player.playerdefinition"
local gameManager = class({name = "Game Manager"})

function gameManager:new()
    self.palettes = {}
    self.currentPaletteGroup = {}
    self.currentPalette = {}
    self.maxPaletteSwapCooldown = 3
    self.paletteSwapCooldown = -1

    self.isTransitioning = false
    self.isPaused = false
    self.pauseManager = nil

    self.freezeFrames = 0
    self.gameFrozen = false

    -- Set up the player definitions
    self.playerDefinitions = {
        ["default definition"] = playerDefinition("default", playerDefault, ""),
        ["light definition"] = playerDefinition("light", playerLight, ""),
        ["heavy definition"] = playerDefinition("heavy", playerHeavy, "")
    }

    self.currentPlayerDefinition = self.playerDefinitions["default definition"]

    -- Set up the options
    self.optionsFile = "options.txt"
    self.expectedOptionsVersion = "0.3"
    
    self.options = {
        OPTIONS_VERSION = "0.3",
        enableFullscreen = true,
        enableBackground = true,
        fadingPercentage = 10,
        speedPercentage = 100,
        musicVolPercentage = 70,
        sfxVolPercentage = 100,
        enableDebugMode = false,
        limitPaletteSwaps = false,
        toggleScreenshake = false,
        disableFreeze = false,
        centerCamera = false,
    }

    self.unlocks = {
        level1beaten = false,
        level2beaten = false,
        level3beaten = false,
        shipUnlocks = {

        }
    }

    love.filesystem.setIdentity("switchblade")
    self:loadOptions()
end

function gameManager:update(dt)
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

    self.freezeFrames = self.freezeFrames - 1 * dt
    self.gameFrozen = self.freezeFrames > 0

    if self:getOption("limitPaletteSwaps") then
        self.paletteSwapCooldown = self.paletteSwapCooldown - (1 * dt)
    end
end

function gameManager:changePlayerDefinition(definitionName)
    local chosenDefinition = self.playerDefinitions[definitionName]

    if chosenDefinition == nil then
        chosenDefinition = self.playerDefinitions["default definition"]
    end

    self.currentPlayerDefinition = chosenDefinition
end

function gameManager:setFreezeFrames(freezeFrames)
    self.freezeFrames = freezeFrames / 50
end

function gameManager:togglePausing()
    self.isPaused = not self.isPaused
end

function gameManager:addPalette(groupName, palette)
    local group = self.palettes[groupName]

    assert(group ~= nil, "Group is nil! Did you add it?")

    table.insert(self.palettes[groupName], palette)
end

function gameManager:swapPaletteGroup(newPaletteGroup)
    local group = self.palettes[newPaletteGroup]
    assert(group ~= nil, "Group is nil! Did you add it?")

    self.currentPaletteGroup = group
end

function gameManager:swapPalette()
    if self:getOption("limitPaletteSwaps") and self.paletteSwapCooldown > 0 then
        return
    end

    local paletteIndex = love.math.random(1, #self.currentPaletteGroup)
    self.currentPalette = self.currentPaletteGroup[paletteIndex]

    self.paletteSwapCooldown = self.maxPaletteSwapCooldown
end

function gameManager:addPaletteGroup(name)
    self.palettes[name] = {}
end

function gameManager:setupPalettes(paletteImages)
    for name, paletteImage in pairs(paletteImages) do
        local width, height = paletteImage:getDimensions()
        self:addPaletteGroup(name)

        for y = 0, height - 1 do
            local grabbedColours = {}

            for x = 0, width - 1 do
                local r, g, b, a = paletteImage:getPixel(x, y)
                table.insert(grabbedColours, {r, g, b, a})
            end
            
            self:addPalette(name,
            {
                playerColour = grabbedColours[1],
                enemyColour = grabbedColours[2],
                backgroundColour = {
                    grabbedColours[3],
                    grabbedColours[4],
                    grabbedColours[5],
                    grabbedColours[6],
                    grabbedColours[7],
                },
                uiColour = grabbedColours[8],
                enemySpawnColour = grabbedColours[9],
                uiSelectedColour = grabbedColours[10],
            })
        end
    end
    
    -- Swap to a random palette
    local paletteIndex = love.math.random(1, #self.currentPaletteGroup)
    self.currentPalette = self.currentPaletteGroup[paletteIndex]
end

function gameManager:saveOptions()
    local string = ""

    for k, v in pairs(self.options) do
        string = string..k.."="..tostring(v).."\n"
    end

    local file = love.filesystem.newFile(self.optionsFile)
    local bool, err = file:open("w")
    print(err)

    file:write(string)
    file:close()
end

function gameManager:loadOptions()
    local info = love.filesystem.getInfo(self.optionsFile)

    if info then
        print("file exists")
        local options = {}

        for line in love.filesystem.lines(self.optionsFile) do
            local lineVals = {}
            
            for string in string.gmatch(line, "([^".."=".."]+)") do
                table.insert(lineVals, string)
            end

            local option = lineVals[1]
            local value = lineVals[2]

            if value == "true" then
                value = true
            elseif value == "false" then
                value = false
            elseif type(value) == "string" then
                value = value
            elseif tonumber(value) then
                value = tonumber(value)
            end

            options[option] = value
            print(line)
        end

        -- Check to see if the options file is using the old version
        if options.OPTIONS_VERSION then
            print ("Current options version: "..options.OPTIONS_VERSION)
        end

        if options.OPTIONS_VERSION == nil or options.OPTIONS_VERSION ~= self.expectedOptionsVersion then
            print("Options are using old values or options file is out of date. Recreating...")
            self:saveOptions()
            return
        end

        self.options = options
    else
        self:saveOptions()
    end
end

function gameManager:getOption(optionName)
    assert(self:optionExists(optionName), "Option does not exist!")
    return self.options[optionName]
end

function gameManager:setOption(optionName, newValue)
    assert(self:optionExists(optionName), "Option does not exist!")
    self.options[optionName] = newValue
end

function gameManager:optionExists(optionName)
    for k, v in pairs(self.options) do
        if k == optionName then
            return true
        end
    end

    return false
end

function gameManager:draw()

end

return gameManager