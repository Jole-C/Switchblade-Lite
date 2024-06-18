local gameObject = require "src.objects.gameobject"
local enemyBase = class({name = "Enemy Base", extends = gameObject})

function enemyBase:new(x, y)
    self:super(x, y)

    self.health = 1
    self.maxInvulnerableTime = 0.15

    self.invulnerableTime = 0
    self.isInvulnerable = false
    self.enemyColour = game.manager.currentPalette.enemyColour
    
    local currentGamestate = gameHelper:getCurrentState()

    if currentGamestate.enemyManager then
        currentGamestate.enemyManager:registerEnemy(self)
    end
end

function enemyBase:update(dt)
    if self.isInvulnerable == true then
        self.enemyColour = {1, 1, 1, 1}
    else
        self.enemyColour = game.manager.currentPalette.enemyColour
    end
    
    if self.invulnerableTime <= 0 then
        self.isInvulnerable = false
    end
end

function enemyBase:checkColliders(colliders)
    local world = gameHelper:getWorld()
    local colliderTable = colliders

    if colliders == nil then
        return
    end

    if colliderTable.type and colliderTable:type() == "Collider" then
        colliderTable = {colliders}
    end

    for _, collider in pairs(colliderTable) do
        if world:hasItem(collider) then
            local colliderPositionX, colliderPositionY = world:getRect(collider)
            local x, y, cols, len = world:check(collider, colliderPositionX, colliderPositionY)
    
            for i = 1, len do
                local collidedObject = cols[i].other.owner
                local colliderDefinition = cols[i].other.colliderDefinition
    
                if not collidedObject or not colliderDefinition then
                    goto continue
                end
    
                local returnEarly = self:handleCollision(collider, collidedObject, colliderDefinition)
    
                if returnEarly then
                    return
                end
    
                ::continue::
            end
        end
    end
end

function enemyBase:handleCollision(collider, collidedObject, colliderDefinition)
    if colliderDefinition == colliderDefinitions.player then
        if collidedObject.onHit then
            collidedObject:onHit(1)
        end
    end

    return false
end

function enemyBase:handleDamage(damageType, amount)
    if damageType == "bullet" or damageType == "boost" or damageType == "contact" then
        self.health = self.health - amount
        return true
    end

    return false
end

function enemyBase:onHit(damageType, amount)
    if self.isInvulnerable == true then
        return
    end

    local tookDamage = self:handleDamage(damageType, amount)

    if self.health <= 0 then
        self:destroy()
    end

    self:setInvulnerable()

    if game.manager then
        game.manager:setFreezeFrames(1)
    end

    return tookDamage
end

function enemyBase:setInvulnerable()
    self.isInvulnerable = true
    self.invulnerableTime = self.maxInvulnerableTime
end

function enemyBase:cleanup()
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

return enemyBase