local hudElement require "game.interface.hudelement"
local textElement = class({name = "Text", extends = hudElement})

function textElement:new(text, fontName, textAlign, x, y)
    self:super()

    self.text = text
    self.position = vec2(x, y)
    self.textAlign = textAlign
    self.font = game.resourceManager:getResource(fontName)
end

function textElement:draw()
    love.graphics.setFont(self.font)
    love.graphics.setColor(game.gameManager.currentPalette.uiColour)
    
    love.graphics.printf(self.text, self.position.x, self.position.y, 1000, self.textAlign)

    love.graphics.setColor(1, 1, 1, 1)
end

return textElement