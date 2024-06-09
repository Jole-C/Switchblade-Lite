local bossState = require "src.objects.enemy.boss.bossstate"
local phase3UnshieldedIntro = class({name = "Boss 1 Phase 3 Unshield Intro", extends = bossState})

function phase3UnshieldedIntro:enter(bossInstance)
    bossInstance:setShielded(false)
    bossInstance:switchState(bossInstance.states.phase3.unshielded.movement)
end

return phase3UnshieldedIntro