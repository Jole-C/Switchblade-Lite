local gameObject = require "src.objects.gameobject"
local scoreDisplay = require "src.objects.score.scoredisplay"
local worldAlertObject = require "src.objects.stagedirector.worldalertobject"

local scoreManager = class({name = "Score Manager", extends = gameObject})

function scoreManager:new(x, y)
    self:super(x, y)

    self.scoreMultiplier = 1
    self.maxMultiplierResetTime = 4
    self.multiplierResetTime = 0
    self.multiplierPaused = false
    self.score = 0
    self.waveScore = 0
    self.multiplierIncrementAmount = 10
    self.numMultiplierIncrements = 1

    self.bonuses =
    {
        ["boostBonus"] = {bonusFunction = function(score, multiplier)
            return score + (1500 * multiplier)
        end, bonusText = "Boost Bonus!"},
        ["waveBonus"] = {bonusFunction = function(score, multiplier)
            return score * 2
        end, bonusText = "Wave Bonus!"}
    }

    self.scoreDisplay = scoreDisplay()
    game.interfaceRenderer:addHudElement(self.scoreDisplay)

    self.multiplierResetSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("multiplierReset")
    self.bonusSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("timeAdded")
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

function scoreManager:beginNewWaveScore()
    self.waveScore = 0
end

function scoreManager:applyWaveScore()
end

function scoreManager:resetMultiplier(playSound)
    if self.scoreMultiplier > 1 and playSound then
        self.multiplierResetSound:play()

        local playerPosition = game.playerManager.playerPosition
        gameHelper:addGameObject(worldAlertObject(playerPosition.x, playerPosition.y, "Multiplier reset!", "fontScore"))
    end

    self.scoreMultiplier = 1
    self.multiplierResetTime = 0
    self.numMultiplierIncrements = 1
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

function scoreManager:applyBonus(bonusName)
    local bonus = self.bonuses[bonusName]
    assert(bonus ~= nil, "Bonus does not exist!")

    self.waveScore = bonus.bonusFunction(self.waveScore, self.scoreMultiplier)

    local playerPosition = game.playerManager.playerPosition
    local text = worldAlertObject(playerPosition.x, playerPosition.y, bonus.bonusText or "", "fontScore")
    gameHelper:addGameObject(text)

    self.bonusSound:play()
    gameHelper:screenShake(0.3)
end

function scoreManager:cleanup(destroyReason)
    gameObject.cleanup(self, destroyReason)

    game.interfaceRenderer:removeHudElement(self.scoreDisplay)
    game.manager:addRunInfoText("Score", self.score)
end

return scoreManager