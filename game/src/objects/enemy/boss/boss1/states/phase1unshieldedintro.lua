local bossState = require "src.objects.enemy.boss.bossstate"
local phase1UnshieldedIntro = class({name = "Boss 1 Phase 1 Unshield Intro", extends = bossState})

function phase1UnshieldedIntro:enter(bossInstance)
    bossInstance:setShielded(false)
    bossInstance:switchState(bossInstance.states.phase1.unshielded.movement)
end

return phase1UnshieldedIntro