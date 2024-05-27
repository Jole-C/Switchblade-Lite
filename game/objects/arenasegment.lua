local gameObject = require "game.objects.gameobject"
local arenaSegment = class({name = "Arena Segment", extends = gameObject})

function arenaSegment:new(x, y, radius)
    self:super(x, y)

    self.radius = radius

    self.segmentChanges = {}
    self.changeLerpSpeed = 0
    self.originPosition = vec2(x, y)
    self.originRadius = radius
end

function arenaSegment:update()
    for i = #self.segmentChanges, 1, -1 do
        local change = self.segmentChanges[i]
        local changeType = change.changeType
        self.changeLerpSpeed = change.lerpSpeed

        if changeType == "position" then
            self.position.x = math.lerp(self.position.x, change.newPosition.x, self.changeLerpSpeed)
            self.position.y = math.lerp(self.position.y, change.newPosition.y, self.changeLerpSpeed)

            if (change.newPosition - self.position):length() < 3 then
                table.remove(self.segmentChanges, i)
            end
        elseif changeType == "size" then
            self.radius = math.lerp(self.radius, change.newRadius, self.changeLerpSpeed)

            if (change.newRadius - self.radius) < 3 then
                table.remove(self.segmentChanges, i)
            end
        elseif changeType == "reset" then
            self.radius = math.lerp(self.radius, self.originRadius, self.changeLerpSpeed)
            self.position.x = math.lerp(self.position.x, self.originPosition.x, self.changeLerpSpeed)
            self.position.y = math.lerp(self.position.y, self.originPosition.y, self.changeLerpSpeed)

            if (self.radius - self.originRadius) < 3 and (self.originPosition - self.position):length() < 3 then
                table.remove(self.segmentChanges, i)
            end
        end
    end
end

function arenaSegment:addChange(newChangeType)
    table.insert(self.segmentChanges, newChangeType)
end

return arenaSegment