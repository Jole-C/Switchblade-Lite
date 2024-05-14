local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"

local gameoverMenu = class{
    __includes = menu,

    init = function(self)
        self.menus =
        {
            ["main"] =
            {
                textButton("restart", 10, 10, 15, 10, function()
                    gamestate.switch(gameLevelState)
                end),

                textButton("quit", 10, 30, 15, 30, function()
                    gamestate.switch(menuState)
                end),
            }
        }

        self:getMenuSubElements("main")
        menu.init(self)
    end,
}

return gameoverMenu