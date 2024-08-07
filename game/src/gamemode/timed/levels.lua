local enemyDefinitions = require "src.objects.enemy.enemydefinitions"

local levels = 
{
    {enemyClass = enemyDefinitions.wanderer, spawnChance = 3},
    {enemyClass = enemyDefinitions.charger, spawnChance = 3},
    {enemyClass = enemyDefinitions.drone, spawnChance = 3},
    {enemyClass = enemyDefinitions.shielder, spawnChance = 2},
    {enemyClass = enemyDefinitions.orbiter, spawnChance = 2},
    {enemyClass = enemyDefinitions.heater, spawnChance = 3},
    {enemyClass = enemyDefinitions.exploder, spawnChance = 2},
    {enemyClass = enemyDefinitions.crisscross, spawnChance = 2},
    {enemyClass = enemyDefinitions.wanderer, spawnChance = 2},
    {enemyClass = enemyDefinitions.snake, spawnChance = 1},
}

return levels