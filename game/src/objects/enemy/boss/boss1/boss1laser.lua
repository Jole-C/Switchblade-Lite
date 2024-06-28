local laser = require "src.objects.bullet.laser"
local bossLaser = class({name = "Boss 1 Laser", extends = laser})

function bossLaser:new(x, y, angle, length, lifetime)
    self.sprite = game.resourceManager:getAsset("Enemy Assets"):get("boss1"):get("sprites"):get("laserOuter")
    self.spriteInner = game.resourceManager:getAsset("Enemy Assets"):get("boss1"):get("sprites"):get("laserInner")

    self:super(x, y, angle, 0, length, lifetime, 8)

    self.innerLaserScaleMultiplier = 0
    self.innerLaserScaleTime = 0
    self.innerLaserScaleFrequency = 30
    self.innerLaserScaleAmplitude = 1.5
    self.laserOffsetPosition = 40
end

function bossLaser:update(dt)
    laser.update(self, dt)
    
    self.innerLaserScaleTime = self.innerLaserScaleTime + (self.innerLaserScaleFrequency * dt)
    self.innerLaserScaleMultiplier = ((math.sin(self.innerLaserScaleTime) + 1) / 2) * self.innerLaserScaleAmplitude
end

function bossLaser:draw()
    if not self.sprite then
        return
    end

    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    local laserX = self.position.x + math.cos(self.angle) * self.laserOffsetPosition
    local laserY = self.position.y + math.sin(self.angle) * self.laserOffsetPosition
    
    love.graphics.setColor(game.manager.currentPalette.enemyColour)
    love.graphics.draw(self.sprite, laserX, laserY, self.angle, self.length, 1, 0, yOffset)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.spriteInner, laserX, laserY, self.angle, self.length, 0.5 + 1 * self.innerLaserScaleMultiplier, 0, yOffset)
    
    love.graphics.setColor(game.manager.currentPalette.enemyColour)
    love.graphics.circle("fill", laserX, laserY, 32 + 10 * self.innerLaserScaleMultiplier)
end

function bossLaser:handleCollision(items, len, dt)
    for i = 1, len do
        local item = items[i]
        local collidedObject = item.owner
        local colliderDefinition = item.colliderDefinition
        local x = items[i].x1
        local y = items[i].y1

        if not collidedObject or not colliderDefinition then
            goto continue
        end

        if colliderDefinition == colliderDefinitions.player then
            collidedObject:accumulateTemperature(dt, 3)
            return true
        end

        ::continue::
    end
end

return bossLaser