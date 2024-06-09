local bossState = require "src.objects.enemy.boss.bossstate"
local phase2ShieldedMovement = class({name = "Boss 1 Phase 2 Shield Movement", extends = bossState})

-- This state does nothing other than animate the boss, when the shield health is depleted, it switches to the unshielded state
function phase2ShieldedMovement:enter(bossInstance)
end

function phase2ShieldedMovement:update(dt, bossInstance)

    if #bossInstance.orbs <= 0 then
        bossInstance:switchState(bossInstance.states.phase2.unshielded.intro)
    end
end

return phase2ShieldedMovement