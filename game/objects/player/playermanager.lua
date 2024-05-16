local playerManager = class{
    playerReference,
    playerPosition,

    init = function(self)
        self.playerPosition = vector.new(0, 0)
    end,

    spawnPlayer = function(self, x, y)
        local newPlayer = gameManager.currentPlayerDefinition.shipClass(x, y)
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
        if self.playerReference then
            self.playerPosition = self.playerReference.position

            if self.playerReference.health <= 0 then
                self.playerReference = nil
            end
        end
    end
}

return playerManager