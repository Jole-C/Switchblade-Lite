local enemy = require "src.objects.enemy.enemy"
local eye = require "src.objects.enemy.enemyeye"
local collider = require "src.collision.collider"

local sticker = class({name = "Sticker", extends = enemy})

function sticker:new(x, y)
    self:super(x, y)

    self.startingSpeed = 0

    self.health = 1
    self.speed = 85
    self.angleTurnRate = 0.05
    self.secondsBetweenAngleChange = 1
    self.randomChangeOffset = 0.5
    self.circleFrequency = 2
    self.circleAmplitude = 3
    self.circleRadius = 2
    self.maxStickGracePeriod = 3

    self.circleSine = 0
    self.circleRadiusOffset = 0

    self.angle = 0
    self.targetAngle = love.math.random(0, math.pi * 2)
    self.angleChangeCooldown = self.secondsBetweenAngleChange

    self.stickOffset = vec2(0, 0)

    self.isSticking = false
    self.stickGracePeriod = 0

    self.sprite = game.resourceManager:getAsset("Enemy Assets"):get("sticker"):get("bodySprite")

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:getWorld():add(self.collider, self.position.x, self.position.y, 12, 12)

    self.eye = eye(x, y, 2, 5, true)
end

function sticker:update(dt)
    enemy.update(self, dt)

    local playerPosition = game.playerManager.playerPosition
    local playerReference = game.playerManager.playerReference

    if playerReference == nil then
        return
    end

    self.stickGracePeriod = self.stickGracePeriod - (1 * dt)

    self.startingSpeed = math.lerpDT(self.startingSpeed, 0, 0.025, dt)

    if self.startingSpeed <= 0.1 then
        self.startingSpeed = 0

        if self.isSticking == false then
            self.angleChangeCooldown = self.angleChangeCooldown - 1 * dt
    
            if self.angleChangeCooldown <= 0 then
                self.angleChangeCooldown = self.secondsBetweenAngleChange + math.random(-self.randomChangeOffset, self.randomChangeOffset)
                self.targetAngle = love.math.random(0, math.pi * 2)
            end
            
            self.angle = math.lerpAngle(self.angle, self.targetAngle, self.angleTurnRate, dt)
            
            self.position.x = self.position.x + math.cos(self.angle) * self.speed / 3 * dt
            self.position.y = self.position.y + math.sin(self.angle) * self.speed / 3 * dt
        end
    else
        self.position.x = self.position.x + math.cos(self.angle) * self.startingSpeed * dt
        self.position.y = self.position.y + math.sin(self.angle) * self.startingSpeed * dt
    end

    if self.isSticking == false then
        if (playerPosition - self.position):length() < 25 and self.stickGracePeriod <= 0 then
            self.isSticking = true

            self.stickOffset = (self.position - playerPosition):normalise_inplace()
            self.stickOffset = self.stickOffset * 10

            self.position = playerPosition + self.stickOffset
        end
    else
        self.position = playerPosition + self.stickOffset

        if playerReference then
            playerReference:accumulateTemperature(dt, 1.35)

            if playerReference.isOverheating == true then
                self:destroy()
            end

            if playerReference.isBoosting == true then
                self.isSticking = false
                self.stickGracePeriod = self.maxStickGracePeriod
            end
        end
    end

    self.circleSine = self.circleSine + self.circleFrequency * dt
    self.circleRadiusOffset = math.sin(self.circleSine) * self.circleAmplitude

    if self.eye then
        self.eye.eyeBasePosition.x = self.position.x
        self.eye.eyeBasePosition.y = self.position.y
        self.eye:update()
    end

    local arena = gameHelper:getArena()
    self.position = arena:getClampedPosition(self.position)

    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end

    self:checkColliders(self.collider)
end

function sticker:handleCollision(collider, collidedObject, colliderDefinition)
    return false
end

function sticker:handleDamage(damageType, amount)
    if self.isSticking == true and damageType == "boost" or damageType == "bullet" then
        self.health = self.health - amount
        return true
    elseif self.isSticking == true and damageType ~= "boost" then
        return false
    end

    enemy.handleDamage(self, damageType, amount)
end

function sticker:draw()
    if not self.sprite then
        return
    end

    love.graphics.setColor(self.enemyColour)

    -- Draw the sprite
    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, 1, 1, xOffset, yOffset)

    love.graphics.circle("fill", self.position.x - 5, self.position.y, self.circleRadius + self.circleRadiusOffset)
    love.graphics.circle("fill", self.position.x + 5, self.position.y, self.circleRadius + self.circleRadiusOffset)
    love.graphics.circle("fill", self.position.x, self.position.y - 5, self.circleRadius + self.circleRadiusOffset)
    love.graphics.circle("fill", self.position.x, self.position.y + 5, self.circleRadius + self.circleRadiusOffset)

    love.graphics.setColor(1, 1, 1, 1)

    if self.eye then
        self.eye:draw()
    end
end

function sticker:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return sticker