local hudElement = require "src.interface.hudelement"
local interactableHudElement = class({name = "Interactable Hud Element", extends = hudElement})

function interactableHudElement:new()
    self:super()

    self.isSelected = false
    self.owner = {}
end

function interactableHudElement:update(dt)

    if self.isSelected then
        self.drawColour = game.manager.currentPalette.uiSelectedColour
    else
        self.drawColour = game.manager.currentPalette.uiColour
    end
    
    self:updateHudElement(dt)

    if self.isSelected == true then
        self:checkForInteractions()
    end
end

function interactableHudElement:draw()
end

function interactableHudElement:updateHudElement(dt)

end

-- Used for things like sliders with left and right game.input
function interactableHudElement:checkForInteractions()

end

function interactableHudElement:execute()

end

function interactableHudElement:onSelectionEnter(inputPressed)
end

function interactableHudElement:onSelectionExit(inputPressed)
end

function interactableHudElement:reset()

end

return interactableHudElement