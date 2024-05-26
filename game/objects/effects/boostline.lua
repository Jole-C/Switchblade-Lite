local effect = require "game.objects.effects.effect"
local boostLine = class({name = "Boost Lines Effect", extends = effect})

function boostLine:new(x, y)
    self:super(x, y)

    self.speed = -1000
    self.lineLengthHalf = 30
    self.angle = angle or 0
    self.lifetime = 1

    local player = game.playerManager.playerReference
    if player then
        self.angle = player.velocity:angle()
    end
end

function boostLine:update(dt)
    effect.update(self, dt)

    self.position.x = self.position.x + math.cos(self.angle) * self.speed * dt
    self.position.y = self.position.y + math.sin(self.angle) * self.speed * dt
end

function boostLine:draw()
    local x1 = self.position.x + math.cos(self.angle) * self.lineLengthHalf
    local y1 = self.position.y + math.sin(self.angle) * self.lineLengthHalf
    local x2 = self.position.x + math.cos(self.angle) * -self.lineLengthHalf
    local y2 = self.position.y + math.sin(self.angle) * -self.lineLengthHalf

    love.graphics.setColor(1, 1, 1, 0.25)
    love.graphics.line(x1, y1, x2, y2)
end

return boostLine