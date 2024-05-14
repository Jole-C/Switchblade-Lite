local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"

local gameoverMenu = class{
    __includes = menu,

    init = function(self)
        self.menus =
        {
            ["main"] = {
                textButton("retry", "font main", 10, 10, 15, 10, function(self)
                    gamestate.switch(gameLevelState)
                end),

                textButton("quit to menu", "font main", 10, 30, 15, 30, function()
                    gamestate.switch(menuState)
                end),
            }
        }

        self:switchMenu("main")
    end,
}

return gameoverMenu