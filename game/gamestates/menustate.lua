local mainMenu = require "game.menu.mainmenu.mainmenu"

local menuState = gamestate.new()

function menuState:init()
    self.name = "menu"
end

function menuState:enter()
    collectgarbage("collect")
    
    camera:setWorld(0, 0, screenWidth, screenHeight)
    camera:setPosition(screenWidth/2, screenHeight/2)
    interfaceRenderer:clearElements()
    self.menu = mainMenu()
end

function menuState:leave()
    self.menu:destroy()
    self.menu = nil
    interfaceRenderer:clearElements()
end

function menuState:update(dt)
    self.menu:update(dt)
end

function menuState:draw()
    self.menu:draw()
end

return menuState