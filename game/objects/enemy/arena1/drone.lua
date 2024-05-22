local enemy = require "game.objects.enemy.enemy"
local collider = require "game.collision.collider"
local tail = require "game.objects.enemy.enemytail"
local eye = require "game.objects.enemy.enemyeye"
local drone = class({name = "Drone Enemy", extends = enemy})

function drone:new(x, y)
    self:super(x, y, "drone sprite")

    -- Parameters of the enemey
    self.maxSpeed = 40
    self.maxSteeringForce = 30
    self.health = 5

    -- Variables
    self.angle = 0
    self.velocity = vector.new(0, 0)

    -- Components
    self.collider = collider(colliderDefinitions.enemy, self)
    gamestate.current().world:add(self.collider, self.position.x, self.position.y, 8, 8)

    self.tail = tail("charger tail sprite", 15, 1)
    self.eye = eye(3, 2)
end

function drone:update(dt)
    -- Move the enemy using seek steering behaviour
    local playerPosition = playerManager.playerPosition

    local targetVelocity = (playerPosition - self.position):normalized() * self.maxSpeed * dt
    local steeringVelocity = (targetVelocity - self.velocity):trimmed(self.maxSteeringForce) * dt
    self.velocity = (self.velocity + steeringVelocity):trimmed(self.maxSpeed)

    -- Clamp the enemy's position
    if gamestate.current().arena then
        self.position = gamestate.current().arena:getClampedPosition(self.position + self.velocity)
    end

    -- Update the angle of the enemy
    self.angle = self.position:angleTo(playerPosition)

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
    local world = gamestate.current().world

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

    love.graphics.setColor(gameManager.currentPalette.enemyColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle - self.tail.tailAngleWave/8, 1, 1, xOffset, yOffset)
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the tail
    if self.tail then
        self.tail:draw()
    end
end

function drone:cleanup()
    local world = gamestate.current().world
    if world and world:hasItem(self.collider) then
        gamestate.current().world:remove(self.collider)
    end
end

return drone