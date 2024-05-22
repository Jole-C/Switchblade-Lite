local gameObject = require "game.objects.gameobject"

local arenaController = class{
    __includes = gameObject,

    circleSize = 10,
    circleWarpAmplitude = 15,
    circleWarpFrequency = 0.2,
    circleWarpTime = 0,

    circleSpacing = 20,
    numberOfCircles = 30,

    arenaSegments = {},

    arenaScale = 0,
    doIntro = false,

    init = function(self)
        self.maxArenaScale = arenaRadius

        local radius = math.random(100, 300)
    end,

    update = function(self, dt)
        assert(#self.arenaSegments > 0, "Number of arena segments cannot be 0!")

        -- Animate the background circles
        self.circleWarpTime = self.circleWarpTime + self.circleWarpFrequency * dt
        self.circleSize = math.sin(self.circleWarpTime) * self.circleWarpAmplitude

        -- Scale the arena on intro
        if self.doIntro then
            self.arenaScale = math.lerp(self.arenaScale, 1, 0.01)
        end
    end,

    draw = function(self)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(3)

        for i = 1, #self.arenaSegments do
            local segment = self.arenaSegments[i]

            if segment then
                love.graphics.circle("line", segment.position.x, segment.position.y, segment.radius * self.arenaScale)
            end
        end

        love.graphics.setLineWidth(1)

        love.graphics.setColor(0.1, 0, 0.1, 1)

        for i = 1, #self.arenaSegments do
            local segment = self.arenaSegments[i]

            if segment then
                love.graphics.circle("fill", segment.position.x, segment.position.y, segment.radius * self.arenaScale)
            end
        end
        
        love.graphics.stencil(function()
            for i = 1, #self.arenaSegments do
                local segment = self.arenaSegments[i]
    
                if segment then
                    love.graphics.circle("fill", segment.position.x, segment.position.y, segment.radius * self.arenaScale)
                end
            end
        end, "replace", 1, false)

        love.graphics.setStencilTest("equal", 1)

        love.graphics.setColor(0.13, 0, 0.13, 1)

        local backgroundSize = self.numberOfCircles * self.circleSpacing

        for x = 1, self.numberOfCircles do
            for y = 1, self.numberOfCircles do
                love.graphics.circle("fill", -backgroundSize/2 + x * self.circleSpacing, -backgroundSize/2 + y * self.circleSpacing, self.circleSize, 10)
            end
        end

        love.graphics.setStencilTest()

        love.graphics.setStencilTest("equal", 1)
    end,

    enableIntro = function(self)
        self.doIntro = true
    end,

    getClampedPosition = function(self, position)
        if #self.arenaSegments == 0 then
            return
        end

        -- Decide if the position is within any circle or not
        -- If it is just return the position
        for i = 1, #self.arenaSegments do
            local segment = self.arenaSegments[i]

            if segment then
                local positionToSegment = (segment.position - position)

                if positionToSegment:len() < segment.radius then
                    return position
                end
            end
        end

        -- If it isn't comptue the closest distance
        local minDistance = math.huge
        local closestCircle = nil
        local closestEdgePosition = nil

        for i = 1, #self.arenaSegments do
            local segment = self.arenaSegments[i]

            if segment then
                local positionToSegment = (position - segment.position)
                local normalized = positionToSegment:normalized()

                normalized = normalized * segment.radius

                local edgePosition = segment.position + normalized
                local edgeToPosition = (position - edgePosition)

                if edgeToPosition:len() < minDistance then
                    minDistance = edgeToPosition:len()
                    closestCircle = segment
                    closestEdgePosition = edgePosition
                end
            end
        end

        if closestCircle then
            return closestEdgePosition
        end

        return position:trimmed(arenaRadius)
    end,

    getDistanceToArena = function(self, position)
        for i = 1, #self.arenaSegments do
            local segment = self.arenaSegments[i]

            if segment then
                local positionToSegment = (segment.position - position)

                return positionToSegment:len()
            end
        end
    end,

    isPositionWithinArena = function(self, position)
        for i = 1, #self.arenaSegments do
            local segment = self.arenaSegments[i]

            if segment then
                local positionToSegment = (segment.position - position)

                if positionToSegment:len() < segment.radius then
                    return true
                end
            end
        end

        return false
    end,

    addArenaSegment = function(self, segment)
        return table.insert(self.arenaSegments, segment)
    end,

    cleanup = function(self)
        self.arenaSegments = {}
    end
}

return arenaController