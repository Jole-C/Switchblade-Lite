local gameObject = require "src.objects.gameobject"
local effect = class({name = "Effect", extends = gameObject})

function effect:new(x, y)
    self:super(x, y)
    self.lifetime = 5
    
end

function effect:update(dt)
    self.lifetime = self.lifetime - 1 * dt

    if self.lifetime <= 0 then
        self:destroy()
    end
end

function effect:draw()

end

return effect