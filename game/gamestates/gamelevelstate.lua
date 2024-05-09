local player = require "game.objects.player.player"

local gamelevelstate = gamestate.new()
gamelevelstate.objects = {}
gamelevelstate.world = {}

function gamelevelstate:enter()
    self.world = bump.newWorld()

    local newPlayer = player(0, 0)
    self:addObject(newPlayer)
end

function gamelevelstate:update(dt)
    for index,object in ipairs(self.objects) do
        if object.markedForDelete == true then
            self:removeObject(object)
        end

        object:update(dt)
    end
end

function gamelevelstate:draw()
end

function gamelevelstate:addObject(object)
    table.insert(self.objects, object)
end

function gamelevelstate:removeObject(object)
    table.remove(self.objects, object)
end

return gamelevelstate