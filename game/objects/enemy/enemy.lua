local gameobject = require "game.objects.gameobject"

local enemy = class{
    __includes = gameobject,

    name = "enemy base",
    health = 0,

    onHit = function(self, damage)

    end
}

return enemy