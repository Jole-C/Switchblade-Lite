local gameobject = require "game.objects.gameobject"
local collider = require "game.collision.collider"

local wall = class{
    __includes = gameobject,

    name = "wall",
    dimensions,
    collider,
    
    init = function(self, x, y, w, h)
        gameobject.init(self, x, y)

        self.dimensions = vector.new(w, h)
        self.collider = collider(colliderDefinitions.wall, self)
        gamestate.current().world:add(self.collider, self.position.x, self.position.y, self.dimensions.x, self.dimensions.y)
    end,

    cleanup = function(self)
        gamestate.current().world:remove(self)
    end
}

return wall