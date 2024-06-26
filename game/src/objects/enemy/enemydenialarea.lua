local gameObject = require "src.objects.gameobject"
local denialArea = class({name = "Enemy Denial Area", extends = gameObject})

function denialArea:new(x, y, radius, lifeTime)
    self:super(x, y)

    self.radius = radius or 100
    self.lifeTime = lifeTime or 3
    self.temperatureAccumulateRate = 2.5
    self.lineWidth = 3
end

function denialArea:update(dt)
    self.lifeTime = self.lifeTime - (1 * dt)

    if self.lifeTime <= 0 then
        self:destroy()
    end

    local player = game.playerManager.playerReference

    if not player then
        return
    end

    local playerPosition = game.playerManager.playerPosition
    local distance = (self.position - playerPosition):length()

    if distance < self.radius then
        player:accumulateTemperature(dt, self.temperatureAccumulateRate)
    end
end

function denialArea:draw()
    love.graphics.setColor(game.manager.currentPalette.enemyColour)
    love.graphics.setLineWidth(self.lineWidth)
    love.graphics.circle("line", self.position.x, self.position.y, self.radius)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

return denialArea