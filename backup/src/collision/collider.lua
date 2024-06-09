local collider = class({name = "Collider"})

function collider:new(colliderDefinition, owner)
    self.colliderDefinition = colliderDefinition
    self.owner = owner
end

return collider