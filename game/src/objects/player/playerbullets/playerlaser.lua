local laser = require "src.objects.bullet.laser"
local playerLaser = class({name = "Player Laser", extends = laser})

function playerLaser:new(x, y, angle, damage, length, lifetime)
    self.sprite = game.resourceManager:getAsset("Enemy Assets"):get("orbiter"):get("laserSprite")
    
    self:super(x, y, angle, damage, length, lifetime)
end

function playerLaser:draw()
    if not self.sprite then
        return
    end

    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2
    
    love.graphics.setColor(game.manager.currentPalette.playerColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, self.length, 1, 0, yOffset)
    love.graphics.circle("fill", self.position.x, self.position.y, 15)
    
    love.graphics.setColor(1, 1, 1, 1)
end

function playerLaser:handleCollision(items, len)
    for i = 1, len do
        local item = items[i]
        local collidedObject = item.owner
        local colliderDefinition = item.colliderDefinition
        local x = items[i].x1
        local y = items[i].y1

        if not collidedObject or not colliderDefinition then
            goto continue
        end

        if colliderDefinition == colliderDefinitions.enemy then
            if collidedObject.onHit then
                collidedObject:onHit("bullet", self.damage)
            end
        end

        ::continue::
    end
end

return playerLaser