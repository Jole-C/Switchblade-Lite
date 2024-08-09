local hudElement require "src.interface.hudelement"
local gamemodeText = class({name = "Gamemode Text", extends = hudElement})

function gamemodeText:new(owner, gamemodes)
    self.owner = owner
    self.enabled = true

    self.gamemodeTextSpacing = 480
    self.shakeIntensity = 3
    self.shakeFade = 0.95

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
    self.gamemodeTextXOffset = 0
end

function gamemodeText:update(dt)
    self.shakeAmount = self.shakeAmount * self.shakeFade
    self.gamemodeTextXOffset = math.lerpDT(self.gamemodeTextXOffset, self.gamemodeTextSpacing * self.owner.selectionIndex - 1, 0.1, dt)
end

function gamemodeText:draw()
    love.graphics.setColor(game.manager.currentPalette.uiColour)

    for index, gamemode in ipairs(self.gamemodes) do
        local spacing = (self.gamemodeTextSpacing * index - self.owner.selectionIndex) - self.gamemodeTextXOffset
    
        love.graphics.setFont(self.alertFont)
        love.graphics.printf(gamemode.name, 0 + spacing, 0, game.arenaValues.screenWidth, "center")
    
        love.graphics.setFont(self.infoFont)
    
        local _, wrappedText = self.infoFont:getWrap(gamemode.description, 480)
        local textY = 125 - (self.infoFont:getHeight() * #wrappedText) / 2
    
        love.graphics.printf(gamemode.description, 0 + spacing, textY, game.arenaValues.screenWidth, "center")
    end
end

function gamemodeText:shake()
    self.shakeAmount = self.shakeIntensity
end

return gamemodeText