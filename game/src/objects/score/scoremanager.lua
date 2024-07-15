local gameObject = require "src.objects.gameobject"
local scoreDisplay = require "src.objects.score.scoredisplay"
local worldAlertObject = require "src.objects.stagedirector.worldalertobject"

local scoreManager = class({name = "Score Manager", extends = gameObject})

function scoreManager:new(x, y)
    self:super(x, y)

    self.scoreMultiplier = 1
    self.scoreWaveMultiplier = 1
    self.maxMultiplierResetTime = 3.5
    self.multiplierResetTime = 0
    self.multiplierPaused = false
    self.score = 0
    self.multiplierIncrementAmount = 10
    self.numMultiplierIncrements = 1

    self.scoreDisplay = scoreDisplay()
    game.interfaceRenderer:addHudElement(self.scoreDisplay)

    self.multiplierResetSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("multiplierReset")
end

function scoreManager:update(dt)
    if self.multiplierPaused then
        return
    end

    self.multiplierResetTime = self.multiplierResetTime - (1 * dt)

    if self.multiplierResetTime <= 0 then
        self:resetMultiplier(true)
    end

    if self.scoreMultiplier == (self.numMultiplierIncrements * self.multiplierIncrementAmount) then
        self.numMultiplierIncrements = self.numMultiplierIncrements + 1

        local playerPosition = game.playerManager.playerPosition
        gameHelper:addGameObject(worldAlertObject(playerPosition.x, playerPosition.y, "Multiplier: *"..self.scoreMultiplier, "fontScore"))
    end
end

function scoreManager:resetMultiplier(playSound)
    if self.scoreMultiplier > 1 and playSound then
        self.multiplierResetSound:play()
    end

    self.scoreMultiplier = 1
    self.multiplierResetTime = 0
    self.numMultiplierIncrements = 1
end

function scoreManager:resetWaveMultiplier()
    self.scoreWaveMultiplier = 1
end

function scoreManager:setMultiplierPaused(multiplierPaused)
    self.multiplierPaused = multiplierPaused
end

function scoreManager:addScore(score, multiplier)
    self.score = self.score + ((score * multiplier) * self.scoreWaveMultiplier)
end

function scoreManager:incrementMultiplier()
    self.scoreMultiplier = self.scoreMultiplier + 1
    self.multiplierResetTime = self.maxMultiplierResetTime
end

function scoreManager:incrementWaveMultiplier()
    self.scoreWaveMultiplier = self.scoreWaveMultiplier + 1
end

function scoreManager:cleanup(destroyReason)
    gameObject.cleanup(self, destroyReason)

    game.interfaceRenderer:removeHudElement(self.scoreDisplay)
    game.manager.runInfo.score = self.score
end

return scoreManager