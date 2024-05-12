local menu = require "game.menu.menu"

local gameOverState = gamestate.new()

function gameOverState:init()
    self.renderToForeground = true
    self.name = "gameover"
end

function gameOverState:enter()
    self.menu = menu(
        {
            {
                name = "restart",
                position = vector.new(10, 10),
                execute = function()
                    gamestate.switch(gameLevel)
                end
            },
            {
                name = "quit",
                position = vector.new(10, 20),
                execute = function()
                    gamestate.switch(menuState)
                end
            },
        }
    )

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