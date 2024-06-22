local cameraTarget = class({name = "Camera Target"})

function cameraTarget:new(positionReference, weight)
    cameraTarget.position = positionReference or vec2(0, 0)
    cameraTarget.weight = weight or 0
end

return cameraTarget