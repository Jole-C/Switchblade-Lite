local player = require "game.objects.player.player"

local playerManager = class{
    playerReference,

    init = function(self)

    end,

    spawnPlayer = function(self, x, y)
        local newPlayer = player(x, y)
        self.playerReference = newPlayer
        return newPlayer
    end,

    destroyPlayer = function(self, x, y)
        self.playerReference:destroy()
        self.playerReference = nil
    end,

    doesPlayerExist = function(self)
        return self.playerReference ~= nil
    end,

    update = function(self)
        if self.playerReference == nil then
            return
        end

        if self.playerReference.health <= 0 then
            self.playerReference = nil
        end
    end
}

return playerManager