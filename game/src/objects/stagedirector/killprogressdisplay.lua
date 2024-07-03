local hudElement = require "src.interface.hudelement"
local killDisplay = class({name = "Kill Display", extends = hudElement})

function killDisplay:new()
    self:super()
    
    self.lineY = game.arenaValues.screenHeight - 5
    self.lineX = 10
    self.lineLength = game.arenaValues.screenWidth - self.lineX
    self.lineWidth = 3

    self.totalKills = 0
    self.kills = 0

    self.time = 0
    self.totalTime = 0
end

function killDisplay:draw()
    love.graphics.setColor(game.manager.currentPalette.uiColour)
    love.graphics.setLineWidth(self.lineWidth)

    local x1 = self.lineX
    local x2 = math.lerp(self.lineX, self.lineLength, math.clamp(self.kills/self.totalKills, 0, 1))
    local y1 = self.lineY
    local y2 = self.lineY

    love.graphics.line(x1, y1, x2, y2)

    love.graphics.setLineWidth(1)

    x1 = self.lineX
    x2 = math.lerp(self.lineLength, self.lineX, math.clamp(self.time/self.totalTime, 0, 1))

    love.graphics.line(x1, y1 - 5, x2, y2 - 5)

    love.graphics.setColor(1, 1, 1, 1)
end

return killDisplay