local enemy = require "game.objects.enemy.enemy"
local collider = require "game.collision.collider"

local grunt = class{
    __includes = enemy,

    health = 1,
    speed = 60,
    checkDistance = 5,
    angle,
    wallBounceCheckPosition,
    spriteName = "charger enemy sprite",

    sprite,
    collider,

    init = function(self, x, y)
        enemy.init(self, x, y, self.spriteName)

        self.angle = love.math.random(0, 6)

        self.wallBounceCheckPosition = vector.new(0, 0)
        self.collider = collider(colliderDefinitions.enemy, self)
        gamestate.current().world:add(self.collider, self.position.x, self.position.y, 8, 8)
    end,

    update = function(self, dt)
        enemy.update(self, dt)

        -- Move the enemy
        local movementDirection = vector.new(math.cos(self.angle), math.sin(self.angle))
        self.position = self.position + movementDirection * self.speed * dt

        self.position.x = math.clamp(self.position.x, 0, gameWidth)
        self.position.y = math.clamp(self.position.y, 0, gameHeight)

        -- Handle collisions
        local world = gamestate.current().world

        if world and world:hasItem(self.collider) then
            -- Handle collision between the border
            self.wallBounceCheckPosition = self.position + movementDirection * self.checkDistance
            local cols, len = gamestate.current().world:queryPoint(self.wallBounceCheckPosition.x, self.wallBounceCheckPosition.y)

            for i = 1, len do
                local collidedObject = cols[i].owner
                local colliderDefinition = cols[i].colliderDefinition

                if not collidedObject or not colliderDefinition then
                    goto continue
                end

                if colliderDefinition == colliderDefinitions.wall then
                    self.angle = self.angle + love.math.random(math.pi - 2, math.pi + 2)
                end

                ::continue::
            end

            -- Handle enemy collision
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

return grunt