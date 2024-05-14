local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"
local text = require "game.interface.text"

local mainMenu = class{
    __includes = menu,

    init = function(self)
        self.menus =
        {
            ["main"] = {
                textButton("start", 10, 10, 15, 10, function()
                    gamestate.switch(gameLevelState)
                end),

                textButton("options", 10, 20, 15, 20, function()
                
                end),

                textButton("quit", 10, 30, 15, 30, function()
                    love.event.quit()
                end),
            },

            ["options"] = {
                text("visual ---------------------", 10, 10, false),

                text("audio ---------------------", 10, 10, false),

                text("controls ---------------------", 10, 10, false),

                textButton("back", 10, 30, 15, 30, function()
                    love.event.quit()
                end),
            },
        }

        self:getMenuSubElements("main")
        menu.init(self)
    end,
}

return mainMenu