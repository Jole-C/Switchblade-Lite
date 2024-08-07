local timedGamemode = require "src.gamemode.timedgamemode"
local timed = class({name = "Timed", extends = timedGamemode})

function timed:new()
    self:super(3, 0)

    self.maxSpawnTime = 2
    self.enemySpawns = 5

    self.level = require "src.gamemode.timed.levels"
    self.levelSpawns = {}
    self.levelWeights = {}

    for _, enemy in ipairs(self.level) do
        table.insert(self.levelSpawns, enemy.enemyClass)
        table.insert(self.levelWeights, enemy.spawnChance)
    end

    gameHelper:getArena():addArenaSegment(0, 0, 300, "main")

    self.spawnTime = self.maxSpawnTime
end

function timed:update(dt)
    local player = game.playerManager.playerReference

    if player then
        player:setHealthCanRecharge(false)
    end

    self.spawnTime = self.spawnTime - (1 * dt)

    if self.spawnTime <= 0 then
        self.spawnTime = self.maxSpawnTime

        local arena = gameHelper:getArena()

        if arena then
            for i = 1, self.enemySpawns do
                local randomSegment = arena:getRandomSegment()
                local randomLength = math.random(0, randomSegment.radius)
                local randomAngle = math.rad(math.random(0, 360))
                local randomPosition = vec2:polar(randomLength, randomAngle)
                local randomEnemy = tablex.pick_weighted_random(self.levelSpawns, self.levelWeights)

                self:spawnEnemy(randomPosition.x, randomPosition.y, randomSegment, randomEnemy)
            end
        end
    end
end

function timed:start()
    self:setTimerPaused(false)
end

return timed