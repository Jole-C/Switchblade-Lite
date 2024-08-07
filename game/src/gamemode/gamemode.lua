local gamemode = class({name = "Gamemode"})
local enemyWarning = require "src.objects.enemy.enemywarning"
local worldAlertObject = require "src.objects.stagedirector.worldalertobject"

local text = require "src.interface.text"

function gamemode:new()
    self.totalKills = 0

    self.oneUpScore = 5000
    self.currentOneUps = 0

    self.debugText = text("", "fontMain", "left", 10, 200, game.arenaValues.screenWidth)
    game.interfaceRenderer:addHudElement(self.debugText)

    self.playerSpawnPosition = vec2(0, 0)
end

function gamemode:update()

end

function gamemode:draw()
    local debugText = ""

    debugText = self:setupDebugText(debugText)
    
    if game.manager:getOption("enableDebugMode") == true and self.debugText then
        self.debugText.text = debugText
    end
end

function gamemode:start()

end

function gamemode:setupDebugText(inputText)
    return inputText or ""
end

function gamemode:registerEnemyKill()
    self.totalKills = self.totalKills + 1
end

function gamemode:cleanup()
    game.interfaceRenderer:removeHudElement(self.debugText)
    
    game.manager:addRunInfoText("Kills", self.totalKills)
end

function gamemode:spawnEnemy(x, y, originSegment, spawnClass)
    local newWarning = enemyWarning(x, y, originSegment, spawnClass, self.enemySpawnTime)
    gameHelper:addGameObject(newWarning)
end

function gamemode:handleOneups()
    local scoreManager = gameHelper:getScoreManager()
    local player = game.playerManager.playerReference
    local playerPosition = game.playerManager.playerPosition

    if scoreManager.score > self.oneUpScore then
        if player then
            if player.health == player.maxHealth then
                player.maxHealth = player.maxHealth + 1
            end

            player.health = player.health + 1
        end

        self.oneUpScore = self.oneUpScore + self.oneUpScore
        self.oneUpSound:play()        
        
        gameHelper:addGameObject(worldAlertObject(playerPosition.x, playerPosition.y, "One up!", "fontScore"))
    end
end

return gamemode