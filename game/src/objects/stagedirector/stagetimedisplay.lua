local hudElement = require "src.interface.hudelement"
local stageTimeHud = class({name = "Stage Time Hud", extends = hudElement})

function stageTimeHud:new()
    self:super()

    self.timeSeconds = 0
    self.timeMinutes = 0
    self.timerScale = 1
    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontTime")
end

function stageTimeHud:draw()
    local timeString = string.format("%02.0f:%02.0f",math.abs(self.timeMinutes),math.abs(math.floor(self.timeSeconds)))
    local textWidth = self.font:getWidth(timeString)
    local textHeight = self.font:getHeight(timeString)
    local scaleX = 1
    local scaleY = 1
    local positionOffsetX = 0
    local positionOffsetY = 0

    love.graphics.setFont(self.font)
    love.graphics.setColor(game.manager.currentPalette.uiColour)

    if self.timerScale > 1 then
        love.graphics.setColor(game.manager.currentPalette.playerColour)
    end

    if self.timeSeconds <= 5 and self.timeMinutes <= 0 then
        love.graphics.setColor(game.manager.currentPalette.enemyColour)

        local scale = math.lerp(1, 3, 1 - (math.max(math.floor(self.timeSeconds), 1)/5))
        scaleX = scale
        scaleY = scale
        positionOffsetX = math.random(-3, 3)
        positionOffsetY = math.random(-3, 3)
    end

    love.graphics.print(timeString, game.arenaValues.screenWidth/2 + positionOffsetX, 8 + positionOffsetY, 0, scaleX * self.timerScale, scaleY * self.timerScale, textWidth/2, 0)
end

return stageTimeHud