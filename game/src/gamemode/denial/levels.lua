local enemyDefinitions = require "src.objects.enemy.enemydefinitions"

local levels =
{
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 1},
            {enemyClass = enemyDefinitions.charger, spawnChance = 1},
        },

        minEnemySpawns = 6,
        maxEnemySpawns = 6,
        numberOfAreas = 1,
        minAreaRadius = 50,
        maxAreaRadius = 100,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 2},
            {enemyClass = enemyDefinitions.charger, spawnChance = 2},
            {enemyClass = enemyDefinitions.drone, spawnChance = 1},
        },

        minEnemySpawns = 6,
        maxEnemySpawns = 6,
        numberOfAreas = 1,
        minAreaRadius = 50,
        maxAreaRadius = 100,
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
        numberOfAreas = 2,
        minAreaRadius = 50,
        maxAreaRadius = 100,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 4},
            {enemyClass = enemyDefinitions.charger, spawnChance = 4},
            {enemyClass = enemyDefinitions.drone, spawnChance = 2},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 1},
            {enemyClass = enemyDefinitions.orbiter, spawnChance = 1},
        },

        minEnemySpawns = 6,
        maxEnemySpawns = 6,
        numberOfAreas = 2,
        minAreaRadius = 50,
        maxAreaRadius = 75,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 4},
            {enemyClass = enemyDefinitions.heater, spawnChance = 6},
            {enemyClass = enemyDefinitions.charger, spawnChance = 4},
            {enemyClass = enemyDefinitions.drone, spawnChance = 2},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 1},
            {enemyClass = enemyDefinitions.orbiter, spawnChance = 1},
        },

        minEnemySpawns = 6,
        maxEnemySpawns = 6,
        numberOfAreas = 2,
        minAreaRadius = 50,
        maxAreaRadius = 100,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 4},
            {enemyClass = enemyDefinitions.heater, spawnChance = 4},
            {enemyClass = enemyDefinitions.charger, spawnChance = 4},
            {enemyClass = enemyDefinitions.drone, spawnChance = 4},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 2},
            {enemyClass = enemyDefinitions.orbiter, spawnChance = 2},
            {enemyClass = enemyDefinitions.exploder, spawnChance = 3},
        },

        minEnemySpawns = 7,
        maxEnemySpawns = 7,
        numberOfAreas = 3,
        minAreaRadius = 50,
        maxAreaRadius = 100,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 4},
            {enemyClass = enemyDefinitions.heater, spawnChance = 4},
            {enemyClass = enemyDefinitions.charger, spawnChance = 4},
            {enemyClass = enemyDefinitions.drone, spawnChance = 4},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 2},
            {enemyClass = enemyDefinitions.orbiter, spawnChance = 2},
            {enemyClass = enemyDefinitions.exploder, spawnChance = 3},
        },

        minEnemySpawns = 7,
        maxEnemySpawns = 7,
        numberOfAreas = 3,
        minAreaRadius = 50,
        maxAreaRadius = 100,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 4},
            {enemyClass = enemyDefinitions.heater, spawnChance = 4},
            {enemyClass = enemyDefinitions.charger, spawnChance = 4},
            {enemyClass = enemyDefinitions.drone, spawnChance = 4},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 2},
            {enemyClass = enemyDefinitions.orbiter, spawnChance = 2},
            {enemyClass = enemyDefinitions.exploder, spawnChance = 3},
            {enemyClass = enemyDefinitions.snake, spawnChance = 1},
        },

        minEnemySpawns = 7,
        maxEnemySpawns = 7,
        numberOfAreas = 3,
        minAreaRadius = 50,
        maxAreaRadius = 100,
    },
}

return levels