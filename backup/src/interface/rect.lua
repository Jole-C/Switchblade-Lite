local hudElement = require "src.interface.hudelement"
local rect = class({name = "Rectangle", extends = hudElement})

function rect:new(x, y, w, h, fillType, colour, blendMode, alphaMode)
    self:super()
    
    self.position = vec2(x, y)
    self.dimensions = vec2(w, h)
    self.fillType = fillType
    self.colour = colour
    self.blendMode = blendMode or "alpha"
    self.alphaMode = alphaMode or "alphamultiply"
end

function rect:draw()
    love.graphics.setColor(self.colour)
    love.graphics.setBlendMode(self.blendMode, self.alphaMode)
    love.graphics.rectangle(self.fillType, self.position.x, self.position.y, self.dimensions.x, self.dimensions.y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")
end

return rect