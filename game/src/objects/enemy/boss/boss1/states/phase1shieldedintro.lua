local bossState = require "src.objects.enemy.boss.bossstate"
local phase1ShieldedIntro = class({name = "Boss 1 Phase 1 Shield Intro", extends = bossState})

function phase1ShieldedIntro:enter(bossInstance)
    self.lerpSpeed = 0.05
    self.lerpRadius = 5
end

function phase1ShieldedIntro:update(dt, bossInstance)
    bossInstance.position.x = math.lerpDT(bossInstance.position.x, 0, self.lerpSpeed, dt)
    bossInstance.position.y = math.lerpDT(bossInstance.position.y, 0, self.lerpSpeed, dt)

    if (bossInstance.position - vec2:zero()):length() < self.lerpRadius then
        bossInstance:setShielded(true)
        bossInstance:summonOrbs(3)
        bossInstance:switchState(bossInstance.states.phase1.shielded.movement) 
    end
end

return phase1ShieldedIntro