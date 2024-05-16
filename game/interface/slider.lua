local interactiveHudElement = require "game.interface.interactablehudelement"

local slider = class{
    __includes = interactiveHudElement,

    position,
    value,
    minValue,
    maxValue,
    text = "",
    font,
    lineLength = 75,

    init = function(self, text, font, value, minValue, maxValue, x, y)
        self.position = vector.new(x, y)
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.text = text
        self.font = resourceManager:getResource(font)
    end,

    -- Used for things like sliders with left and right input
    checkForInteractions = function(self)
        self.value = math.clamp(self.value, self.minValue, self.maxValue)

        if input:down("menuLeft") and self.value > self.minValue then
            self.value = self.value - 1
        end

        if input:down("menuRight") and self.value < self.maxValue then
            self.value = self.value + 1
        end
    end,

    draw = function(self)
        love.graphics.setColor(self.drawColour)
        love.graphics.setFont(self.font)

        -- Print the text for the slider
        love.graphics.print(self.text, self.position.x, self.position.y)

        -- Print the text for the slider's percentage
        love.graphics.print(tostring(self.value/self.maxValue * 100).."%", self.position.x + 120, self.position.y)
        
        -- Print the slider
        local textHeight = self.font:getHeight(self.text)
        local lineX = self.position.x + 180
        local lineY = self.position.y + textHeight/2 + 1

        love.graphics.setLineWidth(2)
        love.graphics.line(lineX, lineY, lineX + self.lineLength, lineY)
        love.graphics.circle("fill", math.floor(lineX + (self.value/self.maxValue) * self.lineLength), lineY, 6)
        love.graphics.setLineWidth(1)

        love.graphics.setColor(1, 1, 1, 1)
    end
}

return slider