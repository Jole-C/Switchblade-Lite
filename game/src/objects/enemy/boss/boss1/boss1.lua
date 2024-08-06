local boss = require "src.objects.enemy.boss.boss"
local states = require "src.objects.enemy.boss.boss1.statetree"
local bossOrb = require "src.objects.enemy.boss.boss1.boss1orb"
local tail = require "src.objects.enemy.enemytail"
local eye = require "src.objects.enemy.enemyeye"
local collider = require "src.collision.collider"

local boss1 = class({name = "Boss 1", extends = boss})

function boss1:new(x, y)
    self.bossName = "Ocellatus"
    self.bossSubtitle = "Not as sharp as its edges"
    
    self:super(x, y)
    self.states = states

    self.orbs = {}
    self.numberOfOrbs = 3

    self.secondsBetweenAngleChange = 1
    self.randomChangeOffset = 0.5
    self.targetAngle = love.math.random(0, math.pi * 2)
    self.angleChangeCooldown = self.secondsBetweenAngleChange

    self.angle = 0
    self.speed = 16

    self.angleTurnSpeed = 1
    self.angleFriction = 2

    self.tentacleWiggle = 0
    self.tentacleWiggleTime = 0
    self.tentacleWiggleFrequency = 5
    self.tentacleWiggleAmplitude = 18

    local assets = game.resourceManager:getAsset("Enemy Assets"):get("boss1")
    self.coreSprite = assets:get("sprites"):get("core")
    self.tail1sprite = assets:get("sprites"):get("tail1")
    self.tail2sprite = assets:get("sprites"):get("tail2")
    self.mandibleSprite = assets:get("sprites"):get("mandible")
    self.spikeSprite = assets:get("sprites"):get("spike")
    
    self.tail1 = tail(self.tail1sprite, 0, 0, 4, 0.5)
    self.tail2 = tail(self.tail2sprite, 0, 0, 4, 1)
    self.eye = eye(x, y, 10, 10, true)

    self.mandibleOpenAngle = 1
    self.mandibleCloseAngle = 0
    self.mandibleAngle = self.mandibleCloseAngle
    self.mandibleTargetAngle = self.mandibleCloseAngle
    self.enemySpawnPosition = vec2(0, 0)

    self.mesh = nil
    self:generateMesh()

    self.fearLevel = 1
    self.fearValues = 
    {
        movementSpeed =
        {
            16,
            30,
            50,
        },
        
        wiggleSpeed =
        {
            4,
            8,
            12
        },
        
        eyeRadius =
        {
            12,
            8,
            6
        }
    }

    self:setFearLevel(1)

    self.colliders = {}
    self.colliderIndices = {}

    self:initialiseColliders(
    {
        mainCollider = {
            width = 37,
        },
        tail1Collider = {
            width = 22,
        },
        tail2Collider = {
            width = 12,
        },
    })

    local assets = game.resourceManager:getAsset("Enemy Assets"):get("boss1")
    self.spawnSound = assets:get("sounds"):get("spawn")
    self.hurtSound = assets:get("sounds"):get("hurt")
    self.fireSound = assets:get("sounds"):get("fire")
    self.sounds = assets:get("sounds"):get("randomSounds")
    self.spawnSound:play()

    self:setPhase()
    self:switchState("intro")
end

