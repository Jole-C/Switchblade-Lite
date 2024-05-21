local bullet = require "game.objects.bullet.bullet"

local playerLaser = class{
    __includes = bullet,
    sprite,
    length = 0,
    lifetime = 0.1,
    bouncesLeft = 3,
    circlePosition,

    init = function(self, x, y, angle, damage, colliderDefinition, bouncesLeft, subLaserClass)
        self.position = vector.new(x, y)
        self.circlePosition = vector.new(0, 0)
        self.angle = angle
        self.damage = damage
        self.length = screenWidth * 2
        self.sprite = resourceManager:getResource("player laser sprite")

        self.bouncesLeft = bouncesLeft

        if self.bouncesLeft > 0 then
            self.subLaserClass = subLaserClass
        end
    end,

    update = function(self, dt)
        self.lifetime = self.lifetime - 1 * dt

        if self.lifetime <= 0 then
            self:destroy()
        end

        local world = gamestate.current().world

        if world then
            local x1 = self.position.x
            local y1 = self.position.y
            local x2 = self.position.x + math.cos(self.angle) * self.length
            local y2 = self.position.y + math.sin(self.angle) * self.length

            local items, len = world:querySegmentWithCoords(x1, y1, x2, y2)

            for i = 1, len do
                local item = items[i].item
                local collidedObject = item.owner
                local colliderDefinition = item.colliderDefinition
                local x = items[i].x1
                local y = items[i].y1
                
                self.circlePosition.x = x
                self.circlePosition.y = y

                if not collidedObject or not colliderDefinition then
                    goto continue
                end

                if colliderDefinition == colliderDefinitions.enemy then
                    if collidedObject.onHit then
                        collidedObject:onHit(self.damage)
                    end
                elseif colliderDefinition == colliderDefinitions.wall and self.bouncesLeft > 0 then
                    if collidedObject.normal then
                        local angleVector = vector.new(math.cos(self.angle), math.sin(self.angle))
                        local dot = collidedObject.normal * angleVector
                        local reflectedVector = angleVector:mirrorOn(collidedObject.normal)
                        local reflectedAngle = math.atan2(reflectedVector.y, reflectedVector.x)
                        local newPlayerLaser = self.subLaserClass(x, y, reflectedAngle + math.pi, self.damage, self.colliderDefinition, self.bouncesLeft - 1, self.subLaserClass)
                        newPlayerLaser.lifetime = self.lifetime
                        gamestate.current():addObject(newPlayerLaser)
                    end
                end

                ::continue::
            end
        end
    end,

    draw = function(self)
        if not self.sprite then
            return
        end

        local xOffset, yOffset = self.sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2
        
        love.graphics.setColor(gameManager.currentPalette.playerColour)
        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, self.length, 1, 0, yOffset)

        if self.bouncesLeft > 0 then
            love.graphics.circle("fill", self.circlePosition.x, self.circlePosition.y, 15)
        end
        
        love.graphics.setColor(1, 1, 1, 1)
    end

}

return playerLaser