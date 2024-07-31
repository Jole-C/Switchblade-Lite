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

    self.numberOfMetaballs = 700
    self.ballSpawnDistance = 300
    self.minPositionChangeCooldown = 0.1
    self.maxPositionChangeCooldown = 0.5
    self.minPositionLerpRate = 0.1
    self.maxPositionLerpRate = 0.3
    self.minPositionDistance = 10
    self.maxPositionDistance = 60
    self.minSpriteScale = 0.1
    self.maxSpriteScale = 1
    self.colliderWidth = 10
    self.eyeDistance = 7
    self.eyeRadius = 15

    self.points = {}
    self.lastHitPoint = nil
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
    self:updateMetaballs(dt)
    self:updatePoints(dt)

    boss.update(self, dt)
end

function boss2:updatePoints(dt)    
    for pointKey, point in pairs(self.points) do
        local averagePoint = vec2(0, 0)

        for metaballKey, metaball in ipairs(point.attractedMetaballs) do
            averagePoint.x = averagePoint.x + metaball.position.x
            averagePoint.y = averagePoint.y + metaball.position.y
        end

        averagePoint.x = averagePoint.x / #point.attractedMetaballs
        averagePoint.y = averagePoint.y / #point.attractedMetaballs

        if point.eye then
            point.eye.eyeBasePosition.x = averagePoint.x
            point.eye.eyeBasePosition.y = averagePoint.y
            point.eye:update()
        end

        point.invincibleTime = point.invincibleTime - (1 * dt)

        if point.invincibleTime <= 0 then
            point.drawColour = game.manager.currentPalette.enemyColour
        else
            point.drawColour = {1, 1, 1, 1}
        end
    end
end

function boss2:updateMetaballs(dt)
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

        if metaball.pointAttractedTo == nil then
            metaball.pointAttractedTo = closestPoint
            table.insert(metaball.pointAttractedTo.attractedMetaballs, metaball)
        end

        if metaball.pointAttractedTo ~= closestPoint then
            tablex.remove_value(metaball.pointAttractedTo.attractedMetaballs, metaball)
            metaball.pointAttractedTo = closestPoint
            table.insert(metaball.pointAttractedTo.attractedMetaballs, metaball)
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
            if (playerPosition - metaball.position):length() < ((self.metaballSprite:getWidth()/2 * metaball.spriteScale) * 0.7) then
                player:onHit(1)
            end

            for _, bullet in ipairs(game.playerManager.playerBullets) do
                if (bullet.position - metaball.position):length() < 10 then
                    self.lastHitPoint = metaball.pointAttractedTo
                    local tookDamage = self:onHit("bullet", 1)

                    if tookDamage then
                        bullet:destroy()
                        metaball.pointAttractedTo.invincibleTime = self.maxInvulnerableTime
                        break
                    end
                end
            end
        end

        ::continue::
    end
end

function boss2:drawMetaballs()
    love.graphics.setCanvas(self.metaballCanvas)
    love.graphics.setScissor()

    love.graphics.push()
    love.graphics.origin()

    love.graphics.clear()

    love.graphics.setShader(self.blendShader)

    local offsetX = self.metaballSprite:getWidth() / 2
    local offsetY = self.metaballSprite:getHeight() / 2

    for _, point in pairs(self.points) do
        love.graphics.setColor(point.drawColour)

        for __, metaball in ipairs(point.attractedMetaballs) do
            local drawPosition = self:toCanvasSpace(metaball.position)
            love.graphics.draw(self.metaballSprite, drawPosition.x, drawPosition.y, 0, metaball.spriteScale, metaball.spriteScale, offsetX, offsetY)
        end

        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.pop()
    love.graphics.setShader()
end

function boss2:drawMetaballCanvas()
    love.graphics.setCanvas({game.canvases.foregroundCanvas.canvas, stencil = true})
    gameHelper:getArena():setArenaStencil()
    gameHelper:getArena():setArenaStencilTest()

    love.graphics.setShader(self.thresholdShader)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(self.metaballCanvas, self.canvasValues.x, self.canvasValues.y)
    love.graphics.setBlendMode("alpha")
    love.graphics.setShader()
end

function boss2:draw()
    self:drawMetaballs()
    self:drawMetaballCanvas()

    if game.manager:getOption("enableDebugMode") then
        love.graphics.setColor(0, 1, 0, 1)
        for _, metaball in ipairs(self.metaballs) do
            love.graphics.circle("fill", metaball.position.x, metaball.position.y, 5)
        end

        love.graphics.setColor(0, 0, 1, 1)
        for _, point in pairs(self.points) do
            love.graphics.circle("fill", point.position.x, point.position.y, 10)
        end
    end

    if self.renderEyes then
        for _, point in pairs(self.points) do
            if point.eye then
                point.eye:draw()
            end
        end
    end
end

function boss2:setRenderEyes(renderEyes)
    self.renderEyes = renderEyes
end

function boss2:onHitParticles()
    if not self.lastHitPoint then
        return
    end

    for _, metaball in ipairs(self.lastHitPoint.attractedMetaballs) do
        game.particleManager:burstEffect("Enemy Hit", 3, metaball.position)
    end
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
            pointAttractedTo = nil,
        })
    end
end

function boss2:addPoint(pointName)
    self.points[pointName] = 
    {
        position = vec2(self.position.x, self.position.y),
        eye = eye(self.position.x, self.position.y, self.eyeDistance, self.eyeRadius, true),
        attractedMetaballs = {},
        drawColour = game.manager.currentPalette.enemyColour,
        invincibleTime = 0
    }
end

function boss2:getPoint(pointName)
    local point = self.points[pointName]
    assert(point ~= nil, "Point does not exist!")

    return point
end

return boss2