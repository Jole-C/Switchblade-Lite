local gameObject = require "src.objects.gameobject"
local worldIndicator = class({name = "World Indicator", extends = gameObject})

function worldIndicator:new(x, y, text, fontName)
    self:super(x, y)

    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get(fontName or "fontScore")
    self.text = text or ""

    self.yOffset = 20
    self.targetY = y - self.yOffset
    self.yLerpRate = 0.05
    self.textAlpha = 1
    self.textAlphaLerpRate = 0.05
end

function worldIndicator:update(dt)
    self.position.y = math.lerpDT(self.position.y, self.targetY, self.yLerpRate, dt)

    if math.abs(self.position.y - self.targetY) < 1 then
        self.textAlpha = math.lerpDT(self.textAlpha, 0, self.textAlphaLerpRate, dt)

        if self.textAlpha < 0.1 then
            self:destroy()
        end
    end
end

function worldIndicator:draw()
    love.graphics.setFont(self.font)
    local width = self.font:getWidth(self.text)

    local colour = game.manager.currentPalette.uiColour
    love.graphics.setColor(colour[1], colour[2], colour[3], self.textAlpha)
    love.graphics.print(self.text, self.position.x - width / 2, self.position.y)
    love.graphics.setColor(1, 1, 1, 1)
end

return worldIndicator