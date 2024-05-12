local mainMenu = require "game.menu.mainmenu.mainmenu"

local menuState = gamestate.new()

function menuState:init()
    self.renderToForeground = false
    self.name = "menu"
end

function menuState:enter()
    self.menu = mainMenu()

    interfaceCanvas.enabled = true
end

function menuState:leave()
    interfaceCanvas.enabled = false
    self.menu = {}
end

function menuState:update()
    if self.menu then
        self.menu:update()
    end
end

function menuState:draw()
    love.graphics.setCanvas(interfaceCanvas.canvas)
    love.graphics.clear()

    if self.menu then
        self.menu:draw()
    end

    love.graphics.setCanvas()
end

return menuState