local hudElement = require "game.interface.hudelement"
local spriteHudElement = class({name = "Sprite", extends = hudElement})

function spriteHudElement:new(sprite, x, y, angle, scaleX, scaleY, offsetX, offsetY, centerSprite, overrideDrawColour)
    self:super()
    
    self.sprite = resourceManager:getResource(sprite)
    self.position = vector.new(x, y)
    self.angle = angle
    self.scale = vector.new(scaleX, scaleY)
    self.offset = vector.new(offsetX, offsetY)
    self.centerSprite = centerSprite
    self.overrideDrawColour = overrideDrawColour
end

function spriteHudElement:draw()
    hudElement.draw(self)
    
    if not self.sprite then
        return
    end

    local xOffset = self.offset.x
    local yOffset = self.offset.y

    if self.centerSprite == true then
        xOffset, yOffset = self.sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2
    end
    
    local drawColour = gameManager.currentPalette.uiColour

    if self.overrideDrawColour then
        drawColour = self.overrideDrawColour
    end

    love.graphics.setColor(drawColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, self.scale.x, self.scale.y, xOffset, yOffset)
    love.graphics.setColor(1, 1, 1, 1)
end

return spriteHudElement