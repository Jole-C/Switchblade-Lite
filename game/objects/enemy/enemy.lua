local gameobject = require "game.objects.gameobject"

local enemy = class{
    __includes = gameobject,

    name = "enemy base",
    health = 0,
    invulnerableTime = 0.5,
    isInvulnerable = false,
    invulnerableTimer,
    contactDamage = 1,

    init = function(self, x, y)
        gameobject.init(self, x, y)
    end,

    update = function(self, dt)
        if self.invulnerableTimer then
            self.invulnerableTimer:update()
        end
    end,

    onHit = function(self, damage)
        if self.isInvulnerable == true then
            return
        end

        self.health = self.health - damage

        if self.health <= 0 then
            self:destroy()
        end

        self.isInvulnerable = true
        self.invulnerableTimer = timer.after(self.invulnerableTime, function() self:setVulnerable() end)
    end,

    setVulnerable = function(self)
        self.isInvulnerable = false
    end
}

return enemy