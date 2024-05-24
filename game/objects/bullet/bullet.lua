local gameObject = require "game.objects.gameobject"
local collider = require "game.collision.collider"
local bullet = class({name = "Bullet", extends = gameObject})

function bullet:new(x, y, speed, angle, damage, colliderDefinition, width, height)
    self:super(x, y)

    self.speed = speed
    self.angle = angle
    self.damage = damage
    self.lifetime = lifetime

    self.collider = collider(colliderDefinition, self)
    game.gameStateMachine:current_state().world:add(self.collider, x, y, width, height)
end

function bullet:update(dt)
    -- Update the bullet logic, position etc
    self:updateBullet(dt)

    -- Update the collider position and check it for collisions
    local currentGamestate = game.gameStateMachine:current_state()
    local world = currentGamestate.world

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2

        self:checkCollision(colliderPositionX, colliderPositionY)

        if world:hasItem(self.collider) then
            world:update(self.collider, colliderPositionX, colliderPositionY)
        end
    end

    -- Destroy the bullet if it's not in the arena
    if currentGamestate.arena then
        if currentGamestate.arena:isPositionWithinArena(self.position) == false then
            self:destroy()
        end
    end
end

function bullet:updateBullet(dt)
    self.position.x = self.position.x + math.cos(self.angle) * self.speed
    self.position.y = self.position.y + math.sin(self.angle) * self.speed
end

function bullet:checkCollision(x, y)

end

function bullet:draw()
    love.graphics.circle("fill", self.position.x, self.position.y, 5)
end

function bullet:cleanup()
    local world = game.gameStateMachine:current_state().world
    if world and world:hasItem(self.collider) then
        game.gameStateMachine:current_state().world:remove(self.collider)
    end
end

return bullet