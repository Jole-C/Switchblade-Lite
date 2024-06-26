local gameObject = require "src.objects.gameobject"
local collider = require "src.collision.collider"
local bullet = class({name = "Bullet", extends = gameObject})

function bullet:new(x, y, speed, angle, damage, colliderDefinition, width, height)
    self:super(x, y)

    self.speed = speed
    self.angle = angle
    self.damage = damage
    self.radius = width

    self.collider = collider(colliderDefinition, self)
    
    gameHelper:getWorld():add(self.collider, x, y, width, height)
end

function bullet:update(dt)
    -- Update the bullet logic, position etc
    self:updateBullet(dt)

    -- Update the collider position and check it for collisions
    local currentGamestate = gameHelper:getCurrentState()
    local world = currentGamestate.world

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2

        world:update(self.collider, colliderPositionX, colliderPositionY)

    end

    self:checkCollision(self.collider)

    -- Destroy the bullet if it's not in the arena
    if currentGamestate.arena then
        if currentGamestate.arena:isPositionWithinArena(self.position) == false then
            self:destroy()
        end
    end
end

function bullet:updateBullet(dt)
    self.position.x = self.position.x + math.cos(self.angle) * self.speed * dt
    self.position.y = self.position.y + math.sin(self.angle) * self.speed * dt
end

function bullet:checkCollision(collider)
    local world = gameHelper:getWorld()

    if world:hasItem(collider) then
        local colliderPositionX, colliderPositionY = world:getRect(collider)
        local x, y, cols, len = world:check(collider, colliderPositionX, colliderPositionY)

        for i = 1, len do
            local collidedObject = cols[i].other.owner
            local colliderDefinition = cols[i].other.colliderDefinition

            if not collidedObject or not colliderDefinition then
                goto continue
            end

            local returnEarly = self:handleCollision(collider, collidedObject, colliderDefinition)

            if returnEarly then
                return
            end

            ::continue::
        end
    end
end

function bullet:handleCollision(collider, collidedObject, colliderDefinition)
end

function bullet:draw()
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius/2)
end

function bullet:cleanup()
    local world = gameHelper:getWorld()
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return bullet