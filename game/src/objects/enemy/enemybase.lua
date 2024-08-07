local gameObject = require "src.objects.gameobject"
local scoreObject = require "src.objects.score.scoreindicator"

local enemyBase = class({name = "Enemy Base", extends = gameObject})

function enemyBase:new(x, y)
    self:super(x, y)

    self.health = 1
    self.maxInvulnerableTime = 0.15
    self.score = scoreDefinitions.scoreSmall
    self.multiplierToApply = 1

    self.invulnerableTime = 0
    self.isInvulnerable = false
    self.enemyColour = game.manager.currentPalette.enemyColour

    self.damageSound = game.resourceManager:getAsset("Enemy Assets"):get("damageSound")
    
    local currentGamestate = gameHelper:getCurrentState()

    if currentGamestate.enemyManager then
        currentGamestate.enemyManager:registerEnemy(self)
    end
end

function enemyBase:addScore(score, overridePosition)
    local position = self.position

    if overridePosition and overridePosition.type and overridePosition:type() == "vec2" then
        position = overridePosition
    end

    gameHelper:addGameObject(scoreObject(position.x, position.y, score))
end

function enemyBase:update(dt)
    if self.isInvulnerable == true then
        self.enemyColour = {1, 1, 1, 1}
    else
        self.enemyColour = game.manager.currentPalette.enemyColour
    end
    
    self.invulnerableTime = self.invulnerableTime - 1 * dt

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
        if world and world:hasItem(collider) then
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
        if damageType == "bullet" then
            self.multiplierToApply = gameHelper:getScoreManager().scoreMultiplier
        end

        if damageType == "boost" then
            gameHelper:incrementMultiplier()
        end
        
        self:destroy()
        
        return tookDamage
    end

    if tookDamage then
        game.manager:setFreezeFrames(1)
        self:onHitParticles()
        self:setInvulnerable()
        self.damageSound:play()
    end

    return tookDamage
end

function enemyBase:onHitParticles()
    game.particleManager:burstEffect("Enemy Hit", 3, self.position)
end

function enemyBase:setInvulnerable()
    self.isInvulnerable = true
    self.invulnerableTime = self.maxInvulnerableTime
end

function enemyBase:cleanup(destroyReason)
    local currentGamestate = gameHelper:getCurrentState()
    currentGamestate.cameraManager:screenShake(0.1)

    if game.manager then
        game.manager:setFreezeFrames(2)
    end

    if destroyReason ~= "autoDestruction" then
        currentGamestate.stageDirector:registerEnemyKill()
        self:addScore(self.score)
    end

    currentGamestate.enemyManager:unregisterEnemy(self)
end

return enemyBase