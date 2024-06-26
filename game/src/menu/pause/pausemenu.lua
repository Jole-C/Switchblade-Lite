local menu = require "src.menu.menu"
local textButton = require "src.interface.textbutton"
local text = require "src.interface.text"
local pauseMenu = class({name = "Pause Menu", extends = menu})

function pauseMenu:new()
    self:super()
    
    self.menus =
    {
        ["main"] =
        {
            displayMenuName = false,
            elements =
                {
                text("pause", "fontUI", "left", 10, 10, 1000),

                textButton("resume", "fontUI", 10, 25, 15, 25, function()
                    game.manager:togglePausing()
                end),

                textButton("restart", "fontUI", 10, 40, 15, 40, function(self)
                    if self.owner then
                        self.owner:switchMenu("restart")
                    end
                end),

                textButton("quit", "fontUI", 10, 65, 15, 65, function()
                    game.transitionManager:doTransition("menuState")
                    game.manager:togglePausing()
                end),
            }
        },
        ["restart"] =
        {
            displayMenuName = false,
            elements =
                {
                text("are you sure?", "fontUI", "left", 10, 10, 1000),

                textButton("yes!", "fontUI", 10, 25, 15, 25, function()
                    game.transitionManager:doTransition("gameLevelState", function() 
                        gameHelper:getCurrentState():exit()
                        gameHelper:getCurrentState():enter()
                    end)

                    game.manager:togglePausing()
                end),

                textButton("no!", "fontUI", 10, 40, 15, 40, function(self)
                    if self.owner then
                        self.owner:switchMenu("main")
                    end
                end)
            }
        }
    }

    self:switchMenu("main")
end

return pauseMenu