local gameObject = require "src.objects.gameobject"
local laser = class({name = "Laser", extends = gameObject})

function laser:new(x, y, angle, damage, length, lifetime, numberOfQueries)
    self:super(x, y)

    self.angle = angle or 0
    self.damage = damage or 2
    self.length = length or 100
    self.lifetime = lifetime or 0.5
    self.numberOfQueries = numberOfQueries or 3
    
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
    local widthIncrement = self.width/self.numberOfQueries - 1
    local halfWidth = self.width / 2
    
    for i = 1, self.numberOfQueries do
        local offset = (i - 1) * widthIncrement - halfWidth

        local x1 = self.position.x + math.cos(self.angle + quarterAngle) * offset
        local y1 = self.position.y + math.sin(self.angle + quarterAngle) * offset  
        local x2 = x1 + math.cos(self.angle) * self.length
        local y2 = y1 + math.sin(self.angle) * self.length
        
        local world = gameHelper:getWorld()
        local returnEarly =nil

        if world then
            local items, len = world:querySegment(x1, y1, x2, y2)
            returnEarly = self:handleCollision(items, len, dt)
        end
        
        if returnEarly == true then
            return
        end
    end
end

function laser:handleCollision(items, length, dt)

end

return laser