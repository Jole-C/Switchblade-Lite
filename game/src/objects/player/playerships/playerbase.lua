local gameObject = require "src.objects.gameobject"
local collider = require "src.collision.collider"

local playerBullet = require "src.objects.player.playerbullets.playerbullet"
local playerExplosion = require "src.objects.player.playerbullets.playerexplosion"

local ammoDisplay = require "src.objects.player.playerammodisplay"
local healthDisplay = require "src.objects.player.playerhealthdisplay"
local temperatureDisplay = require "src.objects.player.playertemperaturedisplay"

local boostAmmoEffect = require "src.objects.effects.boostammorestore"
local boostLineEffect = require "src.objects.effects.boostline"
local trailEffect = require "src.objects.effects.playertrail"
local gameoverEffect = require "src.objects.player.playergameovereffect"

local cameraTarget = require "src.objects.camera.cameratarget"

local player = class({name = "Player", extends = gameObject})

function player:new(x, y)
    self:super(x, y)

    -- Generic parameters of the ship
    self.maxHealth = 5
    self.maxHealthRechargeCooldown = 2
    self.healthCircleRadius = 200 * game.manager:getOption("playerHealthRingSizePercentage") / 100
    self.maxOverheatPlayRate = 0.5
    self.maxEnemiesForExplosion = self.maxEnemiesForExplosion or 5
    self.boostExplosionDistance = self.boostExplosionDistance or 65
    self.maxBoostHeatDividend = self.maxBoostHeatDividend or 5
    self.invulnerableGracePeriod = self.invulnerableGracePeriod or 0.5
    
    -- Movement parameters of the ship
    self.steeringSpeedMoving = self.steeringSpeedMoving or 60
    self.steeringSpeedStationary = self.steeringSpeedStationary or 140
    self.steeringSpeedBoosting = self.steeringSpeedBoosting or 30
    self.steeringSpeedFiring = self.steeringSpeedFiring or 30
    self.steeringAccelerationMoving = self.steeringAccelerationMoving or 30
    self.steeringAccelerationStationary = self.steeringAccelerationStationary or 60
    self.steeringAccelerationBoosting = self.steeringAccelerationBoosting or 20
    self.steeringAccelerationFiring = self.steeringAccelerationFiring or 20
    self.steeringFriction = self.steeringFriction or 7
    self.accelerationSpeed = self.accelerationSpeed or 30
    self.boostingAccelerationSpeed = self.boostingAccelerationSpeed or 40
    self.friction = self.friction or 1
    self.maxSpeed = self.maxSpeed or 30
    self.maxBoostingSpeed = self.maxBoostingSpeed or 60
    self.maxShipTemperature = self.maxShipTemperature or 100
    self.shipHeatAccumulationRate = self.shipHeatAccumulationRate or 5
    self.shipCoolingRate = self.shipCoolingRate or 40
    self.shipOverheatCoolingRate = self.shipOverheatCoolingRate or 20
    self.boostDamage = self.boostDamage or 3
    self.boostEnemyHitHeatAccumulation = self.boostEnemyHitHeatAccumulation or 25
    self.maxBoostGracePeriod = 0.3
    self.contactDamageHeatMultiplier = self.contactDamageHeatMultiplier or 10
    self.bounceDampening = self.bounceDampening or 0.5
    self.boostLineCount = 5
    self.boostLineSpawnRange = 500
    
    -- Firing parameters of the ship
    self.maxFireCooldown = self.maxFireCooldown or 0.05
    self.bulletSpeed = self.bulletSpeed or 312
    self.bulletDamage = self.bulletDamage or 3
    self.maxAmmo = self.maxAmmo or 30
    self.shipKnockbackForce = self.shipKnockbackForce or 10
    self.fireOffset = self.fireOffset or 10
    self.boostAmmoIncrement = self.boostAmmoIncrement or 5
    self.isShooting = false
    self.boostGracePeriod = self.maxBoostGracePeriod
    
    -- Ship variables
    self.health = self.maxHealth
    self.angle = 0
    self.velocity = vec2(0, 0)
    self.isBoosting = false
    self.isOverheating = false
    self.shipTemperature = 0
    self.ammo = self.maxAmmo
    self.invulnerabilityCooldown = self.invulnerableGracePeriod
    self.fireCooldown = self.maxFireCooldown
    self.isInvulnerable = false
    self.canFire = true
    self.steeringSpeed = 0
    self.maxSteeringSpeed = self.steeringSpeedStationary
    self.steeringAccelerationSpeed = self.steeringAccelerationStationary
    self.displayAmmo = false
    self.overheatPlayCooldown = 0
    self.boostHeatDividend = 1
    self.boostHitEnemies = 0
    self.healthRechargeCooldown = self.maxHealthRechargeCooldown
    
    -- Ship components
    self.collider = collider(colliderDefinitions.player, self)
    gameHelper:addCollider(self.collider, 0, 0, 10, 10)

    self.boostCollider = collider(colliderDefinitions.none, self)
    gameHelper:addCollider(self.boostCollider, 0, 0, 32, 32)

    self.ammoDisplay = ammoDisplay(0, 0)
    gameHelper:addGameObject(self.ammoDisplay)

    self.temperatureDisplay = temperatureDisplay(0, 0)
    gameHelper:addGameObject(self.temperatureDisplay)

    if game.manager:getOption("showPlayerHealth") then
        self.healthDisplay = healthDisplay(0, 0)
        gameHelper:addGameObject(self.healthDisplay)
    end

    local assets = game.resourceManager:getAsset("Player Assets")
    self.sprite = assets:get("sprites"):get("playerSprite")
    self.outlineShader = game.resourceManager:getAsset("Enemy Assets"):get("enemyOutlineShader")
    self.fireSound = assets:get("sounds"):get("fire")
    self.boostSound = assets:get("sounds"):get("boost")
    self.boostFailSound = assets:get("sounds"):get("boostFail")
    self.hurtSound = assets:get("sounds"):get("shipHurt")
    self.overheatWarningSound = assets:get("sounds"):get("overheatWarning")
    self.overheatSound = assets:get("sounds"):get("shipOverheat")
    self.boostHitSound = assets:get("sounds"):get("boostHit")
    self.wallHitSound = assets:get("sounds"):get("wallHit")

    self.cameraTarget = cameraTarget(self.position, 100)
    gameHelper:getCurrentState().cameraManager:addTarget(self.cameraTarget)
