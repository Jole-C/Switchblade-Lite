local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"
local text = require "game.interface.text"
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
                text("pause", "font ui", false, 10, 10),

                textButton("resume", "font ui", 10, 25, 15, 25, function()
                    gameManager:togglePausing()
                end),

                textButton("restart", "font ui", 10, 40, 15, 40, function(self)
                    if self.owner then
                        self.owner:switchMenu("restart")
                    end
                end),

                textButton("quit", "font ui", 10, 65, 15, 65, function()
                    gameStateMachine:set_state("menuState")
                    gameManager:togglePausing()
                end),
            }
        },
        ["restart"] =
        {
            displayMenuName = false,
            elements =
                {
                text("are you sure?", "font ui", false, 10, 10),

                textButton("yes", "font ui", 10, 25, 15, 25, function()
                    gameStateMachine:set_state("gameLevelState")
                    gameManager:togglePausing()
                end),

                textButton("no!", "font ui", 10, 40, 15, 40, function(self)
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