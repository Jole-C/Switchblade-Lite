local hudElement = require "game.interface.hudelement"

local interactableHudElement = class{
    __includes = hudElement,
    owner = {},

    update = function(self)
        self:updateHudElement()
        self:checkForInteractions()
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