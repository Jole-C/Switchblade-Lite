local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local tail = require "src.objects.enemy.enemytail"
local eye = require "src.objects.enemy.enemyeye"

local heater = class({name = "Heater", extends = enemy})

function heater:new(x, y)
    self:super(x, y)

    self.health = 2
    self.heatRadius = 30
    self.heatAmount = 2.5
    self.secondsBetweenAngleChange = 0.7
    self.speed = 30

    self.targetAngle = math.random(0, 2 * math.pi)
    self.angleChangeCooldown = self.secondsBetweenAngleChange
    self.eyeOffset = vec2(0, 0)
    self.angle = 0
    self.targetPlayer = false

    self.sprite = game.resourceManager:getAsset("Enemy Assets"):get("wanderer"):get("bodySprite")
    self.tailSprite = game.resourceManager:getAsset("Enemy Assets"):get("wanderer"):get("tailSprite")

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:addCollider(self.collider, self.position.x, self.position.y, 12, 12)

    self.tail = tail(self.tailSprite, x, y, 15, 1)
    self.eye = eye(x, y, 2, 2)
end

function heater:update(dt)
    enemy.update(self, dt)

    self.angle = math.lerpAngle(self.angle, self.targetAngle, 0.01, dt)

    local movementDirection = vec2(math.cos(self.angle), math.sin(self.angle))

    if gameHelper:getCurrentState().arena then
        self.position = gameHelper:getCurrentState().arena:getClampedPosition(self.position + movementDirection * self.speed * dt)
    end

    self.angleChangeCooldown = self.angleChangeCooldown - 1 * dt

    if self.angleChangeCooldown <= 0 then
        local randomPosition = gameHelper:getArena():getRandomPosition(0.7)
        self.targetAngle = (randomPosition - self.position):angle()

        self.angleChangeCooldown = self.secondsBetweenAngleChange
    end

    if self.tail then
        self.tail.tailSpritePosition.x = self.position.x + math.cos(self.angle + math.pi) * 2
        self.tail.tailSpritePosition.y = self.position.y + math.sin(self.angle + math.pi) * 2
        self.tail.baseTailAngle = self.angle

        self.tail:update(dt)
    end

    if self.eye then
        self.eye.eyeBasePosition.x = self.position.x
        self.eye.eyeBasePosition.y = self.position.y
        self.eye:update()
    end

    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end

    self:checkColliders(self.collider)

    local player = game.playerManager.playerReference
    local playerPosition = game.playerManager.playerPosition
    local distanceToPlayer = (playerPosition - self.position):length()

    if distanceToPlayer < self.heatRadius then
        if player then
            player:accumulateTemperature(dt, self.heatAmount)
        end
    end
end

function heater:draw()
    if not self.sprite or not self.tail then
        return
    end
    
    if self.eye then
        self.eye:draw()
    end

    love.graphics.setColor(self.enemyColour)

    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle - self.tail.tailAngleWave/4, 1, 1, xOffset, yOffset)

    if self.tail then
        self.tail:draw()
    end

    love.graphics.circle("line", self.position.x, self.position.y, self.heatRadius)

    love.graphics.setColor(1, 1, 1, 1)
end

function heater:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()
    
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return heater