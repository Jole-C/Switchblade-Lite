local bossState = require "src.objects.enemy.boss.bossstate"
local charger = require "src.objects.enemy.arena1.charger"

local phase1UnshieldedChargerfire = class({name = "Boss 1 Phase 1 Unshield Charger Fire Random", extends = bossState})

function phase1UnshieldedChargerfire:enter(bossInstance)
    bossInstance:setMandibleOpenAmount(1)
end

function phase1UnshieldedChargerfire:update(dt, bossInstance)
    bossInstance:moveRandomly(dt)
    
    for i = 1, 5 do
        local newEnemy = charger(bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)
        newEnemy.angle = bossInstance.angle + math.rad(math.random(-30, 30))
        gameHelper:addGameObject(newEnemy)
    end

    bossInstance:switchState(bossInstance.states.phase1.unshielded.movement)
end

return phase1UnshieldedChargerfire