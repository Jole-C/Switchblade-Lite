local bossState = require "src.objects.enemy.boss.bossstate"
local shieldOutro = class({name = "Shield Outro", extends = bossState})

function shieldOutro:enter(bossInstance)
    self.numberOfExplosions = self.parameters.numberOfExplosions or 7
    self.timeBetweenExplosions = 0
    self.maxTimeBetweenExplosions = self.parameters.timeBetweenExplosions
    self.maxExplosionDistanceOffset = self.parameters.maxExplosionDistanceOffset or 50
    self.returnState = self.parameters.returnState
end

function shieldOutro:update(dt, bossInstance)
    self.timeBetweenExplosions = self.timeBetweenExplosions - (1 * dt)

    if self.timeBetweenExplosions <= 0 then
        gameHelper:screenShake(0.2)

        self.timeBetweenExplosions = self.maxTimeBetweenExplosions

        local angle = math.rad(math.random(0, 360))
        local offset = math.random(-self.maxExplosionDistanceOffset, self.maxExplosionDistanceOffset)
        local offsetVector = vec2(math.cos(angle) * offset, math.sin(angle) * offset)

        bossInstance.position = offsetVector

        self.numberOfExplosions = self.numberOfExplosions - 1
        
        bossInstance.angle = angle

        game.particleManager:burstEffect("Explosion", 300, bossInstance.position + offsetVector / 3)

        bossInstance:playExplosionSound()
    end

    if self.numberOfExplosions <= 0 then
        bossInstance.position = vec2:zero()
        
        bossInstance:setShielded(false)
        bossInstance:switchState(self.returnState)
        gameHelper:screenShake(0.6)
    end
end

return shieldOutro