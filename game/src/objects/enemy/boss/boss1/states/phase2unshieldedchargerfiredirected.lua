local bossState = require "src.objects.enemy.boss.bossstate"
local charger = require "src.objects.enemy.arena1.charger"

local phase1UnshieldedChargerfire = class({name = "Boss 1 Phase 1 Unshield Charger Fire Directed", extends = bossState})

function phase1UnshieldedChargerfire:enter(bossInstance)
    self.bulletsToFire = 10
    self.maxFireCooldown = 0.5
    self.fireCooldown = self.maxFireCooldown
    
    bossInstance:setMandibleOpenAmount(1)
end

function phase1UnshieldedChargerfire:update(dt, bossInstance)
    bossInstance:moveRandomly(dt)
    
    self.fireCooldown = self.fireCooldown - (1 * dt)

    if self.fireCooldown <= 0 then
        self.fireCooldown = self.maxFireCooldown

        local newEnemy = charger(bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)
        newEnemy.angle = bossInstance.angle
        gameHelper:addGameObject(newEnemy)

        self.bulletsToFire = self.bulletsToFire - 1
    end

    if self.bulletsToFire <= 0 then
        bossInstance:switchState(bossInstance.states.phase2.unshielded.movement)
    end
end

return phase1UnshieldedChargerfire