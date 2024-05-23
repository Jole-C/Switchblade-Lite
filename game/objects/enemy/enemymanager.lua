local gameObject = require "game.objects.gameobject"
local enemyManager = class({name = "Enemy Manager", extends = gameObject})

function enemyManager:new()
    self:super(0, 0)

    self.enemies = {}
end

function enemyManager:update(dt)
    gameObject.update(self, dt)
    
    for i = 1, #self.enemies do
        local currentEnemy = self.enemies[i]

        if currentEnemy.markedForDelete == true then
            table.remove(self.enemies, i)
            return
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