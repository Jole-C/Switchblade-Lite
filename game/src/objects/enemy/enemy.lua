local enemyBase = require "src.objects.enemy.enemybase"
local enemy = class({name = "Enemy", extends = enemyBase})

function enemy:new(x, y, spriteName)
    self:super(x, y)
    -- Sounds
    self.deathSounds = game.resourceManager_REPLACESEARCH:getAsset("Enemy Assets"):get("deathSounds")
end

function enemy:update(dt)
    enemyBase.update(self, dt)
end

function enemy:cleanup(destroyReason)
    enemyBase.cleanup(self, destroyReason)

    if destroyReason ~= "autoDestruction" then
        self:playDeathSound()
    end

    game.particleManager:burstEffect("Explosion", 50, self.position)
end

function enemy:playDeathSound()
    local sound = self.deathSounds:get()
    sound:play()
end

return enemy