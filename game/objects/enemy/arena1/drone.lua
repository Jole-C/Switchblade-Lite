local enemy = require "game.objects.enemy.enemy"
local collider = require "game.collision.collider"

local drone = class{
    __includes = enemy,

    maxSpeed = 40,
    maxSteeringForce = 30,
    angle = 0,
    health = 5,
    spriteName = "drone sprite",

    velocity,

    collider,
    sprite,

    init = function(self, x, y)
        enemy.init(self, x, y, self.spriteName)
        self.velocity = vector.new(0, 0)

        self.collider = collider(colliderDefinitions.enemy, self)
        gamestate.current().world:add(self.collider, self.position.x, self.position.y, 8, 8)
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

        if world and world:hasItem(self.collider) then
            local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
            colliderPositionX = self.position.x - colliderWidth/2
            colliderPositionY = self.position.y - colliderHeight/2
            
            world:update(self.collider, colliderPositionX, colliderPositionY)
        end
    end,

    draw = function(self)
        if not self.sprite then
            return
        end

        local playerPosition = playerManager.playerPosition
        local xOffset, yOffset = self.sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2

        love.graphics.setColor(gameManager.currentPalette.enemyColour)
        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
        love.graphics.setColor(1, 1, 1, 1)
    end,

    cleanup = function(self)
        enemy.cleanup(self)
        
        local world = gamestate.current().world
        if world and world:hasItem(self.collider) then
            gamestate.current().world:remove(self.collider)
        end
    end
}

return drone