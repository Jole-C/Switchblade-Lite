local timedGamemode = require "src.gamemode.timedgamemode"
local timed = class({name = "Timed", extends = timedGamemode})

function timed:new()
    self:super("src.gamemode.timed.levels", 3, 0)

    self.maxSpawnTime = 3
    self.enemySpawns = 5
    self.numberOfEnemiesToSpawn = 4

    gameHelper:getArena():addArenaSegment(0, 0, 300, "main")

    self.spawnTime = self.maxSpawnTime
end

function timed:update(dt)
    timedGamemode.update(self, dt)

    local player = game.playerManager.playerReference

    if player then
        player:setHealthCanRecharge(false)
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

function timed:start()
    self:setTimerPaused(false)
end

return timed