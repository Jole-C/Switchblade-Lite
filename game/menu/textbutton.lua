local menuButton = require "game.menu.menubutton"

local textButton = class{
    __includes = menuButton,

    text = "",
    position,
    selectedPosition,
    restPosition,
    lerpSpeed = 0.2,

    init = function(self, text, restX, restY, selectedX, selectedY, execute)
        self.position = vector.new(restX, restY)
        self.selectedPosition = vector.new(selectedX, selectedY)
        self.restPosition = vector.new(restX, restY)
        self.text = text
        self.execute = execute
    end,

    updateHudElement = function(self)
        if self.isSelected then
            self.position.x = math.lerp(self.position.x, self.selectedPosition.x, self.lerpSpeed)
            self.position.y = math.lerp(self.position.y, self.selectedPosition.y, self.lerpSpeed)
        else
            self.position.x = math.lerp(self.position.x, self.restPosition.x, self.lerpSpeed)
            self.position.y = math.lerp(self.position.y, self.restPosition.y, self.lerpSpeed)
        end
    end,

    draw = function(self)
        love.graphics.setColor(gameManager.currentPalette.uiColour)
        love.graphics.print(self.text, self.position.x, self.position.y)
    end
}

return textButton