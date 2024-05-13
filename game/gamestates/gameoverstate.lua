local gameoverMenu = require "game.menu.gameover.gameovermenu"

local gameOverState = gamestate.new()

function gameOverState:init()
    self.name = "menu"
    self.objects = {}
end

function gameOverState:enter()
    interfaceRenderer:clearElements()

    local menu = gameoverMenu()
    self:addObject(menu)
end

function gameOverState:leave()
    self.objects = {}
    interfaceRenderer:clearElements()
end

function gameOverState:update()
    for index,object in ipairs(self.objects) do
        if object.markedForDelete == true then
            self:removeObject(index)
        else
            object:update(dt)
        end
    end
end

function gameOverState:draw()
end

function gameOverState:addObject(object)
    table.insert(self.objects, object)
end

function gameOverState:removeObject(index)
    table.remove(self.objects, index)
end

return gameOverState