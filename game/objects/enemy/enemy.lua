local gameobject = require "game.objects.gameobject"

local enemy = class{
    __includes = gameobject,

    contactDamage = 1,
    spriteName = "",
    
    health = 0,
    invulnerableTimer,
    invulnerableTime = 0.5,
    isInvulnerable = false,

    sprite,

    init = function(self, x, y, spriteName)
        gameobject.init(self, x, y)
        self.sprite = resourceManager:getResource(spriteName)

        local currentGamestate = gamestate.current()
        
        if currentGamestate.enemyManager then
            currentGamestate.enemyManager:registerEnemy(self)
        end
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

        if gameManager then
            gameManager:setFreezeFrames(3)
        end
    end,

    setVulnerable = function(self)
        self.isInvulnerable = false
    end,

    cleanup = function(self)
        if self.invulnerableTimer then
            timer.clear(self.invulnerableTimer)
        end

        local currentGamestate = gamestate.current()

        if currentGamestate.enemyManager then
            currentGamestate.enemyManager:unregisterEnemy(self)
        end
    end
}

return enemy