function boss1:update(dt)
    for index, orb in ipairs(self.orbs) do
        if orb.markedForDelete then
            table.remove(self.orbs, index)
        end
    end

    if self.isShielded == false then
        if self.tail1 then
            local angle = self.angle + math.pi
            local x = self.position.x + math.cos(angle) * 15
            local y = self.position.y + math.sin(angle) * 15
            
            self.tail1.tailSpritePosition.x = x
            self.tail1.tailSpritePosition.y = y
            self.tail1.baseTailAngle = self.angle

            self:updateColliderPosition("tail1Collider", x + math.cos(angle + self.tail1.tailAngleWave) * 16, y + math.sin(angle + self.tail1.tailAngleWave) * 16)

            self.tail1:update(dt)
        end

        if self.tail2 then
            local angle = self.tail1.baseTailAngle + self.tail1.tailAngleWave + math.pi
            local x = self.tail1.tailSpritePosition.x + math.cos(angle) * 27
            local y = self.tail1.tailSpritePosition.y + math.sin(angle) * 27

            self.tail2.tailSpritePosition.x = x
            self.tail2.tailSpritePosition.y = y
            self.tail2.baseTailAngle = self.angle

            self:updateColliderPosition("tail2Collider", x + math.cos(angle) * 8, y + math.sin(angle) * 8)

            self.tail2:update(dt)
        end
    else
        self:updateColliderPosition("mainCollider", self.position.x, self.position.y)
        self:updateColliderPosition("tail1Collider", self.position.x, self.position.y)
        self:updateColliderPosition("tail2Collider", self.position.x, self.position.y)

        self.angle = self.angle + (self.angleTurnSpeed * dt)
        self.angleTurnSpeed = applyFriction(self.angleTurnSpeed, self.angleFriction, dt)
        self.angleTurnSpeed = math.clamp(self.angleTurnSpeed, 1, math.huge)

        local world = gameHelper:getWorld()
        
        if world then
            for _, orb in pairs(self.orbs) do
                local x1 = self.position.x
                local y1 = self.position.y
                local x2 = orb.position.x
                local y2 = orb.position.y

                local items, len = world:querySegment(x1, y1, x2, y2)

                for _, item in pairs(items) do
                    self:handleCollision(nil, item.owner, item.colliderDefinition)
                end
            end
        end
    end

    if self.eye then
        self.eye.eyeBasePosition.x = self.position.x
        self.eye.eyeBasePosition.y = self.position.y
        self.eye:update()

        local eyeRadius = self:getFearLevel().eyeRadius
        
        if self.isInvulnerable == true then
            eyeRadius = eyeRadius * 1.3
        end

        self.eye.eyeRadius = eyeRadius
    end

    self.mandibleAngle = math.lerp(self.mandibleAngle, self.mandibleTargetAngle, 0.1)

    self.enemySpawnPosition.x = self.position.x + math.cos(self.angle - self.tail1.tailAngleWave) * 17
    self.enemySpawnPosition.y = self.position.y + math.sin(self.angle - self.tail1.tailAngleWave) * 17

    self.tentacleWiggleTime = self.tentacleWiggleTime + (self.tentacleWiggleFrequency * dt)
    self.tentacleWiggle = math.sin(self.tentacleWiggleTime) * self.tentacleWiggleAmplitude

    local world = gameHelper:getWorld()

    if world then
        for _, colliderParameter in pairs(self.colliders) do
            if world:hasItem(colliderParameter.colliderReference) then
                local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(colliderParameter.colliderReference)
                colliderPositionX = colliderParameter.position.x - colliderWidth/2
                colliderPositionY = colliderParameter.position.y - colliderHeight/2
                
                world:update(colliderParameter.colliderReference, colliderPositionX, colliderPositionY)
            end
        end
    end

    self:checkColliders(self.colliderIndices)

    boss.update(self, dt)
end

function boss1:draw()
    if self.currentState.drawAbove == false then
        self.currentState:draw()
    end

    if self.isShielded == false then
        if self.eye then
            self.eye:draw()
        end

        love.graphics.setColor(self.enemyColour)
    
        local xOffset, yOffset = self.coreSprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2

        love.graphics.draw(self.coreSprite, self.position.x, self.position.y, self.angle - self.tail1.tailAngleWave, 1, 1, xOffset, yOffset)

        love.graphics.draw(self.mandibleSprite, self.position.x + math.cos(self.angle + math.rad(5)) * 15, self.position.y + math.sin(self.angle + math.rad(5)) * 18, self.angle + self.mandibleAngle)
        love.graphics.draw(self.mandibleSprite, self.position.x + math.cos(self.angle + math.rad(-5)) * 15, self.position.y + math.sin(self.angle + math.rad(-5)) * 18, self.angle + -self.mandibleAngle, 1, -1)

        if self.tail1 then
            self.tail1:draw()
        end

        if self.tail2 then
            self.tail2:draw()
        end
    else
        love.graphics.setColor(game.manager.currentPalette.enemyColour)

        local quarterAngle = math.pi / 2
        
        for _, orb in pairs(self.orbs) do
            local vectorToOrb = (orb.position - self.position)
            local distanceToOrb = vectorToOrb:length()
            local angleToOrb = vectorToOrb:angle()
            local numberOfSegments = 8
            local increment = distanceToOrb/numberOfSegments

            for i = 1, numberOfSegments do
                local segmentPosition = vec2(math.cos(angleToOrb), math.sin(angleToOrb)) * (increment * i)
                local wiggleAngle = angleToOrb + quarterAngle + (0.2 * (1 - (i / numberOfSegments)))
                local wiggleAmount = self.tentacleWiggle * (math.cos((i / numberOfSegments) * math.pi / 2))

                local x = segmentPosition.x + math.cos(wiggleAngle) * wiggleAmount
                local y = segmentPosition.y + math.sin(wiggleAngle) * wiggleAmount
                local radius = 12 + (10 * (1 - (i / numberOfSegments)))

                love.graphics.circle("fill", x, y, radius)
            end
        end

        if self.mesh then
            love.graphics.draw(self.mesh, self.position.x, self.position.y, self.angle)
        end

        local angleIncrement = 2 * math.pi / self.numberOfOrbs
        local xOffset, yOffset = self.spikeSprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2

        for i = 1, self.numberOfOrbs do
            local offset = math.pi / 2
            local angle = angleIncrement * i + self.angle - offset
            local position = self.position + vec2(math.cos(angle) * 80, math.sin(angle) * 80)

            love.graphics.draw(self.spikeSprite, position.x, position.y, angle, 1, 1, xOffset, yOffset)
        end

        if self.eye then
            self.eye:draw()
        end
    end

    if self.currentState.drawAbove == true then
        self.currentState:draw()
    end
