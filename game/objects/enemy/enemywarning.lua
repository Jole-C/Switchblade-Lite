local gameObject = require "game.objects.gameobject"
local enemyWarning = class({name = "Enemy Warning", extends = gameObject})

function enemyWarning:new(x, y, originSegment, enemyDefinition, spawnTime)
    self:super(0, 0)

    self.originSegment = originSegment
    self.spawnClass = enemyDefinition.enemyClass
    self.segmentOffset = vec2(x, y)

    self.spawnTime = spawnTime or 2
    self.spriteScaleFrequencyChange = 8
    self.spriteScaleAmplitude = 1
    self.maxWarningAngleRandomiseCooldown = 0.25

    self.angleWarningRandomiseCooldown = 0
    self.spriteScale = 1
    self.spriteScaleFrequency = 0
    self.angle = math.random(0, 2 * math.pi)

    self.sprite = game.resourceManager:getResource(enemyDefinition.spriteName)

    if self.originSegment then
        self.position.x = self.originSegment.position.x + self.segmentOffset.x
        self.position.y = self.originSegment.position.y + self.segmentOffset.y
    end
end

function enemyWarning:update(dt)
    self.spawnTime = self.spawnTime - (1 * dt)

    if self.spawnTime <= 0 then
        self:spawnEnemy()
        self:destroy()
    end

    self.spriteScale = (math.sin(self.spriteScaleFrequency) * self.spriteScaleAmplitude) * 0.5 + 1
    self.spriteScaleFrequency = self.spriteScaleFrequency + (self.spriteScaleFrequencyChange * dt)

    self.angleWarningRandomiseCooldown = self.angleWarningRandomiseCooldown - (1 * dt)

    if self.angleWarningRandomiseCooldown <= 0 then
        self.angleWarningRandomiseCooldown = self.maxWarningAngleRandomiseCooldown
        self.angle = math.random(0, 2 * math.pi)
    end

    if self.originSegment then
        self.position.x = self.originSegment.position.x + self.segmentOffset.x
        self.position.y = self.originSegment.position.y + self.segmentOffset.y
    end
end

function enemyWarning:draw()
    if not self.sprite then
        return
    end   
    
    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    love.graphics.setColor(game.manager.currentPalette.enemySpawnColour)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, self.angle, self.spriteScale, self.spriteScale, xOffset, yOffset)
    love.graphics.setColor(1, 1, 1, 1)
end

function enemyWarning:spawnEnemy()
    if not self.spawnClass then
        return
    end

    local newEnemy = self.spawnClass(self.position.x, self.position.y)
    gameHelper:addGameObject(newEnemy)
end

return enemyWarning