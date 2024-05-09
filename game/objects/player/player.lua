local gameobject = require "game.objects.gameobject"

local player = class{
    __includes = gameobject,
    
    steeringSpeedMoving = 0.1,
    steeringSpeedStationary = 0.2,
    accelerationSpeed = 0.002,
    friction = 0.995,
    maxSpeed = 3,
    maxHealth = 3,

    health = 3,
    movementSpeed = 0,
    steeringSpeed = 0,
    angle = 0,
    velocity,

    collider,

    init = function(self, x, y)
        gameobject.init(self, x, y)

        self.velocity = vector.new(0, 0)
        self.health = self.maxHealth

        self.sprite = love.graphics.newImage("/game/assets/sprites/player/player.png")
        self.sprite:setFilter("nearest")

        gamestate.current().world:add(self, 0, 0, 10, 10)
    end,

    update = function(self, dt)
        dt = dt or 0

        -- Create a vector holding the direction the ship is expected to move in
        local movementDirection = vector.new(math.cos(self.angle), math.sin(self.angle))
        
        -- Set the steering speed to its default value
        self.steeringSpeed = self.steeringSpeedStationary

        -- Apply a force to the ship when the thrust button is held down and set the steering speed
        if love.keyboard.isDown("w") then
            self.movementSpeed = self.movementSpeed + self.accelerationSpeed
            self.movementSpeed = math.clamp(self.movementSpeed, 0, self.maxSpeed)

            self.velocity = self.velocity + movementDirection * self.movementSpeed

            self.steeringSpeed = self.steeringSpeedMoving
        end

        -- Steer the ship
        if love.keyboard.isDown("a") then
            self.angle = self.angle - self.steeringSpeed
        end

        if love.keyboard.isDown("d") then
            self.angle = self.angle + self.steeringSpeed
        end

        -- Apply the velocity to the ship and then apply friction
        self.velocity = self.velocity:trimmed(self.maxSpeed)
        self.position = self.position + self.velocity

        self.movementSpeed = self.movementSpeed * self.friction
        self.velocity = self.velocity * self.friction

        -- Wrap the ship's position
        if self.position.x < 0 then
            self.position.x = gameWidth
        end
        if self.position.x > gameWidth then
            self.position.x = 0
        end
        if self.position.y < 0 then
            self.position.y = gameHeight
        end
        if self.position.y > gameHeight then
            self.position.y = 0
        end

        -- Check collision
        local world = gamestate.current().world
        local x, y, cols, len = world:check(self, self.position.x, self.position.y)
        world:update(self, self.position.x, self.position.y)

        for i = 1, len do
            local collidedObject = cols[i].other

            if collidedObject.name == "test" then

            end
        end
    end,

    draw = function(self)
        local xOffset, yOffset = self.sprite:getDimensions();
        xOffset = xOffset/2
        yOffset = yOffset/2
        
        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
    end,
}

return player