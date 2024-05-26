local playerBase = require "game.objects.player.playerships.playerbase"
local playerLaser = require "game.objects.player.playerbullets.playerlaser"
local playerLight = class({name = "Player Light", extends = playerBase})

function playerLight:new(x, y)
    -- Generic parameters of the ship
    self.maxHealth = 3
    self.spriteName = "player light"
    
    -- Movement parameters of the ship
    self.steeringSpeedMoving = self.steeringSpeedMoving or 1.5
    self.steeringSpeedStationary = self.steeringSpeedStationary or 0.7
    self.steeringSpeedBoosting = self.steeringSpeedBoosting or 1
    self.steeringSpeedFiring = self.steeringSpeedFiring or 1
    self.steeringAccelerationMoving = self.steeringAccelerationMoving or 1
    self.steeringAccelerationStationary = self.steeringAccelerationStationary or 0.5
    self.steeringAccelerationBoosting = self.steeringAccelerationBoosting or 0.7
    self.steeringAccelerationFiring = self.steeringAccelerationFiring or 0.5
    self.steeringSpeedFiring = 4
    self.accelerationSpeed = 6
    self.boostingAccelerationSpeed = 5
    self.friction = 0.8
    self.maxSpeed = 6
    self.maxBoostingSpeed = 15
    self.maxShipTemperature = 150
    self.shipHeatAccumulationRate = 1
    self.shipCoolingRate = 40
    self.shipOverheatCoolingRate = 20
    self.boostDamage = 0
    self.boostEnemyHitHeatAccumulation = 25
    self.contactDamageHeatMultiplier = 10
    self.invulnerableGracePeriod = 3
    self.idleHeatAccumulationRate = 30
    
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
    self.steeringAccelerationSpeed = self.steeringAccelerationStationary
    self.maxSteeringSpeed = self.steeringSpeedStationary

    if self.isOverheating == false then
        if self.velocity:length() < 3 then
            self.shipTemperature = self.shipTemperature + self.idleHeatAccumulationRate * dt
        end

        -- Apply a forward thrust to the ship
        if game.input:down("thrust") then
            self.velocity = self.velocity + movementDirection * (self.accelerationSpeed * dt)

            self.steeringAccelerationSpeed = self.steeringAccelerationBoosting
            self.maxSteeringSpeed = self.steeringSpeedBoosting
        end

        -- Boost the ship
        if game.input:down("boost") then
            self.isBoosting = true
            self.velocity = self.velocity + movementDirection * (self.boostingAccelerationSpeed * dt)

            self.steeringAccelerationSpeed = self.steeringAccelerationBoosting
            self.maxSteeringSpeed = self.steeringSpeedBoosting

            self:setDisplayAmmo()
            
            self:spawnBoostLines()
        else
            self.isBoosting = false
        end
    end
end

function playerLight:updateShipShooting(dt, movementDirection)
    -- Fire gun
    if self.isBoosting == true or self.ammo <= 0 then
        self.canFire = false
    end

    if self.canFire == true and game.input:down("shoot") then
        local firePosition = self.position + (movementDirection * self.fireOffset)
        local newBullet = playerLaser(firePosition.x, firePosition.y, self.angle, self.bulletDamage, colliderDefinitions.playerbullet, self.laserBounces, playerLaser)
        gameHelper:addGameObject(newBullet)

        self.velocity = self.velocity + (movementDirection * -1) * (self.shipKnockbackForce * dt)
        
        self:setFireCooldown()
        self:setDisplayAmmo()

        self.ammo = self.ammo - 1
    end
end

function playerLight:checkCollision()
    local world = gameHelper:getWorld()

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

    local currentGamestate = gameHelper:getCurrentState()
    if currentGamestate.stageDirector and currentGamestate.stageDirector.inIntro == true then
        return
    end
    
    -- Create a vector holding the direction the ship is expected to move in
    local movementDirection = vec2(math.cos(self.angle), math.sin(self.angle))

    -- Handle ship functionality, moving boosting and firing
    self:updateShipMovement(dt, movementDirection)
    self:updateShipShooting(dt, movementDirection)
    self:updateShipSteering(dt)
    
    -- Handle game timers
    self:updatePlayerTimers(dt)

    -- Handle overheating
    self:updateOverheating(dt)

    -- Apply the velocity to the ship and then apply friction
    self:updatePosition()
    self.velocity = self:applyFriction(dt, self.velocity, self.friction)

    -- Wrap the ship's position
    self:wrapShipPosition()

    -- Check collision
    self:checkCollision()
end

return playerLight