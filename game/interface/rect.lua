local hudElement = require "game.interface.hudelement"

local rect = class{
    __includes = hudElement,
    
    position = {},
    dimensions = {},
    fillType = "fill",
    colour = {},

    init = function(self, x, y, w, h, fillType, colour)
        self.position = vector.new(x, y)
        self.dimensions = vector.new(w, h)
        self.fillType = fillType
        self.colour = colour
    end,

    draw = function(self)
        love.graphics.setColor(self.colour)
        love.graphics.rectangle(self.fillType, self.position.x, self.position.y, self.dimensions.x, self.dimensions.y)
        love.graphics.setColor(1, 1, 1, 1)
    end
}

return rect