local explosion = require "src.objects.bullet.explosion"
local playerExplosion = class({name = "Player Explosion", extends = explosion})

function playerExplosion:new(x, y, radius, damage)
    self:super(x, y, radius, damage, "line", game.manager.currentPalette.playerColour)
end

function playerExplosion:handleExplosion()
    local enemyManager = gameHelper:getCurrentState().enemyManager

    if enemyManager then
        for _, enemy in pairs(enemyManager.enemies) do
            if enemy then
                local vectorToEnemy = (self.position - enemy.position)

                if vectorToEnemy:length() < self.radius then
                    if enemy.onHit then
                        enemy:onHit("boost", self.damage)
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
    
    local explosionBurst = game.particleManager:getEffect("Explosion Burst")
    explosionBurst.systems[1]:setColors(game.manager.currentPalette.playerColour[1], game.manager.currentPalette.playerColour[2], game.manager.currentPalette.playerColour[3], 1)
    
    self.drawColour = game.manager.currentPalette.playerColour
end

return playerExplosion