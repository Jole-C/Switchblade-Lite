local laser = require "src.objects.bullet.laser"
local bossLaser = class({name = "Boss 1 Laser", extends = laser})

function bossLaser:new(x, y, angle, length, lifetime)
    self.sprite = game.resourceManager:getResource("boss 1 laser outer")
    self.spriteInner = game.resourceManager:getResource("boss 1 laser inner")
    
    self:super(x, y, angle, 0, length, lifetime, 8)
end

function bossLaser:update(dt)
    laser.update(self, dt)
end

function bossLaser:draw()
    if not self.sprite then
        return
    end

    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2
    
    love.graphics.setColor(game.manager.currentPalette.enemyColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, self.length, 1, 0, yOffset)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.spriteInner, self.position.x, self.position.y, self.angle, self.length, 1, 0, yOffset)
    
    love.graphics.setColor(game.manager.currentPalette.enemyColour)
    love.graphics.circle("fill", self.position.x, self.position.y, 32)
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