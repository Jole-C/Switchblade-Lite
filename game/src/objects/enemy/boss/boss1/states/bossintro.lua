local bossState = require "src.objects.enemy.boss.bossstate"
local bossIntro = class({name = "Boss 1 Intro", extends = bossState})
local cameraTarget = require "src.objects.camera.cameratarget"

function bossIntro:enter(bossInstance)
    local randomAngle = math.random(0, 2 * math.pi)
    bossInstance.position = vec2(math.cos(randomAngle), math.sin(randomAngle)) * 300

    self.lerpSpeed = 0.0125
    self.lerpRadius = 5
    self.returnState = self.parameters.returnState
    self.phase = self.parameters.phase
    self.drawAbove = false

    gameHelper:screenShake(0.6)
    bossInstance:addAngleSpeed(50)
    bossInstance.introCard:setInIntro()

    self.introEffect = game.particleManager:getEffect("Boss Intro Burst")
    gameHelper:getCurrentState().cameraManager:setOverrideTarget(cameraTarget(bossInstance.position, 1))
    gameHelper:getCurrentState().cameraManager:zoom(3, 0.001)
end

function bossIntro:update(dt, bossInstance)
    bossInstance:setPhaseTime()
    
    game.particleManager:burstEffect("Boss Intro Burst", 20, bossInstance.position)

    local colour = game.manager.currentPalette.enemySpawnColour
    self.introEffect.systems[1]:setColors(colour[1], colour[2], colour[3], colour[4])

    bossInstance.position.x = math.lerpDT(bossInstance.position.x, 0, self.lerpSpeed, dt)
    bossInstance.position.y = math.lerpDT(bossInstance.position.y, 0, self.lerpSpeed, dt)

    if (bossInstance.position - vec2:zero()):length() < self.lerpRadius then
        bossInstance:setPhase(self.phase)
        bossInstance:setShielded(true)
        bossInstance:switchState(self.returnState)
        bossInstance.introCard:setInOutro()
        bossInstance.healthElement:doIntro()
        bossInstance.position = vec2:zero()
        gameHelper:getCurrentState().cameraManager:removeOverrideTarget()
        gameHelper:getCurrentState().cameraManager:zoom(1, 0.1)
    end
end

function bossIntro:draw()
    self.introEffect:draw()
end

return bossIntro