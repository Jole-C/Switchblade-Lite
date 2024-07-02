local bossAttack = require "src.objects.enemy.boss.bossattack"
local laser = require "src.objects.enemy.boss.boss1.boss1laser"

local laserFire = class({name = "Laser Fire", extends = bossAttack})

function laserFire:new(parameters)
    self:super(parameters)
    
    self.angleTurnRate = self.parameters.angleTurnRate or 0.025
    self.returnState = self.parameters.returnState
    self.laserReference = nil
    self.drawAbove = true

    self.laserFireSound = game.resourceManager:getAsset("Enemy Assets"):get("boss1"):get("sounds"):get("laserFire")
    self.laserChargeEffect = game.particleManager:getEffect("Boss Intro Burst")
end

function laserFire:enter(bossInstance)
    bossAttack.enter(self, bossInstance)

    self.laserChargeSound = game.resourceManager:getAsset("Enemy Assets"):get("boss1"):get("sounds"):get("laserCharge"):play()
    bossInstance:setMandibleOpenAmount(1)
    gameHelper:getCurrentState().cameraManager:zoom(1.5, 0.005)
end

function laserFire:update(dt, bossInstance)
    local playerPosition = game.playerManager.playerPosition
    local angleToPlayer = (playerPosition - bossInstance.position):angle()

    bossInstance.angle = math.lerpAngle(bossInstance.angle, angleToPlayer, self.angleTurnRate, dt)

    if self.laserChargeSound:isStopped() and self.laserReference == nil then
        self.laserReference = laser(bossInstance.position.x, bossInstance.position.y, bossInstance.angle, 1000, 4)
        gameHelper:addGameObject(self.laserReference)
        
        self.laserFireSound:play()
        gameHelper:screenShake(0.5)
        game.manager:setFreezeFrames(3)
        gameHelper:getCurrentState().cameraManager:zoom(1, 0.1)
    else
        local effectPosition = vec2(0, 0)
        effectPosition.x = bossInstance.position.x + math.cos(bossInstance.angle) * 40
        effectPosition.y = bossInstance.position.y + math.sin(bossInstance.angle) * 40

        game.particleManager:burstEffect("Boss Intro Burst", 1, effectPosition)
        self.laserChargeEffect.systems[1]:setColors(game.manager.currentPalette.enemyColour)
    end

    if self.laserReference then
        self.laserReference.angle = bossInstance.angle
        
        if self.laserReference.markedForDelete then
            bossInstance:switchState(self.returnState)
            self.laserReference = nil
        end
    end
end

function laserFire:draw()
    if self.laserChargeSound:isStopped() == false then
        self.laserChargeEffect:draw()
    end
end

return laserFire