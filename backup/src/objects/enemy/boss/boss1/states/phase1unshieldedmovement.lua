local bossState = require "src.objects.enemy.boss.bossstate"
local phase1UnshieldedMovement = class({name = "Boss 1 Phase 1 Unshield Movement", extends = bossState})

function phase1UnshieldedMovement:enter(bossInstance)
    self.maxAttackCooldown = 5
    self.attackCooldown = self.maxAttackCooldown
end

function phase1UnshieldedMovement:update(dt, bossInstance)
    local playerPosition = game.playerManager.playerPosition
    local angleToPlayer = (playerPosition - bossInstance.position):angle()

    bossInstance.position.x = bossInstance.position.x + math.cos(angleToPlayer) * (10 * dt)
    bossInstance.position.y = bossInstance.position.y + math.sin(angleToPlayer) * (10 * dt)

    self.attackCooldown = self.attackCooldown - (1 * dt)

    if self.attackCooldown <= 0 then
        self.attackCooldown = self.maxAttackCooldown
        bossInstance:switchAttack(bossInstance.states.phase1.unshielded.attacks)
    end
end

return phase1UnshieldedMovement