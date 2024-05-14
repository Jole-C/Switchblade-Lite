local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"

local mainMenu = class{
    __includes = menu,

    init = function(self)
        self.elements =
        {
            textButton("start", 10, 10, 15, 10, function()
                gamestate.switch(gameLevelState)
            end),

            textButton("options", 10, 20, 15, 20, function()
            
            end),

            textButton("quit", 10, 30, 15, 30, function()
                love.event.quit()
            end),
        }

        menu.init(self)
    end,
}

return mainMenu