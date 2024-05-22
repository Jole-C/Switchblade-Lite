local interactiveHudElement = require "game.interface.interactablehudelement"
local menuButton = class({name = "Menu Button", extends = interactiveHudElement})

function menuButton:new(restX, restY, selectedX, selectedY, execute)
    self:super()
    
    self.position = vector.new(restX, restY)
    self.selectedPosition = vector.new(selectedX, selectedY)
    self.restPosition = vector.new(restX, restY)
    self.execute = execute
    self.lerpSpeed = 0.2
end

function menuButton:updateHudElement()
    if self.isSelected then
        self.position.x = math.lerp(self.position.x, self.selectedPosition.x, self.lerpSpeed)
        self.position.y = math.lerp(self.position.y, self.selectedPosition.y, self.lerpSpeed)
    else
        self.position.x = math.lerp(self.position.x, self.restPosition.x, self.lerpSpeed)
        self.position.y = math.lerp(self.position.y, self.restPosition.y, self.lerpSpeed)
    end
end

function menuButton:reset()
    self.position.x = self.restPosition.x
    self.position.y = self.restPosition.y
end

return menuButton