local enemyBase = require "src.objects.enemy.enemybase"
local enemy = class({name = "Enemy", extends = enemyBase})

function enemy:new(x, y, spriteName)
    self:super(x, y)

    -- Components
    self.sprite = game.resourceManager:getResource(spriteName)
end

function enemy:update(dt)
    enemyBase.update(self, dt)
end

function enemy:cleanup()
    enemyBase.cleanup(self)
end

return enemy