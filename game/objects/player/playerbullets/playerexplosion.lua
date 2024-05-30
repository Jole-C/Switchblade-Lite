local explosion = require "game.objects.bullet.explosion"
local playerExplosion = class({name = "Player Explosion", extends = explosion})

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

return playerExplosion