local gameObject = require "game.objects.gameobject"
local enemy = class({name = "Enemy", extends = gameObject})

function enemy:new(x, y, spriteName)
    self:super(x, y)

    -- Parameters
    self.contactDamage = 1
    self.health = 0
    self.maxInvulnerableTime = 0.5

    -- Variables
    self.isInvulnerable = false
    self.invulnerableTime = self.maxInvulnerableTime

    -- Components
    self.sprite = game.resourceManager:getResource(spriteName)
    
    -- Register the enemy
    local currentGamestate = gameHelper:getCurrentState()
    if currentGamestate.enemyManager then
        currentGamestate.enemyManager:registerEnemy(self)
    end
end

function enemy:update(dt)
    self.invulnerableTime = self.invulnerableTime - 1 * dt

    if self.invulnerableTime <= 0 then
        self.isInvulnerable = false
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
    self.invulnerableTime = self.maxInvulnerableTime

    if game.manager then
        game.manager:setFreezeFrames(3)
    end
end

function enemy:setVulnerable()
    self.isInvulnerable = false
end

function enemy:cleanup()
    gameHelper:getCurrentState().cameraManager:screenShake(0.1)

    if game.manager then
        game.manager:setFreezeFrames(2)
    end

    local currentGamestate = gameHelper:getCurrentState()

    if currentGamestate.enemyManager then
        currentGamestate.enemyManager:unregisterEnemy(self)
    end
end

return enemy