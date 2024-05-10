local enemy = require "game.objects.enemy.bombenemy"

local chargerEnemy = class{
    __includes = enemy,

    health = 1,
    speed = 3,

    

    init = function(self, x, y)
        enemy.init(self, x, y)


    end
}