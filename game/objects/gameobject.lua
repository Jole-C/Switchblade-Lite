

local gameobject = class{
    position,
    name = "",
    markedForDelete = false,

    init = function(self, x, y)
        self.position = vector.new(x, y)
    end,

    update = function(self, dt)

    end,

    draw = function(self)

    end,

    destroy = function(self)
        self:cleanup()
        self.markedForDelete = true
    end,

    cleanup = function(self)

    end
}

return gameobject