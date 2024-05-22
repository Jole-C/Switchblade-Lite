local gameobject = require "game.objects.gameobject"
local collider = require "game.collision.collider"

local bullet = class{
    __includes = gameobject,

    name = "base bullet",
    speed = 0,
    angle = 0,
    damage = 0,
    lifetime = 2,
    collider,

    init = function(self, x, y, speed, angle, damage, colliderDefinition, width, height)
        gameobject.init(self, x, y)

        self.speed = speed
        self.angle = angle
        self.damage = damage
        self.lifetime = lifetime

        self.collider = collider(colliderDefinition, self)
        gamestate.current().world:add(self.collider, x, y, width, height)
    end,

    update = function(self, dt)
        -- Update the bullet logic, position etc
        self:updateBullet(dt)

        -- Update the collider position and check it for collisions
        local currentGamestate = gamestate.current()
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
    end,

    updateBullet = function(self, dt)
        self.position.x = self.position.x + math.cos(self.angle) * self.speed
        self.position.y = self.position.y + math.sin(self.angle) * self.speed
    end,

    checkCollision = function(self, x, y)

    end,

    draw = function(self)
        love.graphics.circle("fill", self.position.x, self.position.y, 5)
    end,

    cleanup = function(self)
        local world = gamestate.current().world
        if world and world:hasItem(self.collider) then
            gamestate.current().world:remove(self.collider)
        end
    end,
}

return bullet