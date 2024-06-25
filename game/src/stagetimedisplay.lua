local hudElement = require "src.interface.hudelement"
local stageTimeHud = class({name = "Stage Time Hud", extends = hudElement})

function stageTimeHud:new()
    self:super()

    self.timeSeconds = 0
    self.timeMinutes = 0
    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontMain")
end

function stageTimeHud:draw()
    local timeString = string.format("%02.0f:%02.0f",self.timeMinutes,self.timeSeconds)
    local textWidth = self.font:getWidth(timeString)
    love.graphics.setFont(self.font)
    love.graphics.print(timeString, game.arenaValues.screenWidth/2 - textWidth/2, 0)
end

return stageTimeHud