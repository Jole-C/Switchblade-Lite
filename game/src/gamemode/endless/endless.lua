local gamemode = require "src.gamemode.gamemode"
local endless = class({name = "Endless", extends = gamemode})

function endless:new()
    self:super("src.gamemode.endless.levels")
    
    self.maxSpawnTime = 3
    self.killsForLevelIncrement = 30
    self.oneUpScore = 1000
    self.spawnTime = 0
    
    gameHelper:getArena():addArenaSegment(0, 0, 300, "main")
end

function endless:update(dt)
    local player = game.playerManager.playerReference

    if player then
        player:setHealthCanRecharge(false)
    end

    self.spawnTime = self.spawnTime - (1 * dt)

    if self.spawnTime <= 0 then
        self.spawnTime = self.maxSpawnTime

        local numberOfEnemiesToSpawn = math.random(self.currentLevel.minNumberSpawns, self.currentLevel.maxNumberSpawns)
        local arena = gameHelper:getArena()

        if arena then
            for i = 1, numberOfEnemiesToSpawn do
                local randomSegment = arena:getRandomSegment()
                local randomLength = math.random(0, randomSegment.radius)
                local randomAngle = math.rad(math.random(0, 360))
                local randomPosition = vec2:polar(randomLength, randomAngle)
                local randomEnemy = tablex.pick_weighted_random(self.currentLevel.enemyClasses, self.currentLevel.enemySpawnWeights)

                self:spawnEnemy(randomPosition.x, randomPosition.y, randomSegment, randomEnemy)
            end
        end
    end

    if self.totalKills > self.killsForLevelIncrement * self.currentLevelIndex and self.currentLevelIndex ~= #self.levels then
       self:incrementLevel()
    end

    self:handleOneups()
end

return endless