end

function player:updateShipMovement(dt, movementDirection)
    self.steeringAccelerationSpeed = self.steeringAccelerationStationary
    self.maxSteeringSpeed = self.steeringSpeedStationary

    if self.isOverheating == false then
        if game.input:down("thrust") then
            self.velocity = self.velocity + movementDirection * (self.accelerationSpeed * dt)

            self.steeringAccelerationSpeed = self.steeringAccelerationMoving
            self.maxSteeringSpeed = self.steeringSpeedMoving
        end

        if game.input:pressed("reverseThrust") then
            self.angle = self.angle + math.pi
            self.velocity = self.velocity * 0.7
        end

        if game.input:down("boost") and game.input:down("thrust") then
            self.isBoosting = true
            self.boostGracePeriod = self.maxBoostGracePeriod
            self.velocity = self.velocity + movementDirection * (self.boostingAccelerationSpeed * dt)

            self.steeringAccelerationSpeed = self.steeringAccelerationBoosting
            self.maxSteeringSpeed = self.steeringSpeedBoosting

            self.shipTemperature = self.shipTemperature + self.shipHeatAccumulationRate * dt
            self:spawnBoostLines()
        end

        if game.input:pressed("boost") and not game.input:down("thrust") then
            gameHelper:screenShake(0.1)
            self.isBoosting = true
            self:spawnTrail()
            self.isBoosting = false
            self.boostFailSound:play()
        end

        if game.input:pressed("boost") and game.input:down("thrust") then
            self.boostSound:play()
        end
    end
end

function player:updateShipSteering(dt)
    if self.isOverheating == false then
        if game.input:down("steerLeft") then
            self.steeringSpeed = self.steeringSpeed - (self.steeringAccelerationSpeed * dt)
        end

        if game.input:down("steerRight") then
            self.steeringSpeed = self.steeringSpeed + (self.steeringAccelerationSpeed * dt)
        end
    end

    self.steeringSpeed = math.clamp(self.steeringSpeed, -self.maxSteeringSpeed, self.maxSteeringSpeed)
    self.angle = self.angle + (self.steeringSpeed * dt)
    self.steeringSpeed = self:applyFriction(dt, self.steeringSpeed, self.steeringFriction)
end

