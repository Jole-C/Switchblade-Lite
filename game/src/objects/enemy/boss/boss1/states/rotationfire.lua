local bossAttack = require "src.objects.enemy.boss.bossattack"
local rotationFire = class({name = "Rotation Fire", extends = bossAttack})

function rotationFire:enter(bossInstance)
    bossAttack.enter(self, bossInstance)

    self.angleTurnSpeed = self.parameters.angleTurnSpeed or 3
    self.maxFireCooldown = self.parameters.maxFireCooldown or 0.1
    self.returnState = self.parameters.returnState

    self.targetAngle = bossInstance.angle + 2 * math.pi
    self.fireCooldown = self.maxFireCooldown
    
    self.chosenEnemyFunction = self:chooseEnemy()
    
    bossInstance:setMandibleOpenAmount(1)
end

function rotationFire:update(dt, bossInstance)
    self.fireCooldown = self.fireCooldown - (1 * dt)

    if self.fireCooldown <= 0 then
        self.fireCooldown = self.maxFireCooldown
        
        local newEnemy = self.chosenEnemyFunction(bossInstance.angle, bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)
        gameHelper:addGameObject(newEnemy)

        bossInstance.fireSound:play()
    end

    bossInstance.angle = bossInstance.angle + (self.angleTurnSpeed * dt)

    if bossInstance.angle > self.targetAngle then
        bossInstance:switchState(self.returnState)
    end
end

return rotationFire