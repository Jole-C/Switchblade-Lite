local playerBase = require "game.objects.player.playerships.playerbase"
local playerDefault = class({name = "Player Default", extends = playerBase})

function playerDefault:new(x, y)
    -- Generic parameters of the ship
    self.maxHealth = 3
    self.spriteName = "player default"

    -- Movement parameters of the ship
    self.steeringSpeedMoving = self.steeringSpeedMoving or 1.3
    self.steeringSpeedStationary = self.steeringSpeedStationary or 0.7
    self.steeringSpeedBoosting = self.steeringSpeedBoosting or 1.1
    self.steeringSpeedFiring = self.steeringSpeedFiring or 1
    self.steeringAccelerationMoving = self.steeringAccelerationMoving or 1
    self.steeringAccelerationStationary = self.steeringAccelerationStationary or 0.5
    self.steeringAccelerationBoosting = self.steeringAccelerationBoosting or 0.7
    self.steeringAccelerationFiring = self.steeringAccelerationFiring or 0.5
    self.steeringFriction = 7
    self.accelerationSpeed = 5
    self.boostingAccelerationSpeed = 7
    self.friction = 1
    self.maxSpeed = 7
    self.maxBoostingSpeed = 10
    self.maxShipTemperature = 100
    self.shipHeatAccumulationRate = 30
    self.shipCoolingRate = 50
    self.shipOverheatCoolingRate = 30
    self.boostDamage = 3
    self.boostEnemyHitHeatAccumulation = 7
    self.contactDamageHeatMultiplier = 20
    self.boostingInvulnerableGracePeriod = 1
    self.invulnerableGracePeriod = 3
    self.bounceDampening = 0.5

    -- Firing parameters of the ship
    self.maxFireCooldown = 0.08
    self.bulletSpeed = 10
    self.bulletDamage = 1
    self.maxAmmo = 14
    self.shipKnockbackForce = 10
    self.fireOffset = 10
    self.boostAmmoIncrement = 7

    -- Components
    self.fireSound = ripple.newSound(game.resourceManager:getResource("default fire"))
    self.boostSound = ripple.newSound(game.resourceManager:getResource("default boost"))

    self:super(x, y)
end

function playerDefault:update(dt)
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

return playerDefault