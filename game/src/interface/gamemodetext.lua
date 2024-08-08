local hudElement require "src.interface.hudelement"
local gamemodeText = class({name = "Gamemode Text", extends = hudElement})

function gamemodeText:new(owner, gamemodes)
    self.owner = owner
    self.enabled = true

    self.gamemodes = gamemodes or {
        {name = "", description = ""},
        {name = "", description = ""},
        {name = "Endless", description = "Defeat an endless barrage of enemies!"},
        {name = "Rush", description = "Beat your high score within the time limit!"},
        {name = "Denial", description = "Your ship is invulnerable, but\nareas spawn that heat your Switchblade!"},
        {name = "Chaos", description = "TO DO"},
        {name = "Crowd", description = "Enemies in proximity to your\nSwitchblade heat it up!"},
        {name = "Challenge", description = "Conquer a set of challenges\nand difficult bosses!"},
    }    

    self.infoFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontUI")
    self.alertFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontAlert")
end

function gamemodeText:draw()
    local currentGamemodeSelection = self.gamemodes[self.owner.selectionIndex] or {name = "", description = ""}

    love.graphics.setColor(game.manager.currentPalette.uiColour)

    love.graphics.setFont(self.alertFont)
    love.graphics.printf(currentGamemodeSelection.name, 0, 0, game.arenaValues.screenWidth, "center")

    
    love.graphics.setFont(self.infoFont)
    love.graphics.printf(currentGamemodeSelection.description, 0, 135, game.arenaValues.screenWidth, "center")

    love.graphics.setColor(1, 1, 1, 1)
end

return gamemodeText