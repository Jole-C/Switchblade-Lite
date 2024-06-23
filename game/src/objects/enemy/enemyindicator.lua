local gameObject = require "src.objects.gameObject"
local enemyIndicator = class({name = "Enemy Indicator", extends = gameObject})

function enemyIndicator:new(x, y, enemy)
    self:super(x, y)

    self.enemy = enemy
    assert(enemy ~= nil, "Enemy reference is nil!")

    self.circleRadiusFrequency = 3
    self.circleRadiusAmplitude = 8
    self.circleRadius = 5
    self.lineWidth = 3

    self.circleRadiusTime = 0
    self.circleRadiusOffset = 0
end

function enemyIndicator:update(dt)
    self.circleRadiusTime = self.circleRadiusTime + (self.circleRadiusFrequency * dt)
    self.circleRadiusOffset = math.sin(self.circleRadiusTime) * self.circleRadiusAmplitude

    if self.enemy.markedForDelete then
        self:destroy()
    end
end

function enemyIndicator:draw()
    if self.enemy == nil then
        return
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(self.lineWidth)
    love.graphics.circle("line", self.enemy.position.x, self.enemy.position.y, self.circleRadius + self.circleRadiusOffset)
    love.graphics.setLineWidth(1)
end

return enemyIndicator