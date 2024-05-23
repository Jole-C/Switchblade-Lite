local playerBase = require "game.objects.player.playerships.playerbase"
local playerLaser = require "game.objects.player.playerbullets.playerlaser"
local playerLight = class({name = "Player Light", extends = playerBase})

function playerLight:new(x, y)
    -- Generic parameters of the ship
    self.maxHealth = 3
    self.spriteName = "player light"
    
    -- Movement parameters of the ship
    self.steeringSpeedMoving = 8
    self.steeringSpeedStationary = 16
    self.steeringSpeedBoosting = 4
    self.accelerationSpeed = 4
    self.boostingAccelerationSpeed = 84
    self.friction = 0.8
    self.maxSpeed = 3
    self.maxBoostingSpeed = 6
    self.maxShipTemperature = 100
    self.shipHeatAccumulationRate = 0.5
    self.shipCoolingRate = 40
    self.shipOverheatCoolingRate = 20
    self.boostDamage = 5
    self.boostEnemyHitHeatAccumulation = 25
    self.contactDamageHeatMultiplier = 10
    self.boostingInvulnerableGracePeriod = 1
    self.invulnerableGracePeriod = 3
    
    -- Firing parameters of the ship
    self.maxFireCooldown = 0.1
    self.bulletSpeed = 5
    self.bulletDamage = 3
    self.maxAmmo = 70
    self.shipKnockbackForce = 50
    self.fireOffset = 10
    self.ammoAccumulationRate = 3
    self.laserBounces = 3
    
    self:super(x, y)
end

function playerLight:updateShipMovement(dt, movementDirection)
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

            self.ammo = self.ammo + self.ammoAccumulationRate * dt
            self.ammo = math.clamp(self.ammo, 0, self.maxAmmo)
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
end

function playerLight:updateShipShooting(dt, movementDirection)
    -- Fire gun
    if self.isBoosting == true or self.ammo <= 0 then
        self.canFire = false
    end

    if self.canFire == true and input:down("shoot") then
        local firePosition = self.position + (movementDirection * self.fireOffset)
        local newBullet = playerLaser(firePosition.x, firePosition.y, self.angle, self.bulletDamage, colliderDefinitions.playerbullet, self.laserBounces, playerLaser)
        gameStateMachine:current_state():addObject(newBullet)

        self.velocity = self.velocity + (movementDirection * -1) * (self.shipKnockbackForce * dt)
        
        self.canFire = false
        self.fireCooldown = self.maxFireCooldown

        self.ammo = self.ammo - 1
    end
end

function playerLight:checkCollision()
    local world = gameStateMachine:current_state().world

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
                if collidedObject.onHit then
                    collidedObject:onHit(self.boostDamage)
                    self.shipTemperature = self.shipTemperature + self.boostEnemyHitHeatAccumulation

                    self:onHit(collidedObject.contactDamage)
                end
            end

            ::continue::
        end
    end
end

function playerLight:update(dt)
    -- Update the hud
    self:updateHud()

    local currentGamestate = gameStateMachine:current_state()
    if currentGamestate.stageDirector and currentGamestate.stageDirector.inIntro == true then
        return
    end
    
    -- Create a vector holding the direction the ship is expected to move in
    local movementDirection = vec2(math.cos(self.angle), math.sin(self.angle))

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
end

return playerLight