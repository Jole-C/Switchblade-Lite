local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local laser = require "src.objects.enemy.enemybullets.overheatlaser"
local eye = require "src.objects.enemy.enemyeye"
local orbiter = class({name = "Orbiter", extends = enemy})

function orbiter:new(x, y)
    self:super(x, y, "orbiter sprite")

    -- Parameters of the enemy
    self.positionOffsetAngleLerpRate = 0.2
    self.distanceFromPlayer = 70
    self.secondsBetweenAngleChange = 3
    self.maxFireCooldown = 6
    self.health = 3
    self.maxLineFlashCooldown = 1

    -- Variables
    self.positionOffsetAngleChangeCooldown = self.secondsBetweenAngleChange
    self.lerpChangeCooldown = self.secondsBetweenAngleChange
    self.positionOffsetAngle = 0
    self.angle = 0
    self.positionOffset = vec2(math.cos(self.positionOffsetAngle) * self.distanceFromPlayer, math.sin(self.positionOffsetAngle) * self.distanceFromPlayer)
    self.fireCooldown = self.maxFireCooldown
    self.lineFlashCooldown = self.maxLineFlashCooldown
    self.flashLine = false

    -- Components
    self.sprite = game.resourceManager:getAsset("Enemy Assets"):get("orbiter"):get("bodySprite")

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:addCollider(self.collider, self.position.x, self.position.y, 12, 12)

    self.eye = eye(x, y, 3, 2)

    -- Set the angle
    local playerPosition = game.playerManager.playerPosition
    self.positionOffsetAngle = (self.position - playerPosition):angle()
end

function orbiter:update(dt)
    enemy.update(self, dt)

    self.lerpChangeCooldown = self.lerpChangeCooldown - (1 * dt)

    if self.lerpChangeCooldown <= 0 then
        self.lerpChangeCooldown = self.secondsBetweenAngleChange
        self.positionOffsetAngle = math.random(0, 2 * math.pi)
    end

    local playerPosition = game.playerManager.playerPosition
    local targetPosition = vec2(math.cos(self.positionOffsetAngle), math.sin(self.positionOffsetAngle)) * self.distanceFromPlayer
    
    self.positionOffset:lerp_direction_inplace(targetPosition, self.positionOffsetAngleLerpRate)
    self.position:lerpDT_inplace(playerPosition + self.positionOffset, 0.05, dt)
    self.position = gameHelper:getArena():getClampedPosition(self.position)
    
    if self.eye then
        self.eye.eyeBasePosition.x = self.position.x
        self.eye.eyeBasePosition.y = self.position.y
        self.eye:update()
    end

    self.angle = (playerPosition - self.position):angle()

    local player = game.playerManager.playerReference

    if player and player.isOverheating == false then
        self.fireCooldown = self.fireCooldown - (1 * dt)

        if self.fireCooldown <= 0 then
            self.fireCooldown = self.maxFireCooldown

            local newLaser = laser(self.position.x, self.position.y, self.angle, 0, 500, 0.05)
            gameHelper:addGameObject(newLaser)
        end

        self.lineFlashCooldown = self.lineFlashCooldown - (1 * dt)

        if self.lineFlashCooldown <= 0 then
            local maxCooldown = math.clamp(self.maxLineFlashCooldown * (self.fireCooldown / self.maxFireCooldown), 0.05, self.maxLineFlashCooldown)
            self.lineFlashCooldown = maxCooldown

            self.flashLine = not self.flashLine
        end
    else
        self.fireCooldown = self.maxFireCooldown
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

    if self.eye then
        self.eye:draw()
    end


    -- Draw the sprite
    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = 11
    yOffset = yOffset/2

    local x1 = self.position.x + math.cos(self.angle) * 21
    local y1 = self.position.y + math.sin(self.angle) * 21
    local x2 = x1 + math.cos(self.angle) * 400
    local y2 = y1 + math.sin(self.angle) * 400

    love.graphics.setColor(self.enemyColour)

    if self.flashLine then
        love.graphics.setColor({1, 1, 1, 1})
    end

    love.graphics.line(x1, y1, x2, y2)


    love.graphics.setColor(self.enemyColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
    
    love.graphics.setColor(1, 1, 1, 1)
end

function orbiter:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return orbiter