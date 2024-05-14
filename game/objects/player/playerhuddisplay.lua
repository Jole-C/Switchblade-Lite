local hudElement = require "game.interface.hudelement"

local playerHud = class{
    __includes = hudElement,
    
    playerReference,

    init = function(self)
    end,

    update = function(self)
        self.playerReference = playerManager.playerReference
    end,

    draw = function(self)
        if self.playerReference == nil then
            return
        end

        love.graphics.print(math.floor(self.playerReference.shipTemperature), 10, 10)
        love.graphics.print(self.playerReference.health, 10, 20)
        love.graphics.print(self.playerReference.ammo, 10, 30)
    end
}

return playerHud