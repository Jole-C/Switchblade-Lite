local hudElement = require "src.interface.hudelement"
local stageTimeHud = class({name = "Stage Time Hud", extends = hudElement})

function stageTimeHud:new()
    self:super()

    self.timeSeconds = 0
    self.timeMinutes = 0
    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontTime")
end

function stageTimeHud:draw()
    local timeString = string.format("%02.0f:%02.0f",math.abs(self.timeMinutes),math.abs(self.timeSeconds))
    local textWidth = self.font:getWidth(timeString)
    love.graphics.setFont(self.font)

    love.graphics.setColor(game.manager.currentPalette.uiColour)

    if self.timeSeconds <= 5 and self.timeMinutes <= 0 then
        love.graphics.setColor(game.manager.currentPalette.enemyColour)
    end

    love.graphics.print(timeString, game.arenaValues.screenWidth/2 - textWidth/2, 8)
end

return stageTimeHud