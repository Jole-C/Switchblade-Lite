local gameObject = "game.objects.gameobject"

local enemyManager = class{
    __includes = gameObject,

    enemies = {},

    init = function(self)

    end,

    update = function(self)
        for i = 1, #self.enemies do
            local currentEnemy = self.enemies[i]

            if currentEnemy.markedForDelete == true then
                table.remove(self.enemies, i)
                return
            end
        end
    end,

    registerEnemy = function(self, enemy)
        table.insert(self.enemies, enemy)
    end,

    unregisterEnemy = function(self, enemy)
        for i = 1, #self.enemies do
            local currentEnemy = self.enemies[i]

            if currentEnemy == enemy then
                table.remove(self.enemies, i)
                return
            end
        end
    end,

    cleanup = function(self)
        self.enemies = {}
    end
}

return enemyManager