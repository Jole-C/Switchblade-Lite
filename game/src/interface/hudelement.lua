local hudElement = class({name = "Base Hud Element"})

function hudElement:new()
    self.drawColour = {1, 1, 1, 1}
end

function hudElement:update(dt)
    
end

function hudElement:draw()

end

return hudElement