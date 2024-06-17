local gameObject = require "src.objects.gameobject"
local playerBullet = require "src.objects.player.playerbullets.playerbullet"
local playerExplosion = require "src.objects.player.playerbullets.playerexplosion"
local collider = require "src.collision.collider"
local playerHud = require "src.objects.player.playerhuddisplay"
local boostAmmoEffect = require "src.objects.effects.boostammorestore"
local boostLineEffect = require "src.objects.effects.boostline"
local trailEffect = require "src.objects.effects.playertrail"

local player = class({name = "Player", extends = gameObject})

function player:new(x, y)
    self:super(x, y)

    -- Generic parameters of the ship
    self.maxHealth = 3
    self.spriteName = self.spriteName or "player default"
    self.maxOverheatPlayRate = 0.5
    self.maxEnemiesForExplosion = self.maxEnemiesForExplosion or 5
    self.boostExplosionDistance = self.boostExplosionDistance or 100
    self.maxBoostHeatDividend = self.maxBoostHeatDividend or 5
    
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
    self.contactDamageHeatMultiplier = self.contactDamageHeatMultiplier or 10
    self.invulnerableGracePeriod = self.invulnerableGracePeriod or 3
    self.bounceDampening = self.bounceDampening or 0.5    
    self.boostLineCount = 5
    self.boostLineSpawnRange = 500
    
    -- Firing parameters of the ship
    self.maxFireCooldown = self.maxFireCooldown or 0.05
    self.bulletSpeed = self.bulletSpeed or 5
    self.bulletDamage = self.bulletDamage or 3
    self.maxAmmo = self.maxAmmo or 30
    self.shipKnockbackForce = self.shipKnockbackForce or 10
    self.fireOffset = self.fireOffset or 10
    self.boostAmmoIncrement = self.boostAmmoIncrement or 5
    self.maxAmmoDisplayTime = 1
    
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
    self.ammoDisplayTime = self.maxAmmoDisplayTime
    self.overheatPlayCooldown = 0
    self.boostHeatDividend = 1
    self.boostHitEnemies = 0
    
    -- Ship components
    self.collider = collider(colliderDefinitions.player, self)
    gameHelper:getWorld():add(self.collider, 0, 0, 6, 6)

    self.boostCollider = collider(colliderDefinitions.none, self)
    gameHelper:getWorld():add(self.boostCollider, 0, 0, 16, 16)

    self.sprite = game.resourceManager:getResource(self.spriteName)
    self.sprite:setFilter("nearest")

    self.hud = playerHud()
    game.interfaceRenderer:addHudElement(self.hud)

    self.ammoFont = game.resourceManager:getResource("font main")
    self.cameraWeight = {position = self.position, weight = 50}

    self.fireSound = self.fireSound or ripple.newSound(game.resourceManager:getResource("default fire"))
    self.fireSound:tag(game.tags.sfx)
    self.boostSound = self.boostSound or ripple.newSound(game.resourceManager:getResource("default boost"))
    self.boostSound:tag(game.tags.sfx)
    self.hurtSound = ripple.newSound(game.resourceManager:getResource("ship hurt"))
    self.hurtSound:tag(game.tags.sfx)
    self.overheatWarningSound = ripple.newSound(game.resourceManager:getResource("ship overheat warning"))
    self.overheatWarningSound:tag(game.tags.sfx)
    self.overheatSound = ripple.newSound(game.resourceManager:getResource("ship overheat"))
    self.overheatSound:tag(game.tags.sfx)
    self.boostHitSound = ripple.newSound(game.resourceManager:getResource("boost hit"))
    self.boostHitSound:tag(game.tags.sfx)

    gameHelper:getCurrentState().cameraManager:addTarget(self.cameraWeight)
end

-- Update the player hud
function player:updateHud(dt)
    if self.hud then
        self.hud:update(dt)
    end
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

        if game.input:down("reverseThrust") then
            self.velocity = self.velocity - movementDirection * (self.accelerationSpeed/1.5 * dt)

            self.steeringAccelerationSpeed = self.steeringAccelerationStationary
            self.maxSteeringSpeed = self.steeringSpeedStationary
        end

        if game.input:down("boost") then
            self.isBoosting = true
            self.velocity = self.velocity + movementDirection * (self.boostingAccelerationSpeed * dt)

            self.steeringAccelerationSpeed = self.steeringAccelerationBoosting
            self.maxSteeringSpeed = self.steeringSpeedBoosting

            self.shipTemperature = self.shipTemperature + self.shipHeatAccumulationRate * dt
            self:spawnBoostLines()
        else
            self.isBoosting = false
        end

        if game.input:pressed("boost") and not game.input:down("shoot") then
            self.boostSound:play()
        end
    end
end

function player:updateShipSteering(dt)
    if game.input:down("steerLeft") then
        self.steeringSpeed = self.steeringSpeed - (self.steeringAccelerationSpeed * dt)
    end

    if game.input:down("steerRight") then
        self.steeringSpeed = self.steeringSpeed + (self.steeringAccelerationSpeed * dt)
    end

    self.steeringSpeed = math.clamp(self.steeringSpeed, -self.maxSteeringSpeed, self.maxSteeringSpeed)
    self.angle = self.angle + (self.steeringSpeed * dt)
    self.steeringSpeed = self:applyFriction(dt, self.steeringSpeed, self.steeringFriction)
end

function player:updateShipShooting(dt, movementDirection)
    if self.isBoosting == true or self.ammo <= 0 then
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
        self:setDisplayAmmo()

        self.fireSound:play({pitch = 1 + (2 * (1 - (self.ammo / self.maxAmmo)))})
        gameHelper:getCurrentState().cameraManager:screenShake(0.05)
        
        self.ammo = self.ammo - 1
    end
