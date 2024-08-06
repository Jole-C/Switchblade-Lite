local gameObject = require "src.objects.gameobject"
local metaball = class({name = "Metaball", extends = gameObject})

function metaball:new(x, y, bossReference)
    self:super(x, y)

    self.minPositionChangeCooldown = 0.1
    self.maxPositionChangeCooldown = 0.5
    self.minPositionLerpRate = 0.1
    self.maxPositionLerpRate = 0.3
    self.minPositionDistance = 10
    self.maxPositionDistance = 60

    self.spriteScale = math.randomFloat(0.1, 1)
    self.positionChangeCooldown = 0
    self.positionDistance = math.random(10, 60)
    self.targetPosition = vec2(0, 0)
    self.lerpRate = math.randomFloat(0.1, 0.3)

    self.points = bossReference.points or {}
    self.attractionTarget = nil
    self.bossReference = bossReference

    local assets = game.resourceManager:getAsset("Enemy Assets"):get("boss2")
    self.metaballSprite = assets:get("sprites"):get("metaball")
end

function metaball:update(dt)
    self:findClosestAttractionTarget()
    self:move(dt)
    self:checkCollision()
end

function metaball:draw()  
    local offsetX = self.metaballSprite:getWidth() / 2
    local offsetY = self.metaballSprite:getHeight() / 2

    local drawPosition = self:toCanvasSpace(self.position)
    love.graphics.draw(self.metaballSprite, drawPosition.x, drawPosition.y, 0, metaball.spriteScale, metaball.spriteScale, offsetX, offsetY)
end

function metaball:toCanvasSpace(position)
    return vec2(position.x + self.bossReference.canvasValues.width / 2, position.y + self.bossReference.canvasValues.height / 2)
end

function metaball:findClosestAttractionTarget()
    local closestPoint = nil
    local closestDistance = math.huge

    for _, point in pairs(self.points) do
        local distance = (point.position - self.position):length()

        if distance < closestDistance then
            closestPoint = point
            closestDistance = distance
        end
    end

    if closestPoint == nil then
        return
    end

    if self.attractionTarget == nil then
        self.attractionTarget = closestPoint
        self.attractionTarget:registerAttractedMetaball(self)
    end

    if self.attractionTarget ~= closestPoint then
        self.attractionTarget:unregisterAttractedMetaball(self)
        self.attractionTarget = closestPoint
        self.attractionTarget:registerAttractedMetaball(self)
    end
end

function metaball:move(dt)
    local closestPoint = self.attractionTarget

    if closestPoint == nil then
        return
    end

    self.positionChangeCooldown = self.positionChangeCooldown - (1 * dt)

    if self.positionChangeCooldown <= 0 then
        self.positionChangeCooldown = math.randomFloat(self.minPositionChangeCooldown, self.maxPositionChangeCooldown)

        local randomAngle = math.rad(math.random(0, 360))
        self.targetPosition = closestPoint.position + vec2:polar(math.random(self.minPositionDistance, self.maxPositionDistance), randomAngle)
        self.lerpRate = math.randomFloat(self.minPositionLerpRate, self.maxPositionLerpRate)
    end

    self.position.x = math.lerpDT(self.position.x, self.targetPosition.x, self.lerpRate, dt)
    self.position.x = math.lerpDT(self.position.y, self.targetPosition.y, self.lerpRate, dt)
end

function metaball:checkCollision()
    local player = game.playerManager.playerReference
    local playerPosition = game.playerManager.playerPosition

    if player == nil then
        return
    end

    local spriteSize = ((self.metaballSprite:getWidth()/2 * metaball.spriteScale) * 0.7)
    
    if (playerPosition - self.position):length() < spriteSize then
        player:onHit(1)
    end

    for _, bullet in ipairs(game.playerManager.playerBullets) do
        local tookDamage = self.bossReference:onHit("bullet", 1)

        if tookDamage then
            bullet:destroy()
            self.attractionTarget:onHitFlash()
            break
        end
    end
end