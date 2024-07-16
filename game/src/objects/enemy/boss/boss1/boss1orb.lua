local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local bullet = require "src.objects.enemy.enemybullet"

local bossOrb = class({name = "Boss 1 Orb", extends = enemy})

function bossOrb:new(x, y, bossReference, angle)
    self:super(x, y)
    
    self.bossReference = bossReference
    self.radius = 0
    self.radiusOffset = 0
    self.radiusChangeTime = 1
    self.radiusOffsetFrequency = 1
    self.radiusOffsetAmplitude = 200
    self.maxRadius = 300
    self.angle = angle or 0
    self.turnRate = 0.25
    self.introDone = false

    self.maxEnemySpawnCooldown = 3
    self.enemySpawnCooldown = self.maxEnemySpawnCooldown

    self.spriteAngle = 0
    self.spriteAngleTurnRate = 2

    self.isDamageable = false
    self.maxDamageableCooldown = 3
    self.damageableCooldown = self.maxDamageableCooldown

    self.sprite = game.resourceManager:getAsset("Enemy Assets"):get("boss1"):get("sprites"):get("orb")
    self.damageableShader = game.resourceManager:getAsset("Enemy Assets"):get("enemyOutlineShader")

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:addCollider(self.collider, x, y, 32, 32)
end

function bossOrb:update(dt)
    enemy.update(self, dt)
    
    self.position.x = math.cos(self.angle) * self.radius
    self.position.y = math.sin(self.angle) * self.radius

    self.angle = self.angle + (self.turnRate * dt)
    self.spriteAngle = self.spriteAngle + (self.spriteAngleTurnRate * dt)

    if self.introDone == false then
        self.radius = math.lerpDT(self.radius, self.maxRadius, 0.02, dt)

        if self.radius > 299 then
            self.introDone = true
        end
    else
        self.radiusChangeTime = self.radiusChangeTime + (self.radiusOffsetFrequency * dt)
        self.radiusOffset = (1 + math.sin(self.radiusChangeTime)) / 2

        self.radius = self.maxRadius - ((1 - self.radiusOffset) * self.radiusOffsetAmplitude)
    end
    
    self.damageableCooldown = self.damageableCooldown - (1 * dt)
    
    if self.damageableCooldown <= 0 then
        self.damageableCooldown = self.maxDamageableCooldown

        self.isDamageable = not self.isDamageable
    end

    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth / 2
        colliderPositionY = self.position.y - colliderHeight / 2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end

    self.enemySpawnCooldown = self.enemySpawnCooldown - (1 * dt)

    if self.enemySpawnCooldown <= 0 then
        local angleToPlayer = (game.playerManager.playerPosition - self.position):angle()
        local newBullet = bullet(self.position.x, self.position.y, 150, angleToPlayer, 1, colliderDefinitions.enemybullet, 16, 16)

        gameHelper:addGameObject(newBullet)

        self.enemySpawnCooldown = self.maxEnemySpawnCooldown
    end
end

function bossOrb:draw()
    love.graphics.setColor(game.manager.currentPalette.enemyColour)

    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.spriteAngle, 1, 1, xOffset, yOffset)

    if self.isDamageable == true then
        love.graphics.setShader(self.damageableShader)
        self.damageableShader:send("stepSize", {2/self.sprite:getWidth(), 2/self.sprite:getHeight()})
        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.spriteAngle, 1, 1, xOffset, yOffset)
        love.graphics.setShader()
    end
end

function bossOrb:handleDamage(damageType, amount)
    if damageType == "boost" and self.isDamageable == true then
        self:destroy()
        return true
    end

    return false
end

function bossOrb:cleanup()
    enemy.cleanup(self)

    if self.bossReference then
        self.bossReference:damageShieldHealth()
    end
    
    local world = gameHelper:getWorld()
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return bossOrb