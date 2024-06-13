local bossState = require "src.objects.enemy.boss.bossstate"
local laser = require "src.objects.enemy.boss.boss1.boss1laser"

local laserFire = class({name = "Laser Fire", extends = bossState})

function laserFire:enter(bossInstance)
    self.angleTurnRate = self.parameters.angleTurnRate or 0.025
    self.laserWindupTime = self.parameters.laserWindupTime or 3
    self.returnState = self.parameters.returnState
    self.laserReference = nil

    bossInstance:setMandibleOpenAmount(1)
end

function laserFire:update(dt, bossInstance)
    local playerPosition = game.playerManager.playerPosition
    local angleToPlayer = (playerPosition - bossInstance.position):angle()

    bossInstance.angle = math.lerpAngle(bossInstance.angle, angleToPlayer, self.angleTurnRate, dt)

    self.laserWindupTime = self.laserWindupTime - (1 * dt)
    if self.laserWindupTime <= 0 and self.laserReference == nil then
        self.laserReference = laser(bossInstance.position.x, bossInstance.position.y, bossInstance.angle, 500, 3)
        gameHelper:addGameObject(self.laserReference)
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