local menu = require "game.menu.menu"

local menuState = gamestate.new()

function menuState:init()
    self.renderToForeground = false
    self.name = "menu"
end

function menuState:enter()
    self.menu = menu(
        {
            {
                name = "start",
                position = vector.new(10, 10),
                execute = function()
                    gamestate.switch(gameLevel)
                end
            },
            {
                name = "options",
                position = vector.new(10, 20),
                execute = function()
                    gamestate.switch(menuState)
                end
            },
            {
                name = "quit",
                position = vector.new(10, 30),
                execute = function()
                    love.event.quit()
                end
            },
        }
    )

    interfaceCanvas.enabled = true
end

function menuState:leave()
    interfaceCanvas.enabled = false
    self.menu = {}
end

function menuState:update()
    self.menu:update()
end

function menuState:draw()
    love.graphics.setCanvas(interfaceCanvas.canvas)
    love.graphics.clear()
    self.menu:draw()
    love.graphics.setCanvas()
end

return menuState