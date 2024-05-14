local interactiveHudElement = require "game.interface.interactablehudelement"

local menuButton = class{
    __includes = interactiveHudElement,
    
    drawColour = {},
    selectedColour = {},
    isSelected = false,
    
    draw = function(self)

    end
}

return menuButton