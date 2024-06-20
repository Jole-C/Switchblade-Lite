local bossState = require "src.objects.enemy.boss.bossstate"
local bossAttack = class({name = "Boss Attack", extends = bossState})

function bossAttack:enter(bossInstance)
    self.enemyFunctions = self.parameters.enemyFunctions
end

function bossAttack:chooseEnemy()
    local index = math.random(1, #self.enemyFunctions)
    return self.enemyFunctions[index]
end

return bossAttack