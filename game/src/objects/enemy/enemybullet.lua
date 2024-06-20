local bullet = require "src.objects.bullet.bullet"
local enemyBullet = class({name = "Enemy Bullet", extends = bullet})

function enemyBullet:handleCollision(collider, collidedObject, colliderDefinition)
    if colliderDefinition == colliderDefinitions.player then
        if collidedObject.onHit then
            collidedObject:onHit(1)
            self:destroy()
        end
    end

    return false
end

function enemyBullet:draw()
    love.graphics.setColor(game.manager.currentPalette.enemyColour)
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius/2)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius/4)
end

return enemyBullet