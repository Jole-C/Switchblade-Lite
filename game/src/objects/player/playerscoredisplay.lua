local hudElement = require "src.interface.hudelement"
local playerScore = class({name = "Player Score", extends = hudElement})

function playerScore:new()
    self:super()
    
    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontTime")
    self.multiplierLineX = 318
    self.multiplierLineY = 26
    self.multiplierLineLength = 480 - self.multiplierLineX
    self.multiplierLineHeight = 6
end

function playerScore:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(game.manager.currentPalette.uiColour)

    local scoreManager = gameHelper:getScoreManager()
    local scoreString = string.format("%07d", scoreManager.score)
    local multiplier = scoreManager.scoreMultiplier
    love.graphics.printf(tostring(multiplier).."x".." "..tostring(scoreString), 0, 8, 480, "right")
    
    local t = scoreManager.multiplierResetTime / scoreManager.maxMultiplierResetTime
    local rectWidth = math.lerp(0, self.multiplierLineLength, math.clamp(t, 0, 1))

    love.graphics.rectangle("fill", self.multiplierLineX, self.multiplierLineY, rectWidth, self.multiplierLineHeight)
    love.graphics.setColor(1, 1, 1, 1)
end

return playerScore