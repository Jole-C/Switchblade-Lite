local bossState = require "src.objects.enemy.boss.bossstate"
local phase1UnshieldedMovement = class({name = "Boss 1 Phase 1 Unshield Movement", extends = bossState})

function phase1UnshieldedMovement:enter(bossInstance)
    self.maxAttackCooldown = 5
    self.attackCooldown = self.maxAttackCooldown
    bossInstance:setMandibleOpenAmount(0)
end

function phase1UnshieldedMovement:update(dt, bossInstance)
    bossInstance:moveRandomly(dt)
    
    self.attackCooldown = self.attackCooldown - (1 * dt)

    if self.attackCooldown <= 0 then
        self.attackCooldown = self.maxAttackCooldown
        bossInstance:switchAttack(bossInstance.states.phase1.unshielded.attacks)
    end

    if bossInstance.phaseHealth <= 0 then
        bossInstance:switchState(bossInstance.states.phase2.shielded.intro)
    end
end

return phase1UnshieldedMovement