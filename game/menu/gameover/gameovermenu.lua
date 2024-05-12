local menu = require "game.menu.menu"
local textButton = require "game.menu.textbutton"

local gameoverMenu = class{
    __includes = menu,

    init = function(self)
        self.elements =
        {
            textButton("restart", 10, 10, 15, 10, function()
                gamestate.switch(gameLevelState)
            end),

            textButton("quit", 10, 30, 15, 30, function()
                gamestate.switch(menuState)
            end),
        }
    end,
}

return gameoverMenu