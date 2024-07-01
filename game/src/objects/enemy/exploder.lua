local enemy = require "src.objects.enemy.enemy"
local wave = require "src.objects.enemy.enemywave"
local collider = require "src.collision.collider"

local exploder = class({name = "Exploder", extends = enemy})

function exploder:new(x, y)
    self:super(x, y)

    self.health = 5
    self.score = 700
    
    self.fuseTime = 2
    self.fuseRadius = 100
    self.waveWidth = 30
    self.waveScaleSpeed = 100

    self.isFused = false

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:addCollider(self.collider, self.position.x, self.position.y, 12, 12)
end

function exploder:update(dt)
    enemy.update(self, dt)

    local playerPosition = game.playerManager.playerPosition
    local distance = (self.position - playerPosition):length()

    if distance < self.fuseRadius then
        self.isFused = true
    end

    if self.isFused then
        self.fuseTime = self.fuseTime - (1 * dt)

        if self.fuseTime <= 0 then
            self:destroy("autoDestruction")
        end
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

function exploder:draw()
    love.graphics.setColor(self.enemyColour)
    love.graphics.circle("fill", self.position.x, self.position.y, 15)
    love.graphics.circle("line", self.position.x, self.position.y, self.fuseRadius)
    love.graphics.setColor(1, 1, 1, 1)
end

function exploder:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end

    self:explosion()
end

function exploder:explosion()
    gameHelper:addGameObject(wave(self.position.x, self.position.y, self.waveWidth, self.waveScaleSpeed))
end

return exploder