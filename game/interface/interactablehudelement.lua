local hudElement = require "game.interface.hudelement"
local interactableHudElement = class({name = "Interactable Hud Element", extends = hudElement})

function interactableHudElement:new()
    self:super()

    self.isSelected = false
    self.owner = {}
end

function interactableHudElement:update(dt)

    if self.isSelected then
        self.drawColour = game.gameManager.currentPalette.uiSelectedColour
    else
        self.drawColour = game.gameManager.currentPalette.uiColour
    end
    
    self:updateHudElement()

    if self.isSelected == true then
        self:checkForInteractions()
    end
end

function interactableHudElement:draw()
end

function interactableHudElement:updateHudElement()

end

-- Used for things like sliders with left and right game.input
function interactableHudElement:checkForInteractions()

end

-- Used when enter is pressed on the button
function interactableHudElement:execute()

end

function interactableHudElement:reset()

end

return interactableHudElement