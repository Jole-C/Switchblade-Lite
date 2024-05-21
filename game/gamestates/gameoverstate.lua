local gameoverMenu = require "game.menu.gameover.gameovermenu"

local gameOverState = gamestate.new()

function gameOverState:init()
    self.name = "menu"
    self.objects = {}
end

function gameOverState:enter()
    camera:setWorld(0, 0, screenWidth, screenHeight)
    camera:setPosition(screenWidth/2, screenHeight/2)
    interfaceRenderer:clearElements()

    local menu = gameoverMenu()
    self:addObject(menu)
end

function gameOverState:leave()
    for i = 1, #self.objects do
        local object = self.objects[i]

        if object.markedForDelete == false then
            object:destroy()
        end
    end
    
    self.objects = {}

    interfaceRenderer:clearElements()
end

function gameOverState:update(dt)
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