local timedGamemode = require "src.gamemode.timedgamemode"
local crowd = class({name = "Crowd", extends = timedGamemode})

function crowd:new()
    self:super("src.gamemode.crowd.levels", 3, 0)

    self.maxSpawnTime = 3
    self.enemySpawns = 5
    self.numberOfEnemiesToSpawn = 16
    self.heatAreaRadius = 50
    self.heatAccumulationRate = 2.5

    self.areaRadiusCircleLineWidth = 5
    
    self.spawnTime = self.maxSpawnTime

    gameHelper:getArena():addArenaSegment(0, 0, 300, "main")
end

function crowd:start()
    local player = game.playerManager.playerReference

    if player then
        player:setHealthCanRecharge(false)
    end
    
    self:setTimerPaused(false)
end

function crowd:update(dt)
    timedGamemode.update(self, dt)

    local player = game.playerManager.playerReference
    local enemies = gameHelper:getEnemyManager().enemies

    if player then
        for _, enemy in ipairs(enemies) do
            local distance = (player.position - enemy.position):length()
    
            if distance < self.heatAreaRadius then
                player:accumulateTemperature(dt, self.heatAccumulationRate)
                return
            end
        end
    end

    self.spawnTime = self.spawnTime - (1 * dt)

    if self.spawnTime <= 0 then
        self.spawnTime = self.maxSpawnTime

        local arena = gameHelper:getArena()

        if arena then
            for i = 1, self.numberOfEnemiesToSpawn do
                local randomSegment = arena:getRandomSegment()
                local randomLength = math.random(0, randomSegment.radius)
                local randomAngle = math.rad(math.random(0, 360))
                local randomPosition = vec2:polar(randomLength, randomAngle)
                local randomEnemy = tablex.pick_weighted_random(self.currentLevel.enemyClasses, self.currentLevel.enemySpawnWeights)

                self:spawnEnemy(randomPosition.x, randomPosition.y, randomSegment, randomEnemy)
            end
        end
    end
end

function crowd:draw()
    love.graphics.setLineWidth(self.areaRadiusCircleLineWidth)
    love.graphics.setColor(game.manager.currentPalette.playerColour)

    local playerPosition = game.playerManager.playerPosition
    love.graphics.circle("line", playerPosition.x, playerPosition.y, self.heatAreaRadius)

    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
end

return crowd