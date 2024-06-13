local bossState = require "src.objects.enemy.boss.bossstate"
local charger = require "src.objects.enemy.charger"
local sticker = require "src.objects.enemy.sticker"

local rotationFire = class({name = "Rotation Fire", extends = bossState})

function rotationFire:enter(bossInstance)
    self.angleTurnSpeed = self.parameters.angleTurnSpeed or 3
    self.maxFireCooldown = self.parameters.maxFireCooldown or 0.1
    self.returnState = self.parameters.returnState

    self.targetAngle = bossInstance.angle + 2 * math.pi
    self.fireCooldown = self.maxFireCooldown
    
    bossInstance:setMandibleOpenAmount(1)
end

function rotationFire:update(dt, bossInstance)
    self.fireCooldown = self.fireCooldown - (1 * dt)

    if self.fireCooldown <= 0 then
        self.fireCooldown = self.maxFireCooldown
        
        local newEnemy = nil

        if math.random(0, 1) == 0 then
            newEnemy = charger(bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)
        else
            newEnemy = sticker(bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)
        end

        if newEnemy ~= nil then
            newEnemy.angle = bossInstance.angle
            gameHelper:addGameObject(newEnemy)
        end
    end

    bossInstance.angle = bossInstance.angle + (self.angleTurnSpeed * dt)

    if bossInstance.angle > self.targetAngle then
        bossInstance:switchState(self.returnState)
    end
end

return rotationFire