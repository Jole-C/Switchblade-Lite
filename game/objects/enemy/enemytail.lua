local enemyTail = class{
    sprite,
    tailSpritePosition,
    tailAngleWave = 0,
    baseTailAngle = 0,
    tailAngleWaveAmount = 0,
    tailAngleWaveFrequency = 0,
    tailAngleWaveAmplitude = 0,

    init = function(self, spriteName, waveFrequency, waveAmplitude)
        self.sprite = resourceManager:getResource(spriteName)
        self.tailSpritePosition = vector.new(0, 0)
        self.tailAngleWaveFrequency = waveFrequency
        self.tailAngleWaveAmplitude = waveAmplitude
    end,

    update = function(self, dt)
        self.tailAngleWaveAmount = self.tailAngleWaveAmount + self.tailAngleWaveFrequency * dt
        self.tailAngleWave = math.sin(self.tailAngleWaveAmount) * self.tailAngleWaveAmplitude
    end,

    draw = function(self)
        if not self.sprite then
            return
        end

        local xOffset, yOffset = self.sprite:getDimensions()
        yOffset = yOffset/2

        love.graphics.setColor(gameManager.currentPalette.enemyColour)
        love.graphics.draw(self.sprite,  self.tailSpritePosition.x, self.tailSpritePosition.y, self.baseTailAngle + self.tailAngleWave, 1, 1, xOffset, yOffset)
        love.graphics.setColor(1, 1, 1, 1)
    end
}

return enemyTail