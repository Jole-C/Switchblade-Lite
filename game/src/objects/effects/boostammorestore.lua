local effect = require "src.objects.effects.effect"
local boostRestore = class({name = "Boost Ammo Restore Effect", extends = effect})

function boostRestore:new(x, y)
    self:super(x, y)

    self.angle = math.random(0, 2 * math.pi)
    self.lineLength = 0
    self.lineIncreaseRate = 3000
    self.lineCount = math.random(3, 4)

    self.circleRadius = 20

    self.sizePercentage = 6
    self.sizeIncrement = 30
end

function boostRestore:update(dt)
    self.lineLength = self.lineLength + (self.lineIncreaseRate * dt)
    self.sizePercentage = self.sizePercentage - (self.sizeIncrement * dt)

    if self.sizePercentage <= 0 then
        self:destroy()
    end
end

function boostRestore:draw()
    local angleIncrement = 2*math.pi/self.lineCount

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(3)

    for i = 1, self.lineCount do
        local x1 = self.position.x
        local y1 = self.position.y
        local x2 = x1 + math.cos(self.angle + angleIncrement * i) * self.lineLength
        local y2 = y1 + math.sin(self.angle + angleIncrement * i) * self.lineLength

        love.graphics.line(x1, y1, x2, y2)
    end

    love.graphics.circle("line", self.position.x, self.position.y, self.circleRadius * self.sizePercentage)
    love.graphics.setLineWidth(1)
end

return boostRestore