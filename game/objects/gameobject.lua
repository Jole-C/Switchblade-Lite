

local gameobject = class{
    position,
    name = "",

    init = function(self, x, y)
        self.position = vector.new(x, y)
    end,

    update = function(self, dt)

    end,

    draw = function(self, dt)

    end
}

return gameobject