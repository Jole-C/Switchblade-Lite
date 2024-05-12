local enemy = require "game.objects.enemy.enemy"

local bombEnemy = class{
    __includes = enemy,

    health = 1,

    cleanup = function(self)
        enemy.cleanup(self)
        
        if gamestate.current().world and gamestate.current().world:hasItem(self.collider) then
            gamestate.current().world:remove(self.collider)
        end
    end
}