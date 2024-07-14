local gameObject = require "src.objects.gameobject"
local scoreDisplay = require "src.objects.score.scoredisplay"

local scoreManager = class({name = "Score Manager", extends = gameObject})

function scoreManager:new(x, y)
    self:super(x, y)

    self.scoreMultiplier = 1
    self.maxMultiplierResetTime = 3.5
    self.multiplierResetTime = 0
    self.multiplierPaused = false
    self.score = 0

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
end

function scoreManager:resetMultiplier(playSound)
    if self.scoreMultiplier > 1 and playSound then
        self.multiplierResetSound:play()
    end

    self.scoreMultiplier = 1
    self.multiplierResetTime = 0
end

function scoreManager:setMultiplierPaused(multiplierPaused)
    self.multiplierPaused = multiplierPaused
end

function scoreManager:addScore(score, multiplier)
    self.score = self.score + (score * multiplier)
end

function scoreManager:incrementMultiplier()
    self.scoreMultiplier = self.scoreMultiplier + 1
    self.multiplierResetTime = self.maxMultiplierResetTime
end

function scoreManager:cleanup(destroyReason)
    gameObject.cleanup(self, destroyReason)

    game.interfaceRenderer:removeHudElement(self.scoreDisplay)
    game.manager.runInfo.score = self.score
end

return scoreManager