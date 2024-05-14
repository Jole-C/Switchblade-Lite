local menuButton = require "game.interface.menubutton"

local textButton = class{
    __includes = menuButton,

    text = "",

    init = function(self, text, font, restX, restY, selectedX, selectedY, execute)
        menuButton.init(self, restX, restY, selectedX, selectedY, execute)
        self.font = resourceManager:getResource(font)
        self.text = text
    end,

    draw = function(self)
        love.graphics.setColor(gameManager.currentPalette.uiColour)
        love.graphics.setFont(self.font)
        love.graphics.print(self.text, self.position.x, self.position.y)
    end
}

return textButton