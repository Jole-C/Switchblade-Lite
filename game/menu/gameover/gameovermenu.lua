local menu = require "game.menu.menu"
local textButton = require "game.interface.textbutton"
local gameoverMenu = class({name = "Gameover Menu", extends = menu})

function gameoverMenu:new()
    self:super()
    
    self.menus =
    {
        ["main"] = {
            displayMenuName = false,
            elements =
                {
                textButton("retry", "font ui", 10, 10, 15, 10, function(self)
                    gamestate.switch(gameLevelState)
                end),

                textButton("quit to menu", "font ui", 10, 25, 15, 25, function()
                    gamestate.switch(menuState)
                end),
            }
        }
    }

    self:switchMenu("main")
end

return gameoverMenu