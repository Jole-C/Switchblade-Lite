local collider = class{
    colliderDefinition = "",
    owner,

    init = function(self, colliderDefinition, owner)
        self.colliderDefinition = colliderDefinition
        self.owner = owner
    end
}

return collider