local enemyDefinitions = require "src.objects.enemy.enemydefinitions"

local levels =
{
    
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 1},
        },

        minEnemySpawns = 3,
        maxEnemySpawns = 6,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 1},
            {enemyClass = enemyDefinitions.charger, spawnChance = 1},
        },

        minEnemySpawns = 3,
        maxEnemySpawns = 6,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 2},
            {enemyClass = enemyDefinitions.charger, spawnChance = 2},
            {enemyClass = enemyDefinitions.drone, spawnChance = 1},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 1},
        },

        minEnemySpawns = 3,
        maxEnemySpawns = 6,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 3},
            {enemyClass = enemyDefinitions.charger, spawnChance = 3},
            {enemyClass = enemyDefinitions.drone, spawnChance = 2},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 1},
            {enemyClass = enemyDefinitions.exploder, spawnChance = 1},
        },

        minEnemySpawns = 3,
        maxEnemySpawns = 6,
    },
}

return levels