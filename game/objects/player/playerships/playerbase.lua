local gameobject = require "game.objects.gameobject"
local playerBullet = require "game.objects.player.playerbullets.playerbullet"
local collider = require "game.collision.collider"
local playerHud = require "game.objects.player.playerhuddisplay"

local player = class{
    __includes = gameobject,
    
    -- Generic parameters of the ship
    maxHealth = 3,
    spriteName = "player default",

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
    maxFireCooldown = 0.05,
    bulletSpeed = 5,
    bulletDamage = 3,
    maxAmmo = 30,
    shipKnockbackForce = 10,
    fireOffset = 10,

    -- Ship variables
    health = 3,
    angle = 0,
    velocity = {},
    isBoosting = false,
    isOverheating = false,
    shipTemperature = 0,
    ammo = 0,
    boostingInvulnerabilityCooldown = 0,
    invulnerabilityCooldown = 0,
    fireCooldown = 0,
    isBoostingInvulnerable = false,
    isInvulnerable = false,
    canFire = true,
    
    -- Ship components
    collider,
    sprite,
    hud,

    init = function(self, x, y)
        gameobject.init(self, x, y)

        -- Initialise variables to their parameters, or create vectors
        self.velocity = vector.new(0, 0)
        self.health = self.maxHealth
        self.ammo = self.maxAmmo
        self.fireCooldown = self.maxFireCooldown
        self.boostingInvulnerabilityCooldown = self.boostingInvulnerableGracePeriod
        self.invulnerabilityCooldown = self.invulnerableGracePeriod

        -- Set up components
        self.sprite = resourceManager:getResource(self.spriteName)
        self.sprite:setFilter("nearest")

        self.collider = collider(colliderDefinitions.player, self)
        gamestate.current().world:add(self.collider, 0, 0, 10, 10)

        self.hud = playerHud()
        interfaceRenderer:addHudElement(self.hud)
    end,

    updateHud = function(self)
        if self.hud then
            self.hud:update()
        end
    end,

    updateShipMovement = function(self, dt, movementDirection)
        -- Set the steering speed to its default value
        local steeringSpeed = self.steeringSpeedStationary

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
                self.boostingInvulnerabilityCooldown = self.boostingInvulnerableGracePeriod
            end

            -- Steer the ship
            if input:down("steerLeft") then
                self.angle = self.angle - (steeringSpeed * dt)
            end

            if input:down("steerRight") then
                self.angle = self.angle + (steeringSpeed * dt)
            end
        end
    end,

    updateShipShooting = function(self, dt, movementDirection)
        -- Fire gun
        if self.isBoosting == true or self.ammo <= 0 then
            self.canFire = false
        end

        if self.canFire == true and input:down("shoot") then
            local firePosition = self.position + (movementDirection * self.fireOffset)
            local newBullet = playerBullet(firePosition.x, firePosition.y, self.bulletSpeed, self.angle, self.bulletDamage, colliderDefinitions.playerbullet, 8, 8)
            gamestate.current():addObject(newBullet)

            self.velocity = self.velocity + (movementDirection * -1) * (self.shipKnockbackForce * dt)
            
            self.canFire = false
            self.fireCooldown = self.maxFireCooldown
            self.ammo = self.ammo - 1
        end
    end,

    updatePlayerTimers = function(self, dt)
        self.fireCooldown = self.fireCooldown - 1 * dt
        self.invulnerabilityCooldown = self.invulnerabilityCooldown - 1 * dt
        self.boostingInvulnerabilityCooldown = self.boostingInvulnerabilityCooldown - 1 * dt

        if self.invulnerabilityCooldown <= 0 then
            self.isInvulnerable = false
        end

        if self.fireCooldown <= 0 then
            self.canFire = true
        end

        if self.boostingInvulnerabilityCooldown <= 0 then
            self.isBoostingInvulnerable = false
        end
    end,

    updateOverheating = function(self, dt)
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
    end,

    updatePosition = function(self)
        local trimmedSpeed = self.maxSpeed

        if self.isBoosting then
            trimmedSpeed = self.maxBoostingSpeed
        end

        self.velocity = self.velocity:trimmed(trimmedSpeed)
        self.position = self.position + self.velocity
    end,

    checkCollision = function(self)
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

    applyFriction = function(self, dt)
        local frictionRatio = 1 / (1 + (dt * self.friction))
        self.velocity = self.velocity * frictionRatio
    end,

    wrapShipPosition = function(self)
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
    end,

    update = function(self, dt)
        -- Update the hud
        self:updateHud()
        
        -- Create a vector holding the direction the ship is expected to move in
        local movementDirection = vector.new(math.cos(self.angle), math.sin(self.angle))

        -- Handle ship functionality, moving boosting and firing
        self:updateShipMovement(dt, movementDirection)
        self:updateShipShooting(dt, movementDirection)
        
        -- Handle game timers
        self:updatePlayerTimers(dt)

        -- Handle overheating
        self:updateOverheating(dt)

        -- Apply the velocity to the ship and then apply friction
        self:updatePosition()
        self:applyFriction(dt)

        -- Wrap the ship's position
        self:wrapShipPosition()

        -- Check collision
        self:checkCollision()
    end,

    draw = function(self)
        if not self.sprite then
            return
        end

        local xOffset, yOffset = self.sprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2
        
        love.graphics.setColor(gameManager.currentPalette.playerColour)
        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
        love.graphics.setColor(1, 1, 1, 1)
    end,

    onHit = function(self, damage)
        if self.isInvulnerable or self.isBoostingInvulnerable then
            return
        end

        self.health = self.health - damage
        self.shipTemperature = self.shipTemperature + (self.contactDamageHeatMultiplier * damage)

        self.isInvulnerable = true
        self.invulnerabilityCooldown = self.invulnerableGracePeriod

        if self.health <= 0 then
            self:destroy()
        end
    end,

    cleanup = function(self)
        local world = gamestate.current().world
        if world and world:hasItem(self.collider) then
            gamestate.current().world:remove(self.collider)
        end
    end
}

return player