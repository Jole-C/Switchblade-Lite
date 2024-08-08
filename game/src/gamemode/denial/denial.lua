local timedGamemode = require "src.gamemode.timedgamemode"
local denialArea = require "src.objects.enemy.enemydenialarea"

local denial = class({name = "Denial", extends = timedGamemode})

function denial:new()
    self:super("src.gamemode.denial.levels", 2, 0)

    self.maxSpawnTime = 3
    self.maxDenialSpawnTime = 3
    self.areaLifetime = 3
    self.killsForLevelIncrement = 30
    self.progressIncrement = 15

    self.spawnTime = 0
    self.denialSpawnTime = self.maxDenialSpawnTime

    gameHelper:getArena():addArenaSegment(0, 0, 300, "main")
end

function denial:start()
    self:setTimerPaused(false)
end

function denial:update(dt)
    timedGamemode.update(self, dt)

    local player = game.playerManager.playerReference

    if player then
        player:setHealthCanRecharge(false)
        player:setInvulnerable()
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

    self.denialSpawnTime = self.denialSpawnTime - (1 * dt)

    if self.denialSpawnTime <= 0 then
        self.denialSpawnTime = self.maxDenialSpawnTime

        local arena = gameHelper:getArena()

        for i = 1, self.currentLevel.numberOfAreas do
            local randomSegment = arena:getRandomSegment()
            local randomLength = math.random(0, randomSegment.radius)
            local randomAngle = math.rad(math.random(0, 360))
            local randomPosition = vec2:polar(randomLength, randomAngle)
            local randomRadius = math.random(self.currentLevel.minAreaRadius, self.currentLevel.maxAreaRadius)

            gameHelper:addGameObject(denialArea(randomPosition.x, randomPosition.y, randomRadius, self.areaLifetime))
        end
    end
end

function denial:parseLevelEntry(currentLevel)
    timedGamemode.parseLevelEntry(self, currentLevel)

    self.currentLevel.numberOfAreas = currentLevel.numberOfAreas
    self.currentLevel.minAreaRadius = currentLevel.minAreaRadius
    self.currentLevel.maxAreaRadius = currentLevel.maxAreaRadius
end

return denial