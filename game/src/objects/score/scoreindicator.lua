local gameObject = require "src.objects.gameobject"
local scoreIndicator = class({name = "Score Indicator", extends = gameObject})

function scoreIndicator:new(x, y, score, multiplier)
    self:super(x, y)

    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontScore")

    self.yOffset = 20
    self.targetY = y - self.yOffset
    self.yLerpRate = 0.05
    self.score = score
    self.multiplier = multiplier
    self.textAlpha = 1
    self.textAlphaLerpRate = 0.05
    
    gameHelper:addScore(self.score, self.multiplier)
end

function scoreIndicator:update(dt)
    self.position.y = math.lerpDT(self.position.y, self.targetY, self.yLerpRate, dt)

    if math.abs(self.position.y - self.targetY) < 1 then
        self.textAlpha = math.lerpDT(self.textAlpha, 0, self.textAlphaLerpRate, dt)

        if self.textAlpha < 0.1 then
            self:destroy()
        end
    end
end

function scoreIndicator:draw()
    local width = self.font:getWidth(self.score)

    local colour = game.manager.currentPalette.uiColour
    love.graphics.setColor(colour[1], colour[2], colour[3], self.textAlpha)
    love.graphics.print(tostring(self.score).."(x"..self.multiplier..")", self.position.x - width / 2, self.position.y)
    love.graphics.setColor(1, 1, 1, 1)
end

return scoreIndicator