function player:updateShipShooting(dt, movementDirection)
    self.ammoDisplay.ammo = self.ammo

    if (self.isBoosting and self.boostGracePeriod <= 0) or self.ammo <= 0 or self.isOverheating then
        self.canFire = false
    end

    if game.input:down("shoot") then
        self.steeringAccelerationSpeed = self.steeringAccelerationFiring
        self.maxSteeringSpeed = self.steeringSpeedFiring
    end

    if self.canFire == true and game.input:down("shoot") then
        local firePosition = self.position + (movementDirection * self.fireOffset)
        local newBullet = playerBullet(firePosition.x, firePosition.y, self.bulletSpeed, self.angle, self.bulletDamage, colliderDefinitions.playerbullet, 16, 16)
        gameHelper:addGameObject(newBullet)

        self.velocity = self.velocity + (movementDirection * -1) * (self.shipKnockbackForce * dt)

        self:setFireCooldown()
        self.ammoDisplay:setDisplayAmmo()

        self.fireSound:play({pitch = 1 + (2 * (1 - (self.ammo / self.maxAmmo)))})
        gameHelper:screenShake(0.05)
        
        self.ammo = self.ammo - 1
        self.isShooting = true
    else
        self.isShooting = false
    end
end

function player:updatePlayerTimers(dt)
    self.fireCooldown = self.fireCooldown - 1 * dt
    self.invulnerabilityCooldown = self.invulnerabilityCooldown - 1 * dt
    self.boostGracePeriod = self.boostGracePeriod - 1 * dt

    if self.invulnerabilityCooldown <= 0 then
        self.isInvulnerable = false
    end

    if self.fireCooldown <= 0 then
        self.canFire = true
    end

    if self.boostGracePeriod <= 0 then
        self.isBoosting = false
    end
end

function player:playOverheatSound(dt)
    if self.shipTemperature > self.temperatureForWarning and self.isOverheating == false then
        self.overheatPlayCooldown = self.overheatPlayCooldown - (1 * dt)

        if self.overheatPlayCooldown <= 0 then
            self.overheatWarningSound:play()

            if self.maxShipTemperature < 0.75 then
                self.overheatPlayCooldown = self.maxOverheatPlayRate
            else
                self.overheatPlayCooldown = self.maxOverheatPlayRate/2
            end
        end

        if self.shipTemperature > self.maxShipTemperature then
            self.overheatSound:play()
            game.particleManager:burstEffect("Explosion Burst", 15, self.position)
            gameHelper:screenShake(0.2)
        end

        local randomAngle = math.rad(math.random(0, 360))
        local offsetVector = vec2(math.cos(randomAngle), math.sin(randomAngle))
        local length = math.random(0, 30)
        game.particleManager:burstEffect("Player Smoke", 30, self.position + (offsetVector * length))
    end
end

function player:updateOverheating(dt)
    self:playOverheatSound(dt)

    if self.shipTemperature >= self.maxShipTemperature then
        self.isBoosting = false

        if self.isOverheating == false then
            self:onHit(2)
        end

        self.isOverheating = true
    end

    local coolingRate = self.shipCoolingRate

    if self.isOverheating == true then
        self.isBoosting = false
        coolingRate = self.shipOverheatCoolingRate
        
        if self.shipTemperature <= 0 then
            self.isOverheating = false
        end

        game.particleManager:burstEffect("Player Smoke", 5, self.position)
    end

    if self.isBoosting == false then
        self.shipTemperature = self.shipTemperature - (coolingRate * dt)
        self.boostHeatDividend = 1
        self.boostHitEnemies = 0
    end

    self.shipTemperature = math.clamp(self.shipTemperature, 0, self.maxShipTemperature)

    self.temperatureDisplay.temperature = self.shipTemperature
    self.temperatureDisplay.maxTemperature = self.maxShipTemperature
end

function player:spawnTrail()
    if self.isOverheating == true then
        return
    end

    local newTrailSegment
    local angle = self.angle + math.pi + math.rad(math.random(-15, 15))
    local x = self.position.x + math.cos(angle) * 10
    local y = self.position.y + math.sin(angle) * 10

    if self.isBoosting == true then
        newTrailSegment = trailEffect(x, y, 10, self.velocity:length()/2, angle)
    else
        newTrailSegment = trailEffect(x, y, 3, self.velocity:length()/2, angle)
    end

    if newTrailSegment then
        gameHelper:addGameObject(newTrailSegment)
    end
end

function player:accumulateTemperature(dt, multiplier)
    self.shipTemperature = self.shipTemperature + self.shipHeatAccumulationRate * multiplier * dt
end

