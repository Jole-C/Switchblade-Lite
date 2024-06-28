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

    self.angle = bossInstance.angle
end

function rotationFire:update(dt, bossInstance)
    self.fireCooldown = self.fireCooldown - (1 * dt)

    if self.fireCooldown <= 0 then
        self.fireCooldown = self.maxFireCooldown
        
        local newEnemy = self.chosenEnemyFunction(self.angle, bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)
        gameHelper:addGameObject(newEnemy)

        bossInstance.fireSound:play()
    end

    self.angle = self.angle + (self.angleTurnSpeed * dt)

    if bossInstance.isShielded == false then
        bossInstance.angle = self.angle
    end

    if self.angle > self.targetAngle then
        bossInstance:switchState(self.returnState)
    end
end

return rotationFire