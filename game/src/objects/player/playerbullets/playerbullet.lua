local bullet = require "src.objects.bullet.bullet"
local playerBullet = class({name = "Player Bullet", extends = bullet})

function playerBullet:new(x, y, speed, angle, damage, colliderDefinition, width, height)
    self:super(x, y, speed, angle, damage, colliderDefinition, width, height)
    self.targetEnemy = nil
    self.targetEnemyAngleLerpRate = 0.02

    local enemyManager = gameHelper:getCurrentState().enemyManager
    local validEnemies = {}

    if enemyManager and math.random(0, 100) > 75 then
        for _, enemy in pairs(enemyManager.enemies) do
            local vectorToEnemy = (enemy.position - self.position)
            local dot = vectorToEnemy:dot(vec2(math.cos(self.angle), math.sin(self.angle)))

            if dot > 0.99 then
                table.insert(validEnemies, enemy)
            end
        end

        self.targetEnemy = validEnemies[math.random(1, #validEnemies)]
    end
end

function playerBullet:update(dt)
    bullet.update(self, dt)

    if self.targetEnemy then
        self.angle = math.lerpAngle(self.angle, (self.targetEnemy.position - self.position):angle(), self.targetEnemyAngleLerpRate, dt)
    end
end

function playerBullet:handleCollision(collider, collidedObject, colliderDefinition)
    if colliderDefinition == colliderDefinitions.enemy then
        if collidedObject.onHit then
            collidedObject:onHit("bullet", self.damage)
            self:destroy()
        end
    end

    return false
end

function playerBullet:draw()
    love.graphics.setColor(game.manager.currentPalette.playerColour)
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius/2)
    love.graphics.setColor(1, 1, 1, 1)
end

return playerBullet