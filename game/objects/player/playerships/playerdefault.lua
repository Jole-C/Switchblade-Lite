local playerBase = require "game.objects.player.playerships.playerbase"
local playerDefault = class({name = "Player Default", extends = playerBase})

function playerDefault:new(x, y)
    -- Generic parameters of the ship
    self.maxHealth = 3
    self.spriteName = "player default"

    -- Movement parameters of the ship
    self.steeringSpeedMoving = 6
    self.steeringSpeedStationary = 14
    self.steeringSpeedBoosting = 3
    self.accelerationSpeed = 3
    self.boostingAccelerationSpeed = 4
    self.friction = 1
    self.maxSpeed = 3
    self.maxBoostingSpeed = 6
    self.maxShipTemperature = 100
    self.shipHeatAccumulationRate = 1
    self.shipCoolingRate = 40
    self.shipOverheatCoolingRate = 20
    self.boostDamage = 5
    self.boostEnemyHitHeatAccumulation = 7
    self.contactDamageHeatMultiplier = 10
    self.boostingInvulnerableGracePeriod = 1
    self.invulnerableGracePeriod = 3

    -- Firing parameters of the ship
    self.maxFireCooldown = 0.05
    self.bulletSpeed = 5
    self.bulletDamage = 3
    self.maxAmmo = 30
    self.shipKnockbackForce = 10
    self.fireOffset = 10

    self:super(x, y)
end

function playerDefault:update(dt)
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

return playerDefault