local gameObject = require "src.objects.gameobject"
local playerAmmoDisplay = class({name = "Player Ammo Display", extends = gameObject})

function playerAmmoDisplay:new(x, y)
    self:super(x, y)

    self.maxAmmoDisplayTime = 1
    self.ammoDisplayTime = self.maxAmmoDisplayTime

    self.ammoIncrementAmount = 0
    self.maxAmmoIncrementDisplayTime = 1
    self.ammoIncrementDisplayTime = 0

    self.displayAmmo = true

    self.ammoFont = game.resourceManager:getAsset("Interface Assets"):get("fonts"):get("fontMain")
    self.ammo = 0
end

function playerAmmoDisplay:update(dt)
    self.ammoDisplayTime = self.ammoDisplayTime - (1 * dt)
    self.ammoIncrementDisplayTime = self.ammoIncrementDisplayTime - (1 * dt)

    if self.ammoDisplayTime <= 0 and self.ammoIncrementDisplayTime <= 0 then
        self.displayAmmo = false
    end
end

function playerAmmoDisplay:draw()
    love.graphics.setColor(1, 1, 1, 1)
    
    if self.displayAmmo == true then
        local string = tostring(self.ammo)

        if self.ammoIncrementDisplayTime > 0 then
            string = string.."(".."+"..tostring(self.ammoIncrementAmount)..")"
        end
        
        love.graphics.setFont(self.ammoFont)
        local width = self.ammoFont:getWidth(string)

        love.graphics.printf(string, self.position.x - width/2, self.position.y + 10, width, "center")
    end
end

function playerAmmoDisplay:setDisplayAmmo(ammoIncrementAmount)
    self.displayAmmo = true
    self.ammoDisplayTime = self.maxAmmoDisplayTime

    if ammoIncrementAmount then
        self.ammoIncrementDisplayTime = self.maxAmmoIncrementDisplayTime
        self.ammoIncrementAmount = ammoIncrementAmount
    end
end

return playerAmmoDisplay