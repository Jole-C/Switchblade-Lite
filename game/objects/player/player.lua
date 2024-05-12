local gameobject = require "game.objects.gameobject"
local playerBullet = require "game.objects.player.playerbullet"
local collider = require "game.collision.collider"

local player = class{
    __includes = gameobject,
    
    -- Generic parameters of the ship
    maxHealth = 3,

    -- Movement parameters of the ship
    steeringSpeedMoving = 6,
    steeringSpeedStationary = 14,
    steeringSpeedBoosting = 3,
    accelerationSpeed = 3,
    boostingAccelerationSpeed = 4,
    friction = 1,
    maxSpeed = 3,
    maxBoostingSpeed = 6,
    maxShipTemperature = 100,
    shipHeatAccumulationRate = 1,
    shipCoolingRate = 40,
    shipOverheatCoolingRate = 20,
    boostDamage = 5,
    boostEnemyHitHeatAccumulation = 25,
    contactDamageHeatMultiplier = 10,
    boostingInvulnerableGracePeriod = 1,
    invulnerableGracePeriod = 3,

    -- Firing parameters of the ship
    fireCooldown = 0.05,
    bulletSpeed = 5,
    bulletDamage = 3,
    maxAmmo = 30,
    shipKnockbackForce = 10,

    -- Ship variables
    health = 3,
    angle = 0,
    velocity,
    isBoosting = false,
    isOverheating = false,
    shipTemperature = 0,
    fireResetTimer,
    ammo = 0,
    canFire = true,
    boostingGraceTimer,
    invulnerableTimer,
    isInvulnerable = false,
    isBoostingInvulnerable = false,
    
    -- Ship components
    collider,
    sprite,

    init = function(self, x, y)
        gameobject.init(self, x, y)

        self.velocity = vector.new(0, 0)
        self.health = self.maxHealth
        self.ammo = self.maxAmmo

        self.sprite = resourceManager:getResource("player sprite")
        self.sprite:setFilter("nearest")

        self.collider = collider(colliderDefinitions.player, self)
        gamestate.current().world:add(self.collider, 0, 0, 10, 10)
    end,

    update = function(self, dt)
        -- Create a vector holding the direction the ship is expected to move in
        local movementDirection = vector.new(math.cos(self.angle), math.sin(self.angle))
        
        -- Set the steering speed to its default value
        local steeringSpeed = self.steeringSpeedStationary

        -- Handle ship functionality, moving boosting and firing
        if self.isOverheating == false then
            -- Apply a forward thrust to the ship
            if input:down("thrust") then
                self.velocity = self.velocity + movementDirection * (self.accelerationSpeed * dt)

                steeringSpeed = self.steeringSpeedMoving
            end

            -- Boost the ship
            if input:down("boost") then
                self.isBoosting = true
                self.velocity = self.velocity + movementDirection * (self.boostingAccelerationSpeed * dt)

                steeringSpeed = self.steeringSpeedBoosting

                self.shipTemperature = self.shipTemperature + self.shipHeatAccumulationRate
            end

            -- After boosting stops, set up the timer for post boosting invulnerability
            if self.isBoosting == true and input:down("boost") == false then
                self.isBoosting = false

                self.isBoostingInvulnerable = true
                self.boostingGraceTimer = timer.after(self.boostingInvulnerableGracePeriod, function() self:setBoostingVulnerable() end)
            end

            -- Steer the ship
            if input:down("steerLeft") then
                self.angle = self.angle - (steeringSpeed * dt)
            end

            if input:down("steerRight") then
                self.angle = self.angle + (steeringSpeed * dt)
            end

            -- Fire gun
            if self.canFire == true and input:down("shoot") and self.ammo > 0 and self.isBoosting == false then
                local newBullet = playerBullet(self.position.x, self.position.y, self.bulletSpeed, self.angle, self.bulletDamage, 5, colliderDefinitions.player, 8, 8)
                gamestate.current():addObject(newBullet)
    
                self.canFire = false
                self.fireResetTimer = timer.after(self.fireCooldown, function() self:setCanFire() end)
                self.ammo = self.ammo - 1

                self.velocity = self.velocity + (movementDirection * -1) * (self.shipKnockbackForce * dt)
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

        local frictionRatio = 1 / (1 + (dt * self.friction))
        self.velocity = self.velocity * frictionRatio

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

        if world and world:hasItem(self.collider) then
            local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
            colliderPositionX = self.position.x - colliderWidth/2
            colliderPositionY = self.position.y - colliderHeight/2
    
            local x, y, cols, len = world:check(self.collider, colliderPositionX, colliderPositionY)
            world:update(self.collider, colliderPositionX, colliderPositionY)
    
            for i = 1, len do
                local collidedObject = cols[i].other.owner
                local colliderDefinition = cols[i].other.colliderDefinition
    
                if not collidedObject or not colliderDefinition then
                    goto continue
                end
    
                if colliderDefinition == colliderDefinitions.enemy then
                    if self.isBoosting == true  then
                        if collidedObject.onHit then
                            collidedObject:onHit(self.boostDamage)
                            self.shipTemperature = self.shipTemperature + self.boostEnemyHitHeatAccumulation

                            if collidedObject.health <= 0 and self.isBoostingInvulnerable == false then
                                self.ammo = self.maxAmmo
                                gameManager:swapPalette()
                            end
                        end
                    else
                        self:onHit(collidedObject.contactDamage)
                        collidedObject:destroy()
                    end
                end
    
                ::continue::
            end
        end
    end,

    draw = function(self)
        local xOffset, yOffset = self.sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2
        
        love.graphics.setColor(gameManager.currentPalette.playerColour)
        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
        love.graphics.print("temperature: "..math.floor(self.shipTemperature).."hp: "..self.health.."ammo: "..self.ammo, 0, 0)
        love.graphics.setColor(1, 1, 1, 1)

        if self.isBoostingInvulnerable then
            love.graphics.print("is boosting invulnerable", 50, 50)
        end
    end,

    setCanFire = function(self)
        self.canFire = true
    end,

    setBoostingVulnerable = function(self)
        self.isBoostingInvulnerable = false
    end,

    setVulnerable = function(self)
        self.isInvulnerable = false
    end,

    onHit = function(self, damage)
        if self.isInvulnerable or self.isBoostingInvulnerable then
            return
        end

        self.health = self.health - damage
        self.shipTemperature = self.shipTemperature + (self.contactDamageHeatMultiplier * damage)

        self.isInvulnerable = true
        self.invulnerableTimer = timer.after(self.invulnerableGracePeriod, function() self:setVulnerable() end)

        if self.health <= 0 then
            self:destroy()
        end
    end,

    cleanup = function(self)
        if gamestate.current().world then
            gamestate.current().world:remove(self.collider)
        end

        if self.boostingGraceTimer then
            timer.cancel(self.boostingGraceTimer)
        end

        if self.invulnerableTimer then
            timer.cancel(self.invulnerableTimer)
        end
    end
}

return player