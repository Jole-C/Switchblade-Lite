local gameObject = require "game.objects.gameobject"

local arena = class{
    __includes = gameObject,

    circleSize = 5,
    circleWarpAmplitude = 15,
    circleWarpFrequency = 0.5,
    circleWarpTime = 0,

    circleSpacing = 50,
    numberOfCircles = 10,

    arenaScale = 0,
    doIntro = false,

    init = function(self)
        self.maxArenaScale = arenaRadius
    end,

    update = function(self, dt)
        -- Animate the background circles
        self.circleWarpTime = self.circleWarpTime + self.circleWarpFrequency * dt
        self.circleSize = math.sin(self.circleWarpTime) * self.circleWarpAmplitude

        -- Scale the arena on intro
        if self.doIntro then
            self.arenaScale = math.lerp(self.arenaScale, 1, 0.01)
        end
    end,

    draw = function(self)
        love.graphics.setColor(0.1, 0, 0.1, 1)
        love.graphics.circle("fill", arenaPosition.x, arenaPosition.y, arenaRadius * self.arenaScale)
        
        love.graphics.stencil(function()
            love.graphics.circle("fill", arenaPosition.x, arenaPosition.y, arenaRadius * self.arenaScale)
        end, "replace", 1, false)

        love.graphics.setStencilTest("equal", 1)

        love.graphics.setColor(0.13, 0, 0.13, 1)

        local backgroundSize = self.numberOfCircles * self.circleSpacing

        for x = 1, self.numberOfCircles do
            for y = 1, self.numberOfCircles do
                love.graphics.circle("fill", -backgroundSize/2 + x * self.circleSpacing, -backgroundSize/2 + y * self.circleSpacing, self.circleSize)
            end
        end

        love.graphics.setStencilTest()

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", arenaPosition.x, arenaPosition.y, arenaRadius * self.arenaScale)
        love.graphics.setLineWidth(1)

        love.graphics.setStencilTest("equal", 1)
    end,

    enableIntro = function(self)
        self.doIntro = true
    end,

    getClampedPosition = function(self, position)
        return position:trimmed(arenaRadius)
    end,

    getDistanceToArena = function(self, position)
        return (position - arenaPosition):len()
    end
}

return arena