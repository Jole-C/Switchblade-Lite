local enemyTail = class({name = "Enemy Tail"})

function enemyTail:new(spriteName, spriteX, spriteY, waveFrequency, waveAmplitude)
    self.tailAngleWaveFrequency = waveFrequency
    self.tailAngleWaveAmplitude = waveAmplitude

    self.tailSpritePosition = vec2(spriteX or 0, spriteY or 0)
    self.tailAngleWave = 0
    self.tailAngleWaveAmount = 0
    self.baseTailAngle = 0

    self.sprite = game.resourceManager:getResource(spriteName)
end

function enemyTail:update(dt)
    self.tailAngleWaveAmount = self.tailAngleWaveAmount + self.tailAngleWaveFrequency * dt
    self.tailAngleWave = math.sin(self.tailAngleWaveAmount) * self.tailAngleWaveAmplitude
end

function enemyTail:draw()
    if not self.sprite then
        return
    end

    local xOffset, yOffset = self.sprite:getDimensions()
    yOffset = yOffset/2

    love.graphics.setColor(game.gameManager.currentPalette.enemyColour)
    love.graphics.draw(self.sprite,  self.tailSpritePosition.x, self.tailSpritePosition.y, self.baseTailAngle + self.tailAngleWave, 1, 1, xOffset, yOffset)
    love.graphics.setColor(1, 1, 1, 1)
end

return enemyTail