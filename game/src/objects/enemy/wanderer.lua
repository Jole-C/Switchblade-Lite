local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local tail = require "src.objects.enemy.enemytail"
local eye = require "src.objects.enemy.enemyeye"
local wanderer = class({name = "Wanderer Enemy", extends = enemy})

function wanderer:new(x, y)
    self:super(x, y, "wanderer sprite")

    -- Parameters of the enemy
    self.secondsBetweenAngleChange = 1
    self.randomChangeOffset = 0.5
    self.speed = 16
    self.health = 1
    self.maxAngleOffset = 30
    self.maxDistanceFromPlayer = 50
    self.chanceToAngleToPlayer = 50

    -- Variables
    self.targetAngle = math.random(0, 2 * math.pi)
    self.angleChangeCooldown = self.secondsBetweenAngleChange
    self.eyeOffset = vec2(0, 0)
    self.angle = 0
    self.targetPlayer = false

    -- Components
    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:getWorld():add(self.collider, self.position.x, self.position.y, 12, 12)

    self.tail = tail("wanderer tail sprite", x, y, 15, 1)
    self.eye = eye(x, y, 2, 2)

    if math.random(0, 100) > self.chanceToAngleToPlayer then
        self.speed = 30
        self.targetPlayer = true
    end
end

function wanderer:update(dt)
    enemy.update(self, dt)
    
    -- Move the enemy and lerp its angle to the target angle
    self.angle = math.lerpAngle(self.angle, self.targetAngle, 0.01, dt)

    local movementDirection = vec2(math.cos(self.angle), math.sin(self.angle))

    -- Clamp the enemy's position to the world border
    if gameHelper:getCurrentState().arena then
        self.position = gameHelper:getCurrentState().arena:getClampedPosition(self.position + movementDirection * self.speed * dt)
    end

    -- Randomise the enemy's angle
    self.angleChangeCooldown = self.angleChangeCooldown - 1 * dt

    if self.angleChangeCooldown <= 0 then
        if self.targetPlayer == true then
            local playerPosition = game.playerManager.playerPosition
            local angle = math.random(0, 2 * math.pi)
            local targetPosition = vec2(math.cos(angle), math.sin(angle)) * math.random(-self.maxDistanceFromPlayer, self.maxDistanceFromPlayer)
    
            targetPosition = playerPosition + targetPosition
            self.targetAngle = (playerPosition - self.position):angle() + math.rad(math.random(-self.maxAngleOffset, self.maxAngleOffset))
        else
            self.targetAngle = math.random(0, 2 * math.pi)
        end

        self.angleChangeCooldown = self.secondsBetweenAngleChange
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
        self.eye.eyeBasePosition.x = self.position.x
        self.eye.eyeBasePosition.y = self.position.y
        self.eye:update()
    end

    -- Handle collisions
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end

    self:checkColliders(self.collider)
end

function wanderer:draw()
    if not self.sprite or not self.tail then
        return
    end
    
    -- Draw the eye
    if self.eye then
        self.eye:draw()
    end

    love.graphics.setColor(self.enemyColour)

    -- Draw the sprite
    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle - self.tail.tailAngleWave/4, 1, 1, xOffset, yOffset)

    -- Draw the tail
    if self.tail then
        self.tail:draw()
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function wanderer:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return wanderer