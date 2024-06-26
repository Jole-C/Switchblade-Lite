local gamestate = require "src.gamestates.gamestate"
local gameoverMenu = require "src.menu.gameover.gameovermenu"

local gameOverState = class({name = "Gameover State", extends = gamestate})

function gameOverState:enter()
    game.camera:reset()
    game.manager:swapPaletteGroup("main")
    self.menu = gameoverMenu()
end

function gameOverState:exit()
    self.menu:destroy()
end

function gameOverState:update(dt)
    self.menu:update(dt)
end

function gameOverState:draw()
    self.menu:draw()
end

function gameOverState:addObject(object)
    table.insert(self.objects, object)
end

function gameOverState:removeObject(index)
    table.remove(self.objects, index)
end

return gameOverState