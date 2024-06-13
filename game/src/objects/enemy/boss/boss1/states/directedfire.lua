local bossState = require "src.objects.enemy.boss.bossstate"
local charger = require "src.objects.enemy.charger"
local sticker = require "src.objects.enemy.sticker"

local fireDirected = class({name = "Fire Directed", extends = bossState})

function fireDirected:enter(bossInstance)
    self.enemiesToFire = self.parameters.enemiesToFire or 5
    self.maxFireCooldown = self.parameters.maxFireCooldown or 0.5
    self.fireCooldown = self.maxFireCooldown
    self.returnState = self.parameters.returnState
    
    bossInstance:setMandibleOpenAmount(1)
end

function fireDirected:update(dt, bossInstance)
    bossInstance:moveRandomly(dt)

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
            newEnemy.angle = bossInstance.angle + math.rad(math.random(-5, 5))
            gameHelper:addGameObject(newEnemy)
        end

        self.enemiesToFire = self.enemiesToFire - 1
    end

    if self.enemiesToFire <= 0 then
        bossInstance:switchState(self.returnState)
    end
end

return fireDirected