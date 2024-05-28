local gameObject = require "game.objects.gameobject"
local enemy = class({name = "Enemy", extends = gameObject})

function enemy:new(x, y, spriteName)
    self:super(x, y)

    -- Parameters
    self.contactDamage = 1
    self.health = 0
    self.maxInvulnerableTime = 0.15
    self.enemyColour = game.manager.currentPalette.enemyColour

    -- Variables
    self.isInvulnerable = false
    self.invulnerableTime = 0

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

    if self.isInvulnerable == true then
        self.enemyColour = {1, 1, 1, 1}
    else
        self.enemyColour = game.manager.currentPalette.enemyColour
    end
end

function enemy:handleDamage(damage)
    if damage.type == "bullet" or "boost" then
        self.health = self.health - damage.amount
    end
end

function enemy:onHit(damage)
    if self.isInvulnerable == true then
        return
    end

    if type(damage) ~= "table" then
        damage = {type = "bullet", amount = 1}
    end

    self:handleDamage(damage)

    if self.health <= 0 then
        self:destroy()
    end

    self:setInvulnerable()

    if game.manager then
        game.manager:setFreezeFrames(3)
    end
end

function enemy:setInvulnerable()
    self.isInvulnerable = true
    self.invulnerableTime = self.maxInvulnerableTime
end

function enemy:cleanup()
    local currentGamestate = gameHelper:getCurrentState()
    currentGamestate.cameraManager:screenShake(0.1)

    if game.manager then
        game.manager:setFreezeFrames(2)
    end

    if currentGamestate.stageDirector then
        currentGamestate.stageDirector:registerEnemyKill()
    end

    if currentGamestate.enemyManager then
        currentGamestate.enemyManager:unregisterEnemy(self)
    end
end

return enemy