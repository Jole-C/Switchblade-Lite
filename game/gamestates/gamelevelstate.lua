local player = require "game.objects.player.player"

local gamelevelstate = gamestate.new()
gamelevelstate.objects = {}
gamelevelstate.world = {}

function gamelevelstate:enter()
    self.world = bump.newWorld()
    
    local newPlayer = player(0, 0)
    table.insert(self.objects, newPlayer)
end

function gamelevelstate:update(dt)
    for index,object in ipairs(self.objects) do
        object:update(dt)
    end
end

function gamelevelstate:draw()
end

return gamelevelstate