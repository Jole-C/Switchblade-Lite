local interactiveHudElement = require "game.interface.interactablehudelement"
local slider = class({name = "Menu Slider", extends = interactiveHudElement})

function slider:new(text, font, value, minValue, maxValue, x, y, referenceToSet)
    self:super()
    
    self.position = vec2(x, y)
    self.value = value
    self.minValue = minValue
    self.maxValue = maxValue
    self.text = text
    self.font = game.resourceManager:getResource(font)
    self.lineLength = 75
    self.referenceToSet = referenceToSet
end

function slider:checkForInteractions()
    self.value = math.clamp(self.value, self.minValue, self.maxValue)

    if game.input:down("menuLeft") and self.value > self.minValue then
        self.value = self.value - 1
    end

    if game.input:down("menuRight") and self.value < self.maxValue then
        self.value = self.value + 1
    end

    local table = self.referenceToSet.table
    local value = self.referenceToSet.value

    if table and value then
        table[value] = self.value
    end
end

function slider:draw()
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

return slider