local gameObject = require "game.objects.gameobject"
local velocityEntity = class({name = "Velocity Entity", extends = gameObject})

function velocityEntity:new(x, y)
    self:super(x, y)
    
    -- Initialise values used by velocity
    self.velocity = 0
    self.friction = 0
    self.mass = 1
end

function velocityEntity:applyFriction(dt)
    local frictionRatio = 1 / (1 + (dt * self.friction / self.mass))
    self.velocity = self.velocity * frictionRatio
end

function velocityEntity:addForce(force)
    self.velocity = self.velocity + (force / self.mass)
end

return velocityEntity