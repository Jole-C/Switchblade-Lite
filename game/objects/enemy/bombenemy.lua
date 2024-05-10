local enemy = require "game.objects.enemy.enemy"

local bombEnemy = class{
    __includes = enemy,

    health = 1
}