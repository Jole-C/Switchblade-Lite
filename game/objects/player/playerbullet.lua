local bullet = require "game.objects.bullet.bullet"

local playerBullet = class{
    __includes = bullet,

    name = "player bullet",

    checkCollision = function(self, xx, yy)
        local world = gamestate.current().world

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
    end,
}

return playerBullet