local enemyBase = require "src.objects.enemy.enemybase"
local enemy = class({name = "Enemy", extends = enemyBase})

function enemy:new(x, y, spriteName)
    self:super(x, y)
    -- Sounds
    self.deathSounds =
    {
        ripple.newSound(game.resourceManager:getResource("enemy hit 1")),
        ripple.newSound(game.resourceManager:getResource("enemy hit 2")),
        ripple.newSound(game.resourceManager:getResource("enemy hit 3")),
        ripple.newSound(game.resourceManager:getResource("enemy hit 4")),
        ripple.newSound(game.resourceManager:getResource("enemy hit 5")),
    }

    self.deathSounds = {}

    for i = 1, 5 do
        table.insert(self.deathSounds, ripple.newSound(game.resourceManager:getResource("enemy hit "..i)))
        self.deathSounds[i]:tag(game.tags.sfx)
    end
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
    local soundIndex = math.random(1, #self.deathSounds)
    local sound = self.deathSounds[soundIndex]

    if sound then
        sound:play()
    end
end

return enemy