local menuButton = require "src.interface.menubutton"
local spriteButton = class({name = "Sprite Button", extends = menuButton})

function spriteButton:new(sprite, restX, restY, selectedX, selectedY, execute, centerSprite)
    self:super(restX, restY, selectedX, selectedY, execute)
    self.sprite = sprite
    self.centerSprite = centerSprite or false
end

function spriteButton:draw()
    if not self.sprite then
        return
    end

    local xOffset, yOffset = 0, 0

    if self.centerSprite then
        xOffset, yOffset = self.sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2
    end
    
    love.graphics.setColor(self.drawColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, 1, 1, xOffset, yOffset)

    love.graphics.setColor(1, 1, 1, 1)
end

return spriteButton