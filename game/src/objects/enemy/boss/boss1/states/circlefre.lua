local bossAttack = require "src.objects.enemy.boss.bossattack"
local circleFire = class({name = "Circle Fire", extends = bossAttack})

function circleFire:enter(bossInstance)
    bossAttack.enter(self, bossInstance)
    
    self.timesToRepeat = self.parameters.timesToRepeat or 5
    self.numberOfEnemies = self.parameters.numberOfEnemiesInCircle or 3
    self.maxFireCooldown = 0.5
    self.fireCooldown = self.maxFireCooldown
    self.baseAngleIncrement = 2
    self.returnState = self.parameters.returnState
    
    bossInstance:setMandibleOpenAmount(1)
end

function circleFire:update(dt, bossInstance)
    self.fireCooldown = self.fireCooldown - (1 * dt)

    if self.fireCooldown <= 0 then
        local angleIncrement = 2 * math.pi / self.numberOfEnemies

        for i = 1, self.numberOfEnemies do
            local angle = self.baseAngleIncrement + angleIncrement * i
            local spawnFunction = self:chooseEnemy(self.enemyFunctions)

            local newEnemy = spawnFunction(angle, bossInstance.enemySpawnPosition.x, bossInstance.enemySpawnPosition.y)

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

return circleFire