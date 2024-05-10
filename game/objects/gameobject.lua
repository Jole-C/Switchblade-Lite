

local gameobject = class{
    position,
    name = "",
    colliderDefinition = "",
    markedForDelete = false,

    init = function(self, x, y)
        self.position = vector.new(x, y)
    end,

    update = function(self, dt)

    end,

    draw = function(self)

    end,

    destroy = function(self)
        self.markedForDelete = true
        self:cleanup()    
    end,

    cleanup = function(self)

    end
}

return gameobject