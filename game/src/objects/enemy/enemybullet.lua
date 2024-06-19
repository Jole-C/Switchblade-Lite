local bullet = require "src.objects.bullet.bullet"
local enemyBullet = class({name = "Enemy Bullet", extends = bullet})

function enemyBullet:checkCollision(xx, yy)
    local world = gameHelper:getWorld()
    
    if world:hasItem(self.collider) then
        local x, y, cols, len = world:check(self.collider, xx, yy)

        for i = 1, len do
            local collidedObject = cols[i].other.owner
            local colliderDefinition = cols[i].other.colliderDefinition

            if collidedObject and colliderDefinition then
                if colliderDefinition == colliderDefinitions.player then
                    if collidedObject.onHit then
                        collidedObject:onHit(self.damage)
                    end
                    
                    self:destroy()
                end
            end
        end
    end
end

function enemyBullet:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius/4)

    love.graphics.setColor(game.manager.currentPalette.enemyColour)
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius/2)

    love.graphics.setColor(1, 1, 1, 1)
end

return enemyBullet