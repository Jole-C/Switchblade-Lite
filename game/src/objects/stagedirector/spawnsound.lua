local gameObject = require "src.objects.gameobject"
local spawnSound = class({name = "Spawn Sound", extends = gameObject})

function spawnSound:new(delayTime)
    self.delayTime = delayTime

    self.spawnSound = game.resourceManager:getAsset("Enemy Assets"):get("spawnSounds"):get("spawn")
    self.warningSound = game.resourceManager:getAsset("Enemy Assets"):get("spawnSounds"):get("warning")

    self.warningSound:play()
end

function spawnSound:update(dt)
    self.delayTime = self.delayTime - (1 * dt)

    if self.delayTime <= 0 then
        self:destroy()
        self.spawnSound:play()
        gameHelper:screenShake(0.1)
    end
end

return spawnSound