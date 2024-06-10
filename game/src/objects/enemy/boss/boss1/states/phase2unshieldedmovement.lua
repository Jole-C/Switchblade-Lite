local bossState = require "src.objects.enemy.boss.bossstate"
local phase2UnshieldedMovement = class({name = "Boss 1 Phase 2 Unshield Movement", extends = bossState})

function phase2UnshieldedMovement:enter(bossInstance)
    self.maxAttackCooldown = 5
    self.attackCooldown = self.maxAttackCooldown
    
    bossInstance:setMandibleOpenAmount(0)

    bossInstance:setFearLevel(2)
end

function phase2UnshieldedMovement:update(dt, bossInstance)
    bossInstance:moveRandomly(dt)
    
    self.attackCooldown = self.attackCooldown - (1 * dt)

    if self.attackCooldown <= 0 then
        self.attackCooldown = self.maxAttackCooldown
        bossInstance:switchAttack(bossInstance.states.phase2.unshielded.attacks)
    end

    if bossInstance.phaseHealth <= 0 then
        bossInstance:switchState(bossInstance.states.phase3.shielded.intro)
    end
end

return phase2UnshieldedMovement