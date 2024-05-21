local playerBase = require "game.objects.player.playerships.playerbase"
local playerBullet = require "game.objects.player.playerbullets.playerbullet"

local playerDefault = class{
    __includes = playerBase,
    
    -- Generic parameters of the ship
    maxHealth = 3,
    spriteName = "player heavy",

    -- Movement parameters of the ship
    steeringSpeedMoving = 5,
    steeringSpeedStationary = 10,
    steeringSpeedBoosting = 4,
    accelerationSpeed = 2,
    boostingAccelerationSpeed = 1,
    friction = 0.35,
    maxSpeed = 3,
    maxBoostingSpeed = 15,
    maxShipTemperature = 100,
    shipHeatAccumulationRate = 4,
    shipCoolingRate = 40,
    shipOverheatCoolingRate = 15,
    boostDamage = 5,
    boostEnemyHitHeatAccumulation = 35,
    contactDamageHeatAccumulation = 10,
    boostingInvulnerableGracePeriod = 1,
    invulnerableGracePeriod = 3,
    speedForContactDamage = 2,

    -- Firing parameters of the ship
    maxFireCooldown = 0.15,
    bulletSpeed = 5,
    bulletDamage = 3,
    maxAmmo = 30,
    shipKnockbackForce = 10,
    fireOffset = 10,
    bulletsToFire = 3,
    maxBulletAngle = 30,
    overheatDamageTaken = false,

    updateShipMovement = function(self, dt, movementDirection)
        -- Set the steering speed to its default value
        local steeringSpeed = self.steeringSpeedStationary

        if self.isOverheating == false then
            -- Apply a forward thrust to the ship
            if input:down("thrust") then
                self.velocity = self.velocity + movementDirection * (self.accelerationSpeed * dt)

                steeringSpeed = self.steeringSpeedMoving
            end

            -- After boosting stops, set up the timer for post boosting invulnerability
            if self.isBoosting == true and input:down("shoot") == false then
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
        if self.ammo <= 0 then
            self.canFire = false
        end

        if self.canFire == true and input:down("shoot") then
            local firePosition = self.position + ((movementDirection * -1) * self.fireOffset)

            for i = 1, self.bulletsToFire do
                local newBullet = playerBullet(firePosition.x, firePosition.y, self.bulletSpeed, (self.angle + math.pi) + math.rad(love.math.random(-self.maxBulletAngle, self.maxBulletAngle)), self.bulletDamage, colliderDefinitions.playerbullet, 8, 8)
                gamestate.current():addObject(newBullet)
            end

            self.canFire = false
            self.fireCooldown = self.maxFireCooldown
            self.ammo = self.ammo - 1

            self.isBoosting = true
            self.velocity = self.velocity + movementDirection * (self.boostingAccelerationSpeed * dt)
    
            steeringSpeed = self.steeringSpeedBoosting
    
            self.shipTemperature = self.shipTemperature + self.shipHeatAccumulationRate
        end
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
                    if self.velocity:len() > self.speedForContactDamage  then
                        if collidedObject.onHit then
                            collidedObject:onHit(self.boostDamage)

                            if collidedObject.health <= 0 and self.isBoostingInvulnerable == false then
                                self.ammo = self.maxAmmo
                                gameManager:swapPalette()
                            end
                        end
                    else
                        self:onHit(collidedObject.contactDamage)
                        collidedObject:destroy()
                    end

                    self.shipTemperature = self.shipTemperature + self.contactDamageHeatAccumulation
                end

                ::continue::
            end
        end
    end,

    update = function(self, dt)
        -- Update the hud
        self:updateHud()

        local currentGamestate = gamestate.current()
        if currentGamestate.stageDirector and currentGamestate.stageDirector.inIntro == true then
            return
        end
        
        -- Create a vector holding the direction the ship is expected to move in
        local movementDirection = vector.new(math.cos(self.angle), math.sin(self.angle))

        -- Handle ship functionality, moving boosting and firing
        self:updateShipMovement(dt, movementDirection)
        self:updateShipShooting(dt, movementDirection)
        
        -- Handle game timers
        self:updatePlayerTimers(dt)

        -- Handle overheating
        if self.isOverheating and self.overheatDamageTaken == false then
            self:onHit(1)
        end

        self.overheatDamageTaken = self.isOverheating

        self:updateOverheating(dt)

        -- Apply the velocity to the ship and then apply friction
        self:updatePosition()
        self:applyFriction(dt)

        -- Wrap the ship's position
        self:wrapShipPosition()

        -- Check collision
        self:checkCollision()
    end,
}

return playerDefault