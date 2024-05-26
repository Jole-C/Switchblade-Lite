local gameObject = require "game.objects.gameobject"
local cameraManager = class({name = "Camera Manager", extends = gameObject})

function cameraManager:new()
    self:super(0, 0)

    self.cameraReference = game.camera
    self.cameraTargets = {}

    self.cameraTargetPosition = vec2(0, 0)
    self.cameraPosition = vec2(0, 0)
    
    if self.cameraReference then
        self.cameraPosition.x, self.cameraPosition.y = game.camera:getPosition()
    end

    self.cameraLerpSpeed = 0.1
end

function cameraManager:update(dt)
    local numeratorX, denominatorX = 0, 0
    local numeratorY, denominatorY = 0, 0

    for i = 1, #self.cameraTargets do
        local target = self.cameraTargets[i]

        if target then
            numeratorX = numeratorX + target.position.x * target.weight
            numeratorY = numeratorY + target.position.y * target.weight

            denominatorX = denominatorX + target.weight
            denominatorY = denominatorY + target.weight
        end
    end

    self.cameraTargetPosition.x = numeratorX / denominatorX
    self.cameraTargetPosition.y = numeratorY / denominatorY

    self.cameraPosition.x = math.lerp(self.cameraPosition.x, self.cameraTargetPosition.x, self.cameraLerpSpeed)
    self.cameraPosition.y = math.lerp(self.cameraPosition.y, self.cameraTargetPosition.y, self.cameraLerpSpeed)

    game.camera:setPosition(self.cameraPosition.x, self.cameraPosition.y)
end

function cameraManager:addTarget(newTarget)
    table.insert(self.cameraTargets, newTarget)
end

function cameraManager:removeTarget(targetToRemove)
    tablex.remove_value(self.cameraTargets, targetToRemove)
end

return cameraManager