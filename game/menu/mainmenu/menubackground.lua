local menuBackground = class{
    sprite,

    init = function(self)
        self.sprite = resourceManager:getResource("menu background mesh")
    end,

    draw = function(self)
        if self.sprite then
            love.graphics.draw(self.sprite, 0, 0)
        end
    end,
}

return menuBackground