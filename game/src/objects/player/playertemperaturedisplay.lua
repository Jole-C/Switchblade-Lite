local gameObject = require "src.objects.gameobject"
local playerTemperatureDisplay = class({name = "Player Temperature Display", extends = gameObject})

function playerTemperatureDisplay:new(x, y)
    self:super(x, y)

    self.minArcAngle = math.pi / 2
    self.maxArcAngle = math.pi / 2 + (2 * math.pi)
    self.radius = 25
    self.lineWidth = 5
    self.temperatureAngle = self.minArcAngle

    self.temperature = 0
    self.maxTemperature = 1
end

function playerTemperatureDisplay:update(dt)
    self.temperatureAngle = math.lerp(self.minArcAngle, self.maxArcAngle, self.temperature / self.maxTemperature)
end

function playerTemperatureDisplay:draw()
    love.graphics.setColor(game.manager.currentPalette.playerColour)
    love.graphics.setLineWidth(self.lineWidth)
    love.graphics.arc("line", "open", self.position.x, self.position.y, self.radius, self.minArcAngle, self.temperatureAngle)
    love.graphics.setLineWidth(1)
end

return playerTemperatureDisplay