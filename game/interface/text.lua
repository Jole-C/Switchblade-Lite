local hudElement require "game.interface.hudelement"
local textElement = class({name = "Text", extends = hudElement})

function textElement:new(text, fontName, textAlign, x, y, width)
    self:super()

    self.text = text
    self.position = vec2(x, y)
    self.textAlign = textAlign
    self.width = width
    self.font = game.resourceManager:getResource(fontName)
end

function textElement:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(game.manager.currentPalette.uiColour)
    
    love.graphics.printf(self.text, self.position.x, self.position.y, self.width, self.textAlign)

    love.graphics.setColor(1, 1, 1, 1)
end

return textElement