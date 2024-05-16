local mainMenu = require "game.menu.mainmenu.mainmenu"

local menuState = gamestate.new()

function menuState:init()
    self.name = "menu"
end

function menuState:enter()
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