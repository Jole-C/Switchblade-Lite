local menu = require "src.menu.menu"
local text = require "src.interface.text"
local rect = require "src.interface.rect"
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
                rect(0, 0, 480, 270, "fill", {0, 0, 0, 1}),

                text(game.playerManager.deathReason, "fontUI", "left", 10, 10, 1000),
    
                textButton("retry", "fontUI", 10, 25, 15, 25, function(self)
                    game.transitionManager:doTransition("gameLevelState")
                end),

                textButton("quit to menu", "fontUI", 10, 40, 15, 40, function()
                    game.transitionManager:doTransition("menuState")
                end),
            }
        }
    }

    self:switchMenu("main")
end

return gameoverMenu