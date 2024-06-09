local bossState = require "src.objects.enemy.boss.bossstate"
local phase2UnshieldedIntro = class({name = "Boss 1 Phase 2 Unshield Intro", extends = bossState})

function phase2UnshieldedIntro:enter(bossInstance)
    bossInstance:setShielded(false)
    bossInstance:switchState(bossInstance.states.phase2.unshielded.movement)
end

return phase2UnshieldedIntro