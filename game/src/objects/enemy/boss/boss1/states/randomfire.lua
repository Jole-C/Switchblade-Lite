local bossState = require "src.objects.enemy.boss.bossstate"
local charger = require "src.objects.enemy.charger"
local sticker = require "src.objects.enemy.sticker"

local randomFire = class({name = "Random Fire", extends = bossState})

function randomFire:enter(bossInstance)
    self.enemiesToFire = self.parameters.enemiesToFire or 5
    self.maxAngle = self.parameters.maxAngle or 30
    self.returnState = self.parameters.returnState

    bossInstance:setMandibleOpenAmount(1)
end

function randomFire:update(dt, bossInstance)
    bossInstance:moveRandomly(dt)
    
    for i = 1, self.enemiesToFire do
        local newEnemy = nil

        if math.random(0, 1) == 0 then
            newEnemy = charger(bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)
        else
            newEnemy = sticker(bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)
        end

        if newEnemy ~= nil then
            newEnemy.angle = bossInstance.angle + math.rad(math.random(-self.maxAngle, self.maxAngle))
            gameHelper:addGameObject(newEnemy)
        end
    end

    bossInstance:switchState(self.returnState)
end

return randomFire