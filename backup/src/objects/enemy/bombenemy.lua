--[[local enemy = require "src.objects.enemy.enemy"

local bombEnemy = class{
    __includes = enemy,

    health = 1,

    cleanup = function(self)
        enemy.cleanup(self)
        
        local world = gameHelper:getWorld()
        if world and world:hasItem(self.collider) then
            gameHelper:getWorld():remove(self.collider)
        end
    end
}
]]