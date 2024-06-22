local gameObject = require "src.objects.gameobject"
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

    self.cameraLerpSpeed = 1

    self.screenShakeAmount = 0
    self.cameraShakeOffset = vec2(0, 0)
    self.shakeFadeAmount = 0.95
    
    self.cameraShakeRange = 32
end

function cameraManager:update(dt)
    local numeratorX, numeratorY = 0, 0
    local denominator = 0

    for _, target in pairs(self.cameraTargets) do
        if target.weight > 0 then
            numeratorX = numeratorX + target.position.x * target.weight
            numeratorY = numeratorY + target.position.y * target.weight

            denominator = denominator + target.weight
        end
    end

    if denominator > 0 then
        self.cameraTargetPosition.x = numeratorX / denominator
        self.cameraTargetPosition.y = numeratorY / denominator
    end

    self.cameraShakeOffset.x = math.random(-self.cameraShakeRange, self.cameraShakeRange)
    self.cameraShakeOffset.y = math.random(-self.cameraShakeRange, self.cameraShakeRange)

    self.cameraShakeOffset.x = self.cameraShakeOffset.x * self.screenShakeAmount
    self.cameraShakeOffset.y = self.cameraShakeOffset.y * self.screenShakeAmount

    self.screenShakeAmount = self.screenShakeAmount * self.shakeFadeAmount

    self.cameraPosition.x = math.lerpDT(self.cameraPosition.x, self.cameraTargetPosition.x, self.cameraLerpSpeed, dt)
    self.cameraPosition.y = math.lerpDT(self.cameraPosition.y, self.cameraTargetPosition.y, self.cameraLerpSpeed, dt)

    game.camera:setPosition(self.cameraPosition.x + self.cameraShakeOffset.x, self.cameraPosition.y + self.cameraShakeOffset.y)
end

function cameraManager:addTarget(newTarget)
    assert(newTarget.type ~= nil, "Object added is not a Camera Target!")
    assert(newTarget:type() == "Camera Target", "Object added is not a Camera Target!")

    table.insert(self.cameraTargets, newTarget)
end

function cameraManager:removeTarget(targetToRemove)
    tablex.remove_value(self.cameraTargets, targetToRemove)
end

function cameraManager:screenShake(amount)
    self.screenShakeAmount = amount
end

return cameraManager