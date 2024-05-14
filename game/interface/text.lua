local hudElement require "game.interface.hudelement"

local textElement = class{
    __includes = hudElement,
    text = "",
    position = 0,
    centerText = false,
    font,

    init = function(self, text, fontName, centerText, x, y)
        self.text = text
        self.position = vector.new(x, y)
        self.centerText = centerText
        self.font = resourceManager:getResource(fontName)
    end,

    draw = function(self)
        local textX = 0
        local textY = 0

        love.graphics.setFont(self.font)

        if self.centerText == true then
            textX = self.position.x + self.font:getWidth(self.text)/2
            textY = self.position.y + self.font:getWidth(self.text)/2
        else
            textX = self.position.x
            textY = self.position.y
        end

        love.graphics.print(self.text, textX, textY)
    end,
}

return textElement