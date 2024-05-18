local menuButton = require "game.interface.menubutton"

local textButton = class{
    __includes = menuButton,

    text = "",
    centerText,

    init = function(self, text, font, restX, restY, selectedX, selectedY, execute, centerText)
        centerText = centerText or false

        menuButton.init(self, restX, restY, selectedX, selectedY, execute)
        self.font = resourceManager:getResource(font)
        self.text = text
        self.centerText = centerText
    end,

    draw = function(self)
        love.graphics.setColor(self.drawColour)
        love.graphics.setFont(self.font)

        if self.centerText then
            love.graphics.printf(self.text, self.position.x, self.position.y, gameWidth, "center")
        else
            love.graphics.print(self.text, self.position.x, self.position.y)
        end

        love.graphics.setColor(1, 1, 1, 1)
    end
}

return textButton