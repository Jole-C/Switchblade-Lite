local grunt = require "game.objects.enemy.arena1.grunt"
local soldier = require "game.objects.enemy.arena1.soldier"
local utility = require "game.objects.enemy.arena1.grunt"
local specialist = require "game.objects.enemy.arena1.grunt"

local levelDefinition = 
{
    enemyDefinitions =
    {
        ["grunt"] = grunt,
        ["soldier"] = soldier,
        ["utility"] = utility,
        ["specialist"] = specialist,
    }, 
    level =
    {
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 3,
                },
            }
        },
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 5,
                },
            }
        },
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 7,
                }
            }
        },
        
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 3,
                },
                {
                    enemyID = "soldier",
                    spawnCount = 1,
                },
            }
        },
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 5,
                },
                {
                    enemyID = "soldier",
                    spawnCount = 2,
                },
            }
        },
        {
            waveType = "random",
            enemyDefs =
            {
                {
                    enemyID = "grunt",
                    spawnCount = 5,
                },
                {
                    enemyID = "soldier",
                    spawnCount = 3,
                },
            }
        },
    }
}

return levelDefinition