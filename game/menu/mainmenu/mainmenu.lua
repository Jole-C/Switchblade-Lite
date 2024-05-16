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
                    textButton("start", "font ui", 10, 10, 15, 10, function(self)
                        self.owner:switchMenu("gamemodeselect")
                    end),
    
                    textButton("options", "font ui", 10, 25, 15, 25, function(self)
                        if self.owner then
                            self.owner:switchMenu("options")
                        end
                    end),
    
                    textButton("quit", "font ui", 10, 50, 15, 50, function()
                        love.event.quit()
                    end)
                }
            },

            ["options"] = 
            {
                displayMenuName = false,

                elements =
                {
                    text("visual", "font ui", false, 10, 10),

                    toggleButton("toggle bg.", "font ui", 10, 25, 20, 25),

                    slider("bg. fading", "font ui", 25, 0, 100, 10, 40),

                    slider("bg. speed", "font ui", 25, 0, 100, 10, 55),

                    text("audio", "font ui", false, 10, 80),

                    slider("music vol.", "font ui", 25, 0, 100, 10, 95),

                    slider("sfx vol.", "font ui", 25, 0, 100, 10, 110),

                    textButton("back", "font ui", 10, 135, 15, 135, function(self)
                        if self.owner then
                            self.owner:switchMenu("main")
                        end
                    end),
                }
            },

            ["gamemodeselect"] =
            {
                displayMenuName = false,
                
                elements =
                {
                    textButton("level select", "font ui", 10, 10, 15, 10, function(self)
                        self.owner:switchMenu("levelselect")
                    end),
    
                    textButton("endless", "font ui", 10, 25, 15, 25, function()
                    end),
    
                    textButton("back", "font ui", 10, 50, 15, 50, function(self)
                        self.owner:switchMenu("main")
                    end)
                }
            },

            ["levelselect"] =
            {
                displayMenuName = false,
                
                elements =
                {
                    textButton("level 1", "font ui", 10, 10, 15, 10, function()
                        gameManager:changePlayerDefinition("default definition")
                        gamestate.switch(gameLevelState)
                    end),
    
                    textButton("level 2", "font ui", 10, 25, 15, 25, function()
                        gameManager:changePlayerDefinition("light definition")
                        gamestate.switch(gameLevelState)
                    end),
    
                    textButton("level 3", "font ui", 10, 40, 15, 40, function()
                        gameManager:changePlayerDefinition("heavy definition")
                        gamestate.switch(gameLevelState)
                    end),
    
                    textButton("back", "font ui", 10, 65, 15, 65, function(self)
                        self.owner:switchMenu("gamemodeselect")
                    end)
                }
            },
        }

        self:switchMenu("main")
    end,
}

return mainMenu