function player:updatePosition(dt)
    local arena = gameHelper:getCurrentState().arena

    if not arena then
        return
    end

    if game.input:down("boost") or game.input:down("thrust") then
        self:spawnTrail()
    end

    local trimmedSpeed = self.maxSpeed

    if self.isBoosting then
        trimmedSpeed = self.maxBoostingSpeed
    end

    self.velocity = self.velocity:trim_length_inplace(trimmedSpeed)

    if arena:isPositionWithinArena(self.position + self.velocity * dt) == false then
        local segment = arena:getSegmentPointIsWithin(self.position)
        
        if segment then
            local normal = (segment.position - self.position):normalise_inplace()
            local playerNormal = vec2(math.cos(self.angle), math.sin(self.angle))
            
            if playerNormal:dot(normal) < 0 then
                self.angle = normal:angle()
            end

            self.velocity = (self.velocity - (2 * self.velocity:dot(normal) * normal)) * self.bounceDampening
            self.wallHitSound:play()
        end
    end

    self.position = self.position + (self.velocity * dt)
    self.position = arena:getClampedPosition(self.position)

    self.velocity = self:applyFriction(dt, self.velocity, self.friction)

    self.cameraTarget.position = self.position
    self.ammoDisplay.position = self.position
    self.temperatureDisplay.position = self.position

    if self.healthDisplay then
        self.healthDisplay.position = self.position
    end
end

