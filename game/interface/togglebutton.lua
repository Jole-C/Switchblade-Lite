local menuButton = require "game.interface.menuButton"

local toggleButton = class{
    __includes = menuButton,

    text = "",
    selectedSprite,
    unselectedSprite,
    spritePosition,
    font,
    bool = false,

    init = function(self, text, font, restX, restY, selectedX, selectedY, execute)
        menuButton.init(self, restX, restY, selectedX, selectedY, execute)
        self.spritePosition = vector.new(restX + 100, restY)
        self.font = resourceManager:getResource(font)
        self.text = text
        self.selectedSprite = resourceManager:getResource("selected box")
        self.unselectedSprite = resourceManager:getResource("unselected box")
    end,

    execute = function(self)
        self.bool = not self.bool
    end,

    draw = function(self)
        -- Draw the button text
        love.graphics.setColor(gameManager.currentPalette.uiColour)
        love.graphics.setFont(self.font)
        love.graphics.print(self.text, self.position.x, self.position.y)

        local sprite = self.unselectedSprite
        
        -- Use the selected sprite if applicable
        if self.bool then
            sprite = self.selectedSprite
        end

        local xOffset, yOffset = sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2
        local textHeight = self.font:getHeight(self.text)

        love.graphics.draw(sprite, self.spritePosition.x, self.spritePosition.y - yOffset + textHeight/2)
    end
}

return toggleButton