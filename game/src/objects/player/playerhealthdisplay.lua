local gameObject = require "src.objects.gameobject"
local playerHealthDisplay = class({name = "Player Health Display", extends = gameObject})

function playerHealthDisplay:new(x, y)
    self:super(x, y)

    self.maxHealthDisplayTime = 1
    self.healthDisplayTime = self.maxHealthDisplayTime
    self.displayHealth = true

    self.healthFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontMain")
    self.health = 0
    self.maxHealth = 0
end

function playerHealthDisplay:draw()
    love.graphics.setColor(1, 1, 1, 1)
    
    if self.health < self.maxHealth then
        love.graphics.setFont(self.healthFont)
        local text = tostring(math.floor(self.health)).."/"..self.maxHealth
        local width = self.healthFont:getWidth(text) + 5
        local height = self.healthFont:getHeight(text)

        love.graphics.printf(text, self.position.x + 10, self.position.y - height/2, width, "center")
    end
end

return playerHealthDisplay