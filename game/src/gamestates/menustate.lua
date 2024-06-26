local gamestate = require "src.gamestates.gamestate"
local mainMenu = require "src.menu.mainmenu.mainmenu"

local menuState = class({name = "Menu State", extends = gamestate})

function menuState:enter()
    collectgarbage("collect")
    
    game.camera:setWorld(0, 0, game.arenaValues.screenWidth, game.arenaValues.screenHeight)
    game.camera:setPosition(game.arenaValues.screenWidth/2, game.arenaValues.screenHeight/2)
    
    self.menu = mainMenu()
end

function menuState:exit()
    self.menu:destroy()
    self.menu = nil
end

function menuState:update(dt)
    self.menu:update(dt)
end

function menuState:draw()
    self.menu:draw()
end

return menuState