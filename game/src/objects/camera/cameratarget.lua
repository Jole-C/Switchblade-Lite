local cameraTarget = class({name = "Camera Target"})

function cameraTarget:new(positionReference, weight)
    self.position = positionReference or vec2(0, 0)
    self.weight = weight or 0
end

return cameraTarget