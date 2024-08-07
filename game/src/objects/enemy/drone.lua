local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local tail = require "src.objects.enemy.enemytail"
local eye = require "src.objects.enemy.enemyeye"
local drone = class({name = "Drone Enemy", extends = enemy}) 

function drone:new(x, y)
    self:super(x, y, "drone sprite")

    -- Parameters of the enemy
    self.maxSpeed = 160
    self.turningRate = 0.2
    self.health = 5
    self.maxChargeCooldown = 3
    self.maxChargeSpeed = 500
    self.chargeDuration = 2
    self.friction = 1
    self.bounceDampening = 0.75
    self.score = scoreDefinitions.scoreMedium

    -- Variables
    self.angle = math.random(0, 2 * math.pi)
    self.velocity = vec2(math.cos(self.angle), math.sin(self.angle))
    self.chargeCooldown = self.maxChargeCooldown
    self.chargeDurationCooldown = self.chargeDuration
    self.isCharging = false
    self.movementDirection = vec2(math.cos(self.angle), math.sin(self.angle))

    self.velocity = self.velocity * self.maxSpeed

    -- Components
    self.sprite = game.resourceManager:getAsset("Enemy Assets"):get("drone"):get("bodySprite")
    self.tailSprite = game.resourceManager:getAsset("Enemy Assets"):get("drone"):get("tailSprite")

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:addCollider(self.collider, self.position.x, self.position.y, 12, 12)

    self.tail = tail(self.tailSprite, x, y, 15, 1)
    self.eye = eye(x, y, 2, 2)
end

function drone:update(dt)
    enemy.update(self, dt)
    
    -- Switch the enemy between charging and non charging state on a loop
    self.chargeCooldown = self.chargeCooldown - 1 * dt

    if self.chargeCooldown <= 0 then
        self.isCharging = true

        self.chargeDurationCooldown = self.chargeDurationCooldown - 1 * dt

        if self.chargeDurationCooldown <= 0 then
            self.chargeDurationCooldown = self.chargeDuration
            self.chargeCooldown = self.maxChargeCooldown
            self.isCharging = false
        end
    end

    if self.isCharging == false then
        local playerPosition = game.playerManager.playerPosition

        self.movementDirection:lerp_direction_inplace((playerPosition - self.position), self.turningRate):normalise_inplace()

        -- Rotate and push the enemy towards the player
        self.velocity = self.velocity + (self.movementDirection * self.maxSpeed) * dt

        -- Update the angle of the enemy
        self.angle = self.velocity:angle()
    else
        -- Charge the enemy forwards
        self.velocity = self.velocity + (self.movementDirection * self.maxChargeSpeed) * dt
    end
 
    -- Apply friction
    self:applyFriction(dt)

    local arena = gameHelper:getCurrentState().arena

    if arena then
        -- Bounce off the wall
        if arena:isPositionWithinArena(self.position + self.velocity * dt) == false then
            self.velocity = self.velocity - (self.velocity * 2)

            if self.isCharging == true then
                self.chargeDurationCooldown = self.chargeDuration
                self.chargeCooldown = self.maxChargeCooldown
                self.isCharging = false
            end
        end

        -- Clamp the enemy's position
        self.position = self.position + self.velocity * dt
        self.position = gameHelper:getCurrentState().arena:getClampedPosition(self.position)
    end

    -- Update the tail
    if self.tail then
        self.tail.tailSpritePosition.x = self.position.x + math.cos(self.angle + math.pi) * 2
        self.tail.tailSpritePosition.y = self.position.y + math.sin(self.angle + math.pi) * 2
        self.tail.baseTailAngle = self.angle

        self.tail:update(dt)
    end

    -- Update the eye
    if self.eye then
        self.eye.eyeBasePosition.x = self.position.x + math.cos(self.angle - self.tail.tailAngleWave/8) * 5
        self.eye.eyeBasePosition.y = self.position.y + math.sin(self.angle - self.tail.tailAngleWave/8) * 5

        self.eye:update()
    end

    -- Update the collider
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end

    self:checkColliders(self.collider)
end

function drone:handleDamage(damageType, amount)
    if damageType == "boost" or damageType == "contact" then
        self.health = self.health - amount
        return true
    elseif damageType == "bullet" then
        self.health = self.health - 3
    end

    return false
end

function drone:draw()
    if not self.sprite then
        return
    end

    -- Draw the eye
    if self.eye then
        self.eye:draw()
    end

    love.graphics.setColor(self.enemyColour)

    -- Draw the sprite
    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = 5
    yOffset = yOffset/2

    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle - self.tail.tailAngleWave/8, 1, 1, xOffset, yOffset)

    -- Draw the tail
    if self.tail then
        self.tail:draw()
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function drone:applyFriction(dt)
    local frictionRatio = 1 / (1 + (dt * self.friction))
    self.velocity = self.velocity * frictionRatio
end

function drone:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return drone