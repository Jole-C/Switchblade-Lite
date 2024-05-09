local gameobject = require "game.objects.gameobject"

local bullet = class{
    __includes = gameobject,

    name = "base bullet",
    speed = 0,
    angle = 0,
    damage = 0,
    lifetime = 2,
    lifeTimer,

    init = function(self, x, y, speed, angle, damage)
        gameobject.init(self, x, y)

        self.speed = speed
        self.angle = angle
        self.damage = damage

        --self.lifeTimer = timer.after(self.lifetime, self.destroy)
    end,

    update = function(self, dt)
        self.position.x = self.position.x + math.cos(self.angle) * self.speed
        self.position.y = self.position.y + math.sin(self.angle) * self.speed
    end,

    draw = function(self)
        love.graphics.circle("fill", self.position.x, self.position.y, 5)
    end,
}

return bullet