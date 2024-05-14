local interactiveHudElement = require "game.render.interactablehudelement"

local menuButton = class{
    __includes = interactiveHudElement,
    
    drawColour = {},
    selectedColour = {},
    isSelected = false,
    
    draw = function(self)

    end
}

return menuButton