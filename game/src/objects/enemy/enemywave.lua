local gameObject = require "src.objects.gameobject"
local wave = class({name = "Enemy Wave", extends = gameObject})

function wave:new(x, y, width, scaleSpeed)
    self:super(x, y)

    self.waveWidth = width or 5

    self.scaleSpeed = scaleSpeed or 30
    self.maxScale = 500
    self.scale = 0
end

function wave:update(dt)
    self.scale = self.scale + (self.scaleSpeed * dt)

    if self.scale > self.maxScale then
        self:destroy()
    end

    local player = game.playerManager.playerReference

    if not player then
        return
    end

    local playerPosition = game.playerManager.playerPosition
    local distance = (self.position - playerPosition):length()

    if distance > self.scale and distance < self.scale + self.waveWidth then
        player:onHit()
    end
end

function wave:draw()
    love.graphics.setColor(game.manager.currentPalette.enemyColour)
    love.graphics.setLineWidth(self.waveWidth)
    love.graphics.circle("line", self.position.x, self.position.y, self.scale + self.waveWidth/2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

return wave