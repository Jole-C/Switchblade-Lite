local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"

local pauseMenu = class{
    __includes = menu,

    init = function(self)
        self.menus =
        {
            ["main"] =
            {
                displayMenuName = false,
                elements =
                    {
                    textButton("resume", "font ui", 10, 10, 15, 10, function(self)
                        gameManager:togglePausing()
                    end),

                    textButton("quit", "font ui", 10, 25, 15, 25, function(self)
                        gamestate.switch(menuState)
                        gameManager:togglePausing()
                    end),
                }
            }
        }

        self:switchMenu("main")
    end,
}

return pauseMenu