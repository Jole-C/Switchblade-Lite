local hudElement = require "src.interface.hudelement"
local playerHud = class({name = "Player Hud", extends = hudElement})

function playerHud:new()
    self:super()

    self.playerReference = nil
    self.font = game.resourceManager_REPLACESEARCH:getAsset("Interface Assets"):get("fonts"):get("fontMain")
end

function playerHud:update(dt)
    hudElement.update(self, dt)

    self.playerReference = game.playerManager.playerReference
end

function playerHud:draw()
    hudElement.draw(self)
    
    if self.playerReference == nil then
        return
    end

    love.graphics.setFont(self.font)
    love.graphics.print(math.floor(self.playerReference.shipTemperature), 10, 10)
    love.graphics.print(self.playerReference.health, 10, 20)
    love.graphics.print(math.abs(math.ceil(self.playerReference.ammo)), 10, 30)
end

return playerHud