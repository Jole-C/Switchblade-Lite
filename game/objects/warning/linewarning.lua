local warning = require "game.objects.warning.warning"
local lineWarning = class({name = "Line Warning", extends = warning})

function lineWarning:new(x, y, lifetime, length, angle, execute)
    self:super(x, y, lifetime, execute)

    self.length = length
    self.angle = angle
end

function lineWarning:draw()
    if not self.spriteVisible then
        return
    end

    love.graphics.setColor(game.manager.currentPalette.enemySpawnColour)
    
    local x1 = self.position.x
    local y1 = self.position.y
    local x2 = x1 + math.cos(self.angle) * self.length
    local y2 = y1 + math.sin(self.angle) * self.length

    love.graphics.line(x1, y1, x2, y2)

    love.graphics.setColor(1, 1, 1, 1)
end