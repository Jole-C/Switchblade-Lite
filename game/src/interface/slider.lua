local interactiveHudElement = require "src.interface.interactablehudelement"
local slider = class({name = "Menu Slider", extends = interactiveHudElement})

function slider:new(text, font, minValue, maxValue, x, y, option)
    self:super()
    
    self.position = vec2(x, y)
    self.option = option
    self.value = game.manager:getOption(option)
    self.minValue = minValue
    self.maxValue = maxValue
    self.text = text
    self.font = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get(font)
    self.lineLength = 75
end

function slider:checkForInteractions()
    self.value = math.clamp(self.value, self.minValue, self.maxValue)

    if game.input:down("menuLeft") and self.value > self.minValue then
        self.value = self.value - 1
    end

    if game.input:down("menuRight") and self.value < self.maxValue then
        self.value = self.value + 1
    end

    game.manager:setOption(self.option, self.value)
end

function slider:draw()
    love.graphics.setColor(self.drawColour)
    love.graphics.setFont(self.font)

    -- Print the text for the slider
    love.graphics.print(self.text, self.position.x, self.position.y)

    -- Print the text for the slider's percentage
    love.graphics.print(tostring(self.value).."%", self.position.x + 200, self.position.y)
    
    -- Print the slider
    local textHeight = self.font:getHeight(self.text)
    local lineX = self.position.x + 270
    local lineY = self.position.y + textHeight/2 + 1
    local circleX = math.lerp(lineX, lineX + self.lineLength, mathx.inverse_lerp(self.value, self.minValue, self.maxValue))

    love.graphics.setLineWidth(2)
    love.graphics.line(lineX, lineY, lineX + self.lineLength, lineY)
    love.graphics.circle("fill", circleX, lineY, 6)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(1, 1, 1, 1)
end

return slider