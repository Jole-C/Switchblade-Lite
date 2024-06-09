local gameObject = require "src.objects.gameobject"
local laser = class({name = "Laser", extends = gameObject})

function laser:new(x, y, angle, damage, length, lifetime)
    self:super(x, y)

    self.angle = angle or 0
    self.damage = damage or 2
    self.length = length or 100
    self.lifetime = lifetime or 0.5
    
    if self.sprite then
        local width, height = self.sprite:getDimensions()
        self.width = height
    else
        self.width = self.width or 8
    end
end

function laser:update(dt)
    self.lifetime = self.lifetime - 1 * dt

    if self.lifetime <= 0 then
        self:destroy()
    end

    local quarterAngle = 1.5708
    local widthIncrement = self.width/3
    local baseX = (self.position.x - math.cos(self.angle + quarterAngle) * widthIncrement)
    local baseY = (self.position.y - math.sin(self.angle + quarterAngle) * widthIncrement)
    
    for i = 1, 3 do
        local x1 = baseX + math.cos(self.angle + quarterAngle) * ((widthIncrement * i) - 2)
        local y1 = baseY + math.sin(self.angle + quarterAngle) * ((widthIncrement * i) - 2)
        local x2 = x1 + math.cos(self.angle) * self.length
        local y2 = y1 + math.sin(self.angle) * self.length
        
        local world = gameHelper:getWorld()

        local items, len = world:querySegment(x1, y1, x2, y2)
        self:handleCollision(items, len)
    end
end

function laser:handleCollision(items, length)

end

return laser