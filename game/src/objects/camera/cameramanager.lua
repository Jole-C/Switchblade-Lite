local gameObject = require "src.objects.gameobject"
local cameraManager = class({name = "Camera Manager", extends = gameObject})

function cameraManager:new()
    self:super(0, 0)

    self.cameraReference = game.camera
    self.cameraTargets = {}
    self.overrideTarget = nil

    self.cameraTargetPosition = vec2(0, 0)
    self.cameraPosition = vec2(0, 0)
    
    if self.cameraReference then
        self.cameraPosition.x, self.cameraPosition.y = game.camera:getPosition()
    end

    self.cameraLerpSpeed = 0.1

    self.screenShakeAmount = 0
    self.cameraShakeOffset = vec2(0, 0)
    self.shakeFadeAmount = 0.95
    
    self.cameraShakeRange = 32
    self.cameraShakeAngleRange = 15

    self.zoomAmount = 1 * (game.manager:getOption("cameraZoomScale") / 100)
    self.targetZoomAmount = self.zoomAmount
    self.zoomRate = 1
end

function cameraManager:update(dt)
    local numeratorX, numeratorY = 0, 0
    local denominator = 0
    local targets = self.cameraTargets

    if self.overrideTarget ~= nil then
        targets = {self.overrideTarget}
    end

    for _, target in pairs(targets) do
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

    if game.manager:getOption("disableAngleshake") == false then
        game.camera:setAngle(0 + math.rad(math.random(-self.cameraShakeAngleRange, self.cameraShakeAngleRange)) * self.screenShakeAmount)
    end
    
    game.camera:setScale(self.zoomAmount)
    self.zoomAmount = math.lerpDT(self.zoomAmount, self.targetZoomAmount, self.zoomRate, dt)
end

function cameraManager:zoom(zoomAmount, zoomRate)
    self.targetZoomAmount = zoomAmount * (game.manager:getOption("cameraZoomScale") / 100)
    self.zoomRate = zoomRate
end

function cameraManager:addTarget(newTarget)
    assert(newTarget.type ~= nil, "Object added is not a Camera Target!")
    assert(newTarget:type() == "Camera Target", "Object added is not a Camera Target!")

    table.insert(self.cameraTargets, newTarget)
end

function cameraManager:setOverrideTarget(overrideTarget)
    self.overrideTarget = overrideTarget
end

function cameraManager:removeOverrideTarget()
    self.overrideTarget = nil
end

function cameraManager:removeTarget(targetToRemove)
    tablex.remove_value(self.cameraTargets, targetToRemove)
end

function cameraManager:screenShake(amount)
    if game.manager:getOption("disableScreenshake") == true then
        return
    end
    
    self.screenShakeAmount = amount
end

return cameraManager