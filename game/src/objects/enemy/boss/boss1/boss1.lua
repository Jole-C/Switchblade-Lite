local boss = require "src.objects.enemy.boss.boss"
local states = require "src.objects.enemy.boss.boss1.statetree"
local bossOrb = require "src.objects.enemy.boss.boss1.boss1orb"
local tail = require "src.objects.enemy.enemytail"
local eye = require "src.objects.enemy.enemyeye"

local boss1 = class({name = "Boss 1", extends = boss})

function boss1:new(x, y)
    self.orbs = {}
    self.numberOfOrbs = 3

    self.secondsBetweenAngleChange = 1
    self.randomChangeOffset = 0.5
    self.targetAngle = love.math.random(0, math.pi * 2)
    self.angleChangeCooldown = self.secondsBetweenAngleChange

    self.angle = 0
    self.speed = 16

    self.coreSprite = game.resourceManager:getResource("boss 1 core")
    self.tail1 = tail("boss 1 tail 1", 0, 0, 4, 0.5)
    self.tail2 = tail("boss 1 tail 2", 0, 0, 4, 1)
    self.eye = eye(x, y, 10, 10, true)

    self.mandibleSprite = game.resourceManager:getResource("boss 1 mandible")
    self.mandibleOpenAngle = 1
    self.mandibleCloseAngle = 0
    self.mandibleAngle = self.mandibleCloseAngle
    self.mandibleTargetAngle = self.mandibleCloseAngle

    self.enemySpawnPosition = vec2(0, 0)

    self.mesh = nil
    self:generateMesh()
    
    self.states = states
    self:super(x, y)
end

function boss1:update(dt)
    boss.update(self, dt)

    for index, orb in ipairs(self.orbs) do
        if orb.markedForDelete then
            table.remove(self.orbs, index)
        end
    end

    if self.tail1 then
        self.tail1.tailSpritePosition.x = self.position.x + math.cos(self.angle + math.pi) * 15
        self.tail1.tailSpritePosition.y = self.position.y + math.sin(self.angle + math.pi) * 15
        self.tail1.baseTailAngle = self.angle

        self.tail1:update(dt)
    end

    if self.tail2 then
        self.tail2.tailSpritePosition.x = self.tail1.tailSpritePosition.x + math.cos(self.tail1.baseTailAngle + self.tail1.tailAngleWave + math.pi) * 27
        self.tail2.tailSpritePosition.y = self.tail1.tailSpritePosition.y + math.sin(self.tail1.baseTailAngle + self.tail1.tailAngleWave + math.pi) * 27
        self.tail2.baseTailAngle = self.angle

        self.tail2:update(dt)
    end

    if self.eye then
        self.eye.eyeBasePosition.x = self.position.x
        self.eye.eyeBasePosition.y = self.position.y
        self.eye:update()
    end

    self.mandibleAngle = math.lerp(self.mandibleAngle, self.mandibleTargetAngle, 0.1)

    self.enemySpawnPosition.x = self.position.x + math.cos(self.angle - self.tail1.tailAngleWave) * 17
    self.enemySpawnPosition.y = self.position.y + math.sin(self.angle - self.tail1.tailAngleWave) * 17
end

function boss1:draw()
    if self.isShielded == false then
        if self.eye then
            self.eye:draw()
        end

        love.graphics.setColor(game.manager.currentPalette.enemyColour)
    
        local xOffset, yOffset = self.coreSprite:getDimensions()
        xOffset = xOffset/2
        yOffset = yOffset/2

        love.graphics.draw(self.coreSprite, self.position.x, self.position.y, self.angle - self.tail1.tailAngleWave, 1, 1, xOffset, yOffset)

        love.graphics.draw(self.mandibleSprite, self.position.x + math.cos(self.angle + math.rad(5)) * 15, self.position.y + math.sin(self.angle + math.rad(5)) * 15, self.angle + self.mandibleAngle)
        love.graphics.draw(self.mandibleSprite, self.position.x + math.cos(self.angle + math.rad(-5)) * 15, self.position.y + math.sin(self.angle + math.rad(-5)) * 15, self.angle + -self.mandibleAngle, 1, -1)

        if self.tail1 then
            self.tail1:draw()
        end

        if self.tail2 then
            self.tail2:draw()
        end
    else
        love.graphics.setColor(game.manager.currentPalette.enemyColour)

        if self.mesh then
            love.graphics.draw(self.mesh, self.position.x, self.position.y, self.angle)
        end

        if self.eye then
            self.eye:draw()
        end
    end
end

function boss1:moveRandomly(dt)
    self.angle = math.lerpAngle(self.angle, self.targetAngle, 0.005)

    local movementDirection = vec2(math.cos(self.angle), math.sin(self.angle))

    self.angleChangeCooldown = self.angleChangeCooldown - 1 * dt

    if self.angleChangeCooldown <= 0 then
        self.angleChangeCooldown = self.secondsBetweenAngleChange + math.random(-self.randomChangeOffset, self.randomChangeOffset)
        self.targetAngle = love.math.random(0, math.pi * 2)
    end

    if gameHelper:getCurrentState().arena then
        self.position = gameHelper:getCurrentState().arena:getClampedPosition(self.position + movementDirection * self.speed * dt)
    end
end

function boss1:setMandibleOpenAmount(percentage)
    self.mandibleTargetAngle = math.lerp(self.mandibleCloseAngle, self.mandibleOpenAngle, percentage)
end

function boss1:damageShieldHealth()
    self.shieldHealth = self.shieldHealth - (100/self.numberOfOrbs)
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

function boss1:handleDamage(damage)
    if damage.type == "bullet" then
        if self.isShielded == false then
            self.phaseHealth = self.phaseHealth - damage.amount
        end
    end
end

return boss1