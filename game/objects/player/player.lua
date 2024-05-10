local gameobject = require "game.objects.gameobject"
local playerBullet = require "game.objects.player.playerbullet"

local player = class{
    __includes = gameobject,
    
    -- Generic parameters of the ship
    maxHealth = 3,

    -- Movement parameters of the ship
    steeringSpeedMoving = 6,
    steeringSpeedStationary = 14,
    accelerationSpeed = 3,
    boostingAccelerationSpeed = 4,
    friction = 59.4,
    maxSpeed = 3,
    maxBoostingSpeed = 6,
    maxShipTemperature = 100,
    shipHeatAccumulationRate = 1,
    shipCoolingRate = 40,
    shipOverheatCoolingRate = 20,

    -- Firing parameters of the ship
    fireCooldown = 0.05,
    bulletSpeed = 5,
    bulletDamage = 3,
    maxAmmo = 30,
    shipKnockackForce = 0.25,

    -- Ship variables
    health = 3,
    movementSpeed = 0,
    steeringSpeed = 0,
    angle = 0,
    velocity,
    isBoosting = false,
    isOverheating = false,
    shipTemperature = 0,
    fireResetTimer,
    ammo = 0,
    canFire = true,

    init = function(self, x, y)
        gameobject.init(self, x, y)

        self.velocity = vector.new(0, 0)
        self.health = self.maxHealth
        self.ammo = self.maxAmmo

        self.sprite = love.graphics.newImage("/game/assets/sprites/player/player.png")
        self.sprite:setFilter("nearest")

        gamestate.current().world:add(self, 0, 0, 10, 10)
    end,

    update = function(self, dt)
        -- Boosting is always assumed to be false
        self.isBoosting = false

        -- Create a vector holding the direction the ship is expected to move in
        local movementDirection = vector.new(math.cos(self.angle), math.sin(self.angle))
        
        -- Set the steering speed to its default value
        self.steeringSpeed = self.steeringSpeedStationary

        -- Handle ship functionality, moving boosting and firing
        if self.isOverheating == false then

            -- Apply a forward thrust to the ship
            if love.keyboard.isDown("w") then
                self.movementSpeed = self.movementSpeed + (self.accelerationSpeed * dt)
                self.movementSpeed = math.clamp(self.movementSpeed, 0, self.maxSpeed)

                self.velocity = self.velocity + movementDirection * (self.movementSpeed * dt)

                self.steeringSpeed = self.steeringSpeedMoving
            end

            -- Boost the ship
            if love.keyboard.isDown("lshift") then
                self.isBoosting = true
                self.movementSpeed = self.movementSpeed + (self.boostingAccelerationSpeed * dt)
                self.movementSpeed = math.clamp(self.movementSpeed, 0, self.maxBoostingSpeed)

                self.velocity = self.velocity + movementDirection * (self.movementSpeed * dt)

                self.steeringSpeed = self.steeringSpeedMoving

                self.shipTemperature = self.shipTemperature + self.shipHeatAccumulationRate
            end

            -- Steer the ship
            if love.keyboard.isDown("a") and self.isBoosting == false then
                self.angle = self.angle - (self.steeringSpeed * dt)
            end

            if love.keyboard.isDown("d") and self.isBoosting == false then
                self.angle = self.angle + (self.steeringSpeed * dt)
            end

            -- Fire gun
            if self.canFire == true and love.keyboard.isDown("space") and self.ammo > 0 and self.isBoosting == false then
                local newBullet = playerBullet(self.position.x, self.position.y, self.bulletSpeed, self.angle, self.bulletDamage)
                gamestate.current():addObject(newBullet)
    
                self.canFire = false
                self.fireResetTimer = timer.after(self.fireCooldown, function() self:setCanFire() end)
                self.ammo = self.ammo - 1

                self.velocity = self.velocity + (movementDirection * -1) * (self.shipKnockackForce * dt)
            end
        end

        -- Handle overheating
        if self.shipTemperature >= self.maxShipTemperature then
            self.isOverheating = true
        end
        
        local coolingRate = self.shipCoolingRate

        if self.isOverheating == true then
            self.isBoosting = false
            coolingRate = self.shipOverheatCoolingRate
            
            if self.shipTemperature <= 0 then
                self.isOverheating = false
            end
        end

        if self.isBoosting == false then
            self.shipTemperature = self.shipTemperature - (coolingRate * dt)
        end

        self.shipTemperature = math.clamp(self.shipTemperature, 0, self.maxShipTemperature)

        -- Apply the velocity to the ship and then apply friction
        local trimmedSpeed = self.maxSpeed

        if self.isBoosting then
            trimmedSpeed = self.maxBoostingSpeed
        end

        self.velocity = self.velocity:trimmed(trimmedSpeed)
        self.position = self.position + self.velocity

        self.movementSpeed = self.movementSpeed * (self.friction * dt)
        self.velocity = self.velocity * (self.friction * dt)

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

        love.graphics.print(self.shipTemperature, 0, 0)
    end,

    setCanFire = function(self)
        self.canFire = true
    end
}

return player