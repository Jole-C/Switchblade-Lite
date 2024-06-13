local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local eye = require "src.objects.enemy.enemyeye"

local bossOrb = class({name = "Boss 1 Orb", extends = enemy})

function bossOrb:new(x, y, bossReference, angle)
    self:super(x, y, "boss 1 orb")
    
    self.bossReference = bossReference
    self.radius = 0
    self.maxRadius = 200
    self.angle = angle or 0
    self.turnRate = 0.5

    self.spriteAngle = 0
    self.spriteAngleTurnRate = 2

    self.isDamageable = false
    self.damageableShader = game.resourceManager:getResource("outline shader")
    self.maxDamageableCooldown = 3
    self.damageableCooldown = self.maxDamageableCooldown

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:getWorld():add(self.collider, x, y, 32, 32)

    self.eye = eye(x, y, 5, 5, true)
end

function bossOrb:update(dt)
    enemy.update(self, dt)
    
    -- Update the position of the orb
    self.position.x = math.cos(self.angle) * self.radius
    self.position.y = math.sin(self.angle) * self.radius

    self.angle = self.angle + (self.turnRate * dt)

    self.spriteAngle = self.spriteAngle + (self.spriteAngleTurnRate * dt)

    self.radius = math.lerpDT(self.radius, self.maxRadius, 0.02, dt)
    
    -- Toggle the enemy between being damageable or not
    self.damageableCooldown = self.damageableCooldown - (1 * dt)
    
    if self.damageableCooldown <= 0 then
        self.damageableCooldown = self.maxDamageableCooldown

        self.isDamageable = not self.isDamageable
    end

    -- Move enemy collider
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end

    if self.eye then
        self.eye.eyeBasePosition.x = self.position.x
        self.eye.eyeBasePosition.y = self.position.y
        
        self.eye:update()
    end
end

function bossOrb:draw()
    if self.eye then
        self.eye:draw()
    end

    love.graphics.setColor(game.manager.currentPalette.enemyColour)

    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.spriteAngle, 1, 1, xOffset, yOffset)

    if self.isDamageable == true then
        love.graphics.setShader(self.damageableShader)
        self.damageableShader:send("stepSize", {1/self.sprite:getWidth(), 1/self.sprite:getHeight()})
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