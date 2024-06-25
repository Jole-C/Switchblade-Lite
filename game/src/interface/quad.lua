local hudElement = require "src.interface.hudelement"
local quadHudElement = class({name = "Quad", extends = hudElement})

function quadHudElement:new(sprite, quad, x, y, angle, scaleX, scaleY, offsetX, offsetY, centerSprite, quadWidth, quadHeight, overrideDrawColour)
    self:super()

    self.sprite = sprite
    self.quad = quad

    self.position = vec2(x, y)
    self.angle = angle
    self.scale = vec2(scaleX, scaleY)
    self.quadSize = vec2(quadWidth, quadHeight)
    self.offset = vec2(offsetX, offsetY)
    self.centerSprite = centerSprite
    self.overrideDrawColour = overrideDrawColour
end

function quadHudElement:draw()
    if not self.quad then
        return
    end

    local xOffset = self.offset.x
    local yOffset = self.offset.y

    if self.centerQuad == true then
        xOffset = self.quadSize.x/2
        yOffset = self.quadSize.y/2
    end
    
    local drawColour = game.manager.currentPalette.uiColour

    if self.overrideDrawColour then
        drawColour = self.overrideDrawColour
    end

    love.graphics.setColor(drawColour)
    love.graphics.draw(self.sprite, self.quad, self.position.x, self.position.y, self.angle, self.scale.x, self.scale.y, xOffset, yOffset)
    love.graphics.setColor(1, 1, 1, 1)
end

return quadHudElement