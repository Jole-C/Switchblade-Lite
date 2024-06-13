local bossState = require "src.objects.enemy.boss.bossstate"
local shieldIntro = class({name = "Shield Intro", extends = bossState})

function shieldIntro:enter(bossInstance)
    bossInstance:setShielded(true)
    bossInstance:summonOrbs(self.parameters.orbsToSummon)
    bossInstance:switchState(self.parameters.returnState) 
end
return shieldIntro