local menuButton = require "game.menu.menubutton"

local spriteButton = class{
    __includes = menuButton,

    spriteName = "",
    position,
    selectedPosition,
    restPosition,
    lerpSpeed = 0.2,
    sprite,

    init = function(self, spriteName, restX, restY, selectedX, selectedY, execute)
        self.position = vector.new(restX, restY)
        self.selectedPosition = vector.new(selectedX, selectedY)
        self.restPosition = vector.new(restX, restY)
        self.sprite = resourceManager:getResource(spriteName)
        self.execute = execute
    end,

    update = function(self)
        if self.isSelected then
            self.position.x = math.lerp(self.position.x, self.selectedPosition.x, self.lerpSpeed)
            self.position.y = math.lerp(self.position.y, self.selectedPosition.y, self.lerpSpeed)
        else
            self.position.x = math.lerp(self.position.x, self.restPosition.x, self.lerpSpeed)
            self.position.y = math.lerp(self.position.y, self.restPosition.y, self.lerpSpeed)
        end
    end,

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