local bossState = require "src.objects.enemy.boss.bossstate"
local unshieldMovement = class({name = "Unshield Movement", extends = bossState})

function unshieldMovement:enter(bossInstance)
    self.maxAttackCooldown = self.parameters.attackCooldown or 5
    self.attackCooldown = self.maxAttackCooldown
    self.attacks = self.parameters.attacks
    self.returnState = nil

    if self.parameters.returnState ~= nil then
        self.phase = self.parameters.returnState.phase
        self.returnState = self.parameters.returnState.state
    end

    self.returnLerpSpeed = 0.05
    self.returnlerpRadius = 5

    bossInstance:setMandibleOpenAmount(0)
end

function unshieldMovement:update(dt, bossInstance)
    if bossInstance.phaseHealth > 0 then
        bossInstance:moveRandomly(dt)
        self.attackCooldown = self.attackCooldown - (1 * dt)

        if self.attackCooldown <= 0 then
            self.attackCooldown = self.maxAttackCooldown
            bossInstance:switchAttack(self.attacks)
        end
    else
        if self.returnState == nil then
            bossInstance:switchState("death")
            return
        end

        bossInstance.position.x = math.lerpDT(bossInstance.position.x, 0, self.returnLerpSpeed, dt)
        bossInstance.position.y = math.lerpDT(bossInstance.position.y, 0, self.returnLerpSpeed, dt)
    
        bossInstance:updateColliderPosition("mainCollider", bossInstance.position.x, bossInstance.position.y)
        
        if (bossInstance.position - vec2:zero()):length() < 5 then
            bossInstance:setPhase(self.phase)
            bossInstance:setShielded(true)
            bossInstance:switchState(self.returnState)
        end
    end
end

return unshieldMovement