local menuButton = require "game.interface.menuButton"

local toggleButton = class{
    __includes = menuButton,

    text = "",
    selectedSprite,
    unselectedSprite,
    spritePosition,
    font,
    bool = false,
    referenceToSet,

    init = function(self, text, font, restX, restY, selectedX, selectedY, defaultValue, referenceToSet)
        menuButton.init(self, restX, restY, selectedX, selectedY, execute)
        self.spritePosition = vector.new(restX + 130, restY)
        self.font = resourceManager:getResource(font)
        self.text = text
        self.selectedSprite = resourceManager:getResource("selected box")
        self.unselectedSprite = resourceManager:getResource("unselected box")
        self.bool = defaultValue == 1
        self.referenceToSet = referenceToSet
    end,

    execute = function(self)
        self.bool = not self.bool

        local table = self.referenceToSet.table
        local value = self.referenceToSet.value

        if table and value then
            table[value] = self.bool and 1 or 0
        end
    end,

    draw = function(self)
        love.graphics.setColor(self.drawColour)
        love.graphics.setFont(self.font)

        -- Draw the button text
        love.graphics.print(self.text, self.position.x, self.position.y)

        -- Set the sprite to the default
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

        love.graphics.setColor(1, 1, 1, 1)
    end
}

return toggleButton