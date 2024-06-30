local playerManager = class({name = "Player Manager"})

function playerManager:new()
    self.playerPosition = vec2(0, 0)
    self.playerReference = nil
    self.deathReason = ""

    self.runInfo =
    {
        deathReason = "NO REASON",
        time =
        {
            minutes = 0,
            seconds = 0,
        },
        bossTime =
        {
            minutes = 0,
            seconds = 0,
        },
        score = 0,
        kills = 0,
    }
end

function playerManager:spawnPlayer(x, y)
    local newPlayer = game.manager.currentPlayerDefinition.shipClass(x, y)
    self.playerReference = newPlayer

    return newPlayer
end

function playerManager:resetRunInfo()
    self.runInfo =
    {
        deathReason = "NO REASON",
        time =
        {
            minutes = 0,
            seconds = 0,
        },
        score = 0,
        kills = 0,
    }
end

function playerManager:destroyPlayer(x, y)
    if self.playerReference then
        self.playerReference:destroy()
        self.playerReference = nil
    end
end

function playerManager:doesPlayerExist()
    return self.playerReference ~= nil
end

function playerManager:update()
    if self.playerReference then
        self.playerPosition = self.playerReference.position

        if self.playerReference.health <= 0 or self.playerReference.markedForDelete then
            self.playerReference = nil
        end
    end
end

return playerManager
