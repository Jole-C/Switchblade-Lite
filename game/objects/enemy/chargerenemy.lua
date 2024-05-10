local enemy = require "game.objects.enemy.enemy"

local chargerEnemy = class{
    __includes = enemy,

    health = 1,
    speed = 3,
    angle,

    sprite,
    wallBounceCheckPosition,

    init = function(self, x, y)
        enemy.init(self, x, y)

        self.angle = love.math.random(0, 6)

        self.sprite = resourceManager:getResource("charger enemy sprite")
        self.sprite:setFilter("nearest")
        self.wallBounceCheckPosition = vector.new(0, 0)
    end,

    update = function(self)
        -- Move the enemy
        local movementDirection = vector.new(math.cos(self.angle), math.sin(self.angle))
        self.position = self.position + movementDirection * self.speed

        -- Handle collision between the border
        self.wallBounceCheckPosition = self.position + movementDirection * 30
        local cols, len = gamestate.current().world:queryPoint(self.wallBounceCheckPosition.x, self.wallBounceCheckPosition.y)

        for i = 1, len do
            local collidedObject = cols[i]

            if collidedObject.colliderDefinition == colliderDefinitions.wall then
                self.angle = self.angle + love.math.pi
            end
        end
    end,

    draw = function(self)
        local xOffset, yOffset = self.sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2

        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
        local cols, len = gamestate.current().world:queryPoint(self.wallBounceCheckPosition.x, self.wallBounceCheckPosition.y)

        love.graphics.circle("fill", self.wallBounceCheckPosition.x, self.wallBounceCheckPosition.y, 2)
    end
}

return chargerEnemy