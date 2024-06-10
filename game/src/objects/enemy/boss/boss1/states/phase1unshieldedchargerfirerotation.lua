local bossState = require "src.objects.enemy.boss.bossstate"
local charger = require "src.objects.enemy.charger"

local phase1UnshieldedChargerfire = class({name = "Boss 1 Phase 1 Unshield Charger Fire Rotation", extends = bossState})

function phase1UnshieldedChargerfire:enter(bossInstance)
    self.angleTurnSpeed = 3
    self.targetAngle = bossInstance.angle + 2 * math.pi

    self.maxFireCooldown = 0.1
    self.fireCooldown = self.maxFireCooldown
    
    bossInstance:setMandibleOpenAmount(1)
end

function phase1UnshieldedChargerfire:update(dt, bossInstance)
    self.fireCooldown = self.fireCooldown - (1 * dt)

    if self.fireCooldown <= 0 then
        self.fireCooldown = self.maxFireCooldown
        
        local newEnemy = charger(bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)
        newEnemy.angle = bossInstance.angle
        gameHelper:addGameObject(newEnemy)
    end

    bossInstance.angle = bossInstance.angle + (self.angleTurnSpeed * dt)

    if bossInstance.angle > self.targetAngle then
        bossInstance:switchState(bossInstance.states.phase1.unshielded.movement)
    end
end

return phase1UnshieldedChargerfire