local playerBase = require "game.objects.player.playerships.playerbase"
local playerDefault = class({name = "Player Default", extends = playerBase})

function playerDefault:new(x, y)
    -- Generic parameters of the ship
    self.maxHealth = 3
    self.spriteName = "player default"

    -- Movement parameters of the ship
    self.steeringSpeedMoving = 10
    self.steeringSpeedStationary = 12
    self.steeringSpeedBoosting = 8
    self.accelerationSpeed = 5
    self.boostingAccelerationSpeed = 7
    self.friction = 1.5
    self.maxSpeed = 7
    self.maxBoostingSpeed = 10
    self.maxShipTemperature = 100
    self.shipHeatAccumulationRate = 0.6
    self.shipCoolingRate = 50
    self.shipOverheatCoolingRate = 30
    self.boostDamage = 5
    self.boostEnemyHitHeatAccumulation = 7
    self.contactDamageHeatMultiplier = 20
    self.boostingInvulnerableGracePeriod = 1
    self.invulnerableGracePeriod = 3
    self.bounceDampening = 1

    -- Firing parameters of the ship
    self.maxFireCooldown = 0.08
    self.bulletSpeed = 10
    self.bulletDamage = 3
    self.maxAmmo = 30
    self.shipKnockbackForce = 10
    self.fireOffset = 10
    self.boostAmmoIncrement = 7

    self:super(x, y)
end

function playerDefault:update(dt)
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