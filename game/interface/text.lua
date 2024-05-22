local hudElement require "game.interface.hudelement"
local textElement = class({name = "Text", extends = hudElement})

function textElement:new(text, fontName, centerText, x, y)
    self:super()

    self.text = text
    self.position = vector.new(x, y)
    self.centerText = centerText
    self.font = resourceManager:getResource(fontName)
end

function textElement:draw()
    local textX = 0
    local textY = 0

    love.graphics.setFont(self.font)
    love.graphics.setColor(gameManager.currentPalette.uiColour)

    if self.centerText == true then
        textX = self.position.x + self.font:getWidth(self.text)/2
        textY = self.position.y + self.font:getHeight(self.text)/2
    else
        textX = self.position.x
        textY = self.position.y
    end

    love.graphics.print(self.text, textX, textY)

    love.graphics.setColor(1, 1, 1, 1)
end

return textElement