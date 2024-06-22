local bossAttack = require "src.objects.enemy.boss.bossattack"
local randomFire = class({name = "Random Fire", extends = bossAttack})

function randomFire:enter(bossInstance)
    bossAttack.enter(self, bossInstance)

    self.enemiesToFire = self.parameters.enemiesToFire or 5
    self.maxAngle = self.parameters.maxAngle or 30
    self.returnState = self.parameters.returnState

    self.chosenEnemyFunction = self:chooseEnemy()

    bossInstance:setMandibleOpenAmount(1)
end

function randomFire:update(dt, bossInstance)
    bossInstance:moveRandomly(dt)
    
    for i = 1, self.enemiesToFire do
        local angle = bossInstance.angle + math.rad(math.random(-self.maxAngle, self.maxAngle))
        local newEnemy = self.chosenEnemyFunction(angle, bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)
        
        gameHelper:addGameObject(newEnemy)
    end

    bossInstance.fireSound:play()

    bossInstance:switchState(self.returnState)
end

return randomFire