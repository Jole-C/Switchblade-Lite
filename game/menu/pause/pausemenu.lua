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
                    textButton("resume", "font main", 10, 10, 15, 10, function(self)
                        gameManager:togglePausing()
                    end),

                    textButton("quit", "font main", 10, 20, 15, 20, function(self)
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