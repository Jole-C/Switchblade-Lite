local enemy = require "game.objects.enemy.enemy"
local collider = require "game.collision.collider"

local droneEnemy = class{
    __includes = enemy,

    maxSpeed = 40,
    maxSteeringForce = 30,
    angle = 0,
    health = 5,

    velocity,

    collider,
    sprite,

    init = function(self, x, y)
        enemy.init(self, x, y)
        self.velocity = vector.new(0, 0)

        self.collider = collider(colliderDefinitions.enemy, self)
        gamestate.current().world:add(self.collider, self.position.x, self.position.y, 8, 8)

        self.sprite = resourceManager:getResource("drone enemy sprite")
        self.sprite:setFilter("nearest")
    end,

    update = function(self, dt)
        -- Move the enemy using seek steering behaviour
        local playerPosition = playerManager.playerPosition

        local targetVelocity = (playerPosition - self.position):normalized() * self.maxSpeed * dt
        local steeringVelocity = (targetVelocity - self.velocity):trimmed(self.maxSteeringForce) * dt
        self.velocity = (self.velocity + steeringVelocity):trimmed(self.maxSpeed)

        self.position = self.position + self.velocity

        -- Update the angle of the enemy
        self.angle = self.position:angleTo(playerPosition)

        -- Update the collider
        local world = gamestate.current().world

        if world then
            local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
            colliderPositionX = self.position.x - colliderWidth/2
            colliderPositionY = self.position.y - colliderHeight/2
            
            world:update(self.collider, colliderPositionX, colliderPositionY)
        end
    end,

    draw = function(self)
        local playerPosition = playerManager.playerPosition
        local xOffset, yOffset = self.sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2

        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
    end,

    cleanup = function(self)
        enemy.cleanup(self)
        
        if not gamestate.current().world then
            return
        end
        
        gamestate.current().world:remove(self.collider)
    end
}

return droneEnemy