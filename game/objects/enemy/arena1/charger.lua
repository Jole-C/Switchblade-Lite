local enemy = require "game.objects.enemy.enemy"
local collider = require "game.collision.collider"
local tail = require "game.objects.enemy.enemytail"
local eye = require "game.objects.enemy.enemyeye"
local charger = class({name = "Charger Enemy", extends = enemy})

function charger:new(x, y)
    self:super(x, y, "charger sprite")

    -- Parameters of the enemey
    self.health = 1
    self.speed = 80
    self.checkDistance = 2

    -- Variables
    self.angle = love.math.random(0, 6)
    self.wallBounceCheckPosition = vec2(0, 0)
    self.eyeOffset = vec2(0, 0)

    -- Components
    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:getWorld():add(self.collider, x, y, 12, 12)

    self.tail = tail("charger tail sprite", self.position.x, self.position.y, 15, 1)
    self.eye = eye(x, y, 2, 2)
end

function charger:handleDamage(damage)
    if damage.type == "bullet" or "boost" then
        self.health = self.health - damage.amount
    end
end

function charger:update(dt)
    enemy.update(self, dt)

    local currentGamestate = gameHelper:getCurrentState()
    local arena = currentGamestate.arena

    if not arena then
        return
    end

    -- Move the enemy
    local movementDirection = vec2(math.cos(self.angle), math.sin(self.angle))
    self.position = currentGamestate.arena:getClampedPosition(self.position + movementDirection * self.speed * dt)

    -- Reverse the enemy's position if it reaches the border
    self.wallBounceCheckPosition = self.position + movementDirection * self.checkDistance

    if currentGamestate.arena:isPositionWithinArena(self.wallBounceCheckPosition) == false then
        self.angle = self.angle + math.pi / 2
    end

    -- Update the tail
    if self.tail then
        self.tail.tailSpritePosition.x = self.position.x + math.cos(self.angle + math.pi) * -2
        self.tail.tailSpritePosition.y = self.position.y + math.sin(self.angle + math.pi) * -2
        self.tail.baseTailAngle = self.angle

        self.tail:update(dt)
    end

    -- Update the eye
    if self.eye then
        self.eye.eyeBasePosition.x = self.position.x + math.cos(self.angle - self.tail.tailAngleWave/4) * 5
        self.eye.eyeBasePosition.y = self.position.y + math.sin(self.angle - self.tail.tailAngleWave/4) * 5
        self.eye:update()
    end
    
    -- Move enemy collider
    local world = currentGamestate.world

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end
end

function charger:draw()
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
    xOffset = 5
    yOffset = yOffset/2

    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle - self.tail.tailAngleWave/4, 1, 1, xOffset, yOffset)

    -- Draw the tail
    if self.tail then
        self.tail:draw()
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function charger:cleanup()
    enemy.cleanup(self)
    
    local world = gameHelper:getWorld()
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return charger