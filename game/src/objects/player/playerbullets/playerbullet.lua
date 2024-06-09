local bullet = require "src.objects.bullet.bullet"
local playerBullet = class({name = "Player Bullet", extends = bullet})

function playerBullet:checkCollision(xx, yy)
    local world = gameHelper:getWorld()
    
    if world:hasItem(self.collider) then
        local x, y, cols, len = world:check(self.collider, xx, yy)

        for i = 1, len do
            local collidedObject = cols[i].other.owner
            local colliderDefinition = cols[i].other.colliderDefinition

            if collidedObject and colliderDefinition then
                if colliderDefinition == colliderDefinitions.enemy then
                    if collidedObject.onHit then
                        collidedObject:onHit("bullet", self.damage)
                    end
                    
                    self:destroy()
                end
            end
        end
    end
end

function playerBullet:draw()
    love.graphics.setColor(game.manager.currentPalette.playerColour)
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius/2)
    love.graphics.setColor(1, 1, 1, 1)
end

return playerBullet