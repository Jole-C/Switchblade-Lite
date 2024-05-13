local menu = require "game.menu.menu"
local textButton = require "game.menu.textbutton"

local pauseMenu = class{
    __includes = menu,

    init = function(self)
        self.elements =
        {
            textButton("resume", 10, 10, 15, 10, function()
                gameManager:togglePausing()
            end),

            textButton("quit", 10, 30, 15, 30, function()
                gamestate.switch(menuState)
                gameManager:togglePausing()
            end),
        }

        menu.init(self)
    end,
}

return pauseMenu