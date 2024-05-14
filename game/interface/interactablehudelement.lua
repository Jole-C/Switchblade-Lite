local hudElement = require "game.interface.hudelement"

local interactableHudElement = class{
    __includes = hudElement,
    
    isSelected = false,
    owner = {},

    update = function(self)
        if self.isSelected then
            self.drawColour = gameManager.currentPalette.uiSelectedColour
        else
            self.drawColour = gameManager.currentPalette.uiColour
        end
        
        self:updateHudElement()

        if self.isSelected == true then
            self:checkForInteractions()
        end
    end,

    updateHudElement = function(self)

    end,

    -- Used for things like sliders with left and right input
    checkForInteractions = function(self)

    end,

    -- Used when enter is pressed on the button
    execute = function(self)

    end,

    reset = function(self)
        
    end
}

return interactableHudElement