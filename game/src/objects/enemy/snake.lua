local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local eye = require "src.objects.enemy.enemyeye"

local snake = class({name = "Snake Enemy", extends = enemy})

function snake:new(x, y)
    self:super(x, y)

    self.spawnPosition = vec2(x, y)

    self.health = 3
    self.defaultSpeed = 80
    self.hurtSpeed = 160
    self.speedLerpRate = 0.1
    self.turningRate = 0.005
    self.numberOfSegments = 30
    self.secondsBetweenAngleChange = 0.7
    self.segmentRadius = 10
    self.segmentIndexSpacing = 10
    self.eyeIndexSpacing = 3
    self.eyeDistance = 1
    self.eyeRadius = 3
    self.vulnerableSegments = 5
    self.maxInvulnerableTime = 0.3
    self.hurtSpeedupTime = 1.5
    self.spawnCircleAmplitude = 5
    self.spawnCircleFrequency = 3
    self.spawnCircleRadius = 20

    self.angleChangeCooldown = self.secondsBetweenAngleChange
    self.damagingVulnerableSegment = false
    self.hurtSpeedupCooldown = 0
    self.targetSpeed = self.defaultSpeed
    self.speed = 0
    self.inIntroduction = true
    self.spawnCircleTime = 0
    self.spawnCircleOffset = 0

    self.angle = math.random(0, 2 * math.pi)
    self.targetAngle = self.angle

    self.segments = {}
    self.positions = {}

    local assets = game.resourceManager:getAsset("Enemy Assets"):get("snake")
    self.headSprite = assets:get("headSprite")
    self.bodySprite = assets:get("bodySprite")
    self.bodySpriteNoEye = assets:get("bodySpriteNoEye")
    self.tailSprite = assets:get("tailSprite")
    self.spawnSound = assets:get("spawnSound"):play()
    self.hurtSound = assets:get("hurtSound")
    self.deathSound = assets:get("deathSound")

    self.startingVulnerableSegment = math.random(1, self.numberOfSegments - self.vulnerableSegments)

    for i = 1, self.numberOfSegments do
        local isVulnerable = i > self.startingVulnerableSegment and i <= self.startingVulnerableSegment + self.vulnerableSegments
        local segment = {
            position = vec2(x, y),
            angle = self.angle,
            isVulnerable = isVulnerable,
            collider = collider(colliderDefinitions.enemy, self)
        }

        gameHelper:addCollider(segment.collider, x - self.segmentRadius / 2, y - self.segmentRadius / 2, self.segmentRadius, self.segmentRadius)

        local hasEye = (i - 1) % self.eyeIndexSpacing == 0

        if isVulnerable == false then
            if hasEye then
                segment.eye = eye(x, y, self.eyeDistance, self.eyeRadius, true)
                segment.sprite = self.bodySprite
            else
                segment.sprite = self.bodySpriteNoEye
            end
        end

        if i == 1 then
            segment.sprite = self.headSprite
        end

        if i == self.numberOfSegments then
            segment.sprite = self.tailSprite
        end

        table.insert(self.segments, segment)
    end
end

