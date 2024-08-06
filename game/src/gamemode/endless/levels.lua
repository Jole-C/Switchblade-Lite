local enemyDefinitions = require "src.objects.enemy.enemydefinitions"

local levels =
{
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 3},
            {enemyClass = enemyDefinitions.drone, spawnChance = 1},
        },

        minEnemySpawns = 3,
        maxEnemySpawns = 5,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.wanderer, spawnChance = 2},
            {enemyClass = enemyDefinitions.charger, spawnChance = 2},
            {enemyClass = enemyDefinitions.drone, spawnChance = 1},
        },

        minEnemySpawns = 3,
        maxEnemySpawns = 5,
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
            {enemyClass = enemyDefinitions.charger, spawnChance = 2},
            {enemyClass = enemyDefinitions.drone, spawnChance = 2},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 1},
            {enemyClass = enemyDefinitions.orbiter, spawnChance = 1},
        },

        minEnemySpawns = 3,
        maxEnemySpawns = 6,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.heater, spawnChance = 2},
            {enemyClass = enemyDefinitions.charger, spawnChance = 2},
            {enemyClass = enemyDefinitions.drone, spawnChance = 2},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 1},
            {enemyClass = enemyDefinitions.orbiter, spawnChance = 1},
        },

        minEnemySpawns = 3,
        maxEnemySpawns = 6,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.heater, spawnChance = 4},
            {enemyClass = enemyDefinitions.charger, spawnChance = 4},
            {enemyClass = enemyDefinitions.drone, spawnChance = 4},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 2},
            {enemyClass = enemyDefinitions.orbiter, spawnChance = 2},
            {enemyClass = enemyDefinitions.exploder, spawnChance = 1},
        },

        minEnemySpawns = 4,
        maxEnemySpawns = 7,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.heater, spawnChance = 4},
            {enemyClass = enemyDefinitions.crisscross, spawnChance = 4},
            {enemyClass = enemyDefinitions.drone, spawnChance = 3},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 2},
            {enemyClass = enemyDefinitions.orbiter, spawnChance = 2},
            {enemyClass = enemyDefinitions.exploder, spawnChance = 1},
        },

        minEnemySpawns = 4,
        maxEnemySpawns = 7,
    },
    {
        spawns = 
        {
            {enemyClass = enemyDefinitions.heater, spawnChance = 4},
            {enemyClass = enemyDefinitions.crisscross, spawnChance = 4},
            {enemyClass = enemyDefinitions.drone, spawnChance = 3},
            {enemyClass = enemyDefinitions.shielder, spawnChance = 2},
            {enemyClass = enemyDefinitions.orbiter, spawnChance = 2},
            {enemyClass = enemyDefinitions.exploder, spawnChance = 2},
            {enemyClass = enemyDefinitions.snake, spawnChance = 1},
        },

        minEnemySpawns = 3,
        maxEnemySpawns = 6,
    },
}

return levels