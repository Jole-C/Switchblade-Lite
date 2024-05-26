local enemy = require "game.objects.enemy.enemy"
local collider = require "game.collision.collider"
local tail = require "game.objects.enemy.enemytail"
local eye = require "game.objects.enemy.enemyeye"
local drone = class({name = "Drone Enemy", extends = enemy})

function drone:new(x, y)
    self:super(x, y, "drone sprite")

    -- Parameters of the enemey
    self.maxSpeed = 1.5
    self.turningRate = 0.16
    self.health = 5
    self.maxChargeCooldown = 4
    self.maxChargeSpeed = 6
    self.chargeDuration = 2
    self.friction = 1
    self.bounceDampening = 0.5

    -- Variables
    self.angle = math.random(0, 2 * math.pi)
    self.velocity = vec2(math.cos(self.angle), math.sin(self.angle))
    self.chargeCooldown = self.maxChargeCooldown
    self.chargeDurationCooldown = self.chargeDuration
    self.isCharging = false
    self.movementDirection = vec2(math.cos(self.angle), math.sin(self.angle))

    self.velocity = self.velocity * self.maxSpeed

    -- Components
    self.collider = collider(colliderDefinitions.enemy, self)
    game.gameStateMachine:current_state().world:add(self.collider, self.position.x, self.position.y, 12, 12)

    self.tail = tail("charger tail sprite", x, y, 15, 1)
    self.eye = eye(x, y, 3, 2)
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

    local arena = game.gameStateMachine:current_state().arena

    if arena then
        -- Bounce off the wall
        if arena:isPositionWithinArena(self.position + self.velocity) == false then
            self.velocity = self.velocity - (self.velocity * 2)

            if self.isCharging == true then
                self.chargeDurationCooldown = self.chargeDuration
                self.chargeCooldown = self.maxChargeCooldown
                self.isCharging = false
            end
        end

        -- Clamp the enemy's position
        self.position = self.position + self.velocity
        self.position = game.gameStateMachine:current_state().arena:getClampedPosition(self.position)
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
        self.eye.eyeBasePosition.x = self.position.x + math.cos(self.angle - self.tail.tailAngleWave/8) * 4
        self.eye.eyeBasePosition.y = self.position.y + math.sin(self.angle - self.tail.tailAngleWave/8) * 4
        self.eye:update()
    end

    -- Update the collider
    local world = game.gameStateMachine:current_state().world

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end
end

function drone:draw()
    if not self.sprite then
        return
    end

    -- Draw the eye
    if self.eye then
        self.eye:draw()
    end

    -- Draw the sprite
    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = 5
    yOffset = yOffset/2

    love.graphics.setColor(game.manager.currentPalette.enemyColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle - self.tail.tailAngleWave/8, 1, 1, xOffset, yOffset)
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the tail
    if self.tail then
        self.tail:draw()
    end
end

function drone:applyFriction(dt)
    local frictionRatio = 1 / (1 + (dt * self.friction))
    self.velocity = self.velocity * frictionRatio
end

function drone:cleanup()
    local world = game.gameStateMachine:current_state().world
    if world and world:hasItem(self.collider) then
        game.gameStateMachine:current_state().world:remove(self.collider)
    end
end

return drone