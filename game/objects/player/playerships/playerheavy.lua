local playerBase = require "game.objects.player.playerships.playerbase"
local playerBullet = require "game.objects.player.playerbullets.playerbullet"
local playerHeavy = class({name = "Player Heavy", extends = playerBase})

function playerHeavy:new(x, y)
    self.spriteName = "player heavy"

    -- Movement parameters of the ship
    self.steeringSpeedMoving = self.steeringSpeedMoving or 1
    self.steeringSpeedStationary = self.steeringSpeedStationary or 0.5
    self.steeringSpeedBoosting = self.steeringSpeedBoosting or 0.7
    self.steeringAccelerationMoving = self.steeringAccelerationMoving or 0.6
    self.steeringAccelerationStationary = self.steeringAccelerationStationary or 0.3
    self.steeringAccelerationBoosting = self.steeringAccelerationBoosting or 0.4
    self.steeringAccelerationFiring = self.steeringAccelerationFiring or 0.5
    self.steeringFriction = 7
    self.accelerationSpeed = 3
    self.boostingAccelerationSpeed = 5
    self.friction = 0.35
    self.maxSpeed = 6
    self.maxBoostingSpeed = 15
    self.maxShipTemperature = 100
    self.shipHeatAccumulationRate = 30
    self.shipCoolingRate = 40
    self.shipOverheatCoolingRate = 20
    self.boostDamage = 5
    self.boostEnemyHitHeatAccumulation = 35
    self.contactDamageHeatAccumulation = 10
    self.invulnerableGracePeriod = 3
    self.speedForContactDamage = 2
    
    -- Firing parameters of the ship
    self.maxFireCooldown = 0.15
    self.bulletSpeed = 5
    self.bulletDamage = 3
    self.maxAmmo = 30
    self.shipKnockbackForce = 10
    self.fireOffset = 10
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
    end
end

function playerHeavy:updateShipShooting(dt, movementDirection)
    -- Fire gun
    if self.ammo <= 0 then
        self.canFire = false
    end

    if self.canFire == true and game.input:down("shoot") then
        local firePosition = self.position + ((movementDirection * -1) * self.fireOffset)

        for i = 1, self.bulletsToFire do
            local newBullet = playerBullet(
                firePosition.x,
                firePosition.y,
                self.bulletSpeed,
                (self.angle + math.pi) + math.rad(love.math.random(-self.maxBulletAngle, self.maxBulletAngle)),
                self.bulletDamage,
                colliderDefinitions.playerbullet,
                8,
                8
            )
            game.gameStateMachine:current_state():addObject(newBullet)
        end

        self:setFireCooldown()
        self:setDisplayAmmo()

        self.isBoosting = true
        self.velocity = self.velocity + movementDirection * (self.boostingAccelerationSpeed * dt)

        self.steeringAccelerationSpeed = self.steeringAccelerationBoosting
        self.maxSteeringSpeed = self.steeringSpeedBoosting

        self.shipTemperature = self.shipTemperature + self.shipHeatAccumulationRate * dt

        self.ammo = self.ammo - 1
    else
        self.isBoosting = false
    end
end

function playerHeavy:checkCollision()
    local world = game.gameStateMachine:current_state().world

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth / 2
        colliderPositionY = self.position.y - colliderHeight / 2

        local x, y, cols, len = world:check(self.collider, colliderPositionX, colliderPositionY)
        world:update(self.collider, colliderPositionX, colliderPositionY)

        for i = 1, len do
            local collidedObject = cols[i].other.owner
            local colliderDefinition = cols[i].other.colliderDefinition

            if not collidedObject or not colliderDefinition then
                goto continue
            end

            if colliderDefinition == colliderDefinitions.enemy then
                if self.velocity:length() > self.speedForContactDamage then
                    if collidedObject.onHit then
                        collidedObject:onHit(self.boostDamage)

                        if collidedObject.health <= 0 then
                            self:incrementAmmo()
                            game.manager:swapPalette()
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
end

function playerHeavy:update(dt)
    -- Update the hud
    self:updateHud()

    local currentGamestate = game.gameStateMachine:current_state()
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
    self:updatePosition()
    self.velocity = self:applyFriction(dt, self.velocity, self.friction)

    -- Wrap the ship's position
    self:wrapShipPosition()

    -- Check collision
    self:checkCollision()
end

return playerHeavy