end

function boss1:playSound()
    local sound = self.sounds:get()
    sound:play()
end

function boss1:addAngleSpeed(speedAddition)
    self.angleTurnSpeed = self.angleTurnSpeed + speedAddition
end

function boss1:moveRandomly(dt)
    local arena = gameHelper:getArena()

    self.angle = math.lerpAngle(self.angle, self.targetAngle, 0.005, dt)

    local movementDirection = vec2(math.cos(self.angle), math.sin(self.angle))

    self.angleChangeCooldown = self.angleChangeCooldown - 1 * dt

    if self.angleChangeCooldown <= 0 then
        self.angleChangeCooldown = self.secondsBetweenAngleChange + math.random(-self.randomChangeOffset, self.randomChangeOffset)
        self.targetAngle = (arena:getRandomPosition(0.8) - self.position):angle()
    end

    self.position = arena:getClampedPosition(self.position + movementDirection * self.speed * dt)
    self:updateColliderPosition("mainCollider", self.position.x, self.position.y)
end

function boss1:setMandibleOpenAmount(percentage)
    self.mandibleTargetAngle = math.lerp(self.mandibleCloseAngle, self.mandibleOpenAngle, percentage)
end

function boss1:damageShieldHealth()
    self.shieldHealth = self.shieldHealth - (100/self.numberOfOrbs)
end

function boss1:setFearLevel(fearLevel)
    fearLevel = fearLevel or 1

    self.speed = self.fearValues.movementSpeed[fearLevel]
    self.tail1.tailAngleWaveFrequency = self.fearValues.wiggleSpeed[fearLevel]
    self.tail2.tailAngleWaveFrequency = self.fearValues.wiggleSpeed[fearLevel]
    self.eye.eyeRadius = self.fearValues.eyeRadius[fearLevel]

    self.fearLevel = fearLevel
end

function boss1:getFearLevel()
    return {
        movementSpeed = self.fearValues.movementSpeed[self.fearLevel],
        wiggleSpeed = self.fearValues.wiggleSpeed[self.fearLevel],
        eyeRadius = self.fearValues.eyeRadius[self.fearLevel],
    }
end

function boss1:summonOrbs(numberOfOrbs)
    self.numberOfOrbs = numberOfOrbs

    local angleIncrement = 2 * math.pi / numberOfOrbs

    for i = 1, numberOfOrbs do
        local angle = angleIncrement * i
        local newEnemy = bossOrb(0, 0, self, angle)

        gameHelper:addGameObject(newEnemy)
        table.insert(self.orbs, newEnemy)
    end

    self:generateMesh()
end

function boss1:generateMesh()
    if self.mesh then
        self.mesh:release()
    end

    self.mesh = love.graphics.newMesh(self.numberOfOrbs, "fan")

    local angle = 2 * math.pi / self.numberOfOrbs
    local offset = math.pi / 2
    local vertices = {}

    for i = 1, self.numberOfOrbs do
        local pointX = math.cos(i * angle - offset) * 64
        local pointY = math.sin(i * angle - offset) * 64

        table.insert(vertices, {pointX, pointY, 0, 0, 1, 1, 1, 1})
    end

    self.mesh:setVertices(vertices)
end

function boss1:handleDamage(damageType, amount)
    if damageType == "bullet" then
        if self.isShielded == false then
            self.phaseHealth = self.phaseHealth - amount
            self:addScore(self.bossHitScore, vec2(self.position.x + math.random(-50, 50), self.position.y + math.random(-50, 50)))
            return true
        end
    end

    return false
end

function boss1:initialiseColliders(colliderParameters)
    local world = gameHelper:getWorld()

    if world then
        for colliderName, colliderParameter in pairs(colliderParameters) do
            local newCollider = collider(colliderDefinitions.enemy, self)

            self.colliders[colliderName] = {
                colliderReference = newCollider,
                position = self.position:copy(),
                width = colliderParameter.width
            }

            world:add(newCollider, self.position.x, self.position.y, colliderParameter.width, colliderParameter.width)
            table.insert(self.colliderIndices, newCollider)
        end
    end
end

function boss1:cleanup(destroyReason)
    boss.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()

    if world then
        for _, collider in pairs(self.colliders) do
            if world:hasItem(collider.colliderReference) then
                world:remove(collider.colliderReference)
            end
        end
    end
end

return boss1