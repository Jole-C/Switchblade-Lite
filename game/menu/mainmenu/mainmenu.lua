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

                textButton("options", 10, 20, 15, 20, function(self)
                    if self.owner then
                        self.owner:switchMenu("options")
                    end
                end),

                textButton("quit", 10, 30, 15, 30, function()
                    love.event.quit()
                end),
            },

            ["options"] = {
                text("visual", 10, 10, false, "font main"),

                text("audio", 10, 20, false, "font main"),

                text("controls", 10, 30, false, "font main"),

                textButton("back", 10, 40, 15, 40, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                    end
                end),
            },
        }

        self:switchMenu("main")
    end,
}

return mainMenu