local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"
local text = require "game.interface.text"
local toggleButton = require "game.interface.togglebutton"
local slider = require "game.interface.slider"

local mainMenu = class{
    __includes = menu,

    init = function(self)
        self.menus =
        {
            ["main"] = 
            {
                displayMenuName = false,
                
                elements =
                {
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
                    end)
                }
            },

            ["options"] = 
            {
                displayMenuName = false,

                elements =
                {
                    text("visual", "font main", false, 10, 10),

                    toggleButton("toggle bg.", "font main", 10, 25, 20, 25),

                    slider("bg. fading", "font main", 25, 0, 100, 10, 40),

                    slider("bg. speed", "font main", 25, 0, 100, 10, 55),

                    text("audio", "font main", false, 10, 80),

                    slider("music vol.", "font main", 25, 0, 100, 10, 95),

                    slider("sfx vol.", "font main", 25, 0, 100, 10, 110),

                    textButton("back", "font main", 10, 130, 15, 130, function(self)
                        if self.owner then
                            self.owner:switchMenu("main")
                        end
                    end),
                }
            },
        }

        self:switchMenu("main")
    end,
}

return mainMenu