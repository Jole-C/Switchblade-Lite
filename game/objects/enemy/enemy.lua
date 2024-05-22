local gameObject = require "game.objects.gameobject"
local enemy = class({name = "Enemy", extends = gameObject})

function enemy:new(x, y, spriteName)
    self:super(x, y)

    -- Parameters
    self.contactDamage = 1
    self.health = 0
    self.invulnerableTime = 0.5

    -- Variables
    self.isInvulnerable = false

    -- Components
    self.invulnerableTimer = nil
    self.sprite = resourceManager:getResource(spriteName)
    
    -- Register the enemy
    local currentGamestate = gamestate.current()
    if currentGamestate.enemyManager then
        currentGamestate.enemyManager:registerEnemy(self)
    end
end

function enemy:update(dt)
    gameObject.update(self, dt)

    if self.invulnerableTimer then
        self.invulnerableTimer:update()
    end
end

function enemy:onHit(damage)
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
end

function enemy:setVulnerable()
    self.isInvulnerable = false
end

function enemy:cleanup()
    if self.invulnerableTimer then
        timer.clear(self.invulnerableTimer)
    end

    local currentGamestate = gamestate.current()

    if currentGamestate.enemyManager then
        currentGamestate.enemyManager:unregisterEnemy(self)
    end
end

return enemy