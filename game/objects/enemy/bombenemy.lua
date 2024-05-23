--[[local enemy = require "game.objects.enemy.enemy"

local bombEnemy = class{
    __includes = enemy,

    health = 1,

    cleanup = function(self)
        enemy.cleanup(self)
        
        local world = gameStateMachine:current_state().world
        if world and world:hasItem(self.collider) then
            gameStateMachine:current_state().world:remove(self.collider)
        end
    end
}
]]