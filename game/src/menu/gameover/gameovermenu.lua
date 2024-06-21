local menu = require "src.menu.menu"
local text = require "src.interface.text"
local textButton = require "src.interface.textbutton"
local gameoverMenu = class({name = "Gameover Menu", extends = menu})

function gameoverMenu:new()
    self:super()
    
    self.menus =
    {
        ["main"] = {
            displayMenuName = false,
            elements =
                {
                text(game.playerManager.deathReason, "font ui", "left", 10, 10, 1000),
    
                textButton("retry", "font ui", 10, 25, 15, 25, function(self)
                    game.gameStateMachine:set_state("gameLevelState")
                end),

                textButton("quit to menu", "font ui", 10, 40, 15, 40, function()
                    game.gameStateMachine:set_state("menuState")
                end),
            }
        }
    }

    self:switchMenu("main")
end

return gameoverMenu