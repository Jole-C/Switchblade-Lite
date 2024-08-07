local timedGamemode = require "src.gamemode.gamemode"
local worldAlertObject = require "src.objects.stagedirector.worldalertobject"

local endless = class({name = "Endless", extends = timedGamemode})

function endless:new()
    self:super(3, 0)            
    
    self.levels = require "src.gamemode.endless.levels"
    self.maxSpawnTime = 3
    self.killsForLevelIncrement = 30
    self.oneUpScore = 5000

    self.currentOneUps = 0
    self.currentLevelIndex = 1
    self.currentLevel = nil
    self:parseCurrentLevel()

    self.spawnTime = 0
    gameHelper:getArena():addArenaSegment(0, 0, 300, "main")

    self.oneUpSound = game.resourceManager:getAsset("Player Assets"):get("sounds"):get("oneUp")
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

    local playerPosition = game.playerManager.playerPosition

    if self.totalKills > self.killsForLevelIncrement * self.currentLevelIndex and self.currentLevelIndex ~= #self.levels then
        self.currentLevelIndex = self.currentLevelIndex + 1
        self:parseCurrentLevel()
        
        gameHelper:addGameObject(worldAlertObject(playerPosition.x, playerPosition.y, "Level up!", "fontScore"))
    end

    local scoreManager = gameHelper:getScoreManager()
    local player = game.playerManager.playerReference

    if scoreManager.score > self.oneUpScore then
        if player then
            if player.health == player.maxHealth then
                player.maxHealth = player.maxHealth + 1
            end

            player.health = player.health + 1
        end

        self.oneUpScore = self.oneUpScore + self.oneUpScore
        self.oneUpSound:play()        
        
        gameHelper:addGameObject(worldAlertObject(playerPosition.x, playerPosition.y, "One up!", "fontScore"))
    end
end

function endless:parseCurrentLevel()
    self.currentLevelIndex = math.clamp(self.currentLevelIndex, 1, #self.levels)
    local currentLevel = self.levels[self.currentLevelIndex]

    self.currentLevel = 
    {
        enemyClasses = {},
        enemySpawnWeights = {},
        minNumberSpawns = currentLevel.minEnemySpawns,
        maxNumberSpawns = currentLevel.maxEnemySpawns,
    }

    for _, enemy in ipairs(currentLevel.spawns) do
        table.insert(self.currentLevel.enemyClasses, enemy.enemyClass)
        table.insert(self.currentLevel.enemySpawnWeights, enemy.spawnChance)
    end
end

function endless:registerEnemyKill()
    self.totalKills = self.totalKills + 1
end

return endless