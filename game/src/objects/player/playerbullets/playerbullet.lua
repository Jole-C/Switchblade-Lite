local bullet = require "src.objects.bullet.bullet"
local playerBullet = class({name = "Player Bullet", extends = bullet})

function playerBullet:new(x, y, speed, angle, damage, colliderDefinition, width, height)
    self:super(x, y, speed, angle, damage, colliderDefinition, width, height)
    game.playerManager:registerPlayerBullet(self)
end

function playerBullet:handleCollision(collider, collidedObject, colliderDefinition)
    if colliderDefinition == colliderDefinitions.enemy then
        if collidedObject.onHit then
            collidedObject:onHit("bullet", self.damage)
            self:destroy()
        end
    end

    return false
end

function playerBullet:draw()
    love.graphics.setColor(game.manager.currentPalette.playerColour)
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius/2)
    love.graphics.setColor(1, 1, 1, 1)
end

return playerBullet