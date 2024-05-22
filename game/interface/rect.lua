local hudElement = require "game.interface.hudelement"
local rect = class({name = "Rectangle", extends = hudElement})

function rect:new(x, y, w, h, fillType, colour)
    self:super()
    
    self.position = vector.new(x, y)
    self.dimensions = vector.new(w, h)
    self.fillType = fillType
    self.colour = colour
end

function rect:draw()
    hudElement.draw(self)
    
    love.graphics.setColor(self.colour)
    love.graphics.rectangle(self.fillType, self.position.x, self.position.y, self.dimensions.x, self.dimensions.y)
    love.graphics.setColor(1, 1, 1, 1)
end

return rect