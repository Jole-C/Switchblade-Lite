local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local tail = require "src.objects.enemy.enemytail"
local eye = require "src.objects.enemy.enemyeye"

local crisscross = class({name = "Criss Cross Enemy", extends = enemy})

function crisscross:new(x, y)
    self:super(x, y)

    self.health = 2
    self.maxSpeed = 80
    self.maxChargingSpeed = 1000
    self.chargeDuration = 1
    self.chargeGraceDuration = 1
    self.friction = 1
    self.maxAngleChangeCooldown = 1

    self.checkAngles = {
        {x = -1, y = 0},
        {x = 1, y = 0},
        {x = 0, y = -1},
        {x = 0, y = 1},
    }

    self.checkDistance = 1000

    self.isCharging = false
    self.chargeCooldown = 0
    self.angleChangeCooldown = self.maxAngleChangeCooldown
    self.chargeGraceCooldown = 0
    self.angle = math.random(0, 2 * math.pi)
    self.spriteAngle = self.angle
    self.velocity = vec2(math.cos(self.angle), math.sin(self.angle)) * self.maxSpeed

    self.sprite = game.resourceManager:getAsset("Enemy Assets"):get("crisscross"):get("bodySprite")
    self.tailSprite = game.resourceManager:getAsset("Enemy Assets"):get("crisscross"):get("tailSprite")
    self.chargeSound = game.resourceManager:getAsset("Enemy Assets"):get("crisscross"):get("chargeSound")

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:addCollider(self.collider, self.position.x, self.position.y, 12, 12)

    self.tail = tail(self.tailSprite, x, y, 15, 1)
    self.eye = eye(x, y, 2, 2)
end

function crisscross:update(dt)
    enemy.update(self, dt)

    local currentSpeed = 0
    
    if self.isCharging == false then
        self.angleChangeCooldown = self.angleChangeCooldown - (1 * dt)

        if self.angleChangeCooldown <= 0 then
            self.angleChangeCooldown = self.maxAngleChangeCooldown
            self.angle = math.random(0, 2 * math.pi)
        end

        currentSpeed = self.maxSpeed

        self.chargeGraceCooldown = self.chargeGraceCooldown - (1 * dt)
    else
        currentSpeed = self.maxChargingSpeed

        self.chargeCooldown = self.chargeCooldown - (1 * dt)

        if self.chargeCooldown <= 0 then
            self.isCharging = false
            self.chargeCooldown = self.chargeDuration
            self.chargeGraceCooldown = self.chargeGraceDuration
        end
    end

    self.velocity.x = self.velocity.x + math.cos(self.angle) * (currentSpeed * dt)
    self.velocity.y = self.velocity.y + math.sin(self.angle) * (currentSpeed * dt)
    self.spriteAngle = self.velocity:angle()
    
    self:applyFriction(dt)

    local arena = gameHelper:getArena()

    if arena then
        if arena:isPositionWithinArena(self.position + self.velocity * dt) == false then
            self.velocity = self.velocity - (self.velocity * 2)
        end

        self.position = self.position + self.velocity * dt
        self.position = arena:getClampedPosition(self.position)
    end

    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2

        for _, check in pairs(self.checkAngles) do
            local x1 = self.position.x
            local y1 = self.position.y
            local x2 = check.x * self.checkDistance
            local y2 = check.y * self.checkDistance

            local items, len = world:querySegment(x1, y1, x2, y2)

            for _, item in pairs(items) do
                if item.colliderDefinition == colliderDefinitions.player and self.isCharging == false and self.chargeGraceCooldown <= 0 then
                    local playerPosition = game.playerManager.playerPosition
                    self.angle = (playerPosition - self.position):angle()
                    self.chargeCooldown = self.chargeDuration
                    self.isCharging = true
                    self.velocity.x = 0
                    self.velocity.y = 0
                    self.chargeSound:play()
                    gameHelper:screenShake(0.05)
                end
            end
        end
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end

    self:checkColliders(self.collider)

    if self.tail then
        self.tail.tailSpritePosition.x = self.position.x + math.cos(self.spriteAngle + math.pi) * 3
        self.tail.tailSpritePosition.y = self.position.y + math.sin(self.spriteAngle + math.pi) * 3
        self.tail.baseTailAngle = self.spriteAngle

        self.tail:update(dt)
    end

    if self.eye then
        self.eye.eyeBasePosition.x = self.position.x + math.cos(self.spriteAngle) * 5
        self.eye.eyeBasePosition.y = self.position.y + math.sin(self.spriteAngle) * 5

        self.eye:update()
    end
end

function crisscross:applyFriction(dt)
    local frictionRatio = 1 / (1 + (dt * self.friction))
    self.velocity = self.velocity * frictionRatio
end

function crisscross:draw()
    if self.eye then
        self.eye:draw()
    end

    if self.isCharging == false then
        love.graphics.setColor(self.enemyColour)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    
    -- Draw the sprite
    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = 5
    yOffset = yOffset/2

    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.spriteAngle, 1, 1, xOffset, yOffset)
   
    if self.tail then
        self.tail:draw()
    end 
    
    love.graphics.setColor(1, 1, 1, 1)
end

function crisscross:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return crisscross