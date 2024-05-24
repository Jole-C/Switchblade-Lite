local gamestate = require "game.gamestates.gamestate"
local mainMenu = require "game.menu.mainmenu.mainmenu"

local menuState = class({name = "Menu State", extends = gamestate})

function menuState:enter()
    collectgarbage("collect")
    
    game.camera:setWorld(0, 0, screenWidth, screenHeight)
    game.camera:setPosition(screenWidth/2, screenHeight/2)
    game.interfaceRenderer:clearElements()
    
    self.menu = mainMenu()
end

function menuState:exit()
    self.menu:destroy()
    self.menu = nil
    game.interfaceRenderer:clearElements()
end

function menuState:update(dt)
    self.menu:update(dt)
end

function menuState:draw()
    self.menu:draw()
end

return menuState