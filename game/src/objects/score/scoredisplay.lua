local hudElement = require "src.interface.hudelement"
local scoreDisplay = class({name = "Score Display", extends = hudElement})

function scoreDisplay:new()
    self:super()
    
    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontTime")
    self.multiplierFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontScore")
    self.multiplierLineX = 318
    self.multiplierLineY = 26
    self.multiplierLineLength = 480 - self.multiplierLineX
    self.multiplierLineHeight = 6
end

function scoreDisplay:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(game.manager.currentPalette.uiColour)

    local scoreManager = gameHelper:getScoreManager()
    local scoreString = string.format("%07d", scoreManager.score)
    local scoreLength = self.font:getWidth(scoreString)

    love.graphics.print(scoreString, 480 - scoreLength - 2, 8)

    love.graphics.setFont(self.multiplierFont)

    local multiplier = scoreManager.scoreMultiplier
    local multiplierString = tostring(multiplier).."*"
    local multiplierLength = self.multiplierFont:getWidth(multiplierString)
    local multiplierHeight = self.multiplierFont:getHeight(multiplierString)
    local scoreHeight = self.font:getHeight(scoreString)

    love.graphics.print(multiplierString, 480 - scoreLength - 2 - multiplierLength, 8 + scoreHeight - multiplierHeight)

    local t = scoreManager.multiplierResetTime / scoreManager.maxMultiplierResetTime
    local rectWidth = math.lerp(0, self.multiplierLineLength, math.clamp(t, 0, 1))

    love.graphics.rectangle("fill", self.multiplierLineX, self.multiplierLineY, rectWidth, self.multiplierLineHeight)

    love.graphics.rectangle("line", self.multiplierLineX, self.multiplierLineY, self.multiplierLineLength, self.multiplierLineHeight)
    love.graphics.setColor(1, 1, 1, 1)
end

return scoreDisplay