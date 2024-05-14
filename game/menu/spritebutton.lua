local textButton = require "game.menu.textbutton"

local spriteButton = class{
    __includes = textButton,

    spriteName = "",
    sprite,

    draw = function(self)
        if not self.sprite then
            return
        end

        local xOffset, yOffset = self.sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2
        
        love.graphics.setColor(gameManager.currentPalette.uiColour)
        love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, 1, 1, xOffset, yOffset)
    end
}

return spriteButton