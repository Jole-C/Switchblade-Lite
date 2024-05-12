local enemy = require "game.objects.enemy.enemy"

local bombEnemy = class{
    __includes = enemy,

    health = 1,

    cleanup = function(self)
        enemy.cleanup(self)
        
        local world = gamestate.current().world
        if world and world:hasItem(self.collider) then
            gamestate.current().world:remove(self.collider)
        end
    end
}