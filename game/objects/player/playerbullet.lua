local bullet = require "game.objects.bullet.bullet"

local playerBullet = class{
    __includes = bullet,

    name = "player bullet"
}

return playerBullet