end

function player:updatePlayerTimers(dt)
    self.fireCooldown = self.fireCooldown - 1 * dt
    self.invulnerabilityCooldown = self.invulnerabilityCooldown - 1 * dt
    self.ammoDisplayTime = self.ammoDisplayTime - 1 * dt

    if self.invulnerabilityCooldown <= 0 then
        self.isInvulnerable = false
    end

    if self.fireCooldown <= 0 then
        self.canFire = true
    end

    if self.ammoDisplayTime <= 0 then
        self.displayAmmo = false
    end
end

function player:playOverheatSound(dt)
    if self.shipTemperature > self.maxShipTemperature/2.3 and self.isOverheating == false then
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
        end
    end
end

function player:updateOverheating(dt)
    self:playOverheatSound(dt)

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
        self.boostHeatDividend = 1
        self.boostHitEnemies = 0
    end

    self.shipTemperature = math.clamp(self.shipTemperature, 0, self.maxShipTemperature)
end

function player:spawnTrail()
    if self.isOverheating == true then
        return
    end

    local newTrailSegment
    local x = self.position.x + math.cos(self.angle) * -10
    local y = self.position.y + math.sin(self.angle) * -10

    if self.velocity:length() > 0 then
        if self.isBoosting == true then
            newTrailSegment = trailEffect(x, y, 10, self.velocity:length()/2, math.pi + self.velocity:angle())
        else
            newTrailSegment = trailEffect(x, y, 3)
        end
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

    self:spawnTrail()

    local trimmedSpeed = self.maxSpeed

    if self.isBoosting then
        trimmedSpeed = self.maxBoostingSpeed
    end

    self.velocity = self.velocity:trim_length_inplace(trimmedSpeed)

    if arena:isPositionWithinArena(self.position + self.velocity * dt) == false then
        local segment = arena:getSegmentPointIsWithin(self.position)
        
        if segment then
            local normal = (segment.position - self.position):normalise_inplace()
            self.velocity = self.velocity - (2 * self.velocity:dot(normal) * normal)
        end
    end

    self.position = self.position + (self.velocity * dt)
    self.position = arena:getClampedPosition(self.position)

    self.velocity = self:applyFriction(dt, self.velocity, self.friction)

    self.cameraWeight.position = self.position
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
        if colliderDefinition == colliderDefinitions.enemy then
            if self.isBoosting == false and collidedObject.onHit then
                collidedObject:onHit("contact", collidedObject.health)
            end
        end
    elseif colliderHit == self.boostCollider then
        if colliderDefinition == colliderDefinitions.enemy then
            if self.isBoosting and collidedObject.onHit then
                local tookDamage = collidedObject:onHit("boost", self.boostDamage)
                
                if tookDamage then
                    self.shipTemperature = self.shipTemperature + (self.boostEnemyHitHeatAccumulation/self.boostHeatDividend)
                end
                
                if collidedObject.markedForDelete then
                    self:incrementAmmo()

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

function player:setDisplayAmmo()
    self.displayAmmo = true
    self.ammoDisplayTime = self.maxAmmoDisplayTime
end

function player:incrementAmmo()
    self.ammo = self.ammo + self.boostAmmoIncrement
    self.ammo = math.clamp(self.ammo, 0, self.maxAmmo)
    self:setDisplayAmmo()
end

function player:setFireCooldown()
    self.fireCooldown = self.maxFireCooldown
    self.canFire = false
end

function player:applyFriction(dt, value, frictionValue)
    local frictionRatio = 1 / (1 + (dt * frictionValue))
    return value * frictionRatio
end

function player:wrapShipPosition()

end

function player:update(dt)
    -- Update the hud
    self:updateHud()
    
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

    -- Wrap the ship's position
    self:wrapShipPosition()

    -- Check collision
    self:checkCollision()
end

function player:draw()
    if not self.sprite then
        return
    end

    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2
    
    love.graphics.setColor(game.manager.currentPalette.playerColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, 1, 1, xOffset, yOffset)
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the ammo count if the player is firing
    if self.displayAmmo == true then
        love.graphics.setFont(self.ammoFont)
        local width = self.ammoFont:getWidth(self.ammo)

        love.graphics.printf(tostring(self.ammo), self.position.x - width/2, self.position.y + 10, width, "center")
    end

    if self.isInvulnerable == true then
        love.graphics.circle("line", self.position.x, self.position.y, 10)
    end
end

function player:spawnBoostLines()
    gameHelper:getCurrentState().cameraManager:screenShake(0.05)

    for i = 1, self.boostLineCount do
        local x = self.position.x + math.random(-self.boostLineSpawnRange, self.boostLineSpawnRange)
        local y = self.position.y + math.random(-self.boostLineSpawnRange, self.boostLineSpawnRange)
        local newBoostLine = boostLineEffect(x, y)
        gameHelper:addGameObject(newBoostLine)
    end
end

function player:onHit(damage)
    if self.isInvulnerable or self.isBoosting then
        return
    end

    damage = damage or 1

    self.health = self.health - damage
    self.shipTemperature = self.shipTemperature + (self.contactDamageHeatMultiplier * damage)

    self.isInvulnerable = true
    self.invulnerabilityCooldown = self.invulnerableGracePeriod

    if self.health <= 0 then
        self:destroy()
    end

    self.hurtSound:play()
end

function player:setInvulnerable()
    self.isInvulnerable = true
    self.invulnerabilityCooldown = self.invulnerableGracePeriod
end

function player:cleanup()
    local world = gameHelper:getWorld()
    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return player