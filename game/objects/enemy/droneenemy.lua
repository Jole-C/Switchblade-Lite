local enemy = require "game.objects.enemy.enemy"

local droneEnemy = class{
    __includes = enemy,

    maxSpeed = 1,
    maxSteeringForce = 1,


    velocity,

    init = function(self, x, y)
        enemy.init(self, x, y)
        self.velocity = vector.new(0, 0)
    end,

    update = function(self, dt)
        local playerPosition = playerManager.playerPosition

        local targetVelocity = (playerPosition - self.position):normalized() * self.maxSpeed
        local steeringVelocity = (targetVelocity - self.velocity):trimmed(self.maxSteeringForce)
        self.velocity = (self.velocity + steeringVelocity):trimmed(self.maxSpeed)

        self.position = self.position + self.velocity
    end,

    draw = function(self)
        love.graphics.circle("fill", self.position.x, self.position.y, 4)
    end
}

return droneEnemy