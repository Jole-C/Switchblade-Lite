local bossState = require "src.objects.enemy.boss.bossstate"
local laser = require "src.objects.enemy.boss.boss1.boss1laser"

local phase1UnshieldedChargerfire = class({name = "Boss 1 Phase 2 Unshield Laser Fire", extends = bossState})

function phase1UnshieldedChargerfire:enter(bossInstance)
    self.angleTurnRate = 0.1
    self.laserWindupTime = 3
    self.laserReference = nil

    bossInstance:setMandibleOpenAmount(1)
end

function phase1UnshieldedChargerfire:update(dt, bossInstance)
    local playerPosition = game.playerManager.playerPosition
    local angleToPlayer = (playerPosition - bossInstance.position):angle()

    bossInstance.angle = math.lerpAngle(bossInstance.angle, angleToPlayer, 0.025, dt)

    self.laserWindupTime = self.laserWindupTime - (1 * dt)
    if self.laserWindupTime <= 0 and self.laserReference == nil then
        self.laserReference = laser(bossInstance.position.x, bossInstance.position.y, bossInstance.angle, 500, 3)
        gameHelper:addGameObject(self.laserReference)
    end

    if self.laserReference then
        self.laserReference.angle = bossInstance.angle
        
        if self.laserReference.markedForDelete then
            bossInstance:switchState(bossInstance.states.phase2.unshielded.movement)
            self.laserReference = nil
        end
    end
end

return phase1UnshieldedChargerfire