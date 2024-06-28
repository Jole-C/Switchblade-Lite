local bossState = require "src.objects.enemy.boss.bossstate"
local laser = require "src.objects.enemy.boss.boss1.boss1laser"

local laserFire = class({name = "Laser Fire", extends = bossState})

function laserFire:enter(bossInstance)
    self.angleTurnRate = self.parameters.angleTurnRate or 0.025
    self.returnState = self.parameters.returnState
    self.laserReference = nil

    bossInstance:setMandibleOpenAmount(1)

    self.laserChargeSound = game.resourceManager:getAsset("Enemy Assets"):get("boss1"):get("sounds"):get("laserCharge"):play()
    self.laserFireSound = game.resourceManager:getAsset("Enemy Assets"):get("boss1"):get("sounds"):get("laserFire")
    gameHelper:getCurrentState().cameraManager:zoom(1.5, 0.005)
end

function laserFire:update(dt, bossInstance)
    local playerPosition = game.playerManager.playerPosition
    local angleToPlayer = (playerPosition - bossInstance.position):angle()

    bossInstance.angle = math.lerpAngle(bossInstance.angle, angleToPlayer, self.angleTurnRate, dt)

    if self.laserChargeSound:isStopped() and self.laserReference == nil then
        self.laserReference = laser(bossInstance.position.x, bossInstance.position.y, bossInstance.angle, 500, 4)
        gameHelper:addGameObject(self.laserReference)
        self.laserFireSound:play()
        gameHelper:screenShake(0.5)
        game.manager:setFreezeFrames(3)
        gameHelper:getCurrentState().cameraManager:zoom(1, 0.1)
    end

    if self.laserReference then
        self.laserReference.angle = bossInstance.angle
        
        if self.laserReference.markedForDelete then
            bossInstance:switchState(self.returnState)
            self.laserReference = nil
        end
    end
end

return laserFire