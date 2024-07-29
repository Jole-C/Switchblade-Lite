local bossState = require "src.objects.enemy.boss.bossstate"
local shieldIntro = class({name = "Shield Intro", extends = bossState})

function shieldIntro:enter(bossInstance)
    gameHelper:screenShake(0.3)
    bossInstance:setShielded(true)
    bossInstance:switchState(self.parameters.returnState)
    bossInstance:setPhaseTime()
    gameHelper:setMultiplierPaused(true)
end

return shieldIntro