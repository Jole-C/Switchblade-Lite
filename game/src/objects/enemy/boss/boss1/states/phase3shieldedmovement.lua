local bossState = require "src.objects.enemy.boss.bossstate"
local phase3ShieldedMovement = class({name = "Boss 1 Phase 3 Shield Movement", extends = bossState})

-- This state does nothing other than animate the boss, when the shield health is depleted, it switches to the unshielded state
function phase3ShieldedMovement:enter(bossInstance)
end

function phase3ShieldedMovement:update(dt, bossInstance)

    if #bossInstance.orbs <= 0 then
        bossInstance:switchState(bossInstance.states.phase3.unshielded.intro)
    end
end

return phase3ShieldedMovement