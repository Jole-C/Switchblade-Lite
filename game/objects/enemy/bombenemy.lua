--[[local enemy = require "game.objects.enemy.enemy"

local bombEnemy = class{
    __includes = enemy,

    health = 1,

    cleanup = function(self)
        enemy.cleanup(self)
        
        local world = game.gameStateMachine:current_state().world
        if world and world:hasItem(self.collider) then
            game.gameStateMachine:current_state().world:remove(self.collider)
        end
    end
}
]]