local playerManager = class({name = "Player Manager"})

function playerManager:new()
    self.playerPosition = vec2(0, 0)
    self.playerReference = nil
    self.deathReason = ""

    self.scoreMultiplier = 1
    self.maxMultiplierResetTime = 3
    self.multiplierResetTime = 0
    self.multiplierPaused = false

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

function playerManager:update(dt)
    if self.playerReference then
        self.playerPosition = self.playerReference.position

        if self.playerReference.health <= 0 or self.playerReference.markedForDelete then
            self.playerReference = nil
            return
        end
    end

    if self.multiplierPaused then
        return
    end

    self.multiplierResetTime = self.multiplierResetTime - (1 * dt)

    if self.multiplierResetTime <= 0 then
        self:resetMultiplier(true)
    end
end

function playerManager:resetMultiplier(playSound)
    if self.multiplierResetSound == nil then
        self.multiplierResetSound = game.resourceManager:getAsset("Interface Assets"):get("sounds"):get("multiplierReset")
    end

    if self.scoreMultiplier > 1 and playSound then
        self.multiplierResetSound:play()
    end

    self.scoreMultiplier = 1
    self.multiplierResetTime = 0
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
        bossTime =
        {
            minutes = 0,
            seconds = 0,
        },
        score = 0,
        kills = 0,
    }
end

function playerManager:setMultiplierPaused(multiplierPaused)
    self.multiplierPaused = multiplierPaused
end

function playerManager:destroyPlayer()
    if self.playerReference then
        self.playerReference:destroy()
        self.playerReference = nil
    end
end

function playerManager:doesPlayerExist()
    return self.playerReference ~= nil
end

function playerManager:addScore(score, multiplier)
    self.runInfo.score = self.runInfo.score + (score * multiplier)
end

function playerManager:incrementMultiplier()
    self.scoreMultiplier = self.scoreMultiplier + 1
    self.multiplierResetTime = self.maxMultiplierResetTime
end

return playerManager
