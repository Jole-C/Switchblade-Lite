local bossState = require "game.objects.enemy.boss.bossstate"
local phase1ShieldedMovement = class({name = "Boss 1 Phase 1 Shield Movement", extends = bossState})

-- This state does nothing other than animate the boss, when the shield health is depleted, it switches to the unshielded state
function phase1ShieldedMovement:enter(bossInstance)
end

function phase1ShieldedMovement:update(dt, bossInstance)

    if #bossInstance.orbs <= 0 then
        bossInstance:switchState(bossInstance.states.phase1.unshielded.intro)
    end
end

return phase1ShieldedMovement