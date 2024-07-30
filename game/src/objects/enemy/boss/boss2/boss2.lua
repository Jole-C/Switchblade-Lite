local boss = require "src.objects.enemy.boss.boss"
local states = require "src.objects.enemy.boss.boss2.statetree"
local collider = require "src.collision.collider"
local eye = require "src.objects.enemy.enemyeye"

local boss2 = class({name = "Boss 2", extends = boss})

function boss2:new(x, y)
    self.bossName = "boss 2 name"
    self.bossSubtitle = "some subtitle"
    
    self:super(x, y)
    self.states = states

    self.canvasValues =
    {
        x = game.arenaValues.worldX,
        y = game.arenaValues.worldY,
        width = game.arenaValues.worldWidth,
        height = game.arenaValues.worldHeight,
    }

    self.metaballCanvas = love.graphics.newCanvas(self.canvasValues.width, self.canvasValues.height)

    self.numberOfMetaballs = 500
    self.ballSpawnDistance = 300
    self.minPositionChangeCooldown = 0.1
    self.maxPositionChangeCooldown = 0.5
    self.minPositionLerpRate = 0.1
    self.maxPositionLerpRate = 0.3
    self.minPositionDistance = 10
    self.maxPositionDistance = 30
    self.minSpriteScale = 0.1
    self.maxSpriteScale = 0.5
    self.colliderWidth = 10

    self.points = {}
    self:addPoint("leftPoint")
    self:addPoint("rightPoint")

    self.metaballs = {}

    local assets = game.resourceManager:getAsset("Enemy Assets"):get("boss2")
    self.thresholdShader = assets:get("shaders"):get("metaballThreshold")
    self.blendShader = assets:get("shaders"):get("metaballBlend")
    self.metaballSprite = assets:get("sprites"):get("metaball")

    self:setPhase()
    self:switchState("intro")
end

function boss2:update(dt)
    local world = gameHelper:getWorld()

    for _, metaball in ipairs(self.metaballs) do
        local closestPoint = nil
        local closestDistance = math.huge

        for _, point in pairs(self.points) do
            local distance = (point.position - metaball.position):length()

            if distance < closestDistance then
                closestPoint = point
                closestDistance = distance
            end
        end

        if closestPoint == nil then
            goto continue
        end
        
        metaball.positionChangeCooldown = metaball.positionChangeCooldown - (1 * dt)

        if metaball.positionChangeCooldown <= 0 then
            metaball.positionChangeCooldown = math.randomFloat(self.minPositionChangeCooldown, self.maxPositionChangeCooldown)

            local randomAngle = math.rad(math.random(0, 360))
            metaball.targetPosition = closestPoint.position + vec2:polar(math.random(self.minPositionDistance, self.maxPositionDistance), randomAngle)

            metaball.lerpRate = math.randomFloat(self.minPositionLerpRate, self.maxPositionLerpRate)
        end

        metaball.position.x = math.lerpDT(metaball.position.x, metaball.targetPosition.x, metaball.lerpRate, dt)
        metaball.position.y = math.lerpDT(metaball.position.y, metaball.targetPosition.y, metaball.lerpRate, dt)

        local player = game.playerManager.playerReference
        local playerPosition = game.playerManager.playerPosition

        if player then
            if (playerPosition - metaball.position):length() < 10 then
                player:onHit(1)
            end

            for _, bullet in ipairs(game.playerManager.playerBullets) do
                if (bullet.position - metaball.position):length() < 10 then
                    self:onHit(1)
                end
            end
        end

        ::continue::
    end

    local colour = self.enemyColour
    self.thresholdShader:send("drawColour", {colour[1], colour[2], colour[3], 1})

    self:checkColliders(self.colliders)

    boss.update(self, dt)
end

function boss2:draw()
    love.graphics.setScissor()
    love.graphics.setCanvas(self.metaballCanvas)
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setShader(self.blendShader)
    love.graphics.clear()

    local offsetX = self.metaballSprite:getWidth() / 2
    local offsetY = self.metaballSprite:getHeight() / 2

    for _, metaball in ipairs(self.metaballs) do
        local drawPosition = self:toCanvasSpace(metaball.position)
        love.graphics.draw(self.metaballSprite, drawPosition.x, drawPosition.y, 0, metaball.spriteScale, metaball.spriteScale, offsetX, offsetY)
    end

    love.graphics.pop()

    love.graphics.setCanvas({game.canvases.foregroundCanvas.canvas, stencil = true})
    gameHelper:getArena():setArenaStencil()
    gameHelper:getArena():setArenaStencilTest()

    love.graphics.setShader(self.thresholdShader)
    love.graphics.draw(self.metaballCanvas, self.canvasValues.x, self.canvasValues.y)
    love.graphics.setShader()

    if game.manager:getOption("enableDebugMode") then
        love.graphics.setColor(0, 1, 0, 1)
        for _, metaball in ipairs(self.metaballs) do
            love.graphics.circle("fill", metaball.position.x, metaball.position.y, 5)
        end

        love.graphics.setColor(0, 0, 1, 1)
        for _, point in pairs(self.points) do
            love.graphics.circle("fill", point.x, point.y, 10)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function boss2:handleDamage(damageType, amount)
    if damageType == "bullet" then
        if self.isShielded == false then
            self.phaseHealth = self.phaseHealth - amount
            self:addScore(self.bossHitScore, gameHelper:getScoreManager().scoreMultiplier, vec2(self.position.x + math.random(-50, 50), self.position.y + math.random(-50, 50)))
            return true
        else
            self.shieldHealth = self.shieldHealth - amount
            return true
        end
    end

    return false
end

function boss2:cleanup(destroyReason)
    boss.cleanup(self, destroyReason)
    self.metaballCanvas:release()
end

function boss2:toCanvasSpace(position)
    return vec2(position.x + self.canvasValues.width / 2, position.y + self.canvasValues.height / 2)
end

function boss2:addMetaballs(metaballsToAdd)
    for i = 1, metaballsToAdd do
        local randomAngle = math.rad(math.random(0, 360))
        local position = vec2(math.cos(randomAngle), math.sin(randomAngle)) * self.ballSpawnDistance
        local spriteScale = math.randomFloat(self.minSpriteScale, self.maxSpriteScale)

        table.insert(self.metaballs, {
            spriteScale = spriteScale,
            position = position,
            positionChangeCooldown = 0,
            positionDistance = math.random(self.minPositionDistance, self.maxPositionDistance),
            targetPosition = vec2(math.cos(randomAngle), math.sin(randomAngle)) * math.random(self.minPositionDistance, self.maxPositionDistance),
            lerpRate = math.randomFloat(self.minPositionLerpRate, self.maxPositionLerpRate),
            radius = self.metaballSprite:getWidth() * spriteScale
        })
    end
end

function boss2:addPoint(pointName)
    self.points[pointName] = 
    {
        position = vec2(self.position.x, self.position.y),
        eye = eye(self.position.x, self.position.y, 10, 30, true)
    }
end

function boss2:getPoint(pointName)
    local point = self.points[pointName]
    assert(point ~= nil, "Point does not exist!")

    return point
end

return boss2