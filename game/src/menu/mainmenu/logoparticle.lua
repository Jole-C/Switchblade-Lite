local logoParticle = class({name = "Logo Particle"})

function logoParticle:new(x, y, angle, speed, radius)
    self.position = vec2(x, y)
    self.angle = angle
    self.speed = speed
    self.radius = radius

    self.markedForDelete = false
end

function logoParticle:update(dt)
    self.radius = self.radius - (10 * dt)

    if self.radius <= 0 then
        self:destroy()
    end

    self.position.x = self.position.x + math.cos(self.angle) * (self.speed * dt)
    self.position.y = self.position.y + math.sin(self.angle) * (self.speed * dt)
end

function logoParticle:draw()
    love.graphics.setColor(game.manager.currentPalette.playerColour)
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius)
    love.graphics.setColor(1, 1, 1, 1)
end

function logoParticle:destroy()
    self.markedForDelete = true
end

return logoParticle