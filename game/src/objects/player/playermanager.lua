local playerManager = class({name = "Player Manager"})

function playerManager:new()
    self.playerPosition = vec2(0, 0)
    self.playerReference = nil
    self.playerBullets = {}
    self.deathReason = ""

    self.scoreMultiplier = 1
    self.maxMultiplierResetTime = 3
    self.multiplierResetTime = 0
    self.multiplierPaused = false
end

function playerManager:update(dt)
    for i = #self.playerBullets, 1, -1 do
        local playerBullet = self.playerBullets[i]

        if playerBullet.markedForDelete then
            table.remove(self.playerBullets, i)
        end
    end
    
    if self.playerReference then
        self.playerPosition = self.playerReference.position

        if self.playerReference.health <= 0 or self.playerReference.markedForDelete then
            self.playerReference = nil
            return
        end
    end
end

function playerManager:registerPlayerBullet(bullet)
    assert(bullet ~= nil, "Player bullet is nil!")
    table.insert(self.playerBullets, bullet)
end

function playerManager:spawnPlayer(x, y)
    local newPlayer = game.manager.currentPlayerDefinition.shipClass(x, y)
    self.playerReference = newPlayer

    return newPlayer
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

return playerManager
