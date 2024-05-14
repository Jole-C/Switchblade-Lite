local interactiveHudElement = require "game.interface.interactablehudelement"

local menuButton = class{
    __includes = interactiveHudElement,
    
    drawColour = {},
    selectedColour = {},
    isSelected = false,
    position,
    selectedPosition,
    restPosition,
    
    draw = function(self)

    end,

    reset = function(self)
        self.position = self.restPosition
    end
}

return menuButton