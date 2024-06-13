local bossState = require "src.objects.enemy.boss.bossstate"
local charger = require "src.objects.enemy.charger"
local sticker = require "src.objects.enemy.sticker"

local circularChargerFire = class({name = "Circle Fire", extends = bossState})

function circularChargerFire:enter(bossInstance)
    self.timesToRepeat = self.parameters.timesToRepeat or 5
    self.numberOfEnemies = self.parameters.numberOfEnemiesInCircle or 3
    self.maxFireCooldown = 0.5
    self.fireCooldown = self.maxFireCooldown
    self.baseAngleIncrement = 2
    self.returnState = self.parameters.returnState
    
    bossInstance:setMandibleOpenAmount(1)
end

function circularChargerFire:update(dt, bossInstance)
    self.fireCooldown = self.fireCooldown - (1 * dt)

    if self.fireCooldown <= 0 then
        local newEnemy = nil

        local angleIncrement = 2 * math.pi / self.numberOfEnemies

        for i = 1, self.numberOfEnemies do
            newEnemy = charger(bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)

            newEnemy.angle = self.baseAngleIncrement + angleIncrement * i
            gameHelper:addGameObject(newEnemy)
        end

        self.timesToRepeat = self.timesToRepeat - 1
        self.baseAngleIncrement = self.baseAngleIncrement + 2
        
        self.fireCooldown = self.maxFireCooldown
    end

    if self.timesToRepeat <= 0 then
        bossInstance:switchState(self.returnState)
    end
end

return circularChargerFire