local gameObject = class({name = "Game Object"})

function gameObject:new(x, y)
    self.position = vec2(x, y)
    self.markedForDelete = false
end

function gameObject:update(dt)

end

function gameObject:draw()

end

function gameObject:destroy(destroyReason)
    self:cleanup(destroyReason)
    self.markedForDelete = true
end

function gameObject:cleanup(destroyReason)

end

return gameObject