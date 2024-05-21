local playerBase = require "game.objects.player.playerships.playerbase"

local playerDefault = class{
    __includes = playerBase,
    
    -- Generic parameters of the ship
    maxHealth = 3,

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
    boostEnemyHitHeatAccumulation = 7,
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