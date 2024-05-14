local interactiveHudElement = require "game.interface.interactablehudelement"

local menuButton = class{
    __includes = interactiveHudElement,
    
    drawColour = {},
    selectedColour = {},
    isSelected = false,
    position,
    selectedPosition,
    restPosition,

    init = function(self, text, restX, restY, selectedX, selectedY, execute)
        self.position = vector.new(restX, restY)
        self.selectedPosition = vector.new(selectedX, selectedY)
        self.restPosition = vector.new(restX, restY)
        self.text = text
        self.execute = execute
    end,

    updateHudElement = function(self)
        if self.isSelected then
            self.position.x = math.lerp(self.position.x, self.selectedPosition.x, self.lerpSpeed)
            self.position.y = math.lerp(self.position.y, self.selectedPosition.y, self.lerpSpeed)
        else
            self.position.x = math.lerp(self.position.x, self.restPosition.x, self.lerpSpeed)
            self.position.y = math.lerp(self.position.y, self.restPosition.y, self.lerpSpeed)
        end
    end,

    reset = function(self)
        self.position.x = self.restPosition.x
        self.position.y = self.restPosition.y
    end
}

return menuButton