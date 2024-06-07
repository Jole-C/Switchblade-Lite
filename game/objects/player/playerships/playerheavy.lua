local playerBase = require "game.objects.player.playerships.playerbase"
local playerBullet = require "game.objects.player.playerbullets.playerbullet"
local trailEffect = require "game.objects.effects.playertrail"
local boostAmmoEffect = require "game.objects.effects.boostammorestore"
local playerHeavy = class({name = "Player Heavy", extends = playerBase})

function playerHeavy:new(x, y)
    self.spriteName = "player heavy"
    self.maxEnemiesForExplosion = 3
    self.boostExplosionDistance = 50
    self.maxBoostHeatDividend = 3

    -- Movement parameters of the ship
    self.steeringSpeedMoving = 62.5
    self.steeringSpeedStationary = 31.25
    self.steeringSpeedBoosting = 43.75
    self.steeringAccelerationMoving = 37.5
    self.steeringAccelerationStationary = 18.75
    self.steeringAccelerationBoosting = 25
    self.steeringAccelerationFiring = 31.25
    self.steeringFriction = 7
    self.accelerationSpeed = 187.5
    self.boostingAccelerationSpeed = 937.5
    self.friction = 0.35
    self.maxSpeed = 375
    self.maxBoostingSpeed = 937.5
    self.maxShipTemperature = 100
    self.shipHeatAccumulationRate = 250
    self.shipCoolingRate = 40
    self.shipOverheatCoolingRate = 20
    self.boostDamage = 5
    self.invulnerableGracePeriod = 3
    self.speedForContactDamage = 125
    self.boostEnemyHitHeatAccumulation = 10
    self.contactDamageHeatMultiplier = 30
    
    -- Firing parameters of the ship
    self.maxFireCooldown = 0.15
    self.bulletSpeed = 5
    self.bulletDamage = 0.5
    self.maxAmmo = 30
    self.shipKnockbackForce = 10
    self.fireOffset = 40
    self.bulletsToFire = 3
    self.maxBulletAngle = 30
    self.overheatDamageTaken = false

    self:super(x, y)
end

function playerHeavy:updateShipMovement(dt, movementDirection)
    self.steeringAccelerationSpeed = self.steeringAccelerationStationary
    self.maxSteeringSpeed = self.steeringSpeedStationary

    if self.isOverheating == false then
        -- Apply a forward thrust to the ship
        if game.input:down("thrust") then
            self.velocity = self.velocity + movementDirection * (self.accelerationSpeed * dt)

            self.steeringAccelerationSpeed = self.steeringAccelerationMoving
            self.maxSteeringSpeed = self.steeringSpeedMoving
        end

        if self.velocity:length() > self.speedForContactDamage then
            self:spawnBoostLines()
            self:spawnTrail()
        end
    end
end

function playerHeavy:updateShipShooting(dt, movementDirection)
    if game.input:down("shoot") and self.ammo > 0 then

        self.isBoosting = true

        if self.canFire then
            local firePosition = self.position + ((movementDirection * -1) * self.fireOffset)
    
            for i = 1, self.bulletsToFire do
                local newBullet = playerBullet(
                    firePosition.x,
                    firePosition.y,
                    self.bulletSpeed,
                    (self.angle + math.pi) + math.rad(love.math.random(-self.maxBulletAngle, self.maxBulletAngle)),
                    self.bulletDamage,
                    colliderDefinitions.playerbullet,
                    16,
                    16
                )
                gameHelper:addGameObject(newBullet)
            end
    
            self.velocity = self.velocity + movementDirection * (self.boostingAccelerationSpeed * dt)
    
            self.steeringAccelerationSpeed = self.steeringAccelerationBoosting
            self.maxSteeringSpeed = self.steeringSpeedBoosting
    
            self.shipTemperature = self.shipTemperature + (self.shipHeatAccumulationRate * dt)
    
            self.ammo = self.ammo - 1
    
            self:setFireCooldown()
            self:setDisplayAmmo()
        end
    else
        self.isBoosting = false
    end
end

function playerHeavy:spawnTrail()
    local newTrailSegment
    local x = self.position.x + math.cos(self.angle) * -10
    local y = self.position.y + math.sin(self.angle) * -10

    if self.velocity:length() > 0 then
        if self.isBoosting == true or self.velocity:length() > self.speedForContactDamage then
            newTrailSegment = trailEffect(x, y, 10, self.velocity:length()/2, math.pi + self.velocity:angle())
        else
            newTrailSegment = trailEffect(x, y, 3)
        end
    end

    if newTrailSegment then
        gameHelper:addGameObject(newTrailSegment)
    end
end

function playerHeavy:handleCollision(colliderHit, collidedObject, colliderDefinition)
    if colliderHit == self.collider then
        if colliderDefinition == colliderDefinitions.enemy then
            if self.velocity:length() < self.speedForContactDamage and collidedObject.onHit then
                self:onHit(collidedObject.contactDamage)
                collidedObject:onHit("bullet", collidedObject.health)
            end
        end
    elseif colliderHit == self.boostCollider then
        if colliderDefinition == colliderDefinitions.enemy then
            if (self.isBoosting or self.velocity:length() > self.speedForContactDamage) and collidedObject.onHit then
                collidedObject:onHit("boost", self.boostDamage)
                self.shipTemperature = self.shipTemperature + (self.boostEnemyHitHeatAccumulation/self.boostHeatDividend)

                if collidedObject.health <= 0 then
                    self:incrementAmmo()

                    if self.isBoosting == true then
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
end

function playerHeavy:update(dt)
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
    if self.isOverheating and self.overheatDamageTaken == false then
        self:onHit(1)
    end

    self.overheatDamageTaken = self.isOverheating

    self:updateOverheating(dt)

    -- Apply the velocity to the ship and then apply friction
    self:updatePosition(dt)

    -- Wrap the ship's position
    self:wrapShipPosition()

    -- Check collision
    self:checkCollision()
end

return playerHeavy