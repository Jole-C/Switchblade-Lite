local bossState = require "src.objects.enemy.boss.bossstate"
local phase3UnshieldedMovement = class({name = "Boss 1 Phase 3 Unshield Movement", extends = bossState})

function phase3UnshieldedMovement:enter(bossInstance)
    self.maxAttackCooldown = 5
    self.attackCooldown = self.maxAttackCooldown
end

function phase3UnshieldedMovement:update(dt, bossInstance)
    local playerPosition = game.playerManager.playerPosition
    bossInstance.angle = (playerPosition - bossInstance.position):angle()

    bossInstance.position.x = bossInstance.position.x + math.cos(bossInstance.angle) * (10 * dt)
    bossInstance.position.y = bossInstance.position.y + math.sin(bossInstance.angle) * (10 * dt)

    self.attackCooldown = self.attackCooldown - (1 * dt)

    if self.attackCooldown <= 0 then
        self.attackCooldown = self.maxAttackCooldown
        bossInstance:switchAttack(bossInstance.states.phase1.unshielded.attacks)
    end

    if bossInstance.phaseHealth <= 0 then
        bossInstance:destroy()
    end
end

return phase3UnshieldedMovement