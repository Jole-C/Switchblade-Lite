local gameObject = require "src.objects.gameobject"
local playerAmmoDisplay = class({name = "Player Ammo Display", extends = gameObject})

function playerAmmoDisplay:new(x, y)
    self:super(x, y)

    self.maxAmmoDisplayTime = 1
    self.ammoDisplayTime = self.maxAmmoDisplayTime
    self.displayAmmo = true

    self.ammoFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontMain")
    self.ammo = 0
end

function playerAmmoDisplay:update(dt)
    self.ammoDisplayTime = self.ammoDisplayTime - 1 * dt

    if self.ammoDisplayTime <= 0 then
        self.displayAmmo = false
    end
end

function playerAmmoDisplay:draw()
    love.graphics.setColor(1, 1, 1, 1)
    
    if self.displayAmmo == true then
        love.graphics.setFont(self.ammoFont)
        local width = self.ammoFont:getWidth(self.ammo)

        love.graphics.printf(tostring(self.ammo), self.position.x - width/2, self.position.y + 10, width, "center")
    end
end

function playerAmmoDisplay:setDisplayAmmo()
    self.displayAmmo = true
    self.ammoDisplayTime = self.maxAmmoDisplayTime
end

return playerAmmoDisplay