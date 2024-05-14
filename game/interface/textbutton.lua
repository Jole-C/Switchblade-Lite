local menuButton = require "game.interface.menubutton"

local textButton = class{
    __includes = menuButton,

    text = "",
    lerpSpeed = 0.2,

    draw = function(self)
        love.graphics.setColor(gameManager.currentPalette.uiColour)
        love.graphics.print(self.text, self.position.x, self.position.y)
    end
}

return textButton