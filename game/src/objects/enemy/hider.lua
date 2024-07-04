local enemy = require "src.objects.enemy.enemy"
local collider = require "src.collision.collider"
local wave = require "src.objects.enemy.enemywave"

local hider = class({name = "Hider", extends = enemy})

function hider:new(x, y)
    self:super(x, y)

    self.maxTimeBetweenWaves = 1.75
    self.waveWidth = 10
    self.waveScaleSpeed = 200
    self.maxRevealGracePeriod = 0.25
    
    self.timeBetweenWaves = 0
    self.revealGracePeriod = self.maxRevealGracePeriod
    self.revealed = false

    self.collider = collider(colliderDefinitions.enemy, self)
    gameHelper:addCollider(self.collider, self.position.x, self.position.y, 12, 12)
end

function hider:update(dt)
    enemy.update(self, dt)

    self.position = gameHelper:getArena():getClampedPosition(self.position)

    local player = game.playerManager.playerReference

    if not player then
        return
    end

    if player.isBoosting then
        self.revealed = true
        self.revealGracePeriod = self.maxRevealGracePeriod
    else
        self.revealGracePeriod = self.revealGracePeriod - (1 * dt)
        
        if self.revealGracePeriod <= 0 then
            self.timeBetweenWaves = self.maxTimeBetweenWaves
            self.revealed = false
        end
    end

    if self.revealed == true then
        self.timeBetweenWaves = self.timeBetweenWaves - (1 * dt)

        if self.timeBetweenWaves <= 0 then
            self.timeBetweenWaves = self.maxTimeBetweenWaves
            gameHelper:addGameObject(wave(self.position.x, self.position.y, self.waveWidth, self.waveScaleSpeed))
        end
    end
end

function hider:draw()
    local colour = self.enemyColour
    local alpha = 0.5

    if self.revealed then
        alpha = 1
    end

    love.graphics.setColor(colour[1], colour[2], colour[3], alpha)
    love.graphics.circle("fill", self.position.x, self.position.y, 15)
    love.graphics.setColor(1, 1, 1, 1)
end

function hider:cleanup(destroyReason)
    enemy.cleanup(self, destroyReason)
    
    local world = gameHelper:getWorld()

    if world and world:hasItem(self.collider) then
        gameHelper:getWorld():remove(self.collider)
    end
end

return hider