function player:checkCollision()
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

            self:handleCollision(self.collider, collidedObject, colliderDefinition)

            ::continue::
        end
    end

    if world and world:hasItem(self.boostCollider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.boostCollider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2

        local x, y, cols, len = world:check(self.boostCollider, colliderPositionX, colliderPositionY)
        world:update(self.boostCollider, colliderPositionX, colliderPositionY)

        for i = 1, len do
            local collidedObject = cols[i].other.owner
            local colliderDefinition = cols[i].other.colliderDefinition

            if not collidedObject or not colliderDefinition then
                goto continue
            end

            self:handleCollision(self.boostCollider, collidedObject, colliderDefinition)

            ::continue::
        end
    end
end

function player:handleCollision(colliderHit, collidedObject, colliderDefinition)
    if colliderHit == self.collider then
        
    elseif colliderHit == self.boostCollider then
        if colliderDefinition == colliderDefinitions.enemy then
            if self.isBoosting and collidedObject.onHit then
                local tookDamage = collidedObject:onHit("boost", self.boostDamage)

                if tookDamage then
                    self.shipTemperature = self.shipTemperature + (self.boostEnemyHitHeatAccumulation/self.boostHeatDividend)
                end
                
                if collidedObject.markedForDelete then
                    if self.ammo < self.maxAmmo then
                        game.manager:setFreezeFrames(4, function()
                            local playerPosition = game.playerManager.playerPosition
                            local newEffect = boostAmmoEffect(playerPosition.x, playerPosition.y)
                            
                            gameHelper:addGameObject(newEffect)
                            gameHelper:screenShake(0.3)

                            game.manager:swapPalette()
                        end)

                        self:incrementAmmo(collidedObject.ammoIncrementAmount)
                    else
                        game.manager:setFreezeFrames(2)
                        gameHelper:screenShake(0.2)
                    end

                    self.boostHitSound:play({pitch = 1 + (2 * (self.boostHitEnemies / self.maxEnemiesForExplosion))})

                    self:handleBoostHeatDividend()
                    self:handleBoostExplosion()
                end
            end
        end
    end
end

function player:handleBoostHeatDividend()
    self.boostHeatDividend = self.boostHeatDividend + 1
    self.boostHeatDividend = math.clamp(self.boostHeatDividend, 0, self.maxBoostHeatDividend)
end

function player:handleBoostExplosion()
    self.boostHitEnemies = self.boostHitEnemies + 1

    if self.boostHitEnemies >= self.maxEnemiesForExplosion then
        self.boostHitEnemies = 0

        local newExplosion = playerExplosion(self.position.x, self.position.y, self.boostExplosionDistance, self.boostDamage)
        gameHelper:addGameObject(newExplosion)
    end
end

function player:incrementAmmo(ammoIncrementAmount)
    ammoIncrementAmount = ammoIncrementAmount or self.boostAmmoIncrement

    self.ammo = self.ammo + ammoIncrementAmount
    self.ammo = math.clamp(self.ammo, 0, self.maxAmmo)

    self.ammoDisplay:setDisplayAmmo(ammoIncrementAmount)
end

function player:setFireCooldown()
    self.fireCooldown = self.maxFireCooldown
    self.canFire = false
end

function player:applyFriction(dt, value, frictionValue)
    local frictionRatio = 1 / (1 + (dt * frictionValue))
    return value * frictionRatio
end

function player:rechargeHealth(dt)
    if self.isBoosting then
        self.healthRechargeCooldown = self.maxHealthRechargeCooldown
    end

    self.healthRechargeCooldown = self.healthRechargeCooldown - (1 * dt)

    if self.healthRechargeCooldown <= 0 then
        self.health = self.health + (3 * dt)
        self.health = math.clamp(self.health, 0, self.maxHealth)
    end
end

function player:update(dt)
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
    self:updatePosition(dt)

    -- Check collision
    self:checkCollision()

    self:rechargeHealth(dt)

    if self.healthDisplay then
        self.healthDisplay.health = self.health
        self.healthDisplay.maxHealth = self.maxHealth
    end
end

function player:draw()
    if not self.sprite then
        return
    end

    local colour = {1, 1, 1, 0.17}

    if self.health <= 2 then
        local enemySpawnColour = game.manager.currentPalette.enemySpawnColour

        colour[1] = enemySpawnColour[1]
        colour[2] = enemySpawnColour[2]
        colour[3] = enemySpawnColour[3]
        colour[4] = 0.17
    end

    love.graphics.setColor(colour)
    love.graphics.circle("fill", self.position.x, self.position.y, math.lerp(0, self.healthCircleRadius, self.health/self.maxHealth))
    love.graphics.setLineWidth(4)
    love.graphics.circle("line", self.position.x, self.position.y, self.healthCircleRadius + 2)
    love.graphics.setColor(colour)
    love.graphics.setLineWidth(2)

    if game.manager:getOption("showHealthRingHelpers") then
        for i = 1, self.maxHealth - 1 do
            local radius = math.lerp(0, self.healthCircleRadius, i/self.maxHealth)
            love.graphics.circle("line", self.position.x, self.position.y, radius)
        end
    end

    love.graphics.setLineWidth(1)

    love.graphics.setColor(1, 1, 1, 0.17)
    if self.health < self.maxHealth then
        love.graphics.circle("line", self.position.x, self.position.y, math.lerp(self.healthCircleRadius, 0, math.clamp((self.healthRechargeCooldown/self.maxHealthRechargeCooldown), 0, 1)))
    end

    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    love.graphics.setColor(game.manager.currentPalette.playerColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
    love.graphics.setColor(1, 1, 1, 1)
    
    if self.isBoosting then
        self.outlineShader:send("stepSize", {1.5/self.sprite:getWidth(), 1.5/self.sprite:getHeight()})
        love.graphics.setShader(self.outlineShader)
        love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
        love.graphics.setShader()
    end

    if self.isInvulnerable == true then
        love.graphics.circle("line", self.position.x, self.position.y, 10)
    end
end

function player:spawnBoostLines()
    gameHelper:screenShake(0.05)

    for i = 1, self.boostLineCount do
        local x = self.position.x + math.random(-self.boostLineSpawnRange, self.boostLineSpawnRange)
        local y = self.position.y + math.random(-self.boostLineSpawnRange, self.boostLineSpawnRange)
        local newBoostLine = boostLineEffect(x, y)
        gameHelper:addGameObject(newBoostLine)
    end
end

function player:onHit(damage)
    self.healthRechargeCooldown = self.maxHealthRechargeCooldown

    if self.isInvulnerable or self.isBoosting then
        return
    end

    damage = damage or 1
    gameHelper:resetMultiplier()
    
    self.health = self.health - damage
    self.shipTemperature = self.shipTemperature + (self.contactDamageHeatMultiplier * damage)

    self.isInvulnerable = true
    self.invulnerabilityCooldown = self.invulnerableGracePeriod

    if self.health <= 0 then
        self:destroy()
    else
        game.manager:setFreezeFrames(7, function()
            gameHelper:screenShake(0.3)
        end)
        
        game.particleManager:burstEffect("Player Death", 10, game.playerManager.playerPosition)
    end

    self.hurtSound:play()
end

function player:setInvulnerable()
    self.isInvulnerable = true
    self.invulnerabilityCooldown = self.invulnerableGracePeriod
end

function player:cleanup(destroyReason)
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end

    game.manager.runInfo.deathReason = "You died!"

    if destroyReason ~= "autoDestruction" then
        gameHelper:addGameObject(gameoverEffect(self.position.x, self.position.y, self.angle))
    end
end

return player