local enemyEye = class{
    
    eyeDistance = 5,
    eyeRadius = 2,
    eyeBasePosition,
    eyePosition,

    init = function(self, eyeDistance, eyeRadius)
        self.eyeDistance = eyeDistance
        self.eyeRadius = eyeRadius
        self.eyeBasePosition = vector.new(0, 0)
        self.eyePosition = vector.new(0, 0)
    end,

    update = function(self)
        if not playerManager.playerReference then
            return
        end

        local eyeAngle = self.eyeBasePosition:angleTo(playerManager.playerReference.position)
        self.eyePosition.x = self.eyeBasePosition.x + math.cos(eyeAngle) * self.eyeDistance
        self.eyePosition.y = self.eyeBasePosition.y + math.sin(eyeAngle) * self.eyeDistance
    end,

    draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.circle("fill", self.eyePosition.x, self.eyePosition.y, self.eyeRadius)
    end
}

return enemyEye