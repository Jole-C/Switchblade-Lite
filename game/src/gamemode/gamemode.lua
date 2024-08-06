local gamemode = class({name = "Gamemode"})
local text = require "src.interface.text"

function gamemode:new()
    self.totalKills = 0

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

end

function gamemode:cleanup()
    game.interfaceRenderer:removeHudElement(self.debugText)
    gameHelper:getScoreManager():applyWaveScore()
    
    game.manager:addRunInfoText("Kills", self.totalKills)
end

return gamemode