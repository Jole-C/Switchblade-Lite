local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"

local shrinker = class({name = "Shrinker", extends = enemy})

function shrinker:new(x, y)
    self:super(x, y)

    self.timeUntilShrink = 3
    self.shrinkLerpSpeed = 0.01
    self.movementSpeed = 60

    self.changeAdded = false
    self.lastSegment = nil
    self.currentSegment = nil

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:addCollider(self.collider, self.position.x, self.position.y, 12, 12)
end

function shrinker:update(dt)
    enemy.update(self, dt)

    local playerPosition = game.playerManager.playerPosition
    local angle = (playerPosition - self.position):angle()

    self.position.x = self.position.x + math.cos(angle) * (self.movementSpeed * dt)
    self.position.y = self.position.y + math.sin(angle) * (self.movementSpeed * dt)
    
    self.position = gameHelper:getArena():getClampedPosition(self.position)
    
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end

    self:checkColliders(self.collider)

    local arena = gameHelper:getArena()

    if not arena then
        return
    end

    self.timeUntilShrink = self.timeUntilShrink - (1 * dt)

    if self.timeUntilShrink <= 0 then
        local segment = arena:getSegmentPointIsWithin(self.position)

        if segment ~= self.lastSegment then
            
            if self.lastSegment then
                self.lastSegment:addChange({
                    changeType = "reset",
                    lerpSpeed = self.shrinkLerpSpeed
                })
            end

            segment:addChange({
                changeType = "shrink",
                lerpSpeed = self.shrinkLerpSpeed
            })

            self.lastSegment = nil
            self.currentSegment = segment
        end

        self.lastSegment = segment
    end
end

function shrinker:draw()
    love.graphics.setColor(self.enemyColour)
    love.graphics.circle("fill", self.position.x, self.position.y, 15)
    love.graphics.setColor(1, 1, 1, 1)
end

function shrinker:handleDamage(damageType, amount)
    if damageType == "boost" or damageType == "contact" then
        self.health = self.health - amount
        return true
    elseif damageType == "bullet" then
        self.health = self.health - 3
    end

    return false
end

function shrinker:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end

    if self.currentSegment then
        self.currentSegment:addChange({
            changeType = "reset",
            lerpSpeed = self.shrinkLerpSpeed
        })
    end
end

return shrinker