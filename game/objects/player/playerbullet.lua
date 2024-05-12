local bullet = require "game.objects.bullet.bullet"

local playerBullet = class{
    __includes = bullet,

    name = "player bullet",

    checkCollision = function(self, xx, yy)
        local world = gamestate.current().world
        
        if world and world:hasItem(self.collider) then
            local x, y, cols, len = world:check(self.collider, xx, yy)
    
            for i = 1, len do
                local collidedObject = cols[i].other.owner
                local colliderDefinition = cols[i].other.colliderDefinition
    
                if not collidedObject or not colliderDefinition then
                    goto continue
                end
    
                if colliderDefinition == colliderDefinitions.enemy then
                    if collidedObject.onHit then
                        collidedObject:onHit(self.damage)
                    end
                    
                    self:destroy()
                end
    
                ::continue::
            end
        end
    end,

    draw = function(self)
        love.graphics.setColor(gameManager.currentPalette.playerColour)
        love.graphics.circle("fill", self.position.x, self.position.y, 5)
        love.graphics.setColor(1, 1, 1, 1)
    end
}

return playerBullet