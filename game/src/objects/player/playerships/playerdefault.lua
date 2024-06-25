local playerBase = require "src.objects.player.playerships.playerbase"
local playerDefault = class({name = "Player Default", extends = playerBase})

function playerDefault:new(x, y)
    -- Generic parameters of the ship
    self.maxHealth = 5
    self.spriteName = "player default"
    self.invulnerableGracePeriod = 0.5

    -- Movement parameters of the ship
    self.steeringSpeedMoving = 81.25
    self.steeringSpeedStationary = 43.75
    self.steeringSpeedBoosting = 68.75
    self.steeringSpeedFiring = 62.5
    self.steeringAccelerationMoving = 62.5
    self.steeringAccelerationStationary = 31.25
    self.steeringAccelerationBoosting = 43.75
    self.steeringAccelerationFiring = 31.25
    self.steeringFriction = 7
    self.accelerationSpeed = 312.5
    self.boostingAccelerationSpeed = 437.5
    self.friction = 1
    self.maxSpeed = 437.5
    self.maxBoostingSpeed = 625
    self.maxShipTemperature = 100
    self.shipHeatAccumulationRate = 30
    self.shipCoolingRate = 50
    self.shipOverheatCoolingRate = 30
    self.boostDamage = 3
    self.boostEnemyHitHeatAccumulation = 7
    self.contactDamageHeatMultiplier = 20
    self.boostingInvulnerableGracePeriod = 1
    self.bounceDampening = 0.5

    -- Firing parameters of the ship
    self.maxFireCooldown = 0.08
    self.bulletSpeed = 625
    self.bulletDamage = 1
    self.maxAmmo = 14
    self.shipKnockbackForce = 10
    self.fireOffset = 10
    self.boostAmmoIncrement = 7
    
    self:super(x, y)
end

return playerDefault