local gameObject = require "src.objects.gameobject"
local arenaSegment = require "src.objects.arenasegment"

local arenaController = class({name = "Arena Controller", extends = gameObject})

function arenaController:new()
    self:super(0, 0)    
    
    -- Background parameters
    self.circleSize = 10
    self.circleWarpAmplitude = 15
    self.circleWarpFrequency = 0.2
    self.circleSpacing = 20
    self.numberOfCircles = 100

    -- Variables
    self.circleWarpTime = 0
    self.arenaSegments = {}
    self.segmentIndices = {}
    self.numberOfSegments = 0
    self.arenaScale = 0
    self.doIntro = false
    self.doOutro = false
    self.outroComplete = false
end

function arenaController:update(dt)
    if self.numberOfSegments <= 0 then
        return
    end

    -- Animate the background circles
    self.circleWarpTime = self.circleWarpTime + self.circleWarpFrequency * dt
    self.circleSize = math.sin(self.circleWarpTime) * self.circleWarpAmplitude

    -- Scale the arena on intro
    if self.doIntro then
        self.arenaScale = math.lerpDT(self.arenaScale, 1, 0.01, dt)

        if self.arenaScale > 0.99 then
            self.doIntro = false
        end
    end

    if self.doOutro then
        self.arenaScale = math.lerpDT(self.arenaScale, 0, 0.05, dt)

        if self.arenaScale < 0.01 then
            self.outroComplete = true
        end
    end
end

function arenaController:draw()
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.setLineWidth(3)
    self:drawSegments("line")
    love.graphics.setLineWidth(1)

    love.graphics.setColor(0.1, 0, 0.1, 1)

    self:drawSegments("fill")
    
    self:setArenaStencil()
    self:setArenaStencilTest()

    love.graphics.setColor(0.13, 0, 0.13, 1)

    local backgroundSize = self.numberOfCircles * self.circleSpacing

    for x = 1, self.numberOfCircles do
        for y = 1, self.numberOfCircles do
            love.graphics.circle("fill", -backgroundSize/2 + x * self.circleSpacing, -backgroundSize/2 + y * self.circleSpacing, self.circleSize, 10)
        end
    end
end

function arenaController:setArenaStencil()
    love.graphics.stencil(function()
        self:drawSegments()
    end, "replace", 1, false)
end

function arenaController:setArenaStencilTest()
    love.graphics.setStencilTest("equal", 1)
end

function arenaController:enableIntro()
    self.doIntro = true
end

function arenaController:enableOutro()
    self.doOutro = true
end

function arenaController:getClampedPosition(position)
    if self.numberOfSegments <= 0 then
        print("No segments!")
        return position, nil
    end

    -- Decide if the position is within any circle or not
    -- If it is just return the position
    for k, v in pairs(self.arenaSegments) do
        local segment = v

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

    for k, v in pairs(self.arenaSegments) do
        local segment = v

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

    return position, nil
end

function arenaController:getDistanceToArena(position)
    for k, v in pairs(self.arenaSegments) do
        local segment = v

        if segment then
            local positionToSegment = (segment.position - position)

            return positionToSegment:length()
        end
    end
end

function arenaController:getSegmentPointIsWithin(position)
    local eligibleSegments = {}

    for k, v in pairs(self.arenaSegments) do
        local segment = v

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
end

function arenaController:isPositionWithinArena(position)
    for k, v in pairs(self.arenaSegments) do
        local segment = v

        if segment then
            local positionToSegment = (segment.position - position)

            if positionToSegment:length() < segment.radius then
                return true
            end
        end
    end

    return false
end

function arenaController:getRandomSegment()
    local randomIndex = self.segmentIndices[math.random(1, #self.segmentIndices)]

    for k, v in pairs(self.arenaSegments) do
        if k == randomIndex then
            return v
        end
    end
end

function arenaController:addArenaSegment(x, y, radius, name)
    local newSegment = arenaSegment(x, y, radius)
    print(newSegment)
    gameHelper:addGameObject(newSegment)

    self.arenaSegments[name] = newSegment
    table.insert(self.segmentIndices, name)

    for k, v in pairs(self.arenaSegments) do
        self.numberOfSegments = self.numberOfSegments + 1
    end

    return newSegment
end

function arenaController:getRandomPosition(maximumDistancePercentage)
    maximumDistancePercentage = maximumDistancePercentage or 1

    local segment = self:getRandomSegment()

    local segmentPosition = segment.position:copy()
    local randomDirection = segmentPosition:rotate_inplace(math.random(0, 2 * math.pi))

    randomDirection = randomDirection * (segment.radius * math.random(0, maximumDistancePercentage))

    return randomDirection
end

function arenaController:drawSegments(fillType)
    for k, v in pairs(self.arenaSegments) do
        local segment = v

        if segment then
            love.graphics.circle(fillType or "fill", segment.position.x, segment.position.y, segment.radius * self.arenaScale)
        end
    end
end

function arenaController:getArenaSegment(name)
    return self.arenaSegments[name]
end

return arenaController
