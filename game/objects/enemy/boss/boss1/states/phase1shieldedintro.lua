local bossState = require "game.objects.enemy.boss.bossstate"
local phase1ShieldedIntro = class({name = "Boss 1 Phase 1 Shield Intro", extends = bossState})

function phase1ShieldedIntro:enter(bossInstance)
    -- Summon boss orbs
    bossInstance:setShielded(true)
    bossInstance:summonOrbs(3)
    bossInstance:switchState(bossInstance.states.phase1.shielded.movement)
end

return phase1ShieldedIntro