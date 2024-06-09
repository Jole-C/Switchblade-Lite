local gameObject = require "src.objects.gameobject"
local warning = class({Name = "Warning", extends = gameObject})

function warning:new(x, y, lifetime, execute)
    self:super(x, y)

    self.lifetime = lifetime
    self.execute = execute

    self.spriteVisible = true
    self.maxSpriteVisibleTime = 0.5
    self.spriteVisibleTime = self.maxSpriteVisibleTime
end

function warning:update(dt)
    self.lifetime = self.lifetime - (1 * dt)

    if self.lifetime <= 0 then
        self:destroy()

        if self.execute then
            self.execute()
        end
    end
    
    self.spriteVisibleTime = self.spriteVisibleTime - (1 * dt)

    if self.spriteVisibleTime <= 0 then
        self.spriteVisibleTime = self.maxSpriteVisibleTime
        self.spriteVisible = not self.spriteVisible
    end
end

function warning:draw()

end