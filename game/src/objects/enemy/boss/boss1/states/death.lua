local bossState = require "src.objects.enemy.boss.bossstate"
local shieldOutro = class({name = "Shield Outro", extends = bossState})

function shieldOutro:enter(bossInstance)
    self.numberOfExplosions = 25
    self.timeBetweenExplosions = 0
    self.maxTimeBetweenExplosions = 0.3
    self.maxExplosionDistanceOffset = 50
    self.numberOfBursts = 5
    self.explosionRadius = 300
    self.startingPosition = bossInstance.position
    gameHelper:getCurrentState().stageDirector:setTimerPaused(true)
    game.playerManager:setMultiplierPaused(true)
    game.musicManager:getTrack("bossMusic"):stop()
    bossInstance.deathSound:play()
end

function shieldOutro:update(dt, bossInstance)
    self.timeBetweenExplosions = self.timeBetweenExplosions - (1 * dt)

    if self.timeBetweenExplosions <= 0 then
        gameHelper:screenShake(0.2)

        self.timeBetweenExplosions = self.maxTimeBetweenExplosions
        self.maxTimeBetweenExplosions = self.maxTimeBetweenExplosions - 0.1
        self.maxTimeBetweenExplosions = math.clamp(self.maxTimeBetweenExplosions, 0.1, 1)

        local angle = math.rad(math.random(0, 360))
        local offset = math.random(-self.maxExplosionDistanceOffset, self.maxExplosionDistanceOffset)
        local offsetVector = vec2(math.cos(angle), math.sin(angle))

        bossInstance.position = self.startingPosition + offsetVector * offset

        self.numberOfExplosions = self.numberOfExplosions - 1
        
        bossInstance.angle = angle

        for i = 1, self.numberOfBursts do
            game.particleManager:burstEffect("Explosion", 50, self.startingPosition + offsetVector * math.random(-self.explosionRadius, self.explosionRadius))
        end

        game.particleManager:burstEffect("Explosion", 100, bossInstance.position)

        bossInstance:playExplosionSound()
    end

    if self.numberOfExplosions <= 0 then
        bossInstance:destroy()
        game.particleManager:burstEffect("Explosion", 1000, bossInstance.position)
    end

    if game.playerManager.playerReference then
        game.playerManager.playerReference:setInvulnerable()
    end
end

return shieldOutro