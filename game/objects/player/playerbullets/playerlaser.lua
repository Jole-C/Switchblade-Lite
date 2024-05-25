local bullet = require "game.objects.bullet.bullet"
local playerLaser = class({name = "Player Laser", extends = bullet})

function playerLaser:new(x, y, angle, damage, colliderDefinition)
    self.damage = damage
    self.length = game.arenaValues.worldWidth * math.abs(game.arenaValues.worldX)
    self.lifetime = 0.05

    self.position = vec2(x, y)
    self.circlePosition = vec2(0, 0)
    self.angle = angle

    self.sprite = game.resourceManager:getResource("player laser sprite")
end

function playerLaser:update(dt)
    self.lifetime = self.lifetime - 1 * dt

    if self.lifetime <= 0 then
        self:destroy()
    end

    local currentGamestate = game.gameStateMachine:current_state()
    local world = currentGamestate.world

    -- Handle laser bouncing
    local arena = currentGamestate.arena
    local bulletEndPoint = vec2(self.position.x + math.cos(self.angle) * self.length, self.position.y + math.sin(self.angle) * self.length)
    local arenaSegment

    if arena then
        bulletEndPoint, arenaSegment = arena:getClampedPosition(bulletEndPoint)
    end

    -- Handle collisions with enemy
    if world then
        local x1 = self.position.x
        local y1 = self.position.y
        local x2 = bulletEndPoint.x
        local y2 = bulletEndPoint.y

        local items, len = world:querySegmentWithCoords(x1, y1, x2, y2)

        for i = 1, len do
            local item = items[i].item
            local collidedObject = item.owner
            local colliderDefinition = item.colliderDefinition
            local x = items[i].x1
            local y = items[i].y1

            if not collidedObject or not colliderDefinition then
                goto continue
            end

            if colliderDefinition == colliderDefinitions.enemy then
                if collidedObject.onHit then
                    collidedObject:onHit(self.damage)
                end
            end

            ::continue::
        end
    end
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

return playerLaser