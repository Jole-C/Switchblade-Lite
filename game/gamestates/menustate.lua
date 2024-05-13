local mainMenu = require "game.menu.mainmenu.mainmenu"

local menuState = gamestate.new()

function menuState:init()
    self.name = "menu"
    self.objects = {}
end

function menuState:enter()
    interfaceRenderer:clearElements()

    local menu = mainMenu()
    self:addObject(menu)
end

function menuState:leave()
    self.objects = {}
    interfaceRenderer:clearElements()
end

function menuState:update()
    for index,object in ipairs(self.objects) do
        if object.markedForDelete == true then
            self:removeObject(index)
        else
            object:update(dt)
        end
    end
end

function menuState:draw()
end

function menuState:addObject(object)
    table.insert(self.objects, object)
end

function menuState:removeObject(index)
    table.remove(self.objects, index)
end

return menuState