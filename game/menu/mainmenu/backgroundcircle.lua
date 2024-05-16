local gameobject = require "game.objects.gameobject"

local circle = class{
    __includes = gameobject,

    size = 10,
    colour = 0.1,
    maxSize = gameWidth * 1.5,

    update = function(self, dt)
        self.size = self.size + 40 * dt
        self.colour = self.colour + 0.01 * dt
        self.colour = math.clamp(self.colour, 0, 0.3)

        if self.size > self.maxSize then
            self:destroy()
        end
    end
}

return circle