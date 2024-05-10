local gameobject = require "game.objects.gameobject"

local enemy = class{
    __includes = gameobject,

    name = "enemy base",
    health = 0,

    init = function(self, x, y)
        gameobject.init(self, x, y)
        
        self.colliderdefinition = colliderdefinitions.enemy
    end,

    onHit = function(self, damage)

    end
}

return enemy