function snake:update(dt)
    enemy.update(self, dt)

    self.targetSpeed = self.defaultSpeed

    self.hurtSpeedupCooldown = self.hurtSpeedupCooldown - (1 * dt)

    if self.hurtSpeedupCooldown > 0 then
        self.targetSpeed = self.hurtSpeed
    end

    self.speed = math.lerpDT(self.speed, self.targetSpeed, self.speedLerpRate, dt)

    self.position.x = self.position.x + math.cos(self.angle) * (self.speed * dt)
    self.position.y = self.position.y + math.sin(self.angle) * (self.speed * dt)

    self.angleChangeCooldown = self.angleChangeCooldown - 1 * dt

    if self.angleChangeCooldown <= 0 then
        local randomPosition = gameHelper:getArena():getRandomPosition(0.7)
        self.targetAngle = (randomPosition - self.position):angle()

        self.angleChangeCooldown = self.secondsBetweenAngleChange
    end

    local arena = gameHelper:getArena()

    if arena:isPositionWithinArena(self.position) == false then
        local normal = vec2(math.cos(self.angle + math.pi), math.sin(self.angle + math.pi))
        self.position = arena:getClampedPosition(normal * 6000)
    end

    self.angle = math.lerpAngle(self.angle, self.targetAngle, self.turningRate, dt)

    table.insert(self.positions, 1, self.position:copy())

    if #self.positions > self.numberOfSegments * self.segmentIndexSpacing then
        table.remove(self.positions, #self.positions)
        self.inIntroduction = false
    end 

    local world = gameHelper:getWorld()

    for index, segment in ipairs(self.segments) do
        local positionIndex = math.clamp(index * self.segmentIndexSpacing, 1, #self.positions)
        segment.position = self.positions[positionIndex]

        if segment.eye then
            segment.eye:update(dt)

            segment.eye.eyeBasePosition.x = segment.position.x
            segment.eye.eyeBasePosition.y = segment.position.y
        end

        if segment.collider and world and world:hasItem(segment.collider) then
            local colliderPositionX, colliderPositionY, colliderWidth, colliderHeight = world:getRect(segment.collider)
            colliderPositionX = segment.position.x - colliderWidth/2
            colliderPositionY = segment.position.y - colliderHeight/2
            
            world:update(segment.collider, colliderPositionX, colliderPositionY)

            if segment.isVulnerable == false then
                self:checkColliders(segment.collider)
            else
                local colliderPositionX, colliderPositionY = world:getRect(segment.collider)
                local x, y, cols, len = world:check(segment.collider, colliderPositionX, colliderPositionY)
        
                for i = 1, len do
                    local collidedObject = cols[i].other.owner
                    local colliderDefinition = cols[i].other.colliderDefinition

                    if colliderDefinition == colliderDefinitions.player then
                        if collidedObject.isBoosting then
                            self.damagingVulnerableSegment = true
                            self:onHit("boosting", 1)
                            self.damagingVulnerableSegment = false

                            return
                        end
                    end
                end
            end
        end
    end

    self.spawnCircleOffset = math.sin(self.spawnCircleTime) * self.spawnCircleAmplitude
    self.spawnCircleTime = self.spawnCircleTime + (self.spawnCircleFrequency * dt)

    if self.inIntroduction then
        game.particleManager:burstEffect("Stream", 9, self.spawnPosition)
    end
end

function snake:draw()
    for index, segment in ipairs(self.segments) do
        if segment.eye then
            segment.eye:draw()
        end
    end

    for index, segment in ipairs(self.segments) do
        if segment.isVulnerable then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.circle("fill", segment.position.x, segment.position.y, self.segmentRadius / 2)
        else
            love.graphics.setColor(self.enemyColour)
            
            local xOffset, yOffset = 0, 0
            local angle = 0

            if index > 1 then
                angle = (self.segments[index - 1].position - segment.position):angle()
                
                xOffset, yOffset = segment.sprite:getDimensions()
                xOffset = xOffset / 2
                yOffset = yOffset / 2
            else
                angle = self.angle
                
                xOffset, yOffset = segment.sprite:getDimensions()
                xOffset = 6
                yOffset = yOffset / 2
            end

            love.graphics.draw(segment.sprite, segment.position.x, segment.position.y, angle, 1, 1, xOffset, yOffset)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)

    if self.inIntroduction then
        love.graphics.circle("fill", self.spawnPosition.x, self.spawnPosition.y, self.spawnCircleRadius + self.spawnCircleOffset)
    end
end

function snake:handleDamage(damageType, amount)
    if self.damagingVulnerableSegment then
        self.health = self.health - amount
        self.hurtSpeedupCooldown = self.hurtSpeedupTime
        
        if self.health > 1 then
            self.hurtSound:play()
        end

        gameHelper:screenShake(0.4)
        
        return true
    end
end

function snake:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()

    for index, segment in ipairs(self.segments) do
        if world and world:hasItem(segment.collider) then
            gameHelper:getWorld():remove(segment.collider)
        end

        game.particleManager:burstEffect("Explosion", 9, segment.position)
    end

    self.deathSound:play()
end

return snake