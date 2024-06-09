local gameObject = class({name = "Game Object"})

function gameObject:new(x, y)
    self.position = vec2(x, y)
    self.markedForDelete = false
end

function gameObject:update(dt)

end

function gameObject:draw()

end

function gameObject:destroy()
    self:cleanup()
    self.markedForDelete = true
end

function gameObject:cleanup()

end

return gameObject