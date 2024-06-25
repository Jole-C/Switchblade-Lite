local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"

local shielder = class({name = "Shielder Enemy", extends = enemy})

function shielder:new(x, y)
    self:super(x, y)

    -- Parameters of the enemey
    self.health = 3
    self.speed = 15
    self.fleeSpeed = 20
    self.turnRate = 0.05
    self.fleeTurnRate = 0.3
    self.shieldDistance = 80
    self.fleeDistance = 100

    -- Variables
    self.direction = vec2(30, 30)
    self.shieldedEnemies = {}

    -- Components
    self.shader = game.resourceManager_REPLACESEARCH:getAsset("Enemy Assets"):get("enemyOutlineShader")
    self.sprite = game.resourceManager_REPLACESEARCH:getAsset("Enemy Assets"):get("shielder"):get("bodySprite")
    
    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:getWorld():add(self.collider, x, y, 12, 12)
end

function shielder:update(dt)
    enemy.update(self, dt)

    -- Move the enemy to the player
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

    -- Update the collider
    local world = gameHelper:getWorld()

    if world then
        if world:hasItem(self.collider) then
            local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(self.collider)
            colliderPositionX = self.position.x - colliderWidth/2
            colliderPositionY = self.position.y - colliderHeight/2
            
            world:update(self.collider, colliderPositionX, colliderPositionY)
        end
    end

    self:checkColliders(self.collider)
end

function shielder:draw()
    if not self.sprite then
        return
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

    self.shader:send("stepSize", {1/self.sprite:getWidth(), 1/self.sprite:getHeight()})
    
    love.graphics.setShader(self.shader)
    love.graphics.draw(self.sprite, self.position.x, self.position.y, 0, 1, 1, xOffset, yOffset)
    love.graphics.setShader()

    love.graphics.circle("line", self.position.x, self.position.y, self.shieldDistance)

    love.graphics.setColor(1, 1, 1, 1)
end

function shielder:handleDamage(damageType, amount)
    if damageType == "boost" or damageType == "contact" then
        self.health = self.health - amount
        return true
    end

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