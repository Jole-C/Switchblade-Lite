local hudElement require "src.interface.hudelement"
local gamemodeText = class({name = "Gamemode Text", extends = hudElement})

function gamemodeText:new(owner, gamemodes)
    self.owner = owner
    self.enabled = true

    self.gamemodes = gamemodes or {
        {name = "", description = ""},
        {name = "Back", description = "Return to the main menu"},
        {name = "Endless", description = "Defeat an endless barrage of enemies!"},
        {name = "Rush", description = "Beat your high score within the time limit!"},
        {name = "Denial", description = "Your ship is invulnerable, but\nareas spawn that heat your Switchblade!"},
        {name = "Chaos", description = "TO DO"},
        {name = "Crowd", description = "Enemies in proximity to your\nSwitchblade heat it up!"},
        {name = "Challenge", description = "Conquer a set of challenges\nand difficult bosses!"},
    }    

    self.infoFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontUI")
    self.alertFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontAlert")

    self.shakeAmount = 0
    self.shakeIntensity = 5
    self.shakeFade = 0.95
end

function gamemodeText:update(dt)
    self.shakeAmount = self.shakeAmount * self.shakeFade
end

function gamemodeText:draw()
    local currentGamemodeSelection = self.gamemodes[self.owner.selectionIndex] or {name = "", description = ""}
    local shakeX = math.random(-self.shakeAmount, self.shakeAmount)
    local shakeY = math.random(-self.shakeAmount, self.shakeAmount)

    love.graphics.setColor(game.manager.currentPalette.uiColour)

    love.graphics.setFont(self.alertFont)
    love.graphics.printf(currentGamemodeSelection.name, 0 + shakeX, 0 + shakeY, game.arenaValues.screenWidth, "center")

    love.graphics.setFont(self.infoFont)

    local _, wrappedText = self.infoFont:getWrap(currentGamemodeSelection.description, 480)
    local textY = 125 - (self.infoFont:getHeight() * #wrappedText) / 2

    love.graphics.printf(currentGamemodeSelection.description, 0 + shakeX, textY + shakeY, game.arenaValues.screenWidth, "center")

    love.graphics.setColor(1, 1, 1, 1)
end

function gamemodeText:shake()
    self.shakeAmount = self.shakeIntensity
end

return gamemodeText