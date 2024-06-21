local bossAttack = require "src.objects.enemy.boss.bossattack"
local charger = require "src.objects.enemy.charger"
local sticker = require "src.objects.enemy.sticker"

local fireDirected = class({name = "Fire Directed", extends = bossAttack})

function fireDirected:enter(bossInstance)
    bossAttack.enter(self, bossInstance)
    
    self.enemiesToFire = self.parameters.enemiesToFire or 5
    self.maxFireCooldown = self.parameters.maxFireCooldown or 0.5
    self.fireCooldown = self.maxFireCooldown
    self.returnState = self.parameters.returnState

    self.chosenEnemyFunction = self:chooseEnemy()
    
    bossInstance:setMandibleOpenAmount(1)
end

function fireDirected:update(dt, bossInstance)
    bossInstance:moveRandomly(dt)

    self.fireCooldown = self.fireCooldown - (1 * dt)

    if self.fireCooldown <= 0 then
        self.fireCooldown = self.maxFireCooldown

        local newEnemy = self.chosenEnemyFunction(bossInstance.angle, bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)

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