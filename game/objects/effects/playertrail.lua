local effect = require "game.objects.effects.effect"
local playerTrail = class({name = "Player Trail", extends = effect})

function playerTrail:new(x, y, radius, speed, angle)
    self:super(x, y)

    self.circleRadius = radius or 5
    self.radiusDecrement = self.circleRadius * 3
    self.speed = speed
    self.angle = angle
    self.lifetime = 0.5
end

function playerTrail:update(dt)
    effect.update(self, dt)

    self.circleRadius = self.circleRadius - self.radiusDecrement * dt

    if self.circleRadius <= 0 then
        self:destroy()
    end

    if self.speed and self.angle then
        self.position.x = self.position.x + math.cos(self.angle) * self.speed
        self.position.y = self.position.y + math.sin(self.angle) * self.speed
    end
end

function playerTrail:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", self.position.x, self.position.y, self.circleRadius)
end

return playerTrail