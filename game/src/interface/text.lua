local hudElement require "src.interface.hudelement"
local textElement = class({name = "Text", extends = hudElement})

function textElement:new(text, font, textAlign, x, y, width, angle, scaleX, scaleY, centerText)
    self.text = text
    self.position = vec2(x, y)
    self.textAlign = textAlign
    self.width = width
    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get(font)
    self.angle = angle or 0
    self.scale = vec2(scaleX or 1, scaleY or 1)
    self.centerText = centerText or false
    self.enabled = true
end

function textElement:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(game.manager.currentPalette.uiColour)

    local offsetX = 0
    local offsetY = 0

    if self.centerText then
        offsetX = self.width/2
        offsetY = self.font:getHeight(self.text)/2
    end
    
    love.graphics.printf(self.text, self.position.x, self.position.y, self.width, self.textAlign, self.angle, self.scale.x, self.scale.y, offsetX, offsetY)

    love.graphics.setColor(1, 1, 1, 1)
end

return textElement