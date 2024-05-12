local gameoverMenu = require "game.menu.gameover.gameovermenu"

local gameOverState = gamestate.new()

function gameOverState:init()
    self.renderToForeground = true
    self.name = "gameover"
end

function gameOverState:enter()
    self.menu = gameoverMenu()

    interfaceCanvas.enabled = true
end

function gameOverState:leave()
    interfaceCanvas.enabled = false
    self.menu = {}
end

function gameOverState:update()
    self.menu:update()
end

function gameOverState:draw()
    love.graphics.setCanvas(interfaceCanvas.canvas)
    love.graphics.clear()
    self.menu:draw()
    love.graphics.setCanvas()
end

return gameOverState