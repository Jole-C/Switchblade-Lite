local bossState = require "src.objects.enemy.boss.bossstate"
local shieldMovement = class({name = "Shield Movement", extends = bossState})

function shieldMovement:enter(bossInstance)
    gameHelper:getCurrentState().stageDirector:setTimerPaused(false)

    self.distance = 250
    self.angleTurnRate = 1
    self.pointLerpRate = 0.1
    
    self.leftPos = vec2(0, 0)
    self.rightPos = vec2(0, 0)
    self.normal = vec2(0, 0)
    self.angle = 0
end

function shieldMovement:update(dt, bossInstance)
    self.normal.x = math.cos(self.angle)
    self.normal.y = math.sin(self.angle)

    self.leftPos.x = self.normal.x * self.distance
    self.leftPos.y = self.normal.y * self.distance

    self.rightPos.x = -self.normal.x * self.distance
    self.rightPos.y = -self.normal.y * self.distance

    self.angle = self.angle + (self.angleTurnRate * dt)

    bossInstance.points.leftPoint.x = math.lerpDT(bossInstance.points.leftPoint.x, self.leftPos.x, self.pointLerpRate, dt)
    bossInstance.points.leftPoint.y = math.lerpDT(bossInstance.points.leftPoint.y, self.leftPos.y, self.pointLerpRate, dt)
    bossInstance.points.rightPoint.x = math.lerpDT(bossInstance.points.rightPoint.x, self.rightPos.x, self.pointLerpRate, dt)
    bossInstance.points.rightPoint.y = math.lerpDT(bossInstance.points.rightPoint.y, self.rightPos.y, self.pointLerpRate, dt)
end

return shieldMovement