local enemyEye = class({name = "EnemyEye"})

function enemyEye:new(baseX, baseY, eyeDistance, eyeRadius)
    self.eyeDistance = eyeDistance
    self.eyeRadius = eyeRadius
    self.eyeBasePosition = vec2(baseX or 0, baseY or 0)
    self.eyePosition = vec2(baseX or 0, baseY or 0)
end

function enemyEye:update()
    if not playerManager.playerReference then
        return
    end

    local eyeAngle = self.eyeBasePosition:angle_difference(playerManager.playerReference.position)
    self.eyePosition.x = self.eyeBasePosition.x + math.cos(eyeAngle) * self.eyeDistance
    self.eyePosition.y = self.eyeBasePosition.y + math.sin(eyeAngle) * self.eyeDistance
end

function enemyEye:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.circle("fill", self.eyePosition.x, self.eyePosition.y, self.eyeRadius)
end

return enemyEye