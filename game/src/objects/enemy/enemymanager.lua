local gameObject = require "src.objects.gameobject"
local enemyManager = class({name = "Enemy Manager", extends = gameObject})

function enemyManager:new()
    self:super(0, 0)

    self.enemies = {}
end

function enemyManager:update(dt)
    gameObject.update(self, dt)
    
    for index, enemy in ipairs(self.enemies) do
        if enemy.markedForDelete == false then
            table.remove(self.enemies, index)
        end
    end
end

function enemyManager:destroyAllEnemies()
    for index, enemy in ipairs(self.enemies) do
        if enemy.markedForDelete == false then
            enemy:destroy()
        end
    end
end

function enemyManager:registerEnemy(enemy)
    table.insert(self.enemies, enemy)
end

function enemyManager:unregisterEnemy(enemy)
    for i = 1, #self.enemies do
        local currentEnemy = self.enemies[i]

        if currentEnemy == enemy then
            table.remove(self.enemies, i)
            return
        end
    end
end

return enemyManager