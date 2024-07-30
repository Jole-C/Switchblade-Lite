local bossState = require "src.objects.enemy.boss.bossstate"
local bossIntro = class({name = "Boss 1 Intro", extends = bossState})
local cameraTarget = require "src.objects.camera.cameratarget"

function bossIntro:enter(bossInstance)
    self.returnState = self.parameters.returnState
    self.phase = self.parameters.phase
    
    self.ballsToAdd = 3
    self.ballAdditionTime = 0.025

    self.ballsAdded = 0
    self.ballAdditionCooldown = 0

    gameHelper:screenShake(0.6)
    bossInstance.introCard:setInIntro()

    gameHelper:setMultiplierPaused(true)
    gameHelper:getCurrentState().cameraManager:setOverrideTarget(cameraTarget(bossInstance.position, 1))
    gameHelper:getCurrentState().cameraManager:zoom(3, 0.001)
end

function bossIntro:update(dt, bossInstance)
    gameHelper:getCurrentState().stageDirector:setTimerPaused(true)

    self.ballAdditionCooldown = self.ballAdditionCooldown - (1 * dt)

    if self.ballAdditionCooldown <= 0 then
        bossInstance:addMetaballs(self.ballsToAdd)
        gameHelper:screenShake(0.1)
        
        self.ballsAdded = self.ballsAdded + self.ballsToAdd
        self.ballAdditionCooldown = self.ballAdditionTime
    end

    if self.ballsAdded >= bossInstance.numberOfMetaballs then
        bossInstance:setPhaseTime()
        bossInstance:setPhase(self.phase)
        bossInstance:setShielded(true)
        bossInstance:switchState(self.returnState)
        bossInstance.introCard:setInOutro()
        bossInstance.healthElement:doIntro()
        bossInstance.position = vec2:zero()
        gameHelper:getCurrentState().cameraManager:removeOverrideTarget()
        gameHelper:getCurrentState().cameraManager:zoom(1, 0.1)
        gameHelper:getCurrentState().stageDirector:setTimerPaused(false)
        gameHelper:screenShake(0.6)
    end

    local player = game.playerManager.playerReference

    if player then
        player:setInvulnerable()
    end
end

function bossIntro:draw()
    self.introEffect:draw()
end

return bossIntro