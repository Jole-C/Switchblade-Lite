local enemy = require "game.objects.enemy.enemy"

local chargerEnemy = class{
    __includes = enemy,

    health = 1,
    speed = 3,
    angle,

    sprite,
    wallBouncePoint = {},
    wallBouncePosition,

    init = function(self, x, y)
        enemy.init(self, x, y)

        self.angle = love.math.random(0, 6)

        self.sprite = resourceManager:getResource("charger enemy sprite")
        self.sprite:setFilter("nearest")
        self.wallBouncePosition = vector.new(0, 0)
        
        gamestate.current().world:add(self.wallBouncePoint, x, y, 1, 1)
        
    end,

    update = function(self)
        -- Move the enemy
        local movementDirection = vector.new(math.cos(self.angle), math.sin(self.angle))
        self.position = self.position + movementDirection * self.speed

        -- Handle collision between the border
        self.wallBouncePosition = self.position + movementDirection * self.speed
        gamestate.current().world:update(self.wallBouncePoint, self.wallBouncePosition.x, self.wallBouncePosition.y)

        local x, y, cols, len = world:check(self, self.position.x, self.position.y)

        for i = 1, len do
            local collidedObject = cols[i].other

            if collidedObject.colliderdefinition == collider then

            end
        end
    end,

    draw = function(self)
        local xOffset, yOffset = self.sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2

        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
    end
}

return chargerEnemy