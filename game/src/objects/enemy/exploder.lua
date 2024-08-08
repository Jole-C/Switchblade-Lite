local enemy = require "src.objects.enemy.enemy"
local wave = require "src.objects.enemy.enemywave"
local collider = require "src.collision.collider"
local eye = require "src.objects.enemy.enemyeye"

local exploder = class({name = "Exploder", extends = enemy})

function exploder:new(x, y, enemyType)
    self:super(x, y)

    enemyType = enemyType or "exploder"

    self.health = 5
    self.score = scoreDefinitions.scoreLarge
    
    self.maxFuseTime = 4
    self.fuseRadius = 100
    self.waveWidth = 30
    self.waveScaleSpeed = 100
    self.fuseRadiusLineWidth = 3
    self.maxFuseFlashCooldown = 1

    self.fuseTime = self.maxFuseTime
    self.fuseFlashCooldown = self.maxFuseFlashCooldown
    self.flash = false
    self.isFused = false

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:addCollider(self.collider, self.position.x, self.position.y, 12, 12)

    self.sprite = game.resourceManager:getAsset("Enemy Assets"):get(enemyType):get("bodySprite")
    self.fuseWarningSound = game.resourceManager:getAsset("Enemy Assets"):get(enemyType):get("warningSound")
    self.explosionSound = game.resourceManager:getAsset("Enemy Assets"):get(enemyType):get("explosionSound")
    self.eye = eye(x, y, 5, 4)
end

function exploder:update(dt)
    enemy.update(self, dt)

    self.position = gameHelper:getArena():getClampedPosition(self.position)
    
    local playerPosition = game.playerManager.playerPosition
    local distance = (self.position - playerPosition):length()

    if distance < self.fuseRadius then
        self.isFused = true
    end

    if self.isFused then
        self.fuseTime = self.fuseTime - (1 * dt)

        if self.fuseTime <= 0 then
            self:destroy("explosion")
        end

        self.fuseFlashCooldown = self.fuseFlashCooldown - (1 * dt)

        if self.fuseFlashCooldown <= 0 then
            local maxCooldown = math.clamp(self.maxFuseFlashCooldown * (self.fuseTime / self.maxFuseTime), 0.05, self.maxFuseFlashCooldown)
            self.fuseFlashCooldown = maxCooldown

            self.flash = not self.flash

            self.fuseWarningSound:play()
        end
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
end

function exploder:draw()
    if self.eye then
        self.eye:draw()
    end

    local colour = self.enemyColour

    if self.flash then
        colour = {1, 1, 1, 1}
    end

    love.graphics.setColor(colour)
    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, 1, 1, xOffset, yOffset)

    love.graphics.setLineWidth(self.fuseRadiusLineWidth)
    love.graphics.circle("line", self.position.x, self.position.y, self.fuseRadius)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(1, 1, 1, 1)
end

function exploder:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end

    if destroyReason == "explosion" then
        self:explosion()

        self.explosionSound:play()
        gameHelper:screenShake(0.4)
        game.particleManager:burstEffect("Stream", 100, self.position)
    end
end

function exploder:handleDamage(damageType, amount)
    if damageType == "boost" or damageType == "contact" then
        self.health = self.health - amount
        return true
    elseif damageType == "bullet" then
        self.health = self.health - 3
    end

    return false
end

function exploder:explosion()
    gameHelper:addGameObject(wave(self.position.x, self.position.y, self.waveWidth, self.waveScaleSpeed))
end

return exploder