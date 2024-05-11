local enemy = require "game.objects.enemy.enemy"

local bombEnemy = class{
    __includes = enemy,

    health = 1,

    cleanup = function(self)
        enemy.cleanup(self)
        
        if not gamestate.current().world then
            return
        end

        gamestate.current().world:remove(self.collider)
    end
}