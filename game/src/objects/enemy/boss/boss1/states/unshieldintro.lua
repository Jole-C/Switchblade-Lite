local bossState = require "src.objects.enemy.boss.bossstate"
local unshieldIntro = class({name = "Unshield Intro", extends = bossState})

function unshieldIntro:enter(bossInstance)
    bossInstance:switchState(self.parameters.returnState)
end

return unshieldIntro