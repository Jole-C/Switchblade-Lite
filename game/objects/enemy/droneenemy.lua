local enemy = require "game.objects.enemy.enemy"
local collider = require "game.collision.collider"

local droneEnemy = class{
    __includes = enemy,

    maxSpeed = 1,
    maxSteeringForce = 1,

    velocity,

    collider,
    sprite,

    init = function(self, x, y)
        enemy.init(self, x, y)
        self.velocity = vector.new(0, 0)

        self.collider = collider(colliderDefinitions.enemy, self)
        gamestate.current().world:add(self.collider, self.position.x, self.position.y, 8, 8)
    end,

    update = function(self, dt)
        local playerPosition = playerManager.playerPosition

        local targetVelocity = (playerPosition - self.position):normalized() * self.maxSpeed
        local steeringVelocity = (targetVelocity - self.velocity):trimmed(self.maxSteeringForce)
        self.velocity = (self.velocity + steeringVelocity):trimmed(self.maxSpeed)

        self.position = self.position + self.velocity

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
        love.graphics.circle("fill", self.position.x, self.position.y, 4)
    end,

    cleanup = function(self)
        if not gamestate.current().world then
            return
        end
        
        gamestate.current().world:remove(self.collider)
    end
}

return droneEnemy