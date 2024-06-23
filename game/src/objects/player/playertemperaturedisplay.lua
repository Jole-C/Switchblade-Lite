local gameObject = require "src.objects.gameobject"
local playerTemperatureDisplay = class({name = "Player Temperature Display", extends = gameObject})

function playerTemperatureDisplay:new(x, y)
    self:super(x, y)

    self.minArcAngle = 3.92699
    self.maxArcAngle = 5.49779
    self.radius = 25
    self.temperatureAngle = self.minArcAngle

    self.temperature = 0
    self.maxTemperature = 1
end

function playerTemperatureDisplay:update(dt)
    self.temperatureAngle = math.lerp(self.minArcAngle, self.maxArcAngle, self.temperature / self.maxTemperature)
end

function playerTemperatureDisplay:draw()
    love.graphics.setColor(game.manager.currentPalette.playerColour)
    love.graphics.setLineWidth(3)
    love.graphics.arc("line", "open", self.position.x, self.position.y, self.radius, self.minArcAngle, self.temperatureAngle)
    love.graphics.setLineWidth(1)
end

return playerTemperatureDisplay