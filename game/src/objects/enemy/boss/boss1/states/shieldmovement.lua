local bossState = require "src.objects.enemy.boss.bossstate"
local shieldMovement = class({name = "Shield Movement", extends = bossState})

-- This state does nothing other than animate the boss, when the shield health is depleted, it switches to the unshielded state
function shieldMovement:enter(bossInstance)
    self.maxAttackCooldown = self.parameters.attackCooldown or 5
    self.attackCooldown = self.maxAttackCooldown
    self.attacks = self.parameters.attacks
    self.returnState = self.parameters.returnState
    gameHelper:getCurrentState().stageDirector:setTimerPaused(false)
end

function shieldMovement:update(dt, bossInstance)
    self.attackCooldown = self.attackCooldown - (1 * dt)

    if self.attackCooldown <= 0 then
        self.attackCooldown = self.maxAttackCooldown
        bossInstance:switchAttack(self.attacks)
    end

    if #bossInstance.orbs <= 0 then
        bossInstance:switchState(self.returnState)
    end
end

return shieldMovement