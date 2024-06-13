local bossState = require "src.objects.enemy.boss.bossstate"
local bossIntro = class({name = "Boss 1 Intro", extends = bossState})

function bossIntro:enter(bossInstance)
    -- Place the boss at a random point outside the arena
    local randomAngle = math.random(0, 2 * math.pi)
    bossInstance.position = vec2(math.cos(randomAngle), math.sin(randomAngle)) * 500

    -- Lerping variables
    self.lerpSpeed = 0.05
    self.lerpRadius = 5
    self.returnState = self.parameters.returnState
    self.phase = self.parameters.phase
end

function bossIntro:update(dt, bossInstance)
    bossInstance.position.x = math.lerpDT(bossInstance.position.x, 0, self.lerpSpeed, dt)
    bossInstance.position.y = math.lerpDT(bossInstance.position.y, 0, self.lerpSpeed, dt)

    if (bossInstance.position - vec2:zero()):length() < self.lerpRadius then
        bossInstance:setPhase(self.phase)
        bossInstance:setShielded(true)
        bossInstance:switchState(self.returnState)
    end
end

return bossIntro