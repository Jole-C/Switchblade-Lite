local menuButton = require "src.interface.menubutton"
local spriteButton = class({name = "Sprite Button", extends = menuButton})

function spriteButton:new(spriteName, restX, restY, selectedX, selectedY, execute)
    self:super(restX, restY, selectedX, selectedY, execute)

    self.sprite = game.resourceManager:getResource(spriteName)
end

function spriteButton:draw()
    if not self.sprite then
        return
    end

    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2
    
    love.graphics.setColor(self.drawColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, 1, 1, xOffset, yOffset)

    love.graphics.setColor(1, 1, 1, 1)
end

return spriteButton