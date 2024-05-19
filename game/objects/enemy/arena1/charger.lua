local enemy = require "game.objects.enemy.enemy"
local collider = require "game.collision.collider"
local tail = require "game.objects.enemy.enemytail"
local eye = require "game.objects.enemy.enemyeye"

local charger = class{
    __includes = enemy,

    health = 1,
    speed = 40,
    checkDistance = 5,
    angle,
    wallBounceCheckPosition,
    spriteName = "charger sprite",

    sprite,
    collider,
    tail,
    eye,

    init = function(self, x, y)
        enemy.init(self, x, y, self.spriteName)

        self.angle = love.math.random(0, 6)

        self.wallBounceCheckPosition = vector.new(0, 0)
        self.collider = collider(colliderDefinitions.enemy, self)
        gamestate.current().world:add(self.collider, self.position.x, self.position.y, 8, 8)
        self.eyeOffset = vector.new(0, 0)

        self.tail = tail("charger tail sprite", 15, 1)
        self.eye = eye(2, 2)
    end,

    update = function(self, dt)
        enemy.update(self, dt)

        -- Move the enemy
        local movementDirection = vector.new(math.cos(self.angle), math.sin(self.angle))
        self.position = self.position + movementDirection * self.speed * dt

        self.position.x = math.clamp(self.position.x, 0, gameWidth)
        self.position.y = math.clamp(self.position.y, 0, gameHeight)

        -- Update the tail
        if self.tail then
            self.tail.tailSpritePosition.x = self.position.x + math.cos(self.angle + math.pi) * 2
            self.tail.tailSpritePosition.y = self.position.y + math.sin(self.angle + math.pi) * 2
            self.tail.baseTailAngle = self.angle

            self.tail:update(dt)
        end

        -- Update the eye
        if self.eye then
            self.eye.eyeBasePosition.x = self.position.x + math.cos(self.angle - self.tail.tailAngleWave/4) * 5
            self.eye.eyeBasePosition.y = self.position.y + math.sin(self.angle - self.tail.tailAngleWave/4) * 5
            self.eye:update()
        end
        
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
                    self.angle = self.angle + math.pi
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
        if not self.sprite or not self.tail then
            return
        end

        -- Draw the eye
        if self.eye then
            self.eye:draw()
        end

        -- Draw the sprite
        local xOffset, yOffset = self.sprite:getDimensions()
        xOffset = 5
        yOffset = yOffset/2

        love.graphics.setColor(gameManager.currentPalette.enemyColour)
        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle - self.tail.tailAngleWave/4, 1, 1, xOffset, yOffset)
        love.graphics.setColor(1, 1, 1, 1)

        -- Draw the tail
        if self.tail then
            self.tail:draw()
        end
    end,

    cleanup = function(self)
        enemy.cleanup(self)
        
        local world = gamestate.current().world
        if world and world:hasItem(self.collider) then
            gamestate.current().world:remove(self.collider)
        end
    end
}

return charger