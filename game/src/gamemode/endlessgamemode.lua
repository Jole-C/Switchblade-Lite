local timedGamemode = require "src.gamemode.timedgamemode"
local alertObject = require "src.objects.stagedirector.alertobject"

local endlessGamemode = class({name = "Endless Gamemode", extends = timedGamemode})

function endlessGamemode:new(levelPath)
    self:super(3, 0)
    
    self.levels = require(levelPath or "src.gamemode.endless.levels")
    
    self.maxSpawnTime = 3

    self.currentLevelIndex = 1
    self.currentLevel = nil
    self:parseCurrentLevel()
end

function endlessGamemode:parseCurrentLevel()
    self.currentLevelIndex = math.clamp(self.currentLevelIndex, 1, #self.levels)
    local currentLevel = self.levels[self.currentLevelIndex]

    self.currentLevel = {}
    self:parseLevelEntry(currentLevel)

    for _, enemy in ipairs(currentLevel.spawns) do
        table.insert(self.currentLevel.enemyClasses, enemy.enemyClass)
        table.insert(self.currentLevel.enemySpawnWeights, enemy.spawnChance)
    end
end

function endlessGamemode:parseLevelEntry(currentLevel)
    self.currentLevel.enemyClasses = {}
    self.currentLevel.enemySpawnWeights = {}
    self.currentLevel.minNumberSpawns = currentLevel.minEnemySpawns
    self.currentLevel.maxNumberSpawns = currentLevel.maxEnemySpawns
end

function endlessGamemode:incrementLevel()
    self.currentLevelIndex = self.currentLevelIndex + 1
    self:parseCurrentLevel()

    gameHelper:addGameObject(alertObject("Level up!", 0.7, 0.2))
end

return endlessGamemode