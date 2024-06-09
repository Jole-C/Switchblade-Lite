local interactiveHudElement = require "src.interface.interactablehudelement"
local menuButton = class({name = "Menu Button", extends = interactiveHudElement})

function menuButton:new(restX, restY, selectedX, selectedY, execute)
    self:super()
    
    self.position = vec2(restX, restY)
    self.selectedPosition = vec2(selectedX, selectedY)
    self.restPosition = vec2(restX, restY)
    self.execute = execute
    self.lerpSpeed = 0.2
end

function menuButton:updateHudElement(dt)
    if self.isSelected then
        self.position.x = math.lerpDT(self.position.x, self.selectedPosition.x, self.lerpSpeed, dt)
        self.position.y = math.lerpDT(self.position.y, self.selectedPosition.y, self.lerpSpeed, dt)
    else
        self.position.x = math.lerpDT(self.position.x, self.restPosition.x, self.lerpSpeed, dt)
        self.position.y = math.lerpDT(self.position.y, self.restPosition.y, self.lerpSpeed, dt)
    end
end

function menuButton:reset()
    self.position.x = self.restPosition.x
    self.position.y = self.restPosition.y
end

return menuButton