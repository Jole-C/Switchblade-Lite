local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"
local text = require "game.interface.text"
local toggleButton = require "game.interface.togglebutton"

local mainMenu = class{
    __includes = menu,

    init = function(self)
        self.menus =
        {
            ["main"] = {
                textButton("start", "font main", 10, 10, 15, 10, function(self)
                    gamestate.switch(gameLevelState)
                end),

                textButton("options", "font main", 10, 20, 15, 20, function(self)
                    if self.owner then
                        self.owner:switchMenu("options")
                    end
                end),

                textButton("quit", "font main", 10, 30, 15, 30, function()
                    love.event.quit()
                end),
            },

            ["options"] = {
                text("visual", "font main", false, 10, 10),

                toggleButton("boop a doop", "font main", 10, 20, 15, 20),
                
                text("audio", "font main", false, 10, 30),

                toggleButton("boop a doop", "font main", 10, 40, 15, 40),

                text("controls", "font main", false, 10, 50),

                textButton("back", "font main", 10, 60, 15, 60, function(self)
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