local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local tail = require "src.objects.enemy.enemytail"
local eye = require "src.objects.enemy.enemyeye"

local shielder = class({name = "Shielder Enemy", extends = enemy})

function shielder:new(x, y)
    self:super(x, y)

    -- Parameters of the enemey
    self.health = 3
    self.speed = 15
    self.fleeSpeed = 20
    self.turnRate = 0.05
    self.fleeTurnRate = 0.3
    self.shieldDistance = 150
    self.fleeDistance = 100
    self.maxSegmentCloseTime = 1
    self.segmentCloseTime = 0
    self.segmentCloseRate = 0.1
    self.maxSegmentOpenOffset = 10
    self.segmentOpenOffset = self.maxSegmentOpenOffset
    self.tailYOffset = 3
    self.score = 500

    -- Variables
    self.direction = vec2(30, 30)
    self.shieldedEnemies = {}

    -- Components
    self.shader = game.resourceManager:getAsset("Enemy Assets"):get("enemyOutlineShader")
    self.sprite = game.resourceManager:getAsset("Enemy Assets"):get("shielder"):get("bodySprite")
    self.segmentSprite = game.resourceManager:getAsset("Enemy Assets"):get("shielder"):get("segmentSprite")
    self.tailSprite = game.resourceManager:getAsset("Enemy Assets"):get("shielder"):get("tailSprite")

    self.tail = tail(self.tailSprite, x, y + self.tailYOffset, 15, 1)
    self.eye = eye(x, y, 2, 2)
    
    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:getWorld():add(self.collider, x, y, 18, 12)
end

function shielder:update(dt)
    enemy.update(self, dt)
    self.multiplierToApply = gameHelper:getScoreManager().scoreMultiplier

    local playerReference = game.playerManager.playerReference
    local playerPosition = game.playerManager.playerPosition

    local speed = self.speed
    local lerpDirection = self.position
    local lerpRate = self.turnRate

    if playerReference then
        lerpDirection = (playerPosition - self.position)

        if playerReference.isBoosting and (self.position - playerPosition):length() < self.fleeDistance then
            lerpDirection = (self.position - playerPosition)
            speed = self.fleeSpeed
            lerpRate = self.fleeTurnRate
        end

        self.direction:lerp_direction_inplace(lerpDirection, lerpRate)
    end

    self.direction:normalise_inplace()
    self.position = self.position + (self.direction * speed) * dt

    local currentGamestate = gameHelper:getCurrentState()
    local enemyManager = currentGamestate.enemyManager
    self.shieldedEnemies = {}

    for _, enemy in pairs(enemyManager.enemies) do
        if enemy and enemy:type() ~= "Shielder Enemy" then
            local distance = (self.position - enemy.position):length()

            if distance < self.shieldDistance then
                enemy:setInvulnerable()
                table.insert(self.shieldedEnemies, enemy)
            end
        end
    end

    self.segmentCloseTime = self.segmentCloseTime - (1 * dt)

    if self.segmentCloseTime > 0 then
        self.segmentOpenOffset = math.lerpDT(self.segmentOpenOffset, 0, self.segmentCloseRate, dt)
    else
        self.segmentOpenOffset = math.lerpDT(self.segmentOpenOffset, self.maxSegmentOpenOffset, self.segmentCloseRate, dt)
    end    
    
    if self.tail then
        self.tail.tailSpritePosition.x = self.position.x
        self.tail.tailSpritePosition.y = self.position.y + self.tailYOffset
        self.tail.baseTailAngle = 4.7123 -- pi + pi / 2

        self.tail:update(dt)
    end

    -- Update the eye
    if self.eye then
        self.eye.eyeBasePosition.x = self.position.x
        self.eye.eyeBasePosition.y = self.position.y
        self.eye:update()
    end

    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
        colliderPositionX = self.position.x - colliderWidth/2
        colliderPositionY = self.position.y - colliderHeight/2
        
        world:update(self.collider, colliderPositionX, colliderPositionY)
    end

    self:checkColliders(self.collider)
end

function shielder:draw()
    if not self.sprite then
        return
    end

    if self.eye then
        self.eye:draw()
    end

    love.graphics.setColor(self.enemyColour)

    for _, enemy in pairs(self.shieldedEnemies) do
        if enemy then
            local x1 = self.position.x
            local y1 = self.position.y
            local x2 = enemy.position.x
            local y2 = enemy.position.y

            love.graphics.line(x1, y1, x2, y2)
        end
    end

    -- Draw the sprite
    local xOffset, yOffset = self.sprite:getDimensions()
    xOffset = xOffset/2
    yOffset = yOffset/2

    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, 1, 1, xOffset, yOffset)
    love.graphics.draw(self.segmentSprite, self.position.x - self.segmentOpenOffset, self.position.y - 2, 0, 1, 1, 15, 6)
    love.graphics.draw(self.segmentSprite, self.position.x + self.segmentOpenOffset, self.position.y + 2, math.pi, 1, 1, 15, 6)

    if self.tail then
        self.tail:draw()
    end

    self.shader:send("stepSize", {2/self.sprite:getWidth(), 2/self.sprite:getHeight()})
    
    love.graphics.setShader(self.shader)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, 1, 1, xOffset, yOffset)
    love.graphics.draw(self.segmentSprite, self.position.x - self.segmentOpenOffset, self.position.y - 2, 0, 1, 1, 15, 6)
    love.graphics.draw(self.segmentSprite, self.position.x + self.segmentOpenOffset, self.position.y + 2, math.pi, 1, 1, 15, 6)

    if self.tail then
        self.tail:draw()
    end
    
    love.graphics.setShader()

    love.graphics.circle("line", self.position.x, self.position.y, self.shieldDistance)

    love.graphics.setColor(1, 1, 1, 1)
end

function shielder:handleDamage(damageType, amount)
    if damageType == "boost" or damageType == "contact" then
        self.health = self.health - amount
        return true
    end

    self.segmentCloseTime = self.maxSegmentCloseTime
    return false
end

function shielder:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        world:remove(self.collider)
    end
end

return shielder