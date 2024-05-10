local gameobject = require "game.objects.gameobject"

local wall = class{
    __includes = gameobject,

    name = "wall",
    dimensions,
    
    init = function(self, x, y, w, h)
        gameobject.init(self, x, y)

        self.dimensions = vector.new(w, h)
        self.colliderdefinition = colliderdefinitions.wall
        gamestate.current().world:add(self, self.position.x, self.position.y, self.dimensions.x, self.dimensions.y)
    end,

    cleanup = function(self)
        gamestate.current().world:remove(self)
    end
}

return wall