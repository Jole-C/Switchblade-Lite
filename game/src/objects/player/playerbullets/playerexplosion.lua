local explosion = require "src.objects.bullet.explosion"
local playerExplosion = class({name = "Player Explosion", extends = explosion})

function playerExplosion:new(x, y, radius, damage)
    self:super(x, y, radius, damage, "line", game.manager.currentPalette.playerColour)

    local explosionBurst = game.particleManager:getEffect("Explosion Burst")
    explosionBurst.systems[1]:setColors(game.manager.currentPalette.playerColour[1], game.manager.currentPalette.playerColour[2], game.manager.currentPalette.playerColour[3], 1)
end

function playerExplosion:handleExplosion()
    local enemyManager = gameHelper:getCurrentState().enemyManager

    if enemyManager and enemyManager.enemies then
        for i = 1, #enemyManager.enemies do
            local enemy = enemyManager.enemies[i]

            if enemy then
                local vectorToEnemy = (self.position - enemy.position)

                if vectorToEnemy:length() < self.radius then
                    if enemy.onHit then
                        enemy:onHit({type = "boost", amount = self.damage})
                    end
                end
            end
        end
    end
end

function playerExplosion:update(dt)
    explosion.update(self, dt)

    local player = game.playerManager.playerReference

    if player then
        player:setInvulnerable()
    end

    game.particleManager:burstEffect("Explosion Burst", 5, self.position)
    self.drawColour = game.manager.currentPalette.playerColour
end

return playerExplosion