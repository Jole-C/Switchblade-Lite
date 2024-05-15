local gameobject = require "game.objects.gameobject"
local collider = require "game.collision.collider"

local wall = class{
    __includes = gameobject,

    name = "wall",
    dimensions,
    collider,
    normal,
    
    init = function(self, x, y, w, h, normal)
        gameobject.init(self, x, y)

        self.dimensions = vector.new(w, h)
        self.collider = collider(colliderDefinitions.wall, self)
        self.normal = normal
        gamestate.current().world:add(self.collider, self.position.x, self.position.y, self.dimensions.x, self.dimensions.y)
    end,

    cleanup = function(self)
        local world = gamestate.current().world
        if world and world:hasItem(self.collider) then
            world:remove(self.collider)
        end
    end
}

return wall