local gameObject = require "src.objects.gameobject"
local explosion = class({name = "Explosion", extends = gameObject})

function explosion:new(x, y, radius, damage, drawType, drawColour)
    self:super(x, y)
    self.radius = 0
    self.maxRadius = radius
    self.damage = damage
    self.lifetime = 1.5
    self.drawType = drawType or "fill"
    self.drawColour = drawColour or {1, 1, 1, 1}

    gameHelper:screenShake(0.2)
end

function explosion:update(dt)
    self.lifetime = self.lifetime - 1 * dt
    self:handleExplosion()

    if self.lifetime <= 0 then
        self:destroy()
    end

    self.radius = self.radius + (500 * dt)
    self.radius = math.clamp(self.radius, 0, self.maxRadius)
end

function explosion:handleExplosion()

end

function explosion:draw()
    love.graphics.setColor(self.drawColour)
    love.graphics.circle(self.drawType, self.position.x, self.position.y, self.radius)
end

return explosion