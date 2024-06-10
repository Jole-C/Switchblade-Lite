local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local laser = require "src.objects.enemy.enemybullets.overheatlaser"
local orbiter = class({name = "Orbiter", extends = enemy})

function orbiter:new(x, y)
    self:super(x, y, "wanderer sprite")

    -- Parameters of the enemy
    self.offsetAngleLerpRate = 0.2
    self.distanceFromPlayer = 70
    self.secondsBetweenAngleChange = 3
    self.maxFireCooldown = 3
    self.health = 3

    -- Variables
    self.offsetAngleChangeCooldown = self.secondsBetweenAngleChange
    self.lerpChangeCooldown = self.secondsBetweenAngleChange
    self.offsetAngle = 0
    self.angle = 0
    self.positionOffset = vec2(math.cos(self.offsetAngle) * self.distanceFromPlayer, math.sin(self.offsetAngle) * self.distanceFromPlayer)
    self.fireCooldown = self.maxFireCooldown
    self.drawLine = false

    -- Components
    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:getWorld():add(self.collider, self.position.x, self.position.y, 12, 12)

    -- Set the angle
    local playerPosition = game.playerManager.playerPosition
    self.offsetAngle = (self.position - playerPosition):angle()
end

function orbiter:update(dt)
    enemy.update(self, dt)

    local playerReference = game.playerManager.playerReference

    if not playerReference then
        return
    end

    self.lerpChangeCooldown = self.lerpChangeCooldown - (1 * dt)

    if self.lerpChangeCooldown <= 0 then
        self.lerpChangeCooldown = self.secondsBetweenAngleChange

        self.offsetAngle = math.random(0, 2 * math.pi)
    end

    local targetPosition = vec2(math.cos(self.offsetAngle) * self.distanceFromPlayer, math.sin(self.offsetAngle) * self.distanceFromPlayer)
    self.positionOffset:lerp_direction_inplace(targetPosition, self.offsetAngleLerpRate)

    self.position:lerpDT_inplace(playerReference.position + self.positionOffset, 0.05, dt)
    self.position = gameHelper:getArena():getClampedPosition(self.position)

    self.angle = (playerReference.position - self.position):angle()
    
    if playerReference.isOverheating == false and playerReference.isBoosting == false then
        self.drawLine = true

        self.fireCooldown = self.fireCooldown - (1 * dt)

        if self.fireCooldown <= 0 then
            self.fireCooldown = self.maxFireCooldown
            local newLaser = laser(self.position.x, self.position.y, self.angle, 0, 500, 0.05)
            gameHelper:addGameObject(newLaser)
        end
    else
        self.fireCooldown = self.maxFireCooldown
        self.drawLine = false
    end

    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end

    self:checkColliders(self.collider)
end

function orbiter:draw()
    if not self.sprite then
        return
    end

    love.graphics.setColor(self.enemyColour)

    -- Draw the sprite
    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    local x1 = self.position.x
    local y1 = self.position.y
    local x2 = x1 + math.cos(self.angle) * 400
    local y2 = y1 + math.sin(self.angle) * 400

    if self.drawLine == true then
        love.graphics.line(x1, y1, x2, y2)
    end

    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.offsetAngle, 1, 1, xOffset, yOffset)
    
    love.graphics.setColor(1, 1, 1, 1)
end

function orbiter:cleanup()
    enemy.cleanup(self)
    
    local world = gameHelper:getWorld()
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return orbiter