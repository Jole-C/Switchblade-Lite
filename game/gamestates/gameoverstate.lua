local gamestate = require "game.gamestates.gamestate"
local gameoverMenu = require "game.menu.gameover.gameovermenu"

local gameOverState = class({name = "Gameover State", extends = gamestate})

function gameOverState:enter()
    game.camera:setWorld(0, 0, screenWidth, screenHeight)
    game.camera:setPosition(screenWidth/2, screenHeight/2)
    game.interfaceRenderer:clearElements()

    self.objects = {}
    
    local menu = gameoverMenu()
    self:addObject(menu)
end

function gameOverState:exit()
    for i = 1, #self.objects do
        local object = self.objects[i]

        if object.markedForDelete == false then
            object:destroy()
        end
    end
    
    self.objects = {}

    game.interfaceRenderer:clearElements()
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