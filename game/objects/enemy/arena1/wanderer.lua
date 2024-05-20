local enemy = require "game.objects.enemy.enemy"
local collider = require "game.collision.collider"
local tail = require "game.objects.enemy.enemytail"
local eye = require "game.objects.enemy.enemyeye"


local wanderer = class{
    __includes = enemy,

    secondsBetweenAngleChange = 1,
    randomChangeOffset = 0.5,
    speed = 16,
    spriteName = "wanderer enemy sprite",

    targetAngle = 0,
    angle = 0,
    angleChangeCooldown = 0,

    sprite,
    collider,
    tail,
    eye,

    init = function(self, x, y)
        enemy.init(self, x, y, self.spriteName)

        self.targetAngle = love.math.random(0, math.pi * 2)
        self.angleChangeCooldown = self.secondsBetweenAngleChange

        self.collider = collider(colliderDefinitions.enemy, self)
        gamestate.current().world:add(self.collider, self.position.x, self.position.y, 8, 8)

        self.eyeOffset = vector.new(0, 0)

        self.tail = tail("wanderer tail sprite", 15, 1)
        self.eye = eye(2, 2)
    end,

    update = function(self, dt)
        -- Move the enemy and lerp its angle to the target angle
        self.angle = math.lerpAngle(self.angle, self.targetAngle, 0.01)

        local movementDirection = vector.new(math.cos(self.angle), math.sin(self.angle))
        self.position = self.position + movementDirection * self.speed * dt
        
        -- Clamp the enemy's position to the world border
        self.position.x = math.clamp(self.position.x, 0, gameWidth)
        self.position.y = math.clamp(self.position.y, 0, gameHeight)

        -- Randomise the enemy's angle
        self.angleChangeCooldown = self.angleChangeCooldown - 1 * dt

        if self.angleChangeCooldown <= 0 then
            self.angleChangeCooldown = self.secondsBetweenAngleChange + math.random(-self.randomChangeOffset, self.randomChangeOffset)
            self.targetAngle = love.math.random(0, math.pi * 2)
        end

        -- Update the tail
        if self.tail then
            self.tail.tailSpritePosition.x = self.position.x + math.cos(self.angle + math.pi) * 2
            self.tail.tailSpritePosition.y = self.position.y + math.sin(self.angle + math.pi) * 2
            self.tail.baseTailAngle = self.angle

            self.tail:update(dt)
        end

        -- Update the eye
        if self.eye then
            self.eye.eyeBasePosition.x = self.position.x
            self.eye.eyeBasePosition.y = self.position.y
            self.eye:update()
        end

        -- Handle collisions
        local world = gamestate.current().world

        if world and world:hasItem(self.collider) then
            -- Move the collider
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
        xOffset = xOffset/2
        yOffset = yOffset/2

        love.graphics.setColor(gameManager.currentPalette.enemyColour)
        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle - self.tail.tailAngleWave/4, 1, 1, xOffset, yOffset)
        love.graphics.setColor(1, 1, 1, 1)

        -- Draw the tail
        if self.tail then
            self.tail:draw()
        end
    end
}

return wanderer