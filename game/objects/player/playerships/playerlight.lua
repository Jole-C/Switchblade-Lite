local playerBase = require "game.objects.player.playerships.playerbase"
local playerLaser = require "game.objects.player.playerbullets.playerlaser"
local boostAmmoEffect = require "game.objects.effects.boostammorestore"
local playerLight = class({name = "Player Light", extends = playerBase})

function playerLight:new(x, y)
    -- Generic parameters of the ship
    self.maxHealth = 3
    self.spriteName = "player light"
    self.maxEnemiesForExplosion = 8
    self.boostExplosionDistance = 150
    self.maxBoostHeatDividend = 6
    
    -- Movement parameters of the ship
    self.steeringSpeedMoving = 93.75
    self.steeringSpeedStationary = 43.75
    self.steeringSpeedBoosting = 62.5
    self.steeringSpeedFiring = 250
    self.steeringAccelerationMoving = 62.5
    self.steeringAccelerationStationary = 31.25
    self.steeringAccelerationBoosting = 43.75
    self.steeringAccelerationFiring = 31.25
    self.accelerationSpeed = 375
    self.boostingAccelerationSpeed = 312.5
    self.friction = 0.8
    self.maxSpeed = 375
    self.maxBoostingSpeed = 937.5
    self.maxShipTemperature = 150
    self.shipHeatAccumulationRate = 1
    self.shipCoolingRate = 40
    self.shipOverheatCoolingRate = 60
    self.boostDamage = 1
    self.boostEnemyHitHeatAccumulation = 30
    self.contactDamageHeatMultiplier = 10
    self.invulnerableGracePeriod = 3
    self.idleHeatAccumulationRate = 15
    self.minimumSpeedForTemperature = 250
    
    -- Firing parameters of the ship
    self.maxFireCooldown = 0.1
    self.bulletSpeed = 5
    self.bulletDamage = 3
    self.maxAmmo = 30
    self.shipKnockbackForce = 50
    self.fireOffset = 10
    self.boostAmmoIncrement = 5
    
    self:super(x, y)
end

function playerLight:updateShipMovement(dt, movementDirection)
    self.steeringAccelerationSpeed = self.steeringAccelerationStationary
    self.maxSteeringSpeed = self.steeringSpeedStationary

    if self.isOverheating == false then
        -- Apply a forward thrust to the ship
        if game.input:down("thrust") then
            self.velocity = self.velocity + movementDirection * (self.accelerationSpeed * dt)

            self.steeringAccelerationSpeed = self.steeringAccelerationMoving
            self.maxSteeringSpeed = self.steeringSpeedMoving
        end

        -- Boost the ship
        if game.input:down("boost") then
            self.isBoosting = true
            self.velocity = self.velocity + movementDirection * (self.boostingAccelerationSpeed * dt)

            self.steeringAccelerationSpeed = self.steeringAccelerationBoosting
            self.maxSteeringSpeed = self.steeringSpeedBoosting

            self:setDisplayAmmo()
        
            self:spawnBoostLines()
            self:spawnTrail()

            self.ammo = self.ammo + self.boostAmmoIncrement * dt
            self.ammo = math.clamp(self.ammo, 0, self.maxAmmo)
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
        local newBullet = playerLaser(firePosition.x, firePosition.y, self.angle, self.bulletDamage, 500, 0.05)
        gameHelper:addGameObject(newBullet)

        self.velocity = self.velocity + (movementDirection * -1) * (self.shipKnockbackForce * dt)
        
        self:setFireCooldown()
        self:setDisplayAmmo()

        self.ammo = self.ammo - 1
    end
end

function playerLight:updateOverheating(dt)
    if self.shipTemperature >= self.maxShipTemperature then
        self.isOverheating = true
    end
    
    local coolingRate = self.shipCoolingRate

    if self.velocity:length() < self.minimumSpeedForTemperature then
        coolingRate = 0
    end

    if self.isOverheating == true then
        self.isBoosting = false
        coolingRate = self.shipOverheatCoolingRate
        
        if self.shipTemperature <= 0 then
            self.isOverheating = false
        end
    end

    self.shipTemperature = self.shipTemperature - (coolingRate * dt)
    self.shipTemperature = math.clamp(self.shipTemperature, 0, self.maxShipTemperature)
end

function playerLight:handleCollision(colliderHit, collidedObject, colliderDefinition)
    if colliderHit == self.collider then
        if colliderDefinition == colliderDefinitions.enemy then
            if self.isBoosting == false and collidedObject.onHit then
                self:onHit(collidedObject.contactDamage)
                collidedObject:onHit("bullet", collidedObject.health)
            end
        end
    elseif colliderHit == self.boostCollider then
        if colliderDefinition == colliderDefinitions.enemy then
            if self.isBoosting and collidedObject.onHit and collidedObject.isInvulnerable == false then
                collidedObject:onHit("boost",self.boostDamage)
                self.shipTemperature = self.shipTemperature + (self.boostEnemyHitHeatAccumulation/self.boostHeatDividend)

                if collidedObject.health <= 0 then
                    local newEffect = boostAmmoEffect(self.position.x, self.position.y)
                    gameHelper:addGameObject(newEffect)
                    game.manager:setFreezeFrames(5)

                    game.manager:swapPalette()

                    self.boostHitSound:play({pitch = 1 + (2 * (self.boostHitEnemies / self.maxEnemiesForExplosion))})

                    self:handleBoostHeatDividend()
                    self:handleBoostExplosion()
                end
            end
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

    -- Build temperature if the ship is still
    if self.velocity:length() < self.minimumSpeedForTemperature and self.isOverheating == false then
        self.shipTemperature = self.shipTemperature + (self.idleHeatAccumulationRate * dt)
    end
    
    -- Handle game timers
    self:updatePlayerTimers(dt)

    -- Handle overheating
    self:updateOverheating(dt)

    -- Apply the velocity to the ship and then apply friction
    self:updatePosition(dt)

    -- Wrap the ship's position
    self:wrapShipPosition()

    -- Check collision
    self:checkCollision()
end

return playerLight