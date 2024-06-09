local bossState = require "src.objects.enemy.boss.bossstate"
local phase3ShieldedIntro = class({name = "Boss 1 Phase 3 Shield Intro", extends = bossState})

function phase3ShieldedIntro:enter(bossInstance)
    self.lerpSpeed = 0.05
    self.lerpRadius = 5
end

function phase3ShieldedIntro:update(dt, bossInstance)
    bossInstance.position.x = math.lerpDT(bossInstance.position.x, 0, self.lerpSpeed, dt)
    bossInstance.position.y = math.lerpDT(bossInstance.position.y, 0, self.lerpSpeed, dt)

    if (bossInstance.position - vec2:zero()):length() < self.lerpRadius then
        bossInstance:setShielded(true)
        bossInstance:summonOrbs(7)
        bossInstance:switchState(bossInstance.states.phase3.shielded.movement) 
    end
end

return phase3ShieldedIntro