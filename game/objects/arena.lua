local gameObject = require "game.objects.gameobject"
local arenaController = class({name = "Arena Controller", extends = gameObject})

function arenaController:new()
    self:super(0, 0)    
    
    self.circleSize = 10
    self.circleWarpAmplitude = 15
    self.circleWarpFrequency = 0.2
    self.circleSpacing = 20
    self.numberOfCircles = 100

    self.circleWarpTime = 0
    self.arenaSegments = {}
    self.arenaScale = 0
    self.doIntro = false
end

function arenaController:update(dt)
    assert(#self.arenaSegments > 0, "Number of arena segments cannot be 0!")

    -- Animate the background circles
    self.circleWarpTime = self.circleWarpTime + self.circleWarpFrequency * dt
    self.circleSize = math.sin(self.circleWarpTime) * self.circleWarpAmplitude

    -- Scale the arena on intro
    if self.doIntro then
        self.arenaScale = math.lerp(self.arenaScale, 1, 0.01)
    end
end

function arenaController:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(3)

    self:drawSegments("line")

    love.graphics.setLineWidth(1)

    love.graphics.setColor(0.1, 0, 0.1, 1)

    self:drawSegments()
    
    love.graphics.stencil(function()
        self:drawSegments()
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
end

function arenaController:enableIntro()
    self.doIntro = true
end

function arenaController:getClampedPosition(position)
    if #self.arenaSegments == 0 then
        return
    end

    -- Decide if the position is within any circle or not
    -- If it is just return the position
    for i = 1, #self.arenaSegments do
        local segment = self.arenaSegments[i]

        if segment then
            local positionToSegment = (segment.position - position)

            if positionToSegment:length() < segment.radius then
                return position, segment
            end
        end
    end

    -- If it isn't compute the closest distance
    local minDistance = math.huge
    local closestCircle = nil
    local closestEdgePosition = nil

    for i = 1, #self.arenaSegments do
        local segment = self.arenaSegments[i]

        if segment then
            local positionToSegment = (position - segment.position)
            local normalise = positionToSegment:normalise()

            normalise = normalise * segment.radius

            local edgePosition = segment.position + normalise
            local edgeToPosition = (position - edgePosition)

            if edgeToPosition:length() < minDistance then
                minDistance = edgeToPosition:length()
                closestCircle = segment
                closestEdgePosition = edgePosition
            end
        end
    end

    if closestCircle then
        return closestEdgePosition, closestCircle
    end

    return position:min_inplace(arenaRadius), nil
end

function arenaController:getDistanceToArena(position)
    for i = 1, #self.arenaSegments do
        local segment = self.arenaSegments[i]

        if segment then
            local positionToSegment = (segment.position - position)

            return positionToSegment:length()
        end
    end
end

function arenaController:getSegmentPointIsWithin(position)
    local eligibleSegments = {}

    for i = 1, #self.arenaSegments do
        local segment = self.arenaSegments[i]

        if segment then
            local positionToSegment = (segment.position - position)

            if positionToSegment:length() < segment.radius then
                table.insert(eligibleSegments, segment)
            end
        end
    end

    if #eligibleSegments == 1 then
        return eligibleSegments[1]
    else
        local closestSegment = nil
        local minimumDistance = math.huge
        for i = 1, #eligibleSegments do
            local segment = eligibleSegments[i]

            if segment.radius < minimumDistance then
                closestSegment = segment
                minimumDistance = segment.radius
            end
        end

        return closestSegment
    end

    return nil
end

function arenaController:isPositionWithinArena(position)
    for i = 1, #self.arenaSegments do
        local segment = self.arenaSegments[i]

        if segment then
            local positionToSegment = (segment.position - position)

            if positionToSegment:length() < segment.radius then
                return true
            end
        end
    end

    return false
end

function arenaController:addArenaSegment(segment)
    return table.insert(self.arenaSegments, segment)
end

function arenaController:cleanup()
end

function arenaController:drawSegments(fillType)
    for i = 1, #self.arenaSegments do
        local segment = self.arenaSegments[i]

        if segment then
            love.graphics.circle(fillType or "fill", segment.position.x, segment.position.y, segment.radius * self.arenaScale)
        end
    end
end

return arenaController
